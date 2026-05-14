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
local string = string

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
function RecipeManager.new(filename, dashboard)
    local self = setmetatable({
        filename = filename,
        dashboard = dashboard,
        recipes = {}
    }, RecipeManager)
    return self
end

--- Loads and validates recipes from JSON
---@return boolean success
function RecipeManager:load()
    if not fs.exists(self.filename) then
        local file = fs.open(self.filename, "w")
        if file then
            file.write("[]")
            file.close()
        end
        return false
    end

    local file = fs.open(self.filename, "r")
    if not file then return false end
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
        self.dashboard:setRecipeCount(#self.recipes)
        return true
    end
    return false
end

--- Helper: Manually formats JSON for readability
local function formatJSON(raw)
    local out = ""
    local indent = 0
    local quoted = false
    for i = 1, #raw do
        local c = raw:sub(i, i)
        if c == '"' and raw:sub(i-1, i-1) ~= "\\" then quoted = not quoted end

        if not quoted then
            if c == "{" or c == "[" then
                indent = indent + 1
                out = out .. c .. "\n" .. string.rep("    ", indent)
            elseif c == "}" or c == "]" then
                indent = indent - 1
                out = out .. "\n" .. string.rep("    ", indent) .. c
            elseif c == "," then
                out = out .. c .. "\n" .. string.rep("    ", indent)
            elseif c == ":" then
                out = out .. ": "
            else
                out = out .. c
            end
        else
            out = out .. c
        end
    end
    return out
end

--- Saves current recipes to JSON
function RecipeManager:save()
    local file = fs.open(self.filename, "w")
    if not file then return end
    local raw = textutils.serialiseJSON(self.recipes)
    file.write(formatJSON(raw))
    file.close()
    self.dashboard:setRecipeCount(#self.recipes)
end

--- Adds a recipe to the list and saves it
---@param recipe table
function RecipeManager:addRecipe(recipe)
    for i, r in ipairs(self.recipes) do
        if r.name == recipe.name then
            self.recipes[i] = recipe
            self:save()
            return
        end
    end

    table_insert(self.recipes, recipe)
    self:save()
end

--- Removes a recipe by its name and saves the list
---@param name string
---@return boolean success
function RecipeManager:removeRecipeByName(name)
    for i, r in ipairs(self.recipes) do
        if r.name == name then
            table.remove(self.recipes, i)
            self:save()
            return true
        end
    end
    return false
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

--- Helper: Counts a specific item in the chest
---@param itemName string
---@param chestItems table
---@return number
local function countItem(itemName, chestItems)
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
        if countItem(itemName, chestItems) < requiredAmount then
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
    if not chestItems or not next(chestItems) then return nil end

    for _, recipe in ipairs(self.recipes) do
        if self:isRecipeComplete(recipe, chestItems) then
            return recipe
        end
    end
    return nil
end

return RecipeManager