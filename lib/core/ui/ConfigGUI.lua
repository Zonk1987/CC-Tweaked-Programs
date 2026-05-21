--- @diagnostic disable: undefined-global
-- ConfigGUI: General In-Game Terminal Config Editor
-- Governed by AGENTS.md

local ConfigGUI = {}
ConfigGUI.__index = ConfigGUI

--- Creates a new ConfigGUI instance
--- @param configStore table The ConfigStore instance
--- @param schema table List of config definitions: { { key, label, type, choices, peripheralType } }
function ConfigGUI.new(configStore, schema)
	local self = setmetatable({
		store = configStore,
		schema = schema,
		selectedIndex = 1,
		running = false,
		modified = false,
	}, ConfigGUI)
	return self
end

--- Scans and returns all peripherals matching a type/prefix or all if nil
--- @param filter string|nil Optional search prefix
--- @return table List of peripheral names
local function getAttachedPeripherals(filter)
	local all = peripheral.getNames()
	if not filter then
		return all
	end
	local matches = {}
	local lowerFilter = string.lower(filter)
	for _, name in ipairs(all) do
		local pType = peripheral.getType(name)
		local isMatch = false
		if pType and string.find(string.lower(pType), lowerFilter) then
			isMatch = true
		elseif string.find(string.lower(name), lowerFilter) then
			isMatch = true
		elseif type(peripheral.hasType) == "function" and peripheral.hasType(name, filter) then
			isMatch = true
		end

		if isMatch then
			table.insert(matches, name)
		end
	end
	return matches
end

--- Draws a single bordered box using clean ASCII characters
local function drawBorder(win, x1, y1, x2, y2, bg, fg)
	win.setBackgroundColor(bg)
	win.setTextColor(fg)

	-- Horizontal lines
	local hLine = string.rep("-", x2 - x1 - 1)
	win.setCursorPos(x1, y1)
	win.write("+" .. hLine .. "+")
	win.setCursorPos(x1, y2)
	win.write("+" .. hLine .. "+")

	-- Vertical lines
	for y = y1 + 1, y2 - 1 do
		win.setCursorPos(x1, y)
		win.write("|")
		win.setCursorPos(x2, y)
		win.write("|")
	end
end

--- Renders the ConfigGUI onto the terminal
function ConfigGUI:draw(termObj)
	local w, h = termObj.getSize()
	termObj.setBackgroundColor(colors.white)
	termObj.setTextColor(colors.black)
	termObj.clear()

	-- 1. Header (Premium style accent stripe)
	termObj.setBackgroundColor(colors.blue)
	termObj.setTextColor(colors.white)
	for y = 1, 3 do
		termObj.setCursorPos(1, y)
		termObj.write(string.rep(" ", w))
	end
	termObj.setCursorPos(math.floor((w - 22) / 2) + 1, 2)
	termObj.write("SYSTEM KONFIGURATION")

	-- 2. List the fields
	local startY = 5
	for i, item in ipairs(self.schema) do
		local y = startY + (i - 1) * 2
		if y > h - 4 then
			break
		end -- Screen overflow guard

		local value = self.store:get(item.key, item.default)
		if type(value) == "boolean" then
			value = value and "True" or "False"
		else
			value = tostring(value)
		end

		-- Draw active/selected background highlight
		if i == self.selectedIndex then
			termObj.setBackgroundColor(colors.blue)
			termObj.setTextColor(colors.lightBlue)
		else
			termObj.setBackgroundColor(colors.white)
			termObj.setTextColor(colors.gray)
		end

		-- Clear row area
		termObj.setCursorPos(2, y)
		termObj.write(string.rep(" ", w - 2))

		-- Label
		termObj.setCursorPos(4, y)
		termObj.write(string.format("%-18s:", item.label))

		-- Value
		termObj.setCursorPos(24, y)
		if i == self.selectedIndex then
			termObj.setTextColor(colors.lightBlue)
			termObj.write(string.format("< %s >", value))
		else
			termObj.setTextColor(colors.black)
			termObj.write(string.format("  %s  ", value))
		end
	end

	-- 3. Bottom controls / Buttons
	termObj.setBackgroundColor(colors.white)
	termObj.setTextColor(colors.black)
	for y = h - 2, h do
		termObj.setCursorPos(1, y)
		termObj.write(string.rep(" ", w))
	end

	-- Instructions
	termObj.setCursorPos(3, h - 2)
	termObj.setTextColor(colors.gray)
	termObj.write("Arrow Keys: Navigate | Enter: Edit | Esc: Exit")

	-- Action highlights
	termObj.setCursorPos(4, h - 1)
	termObj.setBackgroundColor(colors.white)
	if self.selectedIndex == #self.schema + 1 then
		termObj.setTextColor(colors.green)
	else
		termObj.setTextColor(colors.black)
	end
	termObj.write("[ SPEICHERN ]")

	termObj.setCursorPos(24, h - 1)
	termObj.setBackgroundColor(colors.white)
	if self.selectedIndex == #self.schema + 2 then
		termObj.setTextColor(colors.red)
	else
		termObj.setTextColor(colors.black)
	end
	termObj.write("[ ABBRECHEN ]")
end

--- Splits a string into lines of a maximum width
--- @param text string The input string to wrap
--- @param maxWidth number The maximum width of a line
--- @return table List of wrapped lines
local function wrapText(text, maxWidth)
	local lines = {}
	local currentLine = ""

	for word in string.gmatch(text, "%S+") do
		if #currentLine == 0 then
			currentLine = word
		elseif #currentLine + 1 + #word <= maxWidth then
			currentLine = currentLine .. " " .. word
		else
			table.insert(lines, currentLine)
			currentLine = word
		end
	end

	if #currentLine > 0 then
		table.insert(lines, currentLine)
	end

	return lines
end

--- Shows a dynamic overlay popup to edit/read a value
function ConfigGUI:editValue(parentTerm, item)
	local w, h = parentTerm.getSize()
	local popW = 44
	local popH = (item.type == "choice" or item.type == "peripheral") and 9 or 7
	local popX = math.floor((w - popW) / 2) + 1
	local popY = math.floor((h - popH) / 2) + 1

	local popWin = window.create(parentTerm, popX, popY, popW, popH, true)
	popWin.setBackgroundColor(colors.white)
	popWin.clear()
	drawBorder(popWin, 1, 1, popW, popH, colors.white, colors.gray)

	popWin.setCursorPos(3, 2)
	popWin.setTextColor(colors.black)
	popWin.write("Aendere: " .. item.label)

	local currentValue = self.store:get(item.key, item.default)

	if item.type == "boolean" then
		-- Toggle Boolean immediately
		self.store:set(item.key, not currentValue)
		self.modified = true
		popWin.setVisible(false)
		return
	elseif item.type == "choice" then
		-- Choice Selection Popup with Word-Wrapping and dynamic height (9)
		local optionsStr = "Optionen: " .. table.concat(item.choices, ", ")
		local wrapped = wrapText(optionsStr, popW - 6)
		popWin.setCursorPos(3, 4)
		if wrapped[1] then
			popWin.write(wrapped[1])
		end
		popWin.setCursorPos(3, 5)
		if wrapped[2] then
			popWin.write(wrapped[2])
		end

		popWin.setCursorPos(3, 6)
		popWin.setTextColor(colors.blue)
		popWin.write("Geben Sie einen der Werte ein: ")

		popWin.setCursorPos(3, 7)
		term.redirect(popWin)
		local input = read()
		term.redirect(parentTerm)

		-- Validate choice
		local valid = false
		if input then
			local lowerInput = string.lower(input)
			for _, choice in ipairs(item.choices) do
				if string.lower(tostring(choice)) == lowerInput then
					self.store:set(item.key, choice)
					self.modified = true
					valid = true
					break
				end
			end
		end

		if not valid and input and input ~= "" then
			popWin.setCursorPos(3, 8)
			popWin.setTextColor(colors.red)
			popWin.write("Ungueltige Option!")
			sleep(1)
		end
	elseif item.type == "peripheral" then
		-- Scans matching peripherals
		local options = getAttachedPeripherals(item.peripheralType)
		if #options == 0 then
			popWin.setCursorPos(3, 4)
			popWin.setTextColor(colors.red)
			popWin.write("Keine passenden Geraete gefunden!")
			sleep(1.5)
			popWin.setVisible(false)
			return
		end

		-- List peripherals with Word-Wrapping and dynamic height (9)
		local optionsStr = "Geraete: " .. table.concat(options, ", ")
		local wrapped = wrapText(optionsStr, popW - 6)
		popWin.setCursorPos(3, 4)
		if wrapped[1] then
			popWin.write(wrapped[1])
		end
		popWin.setCursorPos(3, 5)
		if wrapped[2] then
			popWin.write(wrapped[2])
		end

		popWin.setCursorPos(3, 6)
		popWin.setTextColor(colors.blue)
		popWin.write("Name eingeben: ")

		popWin.setCursorPos(3, 7)
		term.redirect(popWin)
		local input = read()
		term.redirect(parentTerm)

		if input ~= "" then
			self.store:set(item.key, input)
			self.modified = true
		end
	else
		-- Standard String/Number editor with standard height (7)
		popWin.setCursorPos(3, 4)
		popWin.setTextColor(colors.gray)
		popWin.write("Aktuell: " .. tostring(currentValue))
		popWin.setCursorPos(3, 5)
		popWin.setTextColor(colors.blue)
		popWin.write("> ")

		popWin.setCursorPos(5, 5)
		term.redirect(popWin)
		local input = read()
		term.redirect(parentTerm)

		if input ~= "" then
			if item.type == "number" then
				local num = tonumber(input)
				if num then
					self.store:set(item.key, num)
					self.modified = true
				else
					popWin.setCursorPos(3, 6)
					popWin.setTextColor(colors.red)
					popWin.write("Muss eine Zahl sein!")
					sleep(1)
				end
			else
				self.store:set(item.key, input)
				self.modified = true
			end
		end
	end

	popWin.setVisible(false)
end

--- Runs the interactive ConfigGUI loop
--- @param parentTerm table|nil The target terminal window
--- @return boolean status If true, configurations were saved
function ConfigGUI:run(parentTerm)
	parentTerm = parentTerm or term.current()
	self.running = true
	self.modified = false
	self.selectedIndex = 1

	local totalItems = #self.schema

	while self.running do
		self:draw(parentTerm)

		local event, p1, p2, p3 = os.pullEvent()
		if event == "key" then
			if p1 == keys.up then
				self.selectedIndex = self.selectedIndex - 1
				if self.selectedIndex < 1 then
					self.selectedIndex = totalItems + 2 -- Wrap to Cancel
				end
			elseif p1 == keys.down then
				self.selectedIndex = self.selectedIndex + 1
				if self.selectedIndex > totalItems + 2 then
					self.selectedIndex = 1 -- Wrap to top
				end
			elseif p1 == keys.enter then
				if self.selectedIndex <= totalItems then
					-- Edit configuration field
					local item = self.schema[self.selectedIndex]
					self:editValue(parentTerm, item)
				elseif self.selectedIndex == totalItems + 1 then
					-- SAVE Button
					local ok = self.store:save()
					if ok then
						parentTerm.setBackgroundColor(colors.green)
						parentTerm.setTextColor(colors.white)
						parentTerm.clear()
						local w, h = parentTerm.getSize()
						parentTerm.setCursorPos(math.floor((w - 20) / 2) + 1, math.floor(h / 2) + 1)
						parentTerm.write("Konfiguration gespeichert!")
						sleep(1)
						self.running = false
						return true
					else
						parentTerm.setBackgroundColor(colors.red)
						parentTerm.setTextColor(colors.white)
						parentTerm.clear()
						local w, h = parentTerm.getSize()
						parentTerm.setCursorPos(math.floor((w - 20) / 2) + 1, math.floor(h / 2) + 1)
						parentTerm.write("Fehler beim Speichern!")
						sleep(1.5)
					end
				elseif self.selectedIndex == totalItems + 2 then
					-- CANCEL Button
					self.running = false
					return false
				end
			elseif p1 == keys["esc"] or p1 == keys["escape"] or p1 == 256 or p1 == 1 then
				-- Escape exits immediately without saving
				self.running = false
				return false
			end
		elseif event == "mouse_click" then
			-- Mouse click integration for advanced setups
			local x, y = p2, p3
			local w, h = parentTerm.getSize()

			-- Check items clicks
			local startY = 5
			for i = 1, totalItems do
				local itemY = startY + (i - 1) * 2
				if y == itemY and x >= 2 and x <= w - 2 then
					self.selectedIndex = i
					self:draw(parentTerm)
					local item = self.schema[self.selectedIndex]
					self:editValue(parentTerm, item)
					break
				end
			end

			-- Check button clicks
			if y == h - 1 then
				if x >= 4 and x <= 18 then
					-- SAVE
					self.selectedIndex = totalItems + 1
					self:draw(parentTerm)
					os.queueEvent("key", keys.enter)
				elseif x >= 24 and x <= 38 then
					-- CANCEL
					self.selectedIndex = totalItems + 2
					self:draw(parentTerm)
					os.queueEvent("key", keys.enter)
				end
			end
		end
	end

	return false
end

return ConfigGUI
