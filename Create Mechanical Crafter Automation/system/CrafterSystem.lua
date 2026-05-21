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
local CrafterGrid = require("CrafterGrid")
local ManageRecipes = require("ManageRecipes")
local RedstoneController = require("RedstoneController")

-- Localize globals
local setmetatable = setmetatable
local os_sleep = os.sleep
local os_epoch = os.epoch
local os_pullEvent = os.pullEvent
local parallel_waitForAll = (parallel --[[@as any]]).waitForAll

local colors = colors
local keys = keys
local keys_r = keys.r
local keys_s = keys.s
local keys_m = keys.m

---@class Logger

---@class CrafterSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field crafterGrid CrafterGrid
---@field isCrafting boolean
---@field craftStartTime number
---@field isRecording boolean
---@field manageRecipes ManageRecipes
---@field logger Logger|nil
local CrafterSystem = {}
CrafterSystem.__index = CrafterSystem

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
---@return CrafterSystem
function CrafterSystem.new(options)
	local self = setmetatable({}, CrafterSystem)
	self.logger = options.logger
	self.chest = Chest.new(options.chestName)
	self.dashboard = Dashboard.new()
	self.recipeManager = RecipeManager.new(options.recipeFile or "crafter_recipes.json", self.dashboard)
	self.crafterGrid = CrafterGrid.new()
	self.isCrafting = false
	self.craftStartTime = 0
	self.isRecording = false
	self.manageRecipes = ManageRecipes.new({
		recipeManager = self.recipeManager,
		dashboard = self.dashboard,
	})
	log(
		self,
		"info",
		"CrafterSystem initialized (chest: %s, recipeFile: %s)",
		options.chestName,
		options.recipeFile or "crafter_recipes.json"
	)
	return self
end

--- Main process loop logic
function CrafterSystem:process()
	if not self.chest:isPresent() then
		self.dashboard:setError("Buffer chest missing!")
		log(self, "error", "Buffer chest missing!")
		os_sleep(2)
		return
	end

	if self.crafterGrid:getCount() == 0 then
		self.crafterGrid:discoverCrafters()
		if self.crafterGrid:getCount() == 0 then
			self.dashboard:setError("No Mechanical Crafters found!")
			log(self, "error", "No Mechanical Crafters found!")
			os_sleep(2)
			return
		end
	end

	-- Clear transient errors
	if
		self.dashboard.errorMsg == "Buffer chest missing!"
		or self.dashboard.errorMsg == "No Mechanical Crafters found!"
	then
		self.dashboard:setError("")
	end

	self.dashboard:setCrafterCount(self.crafterGrid:getCount())

	if self.isCrafting then
		self:handleOngoingCraft()
	else
		self:handleNewCraft()
	end

	self.dashboard:draw()
end

--- Logic for when a craft is currently in progress
function CrafterSystem:handleOngoingCraft()
	self.dashboard:setStatus("Crafting in progress...")
	self.dashboard:setMissingItems(nil)
	self.dashboard:draw()

	os_sleep(1)

	if self.crafterGrid:isEmpty() then
		self.isCrafting = false
		self.dashboard:setError("")
		self.dashboard:setStatus("Waiting for items...")
	else
		-- Jam detection (30 seconds)
		if (os_epoch("utc") - self.craftStartTime) > 30000 then
			local jammedMsg = self.crafterGrid:getJammedItem()
			local errStr = "JAMMED: " .. (jammedMsg or "Unknown item stuck!")
			self.dashboard:setError(errStr)
			log(self, "warn", errStr)
		end
	end
end

--- Logic for starting a new craft
function CrafterSystem:handleNewCraft()
	if not self.crafterGrid:isEmpty() then
		self.isCrafting = true
		self.craftStartTime = os_epoch("utc")
		return
	end

	local readyRecipe = self.recipeManager:findReadyRecipe(self.chest, self.crafterGrid:getCount())
	if readyRecipe then
		self.dashboard:setStatus("Filling Crafters...")
		self.dashboard:setMissingItems(nil)
		self.dashboard:draw()

		log(self, "info", "Filling Crafters for recipe: %s", readyRecipe.name)
		local res = self.chest:transferRecipe(readyRecipe, self.crafterGrid)
		if res:isOk() then
			self.isCrafting = true
			self.craftStartTime = os_epoch("utc")
			self.dashboard:setLastCraft(readyRecipe.name)
			self.dashboard:setStatus("Crafting " .. readyRecipe.name .. "...")
			log(self, "info", "Successfully started crafting recipe: %s", readyRecipe.name)
			RedstoneController.pulseAll()
		else
			local err = res:getError()
			local errStr = err and (err.message or err.code) or "Unknown error"
			local hintStr = err and err.hint or ""
			if hintStr ~= "" then
				errStr = errStr .. "\n" .. hintStr
			end
			self.dashboard:setError(errStr)
			log(self, "error", "Failed to transfer items for recipe '%s': %s. Detail: %s", readyRecipe.name, err and err.message or errStr, hintStr)
			os_sleep(4.5)
			self.dashboard:setError("")
		end
	else
		self.dashboard:setStatus("Waiting for items...")
		local missing = self.recipeManager:getMissingItems(self.chest, self.crafterGrid:getCount())
		self.dashboard:setMissingItems(missing)
	end
end

--- Runs the process continuously
function CrafterSystem:mainLoop()
	while true do
		if not self.isRecording then
			self:process()
		end
		os_sleep(0.5)
	end
end

--- Listens to keyboard events
function CrafterSystem:keyListener()
	while true do
		local _, key = os_pullEvent("key")
		if key == keys_r then
			self.dashboard:setStatus("Reloading recipes...")
			log(self, "info", "Reloading recipes requested by keyboard trigger.")
			self.recipeManager:load(self.crafterGrid:getCount())
			self.crafterGrid:discoverCrafters()
			os_sleep(0.5)
			self.dashboard:setStatus("Waiting for items...")
		elseif key == keys_s then
			self:recordNewRecipeFlow()
		elseif key == keys_m then
			self.manageRecipes:open()
		end
	end
end

--- Interactive flow to record a new recipe
function CrafterSystem:recordNewRecipeFlow()
	self.isRecording = true
	self.dashboard.suppressDraw = true

	term.clear()
	term.setCursorPos(1, 1)
	local w, _ = term.getSize()
	if term.isColor() then
		term.setTextColor(colors.cyan)
	end
	print(string.rep("=", w))
	local title = "Record New Recipe"
	local pad = math.max(0, math.floor((w - #title) / 2))
	print(string.rep(" ", pad) .. title)
	print(string.rep("=", w))
	term.setTextColor(colors.white)
	print("\n1. Place the items in the physical crafters")
	print("2. Enter the name of your new recipe")
	print("   (Leave blank and press ENTER to cancel)")
	term.write("\nRecipe Name: ")

	os_sleep(0.1) -- Debounce
	local name = read()
	if not name or name == "" then
		self.isRecording = false
		self.dashboard.suppressDraw = false
		self.dashboard:draw()
		return
	end

	self.dashboard.suppressDraw = false
	self.dashboard:setStatus("Recording " .. name .. "...")
	self.dashboard:draw()

	local res = self.recipeManager:recordRecipe(name, self.crafterGrid)
	if res:isOk() then
		self.dashboard:setError("Recipe saved successfully!")
		self.recipeManager:load(self.crafterGrid:getCount())
		-- Start crafting the recorded recipe immediately
		RedstoneController.pulseAll()
	else
		local err = res:getError()
		local errStr = err and (err.message or err.code) or "Unknown error"
		self.dashboard:setError("Record Error: " .. errStr)
	end

	os_sleep(2)
	self.dashboard:setError("")
	self.dashboard:setStatus("Waiting for items...")
	self.isRecording = false
	self.dashboard:draw()
end

--- Starts the system (backward compatibility)
function CrafterSystem:start()
	self:run()
end

--- Runs the system
function CrafterSystem:run()
	self.recipeManager:load(self.crafterGrid:getCount())
	parallel_waitForAll(function()
		self:mainLoop()
	end, function()
		self:keyListener()
	end)
end

return CrafterSystem
