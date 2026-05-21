local Result = require("Result")

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
		recipes = {},
	}, RecipeStore)
	return self
end

--- Loads recipes from the file
--- @return Result
function RecipeStore:load()
	if not fs.exists(self.filename) then
		local saveRes = self:save() -- Create empty file if missing
		if saveRes:isErr() then
			return saveRes
		end
		return Result.ok(self.recipes)
	end

	local file = fs.open(self.filename, "r")
	if not file then
		return Result.err("FILE_OPEN_FAILED", "Konnte Rezeptdatei nicht oeffnen.")
	end
	local content = file.readAll()
	file.close()
	if not content then
		return Result.err("FILE_READ_FAILED", "Konnte Rezeptdatei nicht lesen.")
	end

	local data = textutils.unserializeJSON(content, {})
	if type(data) ~= "table" then
		return Result.err("INVALID_JSON_FORMAT", "Ungueltiges JSON-Format in Rezeptdatei.")
	end

	self.recipes = data
	return Result.ok(self.recipes)
end

--- Saves current recipes to the file
--- @return Result
function RecipeStore:save()
	local file = fs.open(self.filename, "w")
	if not file then
		return Result.err("FILE_WRITE_FAILED", "Konnte Rezeptdatei nicht zum Schreiben oeffnen.")
	end
	file.write(textutils.serialiseJSON(self.recipes))
	file.close()
	return Result.ok(true)
end

--- Adds or updates a recipe by its name
--- @param recipe table
function RecipeStore:add(recipe)
	if not recipe.name then
		return
	end
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
