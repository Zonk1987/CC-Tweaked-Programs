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
---@field dashboard Dashboard
local RecipeManager = setmetatable({}, { __index = RecipeStore })
RecipeManager.__index = RecipeManager

--- Creates a new RecipeManager instance
---@param filename string
---@param dashboard Dashboard
---@return RecipeManager
function RecipeManager.new(filename, dashboard)
	local self = RecipeStore.new(filename)
	---@cast self RecipeManager
	self.dashboard = dashboard
	return setmetatable(self, RecipeManager)
end

--- Internal helper to generate an example recipe if file doesn't exist
function RecipeManager:generateExample(crafterCount)
	local width, height = 5, 5
	if crafterCount and crafterCount > 0 then
		local root = math.sqrt(crafterCount)
		if root == math.floor(root) and root >= 5 then
			width, height = root, root
		end
	end

	local pattern = {}
	local basePattern = { "0AAA0", "AABAA", "ABCBA", "AABAA", "0AAA0" }
	local padTop = math.floor((height - 5) / 2)
	local padBottom = height - 5 - padTop
	local padLeftStr = string.rep("0", math.floor((width - 5) / 2))
	local padRightStr = string.rep("0", width - 5 - math.floor((width - 5) / 2))
	local emptyRow = string.rep("0", width)

	for _ = 1, padTop do
		table_insert(pattern, emptyRow)
	end
	for _, row in ipairs(basePattern) do
		table_insert(pattern, padLeftStr .. row .. padRightStr)
	end
	for _ = 1, padBottom do
		table_insert(pattern, emptyRow)
	end

	local recipeData = {
		{
			name = "Crushing Wheel (Example)",
			keys = { A = "create:andesite_alloy", B = "~planks", C = "minecraft:stone" },
			pattern = pattern,
		},
	}
	local file = fs.open(self.filename, "w")
	if file then
		file.write(textutils.serializeJSON(recipeData))
		file.close()
	end
	self.dashboard:setError("Generated example recipe!")
end

--- Loads and validates recipes from JSON
---@param crafterCount number|nil
---@return boolean success
function RecipeManager:load(crafterCount)
	local ok, err = RecipeStore.load(self)
	if not ok then
		if not fs.exists(self.filename) then
			self:generateExample(crafterCount)
			return false
		end
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
		if type(recipe.keys) ~= "table" or type(recipe.pattern) ~= "table" then
			self.dashboard:setError("Recipe '" .. recipe.name .. "': Invalid format!")
			return nil
		end

		local flatIngredients = {}
		local currentIndex = 1
		for _, row in ipairs(recipe.pattern) do
			for charIdx = 1, #row do
				local char = row:sub(charIdx, charIdx)
				if char ~= "-" then
					if char == "0" then
						flatIngredients[currentIndex] = "null"
					else
						local itemName = recipe.keys[char]
						if not itemName then
							self.dashboard:setError("Recipe '" .. recipe.name .. "': Unknown key '" .. char .. "'")
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

--- Removes a recipe by its name and saves the list
---@param name string
---@return boolean success
function RecipeManager:removeRecipeByName(name)
	for i, r in ipairs(self.recipes) do
		if r.name == name then
			table.remove(self.recipes, i)
			self:save()
			self.dashboard:setRecipeCount(#self.recipes)
			return true
		end
	end
	return false
end

--- Checks if all ingredients for a recipe are present
function RecipeManager:isRecipeComplete(recipe, chestItems, crafterCount)
	local neededAmounts = {}
	local maxIndex = 0
	for k, v in pairs(recipe.ingredients) do
		local numK = tonumber(k)
		if numK and numK > maxIndex then
			maxIndex = numK
		end
		if type(v) == "string" and v ~= "null" and v ~= "" then
			neededAmounts[v] = (neededAmounts[v] or 0) + 1
		end
	end

	if maxIndex > crafterCount then
		return false
	end
	for itemName, requiredAmount in pairs(neededAmounts) do
		if ItemMatcher.count(itemName, chestItems) < requiredAmount then
			return false
		end
	end
	return true
end

--- Finds the first recipe whose ingredients are completely met
---@param chest any
---@param crafterCount number
---@return table|nil
function RecipeManager:findReadyRecipe(chest, crafterCount)
	local chestItems = chest:list()
	if not chestItems or not next(chestItems) then
		return nil
	end
	for _, recipe in ipairs(self.recipes) do
		if self:isRecipeComplete(recipe, chestItems, crafterCount) then
			return recipe
		end
	end
	return nil
end

--- Calculates missing items for the best matching recipe
---@param chest any
---@param crafterCount number
---@return table|nil
function RecipeManager:getMissingItems(chest, crafterCount)
	if #self.recipes == 0 then
		return nil
	end
	local chestItems = chest:list()
	if not chestItems or not next(chestItems) then
		return nil
	end

	local bestRecipe, bestNeeded, highestMatchCount = nil, {}, 0
	for _, recipe in ipairs(self.recipes) do
		local tempNeeded, matchCount, maxIdx = {}, 0, 0
		for k, v in pairs(recipe.ingredients) do
			local numK = tonumber(k)
			if numK and numK > maxIdx then
				maxIdx = numK
			end
			if type(v) == "string" and v ~= "null" and v ~= "" then
				tempNeeded[v] = (tempNeeded[v] or 0) + 1
			end
		end

		if maxIdx <= crafterCount then
			for itemName, _ in pairs(tempNeeded) do
				matchCount = matchCount + ItemMatcher.count(itemName, chestItems)
			end
			if matchCount > highestMatchCount then
				highestMatchCount, bestRecipe, bestNeeded = matchCount, recipe, tempNeeded
			end
		end
	end

	if not bestRecipe or highestMatchCount == 0 then
		return nil
	end
	local missing = {}
	for itemName, req in pairs(bestNeeded) do
		local inChest = ItemMatcher.count(itemName, chestItems)
		if inChest < req then
			missing[itemName] = req - inChest
		end
	end

	return next(missing) and { recipeName = bestRecipe.name, items = missing } or nil
end

--- Records a new recipe from physical crafters
function RecipeManager:recordRecipe(name, crafterGrid)
	local count = crafterGrid:getCount()
	if count == 0 then
		return false, "No crafters!"
	end
	local width = math.sqrt(count)
	if width ~= math.floor(width) then
		return false, "Grid not square!"
	end

	local keys, reverseKeys, pattern, currentLine = {}, {}, {}, ""
	local charCode, itemsFound = 65, 0

	for i = 1, count do
		local p = peripheral.wrap(crafterGrid:getCrafterName(i))
		---@cast p any
		local item = p and p.getItemDetail(1)
		local char = "0"
		if item then
			itemsFound = itemsFound + 1
			if reverseKeys[item.name] then
				char = reverseKeys[item.name]
			else
				char = string.char(charCode)
				keys[char], reverseKeys[item.name], charCode = item.name, char, charCode + 1
			end
		end
		currentLine = currentLine .. char
		if i % width == 0 then
			table_insert(pattern, currentLine)
			currentLine = ""
		end
	end

	if itemsFound == 0 then
		return false, "Crafters empty!"
	end
	local file = fs.open(self.filename, "r")
	local content = file and file.readAll() or "[]"
	local raw = textutils.unserializeJSON(content, {}) or {}
	if file then
		file.close()
	end

	local found = false
	for i = #raw, 1, -1 do
		local r = raw[i]
		if r.name == name then
			r.keys, r.pattern, found = keys, pattern, true
		elseif r.name == "Crushing Wheel (Example)" then
			table.remove(raw, i)
		end
	end

	if not found then
		table_insert(raw, { name = name, keys = keys, pattern = pattern })
	end

	local outFile = fs.open(self.filename, "w")
	if outFile then
		outFile.write(textutils.serializeJSON(raw))
		outFile.close()
	end

	-- Reload into memory to sync state
	self:load()
	return true
end

--- Saves current recipes to the file (delegated to RecipeStore)
function RecipeManager:save()
	RecipeStore.save(self)
end

-- Return the class module
return RecipeManager
