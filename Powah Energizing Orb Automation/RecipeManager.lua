-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})
-- Localize globals
local setmetatable = setmetatable
local type = type
local ipairs = ipairs
local pairs = pairs
local next = next
local table_insert = table.insert
local fs = fs
local textutils = textutils

---@class RecipeManager
---@field filename string
---@field dashboard any
---@field recipes table[]
local RecipeManager = {}
RecipeManager.__index = RecipeManager

--- Creates a new RecipeManager instance
---@param filename string
---@param dashboard any
---@return RecipeManager
function RecipeManager:new(filename, dashboard)
    local instance = setmetatable({}, self)
    instance.filename = filename
    instance.dashboard = dashboard
    instance.recipes = {}
    return instance
end

--- Loads and validates recipes from JSON
---@return boolean success
function RecipeManager:load()
    if not fs.exists(self.filename) then
        local file = fs.open(self.filename, "w")
        local template = [=[
[
    {
        "name": "YOUR RECIPE NAME HERE",
        "ingredients": {
            "minecraft:dirt": 1,
            "modname:itemname": 2
        }
    }
]
]=]
        file.write(template)
        file.close()
        self.dashboard:setError("Generated " .. self.filename .. "! Please edit.")
        return false
    end

    local file = fs.open(self.filename, "r")
    local content = file.readAll()
    file.close()

    local rawRecipes = textutils.unserializeJSON(content)
    if not rawRecipes then
        self.dashboard:setError("Syntax Error in " .. self.filename .. "!")
        return false
    end

    local validated = self:validate(rawRecipes)
    if validated then
        self.recipes = validated
        self.dashboard.errorMsg = ""
        self.dashboard:setRecipeCount(#self.recipes)
        return true
    end
    return false
end

--- Validates a raw recipe table
---@param rawRecipes table[]
---@return table[]|nil
function RecipeManager:validate(rawRecipes)
    local validRecipes = {}
    for i, recipe in ipairs(rawRecipes) do
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
                self.dashboard:setError("Recipe '" .. recipe.name .. "': Ingredient " .. item .. " has amount <= 0")
                return nil
            end
            totalItems = totalItems + count
        end

        if totalItems > 6 then
            self.dashboard:setError("Recipe '" .. recipe.name .. "': Too large! Max 6 items!")
            return nil
        end

        table_insert(validRecipes, recipe)
    end
    return validRecipes
end

--- Helper: Counts a specific item in the chest
---@param itemName string
---@param chestItems table
---@return number
function RecipeManager:countItem(itemName, chestItems)
    local count = 0
    for _, item in pairs(chestItems) do
        if item.name == itemName then
            count = count + item.count
        end
    end
    return count
end

--- Checks if all ingredients for a recipe are present
---@param recipe table
---@param chestItems table
---@return boolean
function RecipeManager:isRecipeComplete(recipe, chestItems)
    for itemName, requiredAmount in pairs(recipe.ingredients) do
        if self:countItem(itemName, chestItems) < requiredAmount then
            return false
        end
    end
    return true
end

--- Finds the first recipe whose ingredients are completely met
---@param chest Chest
---@return table|nil
function RecipeManager:findReadyRecipe(chest)
    local chestItems = chest:list()
    if not next(chestItems) then return nil end

    for _, recipe in ipairs(self.recipes) do
        if self:isRecipeComplete(recipe, chestItems) then
            return recipe
        end
    end
    return nil
end

return RecipeManager
