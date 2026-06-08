--[[
================================================================================
HubApp Module v1.0.0
================================================================================
Standardized stateful Application controller for Mekanism Portal Dialer Hub.
Integrates the cooperative Scheduler, Virtual Canvas for double-buffering,
and the EventBus for self-healing hot-plug support.
================================================================================
]]

local HAL = require("HAL")
local EventBus = require("EventBus")
local Scheduler = require("Scheduler")
local VirtualCanvas = require("VirtualCanvas")
local HubSystem = require("HubSystem")
local ButtonGrid = require("ButtonGrid")
local RednetProtocol = require("RednetProtocol")

---@diagnostic disable: undefined-global
local colors = colors
local term = term
local keys = keys
---@diagnostic enable: undefined-global

-- ============================================================================
-- Private Helper: CanvasWrapper
-- ============================================================================
-- Wraps a VirtualCanvas to mimic the CC:Tweaked Terminal/Monitor API.
-- This allows existing components (ButtonGrid, Dashboard) to draw seamlessly
-- onto the double-buffered VirtualCanvas without code modifications.
local CanvasWrapper = {}

function CanvasWrapper.new(virtualCanvas, physicalDevice)
	local self = {
		canvas = virtualCanvas,
		physical = physicalDevice,
		native = physicalDevice,
		curX = 1,
		curY = 1,
		fg = colors.white,
		bg = colors.black,
	}

	self.getSize = function()
		return self.canvas.width, self.canvas.height
	end

	self.clear = function()
		self.canvas:clear(self.bg)
	end

	self.setBackgroundColor = function(color)
		self.bg = color
	end

	self.setTextColor = function(color)
		self.fg = color
	end

	self.setCursorPos = function(x, y)
		self.curX = x
		self.curY = y
	end

	self.write = function(text)
		self.canvas:write(self.curX, self.curY, text, self.fg, self.bg)
		self.curX = self.curX + #text
	end

	self.blit = function(text, fgColors, bgColors)
		for i = 1, #text do
			local char = text:sub(i, i)
			local fgCol = 2 ^ tonumber(fgColors:sub(i, i), 16)
			local bgCol = 2 ^ tonumber(bgColors:sub(i, i), 16)
			self.canvas:write(self.curX + i - 1, self.curY, char, fgCol, bgCol)
		end
		self.curX = self.curX + #text
	end

	self.clearLine = function()
		self.canvas:drawBox(1, self.curY, self.canvas.width, 1, self.bg)
	end

	self.setTextScale = function(scale)
		if self.physical and type(self.physical.setTextScale) == "function" then
			self.physical.setTextScale(scale)
			local w, h = self.physical.getSize()
			self.canvas:setSize(w, h)
		end
	end

	self.flush = function()
		self.canvas:flush(self.physical)
	end

	self.setVisible = function(visible)
		if visible then
			self.flush()
		end
	end

	if physicalDevice then
		setmetatable(self, { __index = physicalDevice })
	end

	return self
end

-- ============================================================================
-- HubApp Class Definition
-- ============================================================================
local HubApp = {}
HubApp.__index = HubApp

function HubApp.new(options)
	local self = setmetatable({
		config = options.config,
		logger = options.logger,
		scheduler = options.scheduler,
		running = false,
		monitorLost = false,
		teleporterLost = false,
		monitorName = nil,
		canvasWrapper = nil,
		system = nil,
	}, HubApp)

	-- Register Watchdog system-healing listeners via EventBus
	self.unbindLost = EventBus:on("PERIPHERAL_LOST", function(pKey)
		if pKey == "hub_monitor" then
			self.logger:warn("Watchdog: Monitor-Verbindung verloren!")
			self.monitorLost = true
			term.clear()
			term.setCursorPos(1, 1)
			if term.isColor() then
				term.setTextColor(colors.red)
			end
			print("==================================================")
			print("        HARDWARE-VERBINDUNG VERLOREN              ")
			print("==================================================")
			print("Der Monitor 'hub_monitor' wurde getrennt.")
			print("Bitte Kabel und Modems ueberpruefen...")
		elseif pKey == "hub_teleporter" then
			self.logger:warn("Watchdog: Teleporter-Verbindung verloren!")
			self.teleporterLost = true
			if self.system then
				self.system.lastError = "Teleporter offline!"
				if not self.monitorLost then
					self.system:drawStatus()
				end
			end
		end
	end)

	self.unbindRestored = EventBus:on("PERIPHERAL_RESTORED", function(pKey)
		if pKey == "hub_monitor" then
			self.logger:info("Watchdog: Monitor wiederhergestellt!")
			self.monitorLost = false
			self:initMonitor()
			self.system:drawTerminalHeader()
			self.system:draw()
		elseif pKey == "hub_teleporter" then
			self.logger:info("Watchdog: Teleporter wiederhergestellt!")
			self.teleporterLost = false
			if self.system then
				local tp = HAL.wrap(self.config:get("hub_teleporter"))
				if tp then
					self.system.tp = tp
					self.system.lastError = nil
				else
					self.system.lastError = "Teleporter offline!"
				end
				if not self.monitorLost then
					self.system:draw()
				end
			end
		end
	end)

	return self
end

-- Initialize or re-initialize the monitor and double-buffered canvas
function HubApp:initMonitor()
	local monitorName = self.config:get("hub_monitor", "top")
	self.monitorName = monitorName

	local monitor = HAL.wrap(monitorName)
	if not monitor then
		self.logger:error("Monitor konnte nicht initialisiert werden: " .. tostring(monitorName))
		return
	end

	-- Manually clear the physical monitor to black to match the VirtualCanvas's default state
	monitor.setBackgroundColor(colors.black)
	monitor.clear()

	local canvas = VirtualCanvas.new(monitor)
	local canvasWrapper = CanvasWrapper.new(canvas, monitor)
	canvasWrapper.setTextScale(0.5)

	self.canvasWrapper = canvasWrapper

	if self.system then
		self.system.bm.mon = canvasWrapper
		self.system.nativeMon = canvasWrapper
		self.system.monName = monitorName
	end
end

-- Main entry point of the app execution fiber
function HubApp:run()
	self.running = true

	-- 1. Set up monitor and virtual canvas wrapper
	self:initMonitor()

	-- 2. Open Modem/Rednet protocols
	local openSide = RednetProtocol.openAuto()
	self.logger:info("Rednet/Modem initialisiert auf Seite: " .. tostring(openSide or "Keine"))

	-- 3. Set up button manager with virtual canvas wrapper
	local monitorName = self.config:get("hub_monitor", "top")
	local bm = ButtonGrid.new(monitorName)
	bm.mon = self.canvasWrapper

	local tpName = self.config:get("hub_teleporter", "bottom")

	-- 4. Instantiation of HubSystem
	self.system = HubSystem.new({
		bm = bm,
		tpSide = tpName,
		config = {
			monitorSide = monitorName,
			tpSide = tpName,
			gridColumns = self.config:get("gridColumns", 4),
			gridRows = self.config:get("gridRows", 4),
			recallChannel = self.config:get("recallChannel", 99),
			maxButtons = 24,
		},
		logger = self.logger,
	})

	-- Assign the canvas wrapper as nativeMon to HubSystem for double-buffering flushes
	self.system.nativeMon = self.canvasWrapper

	-- Set the modem side so the terminal UI knows we finished searching
	self.system.modemSide = openSide or "None"

	-- 5. Render initial UI
	self.system:drawTerminalHeader()
	self.system:draw()

	-- 6. Spawn asynchronous event fibers

	-- Touch Event Fiber
	self.scheduler:spawn(function()
		while self.running do
			local _, touchedSide, x, y = Scheduler.waitEvent("monitor_touch")
			if self.running and touchedSide == self.monitorName and not self.monitorLost then
				self.logger:debug("Touch received: x=%d, y=%d", x, y)
				if self.system.isMovingOverlay then
					self.system.isMovingOverlay = false
					if self.system.activeOverlay then
						self.system.activeOverlay.x = x - math.floor(39 / 2)
						self.system.activeOverlay.y = y - 1
					end
					self.system:draw()
				else
					self.system.isBusy = true
					self.system.bm:checkClick(x, y)
					self.system:drawStatus()
					Scheduler.sleep(0.5)
					self.system.bm.flashKey = nil
					self.system:draw()
					self.system.isBusy = false
				end
			end
		end
	end, "HubApp-Touch")

	-- Modem Message Fiber
	self.scheduler:spawn(function()
		local channel = self.config:get("recallChannel", 99)
		while self.running do
			local _, _, msgChannel, _, message, _ = Scheduler.waitEvent("modem_message")
			if self.running and msgChannel == channel then
				if type(message) == "table" and message.command == "RECALL" then
					self.logger:info("Modem-Recall empfangen fuer Portal: %s", tostring(message.target))
					self.system:dial(message.target)
				end
			end
		end
	end, "HubApp-Modem")

	-- Rednet Message Fiber
	self.scheduler:spawn(function()
		while self.running do
			local _, _, message, _ = Scheduler.waitEvent("rednet_message")
			if self.running and type(message) == "table" and message.command == "RECALL" then
				self.logger:info("Rednet-Recall empfangen fuer Portal: %s", tostring(message.target))
				self.system:dial(message.target)
			end
		end
	end, "HubApp-Rednet")

	-- Key Interaction Fiber (terminal config hotkey)
	self.scheduler:spawn(function()
		while self.running do
			local _, key = Scheduler.waitEvent("key")
			if self.running and key == keys.c then
				self.system:configMenu()
			end
		end
	end, "HubApp-TerminalKey")

	-- Keep this main app fiber alive
	while self.running do
		Scheduler.sleep(1)
	end
end

-- Geordnetes Beenden
function HubApp:shutdown()
	self.running = false
	if self.unbindLost then
		self.unbindLost()
	end
	if self.unbindRestored then
		self.unbindRestored()
	end
	self.logger:info("HubApp heruntergefahren.")
end

return HubApp
