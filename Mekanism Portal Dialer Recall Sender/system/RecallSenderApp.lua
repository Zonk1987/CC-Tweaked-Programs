--[[
================================================================================
RecallSenderApp Module v1.0.0
================================================================================
Standardized stateful Application controller for Mekanism Portal Recall Sender.
Integrates cooperative Scheduler, Redstone polling, Rednet transmission,
and standard ConfigGUI.
================================================================================
]]

local HAL = require("HAL")
local Scheduler = require("Scheduler")
local RednetProtocol = require("RednetProtocol")
local RedstoneController = require("RedstoneController")
local ConfigGUI = require("ConfigGUI")

local schema = {
	{ key = "target", label = "Ziel-Ort (Name)", type = "string", default = "Unknown" },
	{ key = "channel", label = "Modem-Kanal", type = "number", default = 99 },
}

local RecallSenderApp = {}
RecallSenderApp.__index = RecallSenderApp

function RecallSenderApp.new(options)
	local self = setmetatable({
		config = options.config,
		logger = options.logger,
		scheduler = options.scheduler,
		running = false,
		target = "Unknown",
		channel = 99,
		modem = nil,
		modemSide = nil,
		tp = nil,
		tpStatus = "Unknown",
	}, RecallSenderApp)
	return self
end

function RecallSenderApp:initHardware()
	local modem = HAL.getModem()
	self.modem = modem
	if modem then
		self.modemSide = HAL.getName(modem)
	end

	self.tp = HAL.getTeleporter()

	-- Try opening rednet/modem protocols
	RednetProtocol.openAuto()

	-- Load current config values
	self.target = self.config:get("target", "Unknown")
	self.channel = self.config:get("channel", 99)
end

function RecallSenderApp:refreshStatus()
	if self.tp then
		local ok, status = pcall(self.tp.getStatus)
		if ok then
			self.tpStatus = status:sub(1, 1):upper() .. status:sub(2)
		else
			self.tpStatus = "Error reading status"
		end
	else
		self.tpStatus = "Remote Hub only"
	end
end

function RecallSenderApp:drawTerminalHeader()
	self:refreshStatus()
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.cyan)
	print("Mekanism Portal Recall Sender v1.0.163-main")
	term.setTextColor(colors.gray)
	local w, _ = term.getSize()
	print(string.rep("-", w))
	term.setTextColor(colors.white)
	print("Target:  " .. self.target)
	print("Channel: " .. self.channel)
	print("Modem:   " .. (self.modemSide or "None"))

	-- Display Teleporter Status
	term.setTextColor(self.tpStatus == "Ready" and colors.lime or colors.yellow)
	print("Portal:  " .. self.tpStatus)

	term.setTextColor(colors.white)
	print("\nStatus:  Waiting for Redstone signal...")
	print("\n[Press 'C' for Configuration]")
end

function RecallSenderApp:broadcastRecall()
	term.setTextColor(colors.yellow)
	print("\n[!] Signal detected! Sending recall...")
	self.logger:info(
		"Redstone signal detected. Broadcasting RECALL command for target portal '%s' on channel %d",
		self.target,
		self.channel
	)

	local payload = { command = "RECALL", target = self.target }
	RednetProtocol.transmit(self.channel, payload)
	RednetProtocol.broadcast("mekanism_portal", "RECALL", { target = self.target })

	term.setTextColor(colors.lime)
	print("[!] Success: Target '" .. self.target .. "' broadcasted.")
	term.setTextColor(colors.white)
end

function RecallSenderApp:run()
	self.running = true

	self:initHardware()
	self:drawTerminalHeader()

	-- Redstone event fiber
	self.scheduler:spawn(function()
		while self.running do
			Scheduler.waitEvent("redstone")
			if self.running and RedstoneController.anyInput() then
				self:broadcastRecall()
				Scheduler.sleep(5)
				self:drawTerminalHeader()
			end
		end
	end, "RecallSenderApp-Redstone")

	-- Periodical UI refresh fiber
	self.scheduler:spawn(function()
		while self.running do
			self:drawTerminalHeader()
			Scheduler.sleep(2)
		end
	end, "RecallSenderApp-Timer")

	-- Keyboard event fiber for config menu
	self.scheduler:spawn(function()
		while self.running do
			local _, key = Scheduler.waitEvent("key")
			if self.running and key == keys.c then
				local gui = ConfigGUI.new(self.config, schema)
				gui:run()
				self.target = self.config:get("target", "Unknown")
				self.channel = self.config:get("channel", 99)
				self:drawTerminalHeader()
			end
		end
	end, "RecallSenderApp-Key")

	-- Keep main fiber alive
	while self.running do
		Scheduler.sleep(1)
	end
end

function RecallSenderApp:shutdown()
	self.running = false
	self.logger:info("RecallSenderApp heruntergefahren.")
end

return RecallSenderApp
