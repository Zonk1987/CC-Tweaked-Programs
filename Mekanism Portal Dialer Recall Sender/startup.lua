--[[
================================================================================
Mekanism Portal Recall Sender v1.0.083-main
================================================================================
]]
--

-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Configure library paths for lib/core
local corePaths = {
	"/lib/core/base/?.lua",
	"/lib/core/peripherals/?.lua",
	"/lib/core/inventory/?.lua",
	"/lib/core/recipes/?.lua",
	"/lib/core/ui/?.lua",
	"/lib/core/network/?.lua",
	"/lib/core/redstone/?.lua",
}
package.path = package.path .. ";" .. table.concat(corePaths, ";")

local ConfigStore = require("ConfigStore")
local HAL = require("HAL")
local RednetProtocol = require("RednetProtocol")
local RedstoneController = require("RedstoneController")
local BootAssistant = require("boot_assistant")

-- Localize globals
local fs = fs
local term = term
local colors = colors
local keys = keys
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local os_startTimer = os.startTimer
local tonumber = tonumber
local write = write
local read = read

---@class RecallConfig
---@field target string The name of this portal destination
---@field channel number The modem channel used for communication

---@class ConfigStore
---@field data table
---@field save fun(self: ConfigStore)
---@field load fun(self: ConfigStore)

---@class RecallSender
---@field configStore ConfigStore
---@field modem table|nil
local RecallSender = {}
RecallSender.__index = RecallSender

--- Creates a new RecallSender
---@return RecallSender
function RecallSender.new()
	local self = setmetatable({
		configStore = ConfigStore.new("config.json", { target = "Unknown", channel = 99 }),
		modem = nil,
	}, RecallSender)

	self:initHardware()
	return self
end

--- Initial hardware check and setup
function RecallSender:initHardware()
	local boot = BootAssistant.new({
		title = "Recall Sender Loader",
		theme = "dark",
		enable_logging = true,
		log_file = "logs/recall_sender_boot.log",
	})

	boot:addStep("setup", "Konfiguration", function()
		if fs.exists("config.json") then
			return true
		end

		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.black)
		term.clear()

		local w, _ = term.getSize()

		-- Header
		term.setBackgroundColor(colors.blue)
		term.setTextColor(colors.black)
		term.setCursorPos(1, 1)
		term.write(string.rep(" ", w))
		local title = "RECALL SENDER SETUP"
		local pad = math.max(0, math.floor((w - #title) / 2))
		term.setCursorPos(pad + 1, 1)
		term.write(title)

		-- Content
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.black)

		term.setCursorPos(2, 3)
		print("Willkommen beim Mekanism Recall Sender!")
		term.setCursorPos(2, 4)
		print("Bitte richte die erste Konfiguration ein.")

		term.setCursorPos(2, 6)
		term.setTextColor(colors.yellow)
		term.write("Ziel-Ort (Name): ")
		term.setTextColor(colors.black)
		local target = read() or "Unknown"
		if target == "" then
			target = "Unknown"
		end

		term.setCursorPos(2, 8)
		term.setTextColor(colors.yellow)
		term.write("Modem-Kanal (Standard 99): ")
		term.setTextColor(colors.black)
		local chanInput = read()
		local channel = tonumber(chanInput) or 99

		self.configStore.data.target = target
		self.configStore.data.channel = channel
		self.configStore:save()

		term.setCursorPos(2, 10)
		term.setTextColor(colors.green)
		print("Setup erfolgreich gespeichert!")
		term.setTextColor(colors.black)
		os_sleep(1.5)
		return true
	end, {
		"Dieser Schritt wird nur beim ersten Start ausgefuehrt,",
		"um das Standard-Ziel und den Funkkanal einzustellen.",
	})

	boot:addStep("modem", "Modem Scan", function()
		local modem = HAL.getModem()
		self.modem = modem
		if modem then
			self.modemSide = HAL.getName(modem)
		end
		if not self.modemSide then
			return "WARN", "Kein Modem gefunden."
		end
		RednetProtocol.openAuto()
		return true
	end, {
		"Ein Modem (vorzugsweise Wireless Modem) wird benoetigt,",
		"um das Recall-Signal drahtlos zu senden.",
	})

	boot:addStep("teleporter", "Teleporter Scan", function()
		self.tp = HAL.getTeleporter()
		if not self.tp then
			return "WARN", "Kein lokaler Teleporter gefunden."
		end
		return true
	end, {
		"Ein lokaler Teleporter ist optional. Der Recall Sender kann auch",
		"als rein kabelloser Signalgeber fuer andere Portale dienen.",
	})

	boot:run()
end

--- Refreshes the teleporter status
function RecallSender:refreshStatus()
	if self.tp then
		local ok, status = pcall(self.tp.getStatus)
		if ok then
			-- Capitalize first letter
			self.tpStatus = status:sub(1, 1):upper() .. status:sub(2)
		else
			self.tpStatus = "Error reading status"
		end
	else
		self.tpStatus = "Remote Hub only"
	end
end

--- Draws the terminal status screen
function RecallSender:drawTerminalHeader()
	self:refreshStatus()
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.cyan)
	print("Mekanism Portal Recall Sender v1.0.083-main")
	term.setTextColor(colors.gray)
	local w, _ = term.getSize()
	print(string.rep("-", w))
	term.setTextColor(colors.white)
	print("Target:  " .. self.configStore.data.target)
	print("Channel: " .. self.configStore.data.channel)
	print("Modem:   " .. (self.modemSide or "None"))

	-- Display Teleporter Status
	term.setTextColor(self.tpStatus == "Ready" and colors.lime or colors.yellow)
	print("Portal:  " .. self.tpStatus)

	term.setTextColor(colors.white)
	print("\nStatus:  Waiting for Redstone signal...")
	print("\n[Press 'C' for Configuration]")
end

--- Interactive configuration menu
function RecallSender:configMenu()
	while true do
		local w, _ = term.getSize()
		term.clear()
		term.setTextColor(colors.cyan)
		local title = "=== Configuration Menu ==="
		local pad = math.max(0, math.floor((w - #title) / 2))
		term.setCursorPos(pad + 1, 1)
		term.write(title)

		term.setTextColor(colors.white)
		term.setCursorPos(1, 3)
		print("1. Target Name       (Current: " .. self.configStore.data.target .. ")")
		print("2. Recall Channel    (Current: " .. self.configStore.data.channel .. ")")
		print("3. Save & Exit")
		print("4. Exit without saving")

		local _, key = os_pullEvent("key")
		if key == keys.one then
			term.setCursorPos(1, 8)
			write("New Target Name: ")
			local input = read()
			if input ~= "" then
				self.configStore.data.target = input
			end
		elseif key == keys.two then
			term.setCursorPos(1, 8)
			write("New Channel: ")
			local input = read()
			self.configStore.data.channel = tonumber(input) or self.configStore.data.channel
		elseif key == keys.three then
			self.configStore:save()
			self:drawTerminalHeader()
			return
		elseif key == keys.four then
			self.configStore:load()
			self:drawTerminalHeader()
			return
		end
	end
end

--- Broadcasts the recall signal
function RecallSender:broadcastRecall()
	term.setTextColor(colors.yellow)
	print("\n[!] Signal detected! Sending recall...")

	local payload = { command = "RECALL", target = self.configStore.data.target }
	RednetProtocol.transmit(self.configStore.data.channel, payload)
	RednetProtocol.broadcast("mekanism_portal", "RECALL", { target = self.configStore.data.target })

	term.setTextColor(colors.lime)
	print("[!] Success: Target '" .. self.configStore.data.target .. "' broadcasted.")
	term.setTextColor(colors.white)
end

--- Main runtime loop
function RecallSender:run()
	self:drawTerminalHeader()
	local messageTimer = nil
	local refreshTimer = os_startTimer(2) -- Auto-refresh every 2s

	while true do
		local event, p1 = os_pullEvent()

		if event == "redstone" then
			if RedstoneController.anyInput() then
				self:broadcastRecall()
				messageTimer = os_startTimer(5) -- Return to header after 5s
			end
		elseif event == "timer" then
			if p1 == messageTimer then
				self:drawTerminalHeader()
			elseif p1 == refreshTimer then
				self:drawTerminalHeader()
				refreshTimer = os_startTimer(2) -- Restart refresh
			end
		elseif event == "key" and p1 == keys.c then
			self:configMenu()
		end
	end
end

-- Execution
local app = RecallSender.new()
app:run()
