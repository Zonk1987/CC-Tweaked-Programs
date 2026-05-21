-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})
local Dashboard = require("Dashboard")
local RecipeManager = require("RecipeManager")
local Chest = require("Chest")
local Orb = require("Orb")
local ImportMenu = require("ImportMenu")
local HAL = require("HAL")

-- Localize globals
local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local os_sleep = os.sleep
local os_epoch = os.epoch
local os_pullEvent = os.pullEvent
local parallel_waitForAll = (parallel --[[@as any]]).waitForAll
local keys_r = keys.r
local keys_i = keys.i

---@class Logger

---@class PowahSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field activeJobs table<string, table>
---@field meBridge any|nil
---@field aeScanner any|nil
---@field logger Logger|nil
local PowahSystem = {}
PowahSystem.__index = PowahSystem

--- Internal logging helper
---@param self table
---@param level string
---@param msg string
---@param ... any
local function log(self, level, msg, ...)
	if self.logger then
		local func = self.logger[level]
		if type(func) == "function" then
			func(self.logger, msg, ...)
		end
	end
end

--- Creates the main system
---@param options table
---@return PowahSystem
function PowahSystem.new(options)
	local self = setmetatable({}, PowahSystem)
	self.logger = options.logger
	self.chest = Chest.new(options.chestName)
	self.dashboard = Dashboard.new()
	self.recipeManager = RecipeManager.new(options.recipeFile or "powah_recipes.json", self.dashboard)
	self.activeJobs = {}
	self.meBridge = options.meBridgeName and HAL.get(options.meBridgeName) or nil
	self.aeScanner = options.aeScannerName and HAL.get(options.aeScannerName) or nil
	log(
		self,
		"info",
		"PowahSystem initialized (chest: %s, recipeFile: %s)",
		options.chestName,
		options.recipeFile or "powah_recipes.json"
	)
	return self
end

--- Finds an orb without a current job
---@return Orb|nil
function PowahSystem:getFreeOrb()
	local allOrbsNames = HAL.listNames("powah:energizing_orb")
	for _, name in ipairs(allOrbsNames) do
		if not self.activeJobs[name] then
			local orb = Orb.new(name)
			if orb:isEmpty() then
				return orb
			end
		end
	end
	return nil
end

--- Monitors currently active crafting jobs
function PowahSystem:checkActiveJobs()
	for orbName, job in pairs(self.activeJobs) do
		local orb = Orb.new(orbName)
		if not orb:isPresent() then
			self.activeJobs[orbName] = nil
		else
			if orb:isEmpty() then
				log(self, "info", "Job completed on orb '%s' for recipe: %s", orbName, job.recipeName)
				self.dashboard:setLastCraft(job.recipeName)
				self.activeJobs[orbName] = nil
				self.dashboard:draw()
			else
				-- Timeout check (1 minute)
				if (os_epoch("utc") - job.startTime) > 60000 then
					local timeoutMsg = "Timeout in " .. orbName .. ". Recovering..."
					self.dashboard:setError(timeoutMsg)
					log(
						self,
						"warn",
						"Timeout in '%s' during craft of recipe '%s'. Recovering items...",
						orbName,
						job.recipeName
					)
					local recRes = orb:recover(self.chest.name)
					if recRes:isErr() then
						local err = recRes:getError()
						local errStr = err and (err.message or err.code) or "Unknown error"
						log(self, "error", "Failed to recover items from orb '%s': %s", orbName, errStr)
					end
					self.activeJobs[orbName] = nil
					os_sleep(1)
					self.dashboard:setError("")
				end
			end
		end
	end
end

--- Main process loop logic
function PowahSystem:process()
	if not self.chest:isPresent() then
		self.dashboard:setError("Chest missing!")
		log(self, "error", "Buffer chest missing!")
		os_sleep(2)
		return
	end

	if self.dashboard.errorMsg == "Chest missing!" or self.dashboard.errorMsg == "No Orb found!" then
		self.dashboard:setError("")
	end

	self.dashboard:updateJobs(self.activeJobs)
	self:checkActiveJobs()

	local freeOrb = self:getFreeOrb()
	if freeOrb then
		local readyRecipe = self.recipeManager:findReadyRecipe(self.chest)
		if readyRecipe then
			self.dashboard:setStatus("Filling " .. freeOrb.name)
			log(self, "info", "Filling orb '%s' for recipe: %s", freeOrb.name, readyRecipe.name)
			local res = self.chest:transferRecipe(readyRecipe, freeOrb.name)

			if res:isOk() then
				self.activeJobs[freeOrb.name] = {
					startTime = os_epoch("utc"),
					recipeName = readyRecipe.name,
				}
				log(
					self,
					"info",
					"Successfully started crafting on '%s' for recipe: %s",
					freeOrb.name,
					readyRecipe.name
				)
				self.dashboard:draw()
			else
				local err = res:getError()
				local errStr = err and (err.message or err.code) or "Unknown error"
				self.dashboard:setError("Transfer: " .. errStr)
				log(
					self,
					"error",
					"Failed to transfer items to orb '%s' for recipe '%s': %s",
					freeOrb.name,
					readyRecipe.name,
					errStr
				)
				local recRes = freeOrb:recover(self.chest.name)
				if recRes:isErr() then
					local recErr = recRes:getError()
					local recErrStr = recErr and (recErr.message or recErr.code) or "Unknown error"
					log(self, "error", "Failed to recover items: %s", recErrStr)
				end
				os_sleep(1)
			end
		else
			self.dashboard:setStatus("Waiting for items...")
		end
	else
		local allOrbs = HAL.listNames("powah:energizing_orb")
		if #allOrbs > 0 then
			self.dashboard:setStatus("All Orbs are busy...")
		else
			self.dashboard:setError("No Orb found!")
		end
	end
end

--- Runs the process continuously
function PowahSystem:mainLoop()
	while true do
		self:process()
		os_sleep(0.1)
	end
end

--- Listens to keyboard events
function PowahSystem:keyListener()
	while true do
		local _, key = os_pullEvent("key")
		if key == keys_r then
			self.dashboard:setStatus("Reloading recipes...")
			log(self, "info", "Reloading recipes requested by keyboard trigger.")
			self.recipeManager:load()
			os_sleep(0.5)
			self.dashboard:setStatus("Waiting for items...")
		elseif key == keys_i then
			local menu = ImportMenu.new({
				meBridge = self.meBridge,
				aeScanner = self.aeScanner,
				recipeManager = self.recipeManager,
				dashboard = self.dashboard,
			})
			---@type any
			local result = menu:open()
			if result:isErr() then
				local err = result:getError()
				if err.code == "ME_BRIDGE_MISSING" then
					self.dashboard:setError("No ME Bridge found!")
				elseif err.code == "NO_PATTERNS_FOUND" then
					self.dashboard:setError("No patterns found!")
				else
					self.dashboard:setError(err.message or "Unknown Error")
				end
				os_sleep(1.5)
				self.dashboard:setError("")
			end
		end
	end
end

--- Starts the system (backward compatibility)
function PowahSystem:start()
	self:run()
end

--- Runs the system
function PowahSystem:run()
	self.recipeManager:load()
	parallel_waitForAll(function()
		self:mainLoop()
	end, function()
		self:keyListener()
	end)
end

return PowahSystem
