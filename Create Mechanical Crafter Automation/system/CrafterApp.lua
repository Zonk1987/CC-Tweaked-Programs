--[[
================================================================================
CrafterApp Module v1.0.0
================================================================================
Standardized stateful Application controller for Create Mechanical Crafter.
Integrates the cooperative Scheduler and central Logging.
================================================================================
]]

local HAL = require("HAL")
local Scheduler = require("Scheduler")
local CrafterSystem = require("CrafterSystem")

local CrafterApp = {}
CrafterApp.__index = CrafterApp

function CrafterApp.new(options)
	local self = setmetatable({
		config = options.config,
		logger = options.logger,
		scheduler = options.scheduler,
		running = false,
		system = nil,
	}, CrafterApp)
	return self
end

function CrafterApp:run()
	self.running = true

	local chestName = self.config:get("buffer", "left")

	-- Register chest in HAL
	HAL.register("buffer", chestName)

	-- Initialize CrafterSystem
	self.system = CrafterSystem.new({
		chestName = "buffer",
		recipeFile = "crafter_recipes.json",
		logger = self.logger,
	})

	-- Pass chest name to dashboard for display
	self.system.dashboard.chestName = chestName

	-- Load recipes initially
	self.system.recipeManager:load(self.system.crafterGrid:getCount())

	-- Main process loop fiber
	self.scheduler:spawn(function()
		while self.running do
			if not self.system.isRecording then
				self.system:process()
			end
			Scheduler.sleep(0.5)
		end
	end, "CrafterApp-Main")

	-- Keyboard interaction fiber
	self.scheduler:spawn(function()
		while self.running do
			local _, key = Scheduler.waitEvent("key")
			if self.running then
				if key == keys.r then
					self.system.dashboard:setStatus("Reloading recipes...")
					self.logger:info("Reloading recipes requested by keyboard trigger.")
					self.system.recipeManager:load(self.system.crafterGrid:getCount())
					self.system.crafterGrid:discoverCrafters()
					Scheduler.sleep(0.5)
					self.system.dashboard:setStatus("Waiting for items...")
				elseif key == keys.s then
					self.system:recordNewRecipeFlow()
				elseif key == keys.m then
					self.system.manageRecipes:open()
				end
			end
		end
	end, "CrafterApp-Key")

	-- Keep main fiber alive
	while self.running do
		Scheduler.sleep(1)
	end
end

function CrafterApp:shutdown()
	self.running = false
	self.logger:info("CrafterApp heruntergefahren.")
end

return CrafterApp
