-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Localize globals
local table_insert = table.insert
local RecipeStore = require("RecipeStore")
local ItemMatcher = require("ItemMatcher")

---@class RecipeManager : RecipeStore
---@field dashboard any
local RecipeManager = setmetatable({}, { __index = RecipeStore })
RecipeManager.__index = RecipeManager

--- Creates a new RecipeManager instance
---@param filename string
---@param dashboard any
---@return RecipeManager
function RecipeManager.new(filename, dashboard)
	local self = RecipeStore.new(filename)
	---@cast self RecipeManager
	self.dashboard = dashboard
	return setmetatable(self, RecipeManager)
end

--- Loads and validates recipes from JSON
---@return boolean success
function RecipeManager:load()
	local ok, err = RecipeStore.load(self)
	if not ok then
		self.dashboard:setError("Load Error: " .. (err or "Unknown"))
		return false
	end

	local validated = self:validate(self.recipes)
	if validated then
		self.recipes = validated
		self.dashboard:setRecipeCount(#self.recipes)
		return true
	end
	return false
end

--- Adds a recipe to the list and saves it
---@param recipe table
function RecipeManager:addRecipe(recipe)
	self:add(recipe)
	self.dashboard:setRecipeCount(#self.recipes)
end

--- Removes a recipe by name and updates the dashboard
---@param name string
---@return boolean success
function RecipeManager:removeRecipeByName(name)
	local found = self:remove(name)
	if found then
		self.dashboard:setRecipeCount(#self.recipes)
	end
	return found
end

--- Validates a raw recipe table
---@param rawRecipes table[]
---@return table[]|nil
function RecipeManager:validate(rawRecipes)
	local validRecipes = {}
	for i, recipe in ipairs(rawRecipes) do
		if recipe.name ~= "YOUR RECIPE NAME HERE" then
			if type(recipe.name) ~= "string" or recipe.name == "" then
				self.dashboard:setError("Recipe #" .. i .. ": Missing name!")
				return nil
			end
			if type(recipe.ingredients) ~= "table" then
				self.dashboard:setError("Recipe '" .. recipe.name .. "': Missing ingredients!")
				return nil
			end

			local totalItems = 0
			for item, count in pairs(recipe.ingredients) do
				if type(count) ~= "number" or count <= 0 then
					self.dashboard:setError("Recipe '" .. recipe.name .. "': Ingredient " .. item .. " invalid amount")
					return nil
				end
				totalItems = totalItems + count
			end

			if totalItems > 6 then
				self.dashboard:setError("Recipe '" .. recipe.name .. "': Too many items (max 6)!")
				return nil
			end
			table_insert(validRecipes, recipe)
		end
	end
	return validRecipes
end

--- Checks if all ingredients for a recipe are present
---@param recipe table
---@param chestItems table
---@return boolean
function RecipeManager:isRecipeComplete(recipe, chestItems)
	for itemName, requiredAmount in pairs(recipe.ingredients) do
		if ItemMatcher.count(itemName, chestItems) < requiredAmount then
			return false
		end
	end
	return true
end

--- Finds the first recipe whose ingredients are completely met
---@param chest any
---@return table|nil
function RecipeManager:findReadyRecipe(chest)
	local chestItems = chest:list()
	if not chestItems or not next(chestItems) then
		return nil
	end

	for _, recipe in ipairs(self.recipes) do
		if self:isRecipeComplete(recipe, chestItems) then
			return recipe
		end
	end
	return nil
end

--- Adds a recipe (delegated to RecipeStore)
function RecipeManager:add(recipe)
	RecipeStore.add(self, recipe)
end

--- Removes a recipe by name (delegated to RecipeStore)
function RecipeManager:remove(name)
	return RecipeStore.remove(self, name)
end

return RecipeManager
