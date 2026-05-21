--[[
================================================================================
PowahApp Module v1.0.0
================================================================================
Standardized stateful Application controller for Powah Energizing Orb Automation.
Integrates the cooperative Scheduler, ME Bridge, AE Scanner, and Logging.
================================================================================
]]

local HAL = require("HAL")
local Scheduler = require("Scheduler")
local PowahSystem = require("PowahSystem")
local ImportMenu = require("ImportMenu")

local PowahApp = {}
PowahApp.__index = PowahApp

function PowahApp.new(options)
	local self = setmetatable({
		config = options.config,
		logger = options.logger,
		scheduler = options.scheduler,
		running = false,
		system = nil,
	}, PowahApp)
	return self
end

function PowahApp:run()
	self.running = true

	local chestName = self.config:get("buffer", "left")
	local meBridgeName = self.config:get("me_bridge", "back")
	local aeScannerName = self.config:get("ae_scanner", "top")

	-- Register peripherals in HAL
	HAL.register("buffer", chestName)
	if meBridgeName then
		HAL.register("me_bridge", meBridgeName)
	end
	if aeScannerName then
		HAL.register("ae_scanner", aeScannerName)
	end

	-- Initialize PowahSystem
	self.system = PowahSystem.new({
		chestName = "buffer",
		recipeFile = "powah_recipes.json",
		meBridgeName = meBridgeName and "me_bridge" or nil,
		aeScannerName = aeScannerName and "ae_scanner" or nil,
		logger = self.logger,
	})

	-- Load recipes initially
	self.system.recipeManager:load()

	-- Main process loop fiber
	self.scheduler:spawn(function()
		while self.running do
			self.system:process()
			Scheduler.sleep(0.1)
		end
	end, "PowahApp-Main")

	-- Keyboard interaction fiber
	self.scheduler:spawn(function()
		while self.running do
			local _, key = Scheduler.waitEvent("key")
			if self.running then
				if key == keys.r then
					self.system.dashboard:setStatus("Reloading recipes...")
					self.logger:info("Reloading recipes requested by keyboard trigger.")
					self.system.recipeManager:load()
					Scheduler.sleep(0.5)
					self.system.dashboard:setStatus("Waiting for items...")
				elseif key == keys.i then
					local menu = ImportMenu.new({
						meBridge = self.system.meBridge,
						aeScanner = self.system.aeScanner,
						recipeManager = self.system.recipeManager,
						dashboard = self.system.dashboard,
					})
					local ok, err = menu:open()
					if not ok then
						if err == "me_bridge_missing" then
							self.system.dashboard:setError("No ME Bridge found!")
						elseif err == "no_patterns_found" then
							self.system.dashboard:setError("No patterns found!")
						end
						Scheduler.sleep(1.5)
						self.system.dashboard:setError("")
					end
				end
			end
		end
	end, "PowahApp-Key")

	-- Keep main fiber alive
	while self.running do
		Scheduler.sleep(1)
	end
end

function PowahApp:shutdown()
	self.running = false
	self.logger:info("PowahApp heruntergefahren.")
end

return PowahApp
