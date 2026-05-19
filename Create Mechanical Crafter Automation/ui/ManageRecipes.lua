-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Localize globals
local term = term
local colors = colors
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local string = string
local math = math
local table_insert = table.insert
local ipairs = ipairs
local pairs = pairs
local keys = keys
local keys_up = keys.up
local keys_down = keys.down
local keys_x = keys.x
local keys_q = keys.q
local keys_f = keys.f
local keys_tab = keys.tab
local keys_left = keys.left
local keys_right = keys.right

---@class ManageRecipes
---@field recipeManager any
---@field dashboard any
local ManageRecipes = {}
ManageRecipes.__index = ManageRecipes

--- Creates a new ManageRecipes instance
function ManageRecipes.new(options)
	local self = setmetatable({}, ManageRecipes)
	self.recipeManager = options.recipeManager
	self.dashboard = options.dashboard
	return self
end

--- Summarizes ingredient counts for a recipe (ordered by char)
local function getIngredientSummary(recipe)
	local summary = {}
	for char, name in pairs(recipe.keys) do
		local count = 0
		for _, row in ipairs(recipe.pattern) do
			local _, c = row:gsub(char, "")
			count = count + c
		end
		if count > 0 then
			table_insert(summary, { char = char, name = name, count = count })
		end
	end
	table.sort(summary, function(a, b)
		return a.char < b.char
	end)
	return summary
end

--- Main UI loop for managing recipes
function ManageRecipes:open()
	self.dashboard.suppressDraw = true
	local selected = 1
	local rightSelected = 1
	local side = "left" -- "left" or "right"
	local w, h = term.getSize()
	local listWidth = math.floor(w * 0.45)

	while true do
		term.clear()
		term.setCursorPos(1, 1)
		term.setTextColor(colors.yellow)
		local title = "=== Manage Recipes (" .. #self.recipeManager.recipes .. ") ==="
		local pad = math.max(0, math.floor((w - #title) / 2))
		term.setCursorPos(pad + 1, 1)
		term.write(title)
		term.setCursorPos(1, 2)
		term.setTextColor(colors.gray)
		term.write(string.rep("-", w))

		-- Left Side: Recipe List
		local maxLines = h - 4
		local offset = (selected > maxLines / 2) and (selected - math.floor(maxLines / 2)) or 0
		offset = math.min(offset, math.max(0, #self.recipeManager.recipes - maxLines))

		for i = 1, maxLines do
			local idx = i + offset
			if idx > #self.recipeManager.recipes then
				break
			end

			term.setCursorPos(1, i + 2)
			local r = self.recipeManager.recipes[idx]

			local isSel = (idx == selected and side == "left")
			term.setTextColor(isSel and colors.lime or (idx == selected and colors.yellow or colors.white))
			term.write(idx == selected and ">" or " ")

			local name = r.name
			if #name > listWidth - 3 then
				name = name:sub(1, listWidth - 5) .. ".."
			end
			term.write(name)
		end

		-- Vertical Separator
		term.setTextColor(colors.gray)
		for i = 3, h - 1 do
			term.setCursorPos(listWidth + 1, i)
			term.write("|")
		end

		-- Right Side: Recipe Details
		local current = self.recipeManager.recipes[selected]
		local summary = {}
		if current then
			summary = getIngredientSummary(current)
			local detailX = listWidth + 3
			local detailW = w - detailX + 1

			term.setCursorPos(detailX, 3)
			term.setTextColor(side == "right" and colors.yellow or colors.lightGray)
			local recipeTitle = current.name
			if #recipeTitle > detailW then
				recipeTitle = recipeTitle:sub(1, detailW - 2) .. ".."
			end
			term.write(recipeTitle)

			term.setCursorPos(detailX, 4)
			term.setTextColor(colors.gray)
			term.write(string.rep("-", detailW))

			for i, item in ipairs(summary) do
				if i + 4 >= h then
					break
				end
				term.setCursorPos(detailX, i + 4)

				local isSel = (i == rightSelected and side == "right")
				term.setTextColor(isSel and colors.lime or colors.white)
				term.write(isSel and ">" or " ")

				term.write(item.count .. "x ")
				local name = item.name
				local shortName = name:match("([^:]+)$") or name
				if name:sub(1, 1) == "~" then
					term.setTextColor(colors.orange)
					shortName = "~" .. (name:sub(2):match("([^:]+)$") or name:sub(2))
				end

				if #shortName > detailW - 5 then
					shortName = shortName:sub(1, detailW - 7) .. ".."
				end
				term.write(shortName)
			end
		end

		-- Footer
		term.setCursorPos(1, h)
		term.setTextColor(colors.gray)
		local footer = "Tab:Side | X:Del | Q:Exit"
		if side == "right" then
			footer = "F:Fuzzy | " .. footer
		end
		term.write(footer)

		local _, key = os_pullEvent("key")
		if key == keys_up then
			if side == "left" and selected > 1 then
				selected = selected - 1
			elseif side == "right" and rightSelected > 1 then
				rightSelected = rightSelected - 1
			end
		elseif key == keys_down then
			if side == "left" and selected < #self.recipeManager.recipes then
				selected = selected + 1
			elseif side == "right" and rightSelected < #summary then
				rightSelected = rightSelected + 1
			end
		elseif key == keys_tab or key == keys_right or key == keys_left then
			side = (side == "left") and "right" or "left"
			rightSelected = 1
		elseif key == keys_f and side == "right" and summary[rightSelected] then
			local item = summary[rightSelected]
			local currentVal = current.keys[item.char]

			-- UI Feedback: Show input prompt in the footer
			term.setCursorPos(1, h)
			term.clearLine()
			term.setTextColor(colors.yellow)
			term.write("Edit Pattern: ")
			term.setTextColor(colors.white)

			-- Small sleep to prevent 'f' from appearing in the prompt
			os_sleep(0.1)

			-- Use read() with the current value as default for easy editing
			local newPattern = read(nil, nil, nil, currentVal)

			if newPattern and newPattern ~= "" then
				current.keys[item.char] = newPattern
				self.recipeManager:save()
				self.recipeManager:load()
			end
		elseif key == keys_x and side == "left" then
			local r = self.recipeManager.recipes[selected]
			if r then
				self.recipeManager:removeRecipeByName(r.name)
				selected = math.max(1, math.min(selected, #self.recipeManager.recipes))
				os_sleep(0.2)
			end
		elseif key == keys_q then
			break
		end
	end

	self.dashboard.suppressDraw = false
	self.dashboard:draw()
	return true
end

return ManageRecipes
