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
---@field dashboard Dashboard
---@field recipes table[]
local RecipeManager = {}
RecipeManager.__index = RecipeManager

--- Creates a new RecipeManager instance
---@param filename string
---@param dashboard Dashboard
---@return RecipeManager
function RecipeManager:new(filename, dashboard)
    local instance = setmetatable({}, self)
    instance.filename = filename
    instance.dashboard = dashboard
    instance.recipes = {}
    return instance
end

--- Loads and validates recipes from JSON
---@param crafterCount number|nil
---@return boolean success
function RecipeManager:load(crafterCount)
    if not fs.exists(self.filename) then
        local width = 5
        local height = 5
        if crafterCount and crafterCount > 0 then
            local root = math.sqrt(crafterCount)
            if root == math.floor(root) and root >= 5 then
                width = root
                height = root
            end
        end

        local pattern = {}
        local basePattern = {
            "0AAA0",
            "AABAA",
            "ABCBA",
            "AABAA",
            "0AAA0"
        }
        
        local padTop = math.floor((height - 5) / 2)
        local padBottom = height - 5 - padTop
        local padLeftStr = string.rep("0", math.floor((width - 5) / 2))
        local padRightStr = string.rep("0", width - 5 - math.floor((width - 5) / 2))
        local emptyRow = string.rep("0", width)
        
        for i = 1, padTop do table.insert(pattern, emptyRow) end
        for _, row in ipairs(basePattern) do
            table.insert(pattern, padLeftStr .. row .. padRightStr)
        end
        for i = 1, padBottom do table.insert(pattern, emptyRow) end

        local recipeData = {
            {
                name = "Crushing Wheel (Example)",
                keys = {
                    A = "create:andesite_alloy",
                    B = "~planks",
                    C = "minecraft:stone"
                },
                pattern = pattern
            }
        }
        
        local file = fs.open(self.filename, "w")
        file.write(textutils.serializeJSON(recipeData))
        file.close()
        
        self.dashboard:setError("Generated example recipe for your grid!")
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
        if type(recipe.keys) ~= "table" then
            self.dashboard:setError("Recipe '" .. recipe.name .. "': Missing keys object!")
            return nil
        end
        if type(recipe.pattern) ~= "table" then
            self.dashboard:setError("Recipe '" .. recipe.name .. "': Missing pattern array!")
            return nil
        end

        local flatIngredients = {}
        local currentIndex = 1

        for rowIdx, row in ipairs(recipe.pattern) do
            if type(row) ~= "string" then
                self.dashboard:setError("Recipe '" .. recipe.name .. "': Pattern row " .. rowIdx .. " is not a string!")
                return nil
            end

            for charIdx = 1, #row do
                local char = row:sub(charIdx, charIdx)
                if char == "-" then
                    -- Do nothing, no physical crafter here
                else
                    if char == "0" then
                        -- Physical crafter exists, but empty slot
                        flatIngredients[currentIndex] = "null"
                    else
                        local itemName = recipe.keys[char]
                        if not itemName then
                            self.dashboard:setError("Recipe '" ..
                                recipe.name .. "': Unknown key '" .. char .. "' in pattern!")
                            return nil
                        end
                        flatIngredients[currentIndex] = itemName
                    end
                    currentIndex = currentIndex + 1
                end
            end
        end

        recipe.ingredients = flatIngredients
        table_insert(validRecipes, recipe)
    end
    return validRecipes
end

--- Helper: Counts a specific item in the chest (supports fuzzy matching with ~)
---@param itemName string
---@param chestItems table
---@return number
function RecipeManager:countItem(itemName, chestItems)
    local count = 0
    for _, item in pairs(chestItems) do
        local isMatch = false
        if itemName:sub(1, 1) == "~" then
            isMatch = item.name:find(itemName:sub(2), 1, true) ~= nil
        else
            isMatch = (item.name == itemName)
        end

        if isMatch then
            count = count + item.count
        end
    end
    return count
end

--- Checks if all ingredients for a recipe are present
---@param recipe table
---@param chestItems table
---@param crafterCount number
---@return boolean
function RecipeManager:isRecipeComplete(recipe, chestItems, crafterCount)
    -- First, calculate how much of each item is needed for the recipe
    local neededAmounts = {}
    local maxIndex = 0

    for k, v in pairs(recipe.ingredients) do
        local numK = tonumber(k)
        if numK and numK > maxIndex then maxIndex = numK end

        if type(v) == "string" and v ~= "null" and v ~= "" then
            neededAmounts[v] = (neededAmounts[v] or 0) + 1
        end
    end

    -- Prevent recipes larger than connected crafters
    if maxIndex > crafterCount then
        return false
    end

    -- Check if we have enough of each needed item in the chest
    for itemName, requiredAmount in pairs(neededAmounts) do
        if self:countItem(itemName, chestItems) < requiredAmount then
            return false
        end
    end
    return true
end

--- Finds the first recipe whose ingredients are completely met
---@param chest Chest
---@param crafterCount number
---@return table|nil
function RecipeManager:findReadyRecipe(chest, crafterCount)
    local chestItems = chest:list()
    if not next(chestItems) then return nil end

    for _, recipe in ipairs(self.recipes) do
        if self:isRecipeComplete(recipe, chestItems, crafterCount) then
            return recipe
        end
    end
    return nil
end

--- Calculates missing items for the best matching recipe based on chest contents
---@param chest Chest
---@param crafterCount number
---@return table|nil
function RecipeManager:getMissingItems(chest, crafterCount)
    if #self.recipes == 0 then return nil end
    local chestItems = chest:list()
    if not next(chestItems) then return nil end -- Chest empty, don't show any missing items

    local bestRecipe = nil
    local bestNeeded = {}
    local highestMatchCount = 0

    for _, recipe in ipairs(self.recipes) do
        local maxIndex = 0
        local tempNeeded = {}
        for k, v in pairs(recipe.ingredients) do
            local numK = tonumber(k)
            if numK and numK > maxIndex then maxIndex = numK end
            if type(v) == "string" and v ~= "null" and v ~= "" then
                tempNeeded[v] = (tempNeeded[v] or 0) + 1
            end
        end
        if maxIndex <= crafterCount then
            local matchCount = 0
            for itemName, _ in pairs(tempNeeded) do
                local inChest = self:countItem(itemName, chestItems)
                if inChest > 0 then
                    matchCount = matchCount + inChest
                end
            end

            if matchCount > highestMatchCount then
                highestMatchCount = matchCount
                bestRecipe = recipe
                bestNeeded = tempNeeded
            end
        end
    end

    if not bestRecipe or highestMatchCount == 0 then return nil end

    local missing = {}
    for itemName, requiredAmount in pairs(bestNeeded) do
        local inChest = self:countItem(itemName, chestItems)
        if inChest < requiredAmount then
            missing[itemName] = requiredAmount - inChest
        end
    end

    if next(missing) == nil then return nil end

    return {
        recipeName = bestRecipe.name,
        items = missing
    }
end

--- Records a new recipe from physical crafters
---@param name string
---@param crafterGrid CrafterGrid
---@return boolean success, string? err
function RecipeManager:recordRecipe(name, crafterGrid)
    local count = crafterGrid:getCount()
    if count == 0 then return false, "No crafters!" end
    
    local width = math.sqrt(count)
    if width ~= math.floor(width) then
        return false, "Grid must be square! (" .. count .. ")"
    end
    
    local keys = {}
    local reverseKeys = {}
    local pattern = {}
    local currentPatternRow = ""
    local charCode = 65 -- 'A'
    local itemsFound = 0
    
    for i = 1, count do
        local crafterName = crafterGrid:getCrafterName(i)
        local p = peripheral.wrap(crafterName)
        if not p then return false, "Crafter missing!" end
        
        local item = p.getItemDetail(1)
        local char = "0"
        
        if item then
            itemsFound = itemsFound + 1
            local itemName = item.name
            if reverseKeys[itemName] then
                char = reverseKeys[itemName]
            else
                char = string.char(charCode)
                keys[char] = itemName
                reverseKeys[itemName] = char
                charCode = charCode + 1
            end
        end
        
        currentPatternRow = currentPatternRow .. char
        
        if i % width == 0 then
            table.insert(pattern, currentPatternRow)
            currentPatternRow = ""
        end
    end
    
    if itemsFound == 0 then
        return false, "Crafters are empty!"
    end
    
    local file = fs.open(self.filename, "r")
    local content = file and file.readAll() or "[]"
    if file then file.close() end
    
    local rawRecipes = textutils.unserializeJSON(content) or {}
    
    local found = false
    for _, r in ipairs(rawRecipes) do
        if r.name == name then
            r.keys = keys
            r.pattern = pattern
            found = true
            break
        end
    end
    
    if not found then
        table.insert(rawRecipes, {
            name = name,
            keys = keys,
            pattern = pattern
        })
    end
    
    file = fs.open(self.filename, "w")
    file.write(textutils.serializeJSON(rawRecipes))
    file.close()
    
    return true
end

return RecipeManager
