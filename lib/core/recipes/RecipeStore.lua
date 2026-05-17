--- @diagnostic disable: undefined-global
-- RecipeStore: Generic JSON-based recipe management
-- Governed by AGENTS.md

local RecipeStore = {}
RecipeStore.__index = RecipeStore

---@class RecipeStore
---@field filename string Path to the JSON file
---@field recipes table[] Loaded recipes


--- Creates a new RecipeStore instance
--- @param filename string
--- @return RecipeStore
function RecipeStore.new(filename)
    local self = setmetatable({
        filename = filename,
        recipes = {}
    }, RecipeStore)
    return self
end

--- Loads recipes from the file
--- @return boolean success, string|nil err
function RecipeStore:load()
    if not fs.exists(self.filename) then
        self:save() -- Create empty file if missing
        return true
    end

    local file = fs.open(self.filename, "r")
    if not file then return false, "file_open_failed" end
    local content = file.readAll()
    file.close()
    if not content then return false, "file_read_failed" end

    local data = textutils.unserializeJSON(content, {})
    if type(data) ~= "table" then return false, "invalid_json_format" end
    
    self.recipes = data
    return true
end

--- Saves current recipes to the file
function RecipeStore:save()
    local file = fs.open(self.filename, "w")
    if file then
        file.write(textutils.serialiseJSON(self.recipes))
        file.close()
    end
end

--- Adds or updates a recipe by its name
--- @param recipe table
function RecipeStore:add(recipe)
    if not recipe.name then return end
    for i, r in ipairs(self.recipes) do
        if r.name == recipe.name then
            self.recipes[i] = recipe
            self:save()
            return
        end
    end
    table.insert(self.recipes, recipe)
    self:save()
end

--- Removes a recipe by name
--- @param name string
--- @return boolean found
function RecipeStore:remove(name)
    for i, r in ipairs(self.recipes) do
        if r.name == name then
            table.remove(self.recipes, i)
            self:save()
            return true
        end
    end
    return false
end

--- Returns the recipe list
--- @return table[]
function RecipeStore:getAll()
    return self.recipes
end

return RecipeStore
