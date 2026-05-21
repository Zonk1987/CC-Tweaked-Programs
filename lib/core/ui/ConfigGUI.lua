---@diagnostic disable: undefined-global, undefined-field
-- luacheck: globals peripheral colors term keys os window sleep read
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
		elseif filter == "inventory" then
			local device = peripheral.wrap(name)
			if device and type(device["list"]) == "function" and type(device["size"]) == "function" then
				isMatch = true
			end
		end

		-- Exclude mechanical crafters from the candidate list
		if
			isMatch
			and (string.find(name, "mechanical_crafter") or (pType and string.find(pType, "mechanical_crafter")))
		then
			isMatch = false
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

--- Shows a dynamic overlay popup to edit/read a value
function ConfigGUI:editValue(parentTerm, item)
	local w, h = parentTerm.getSize()
	local currentValue = self.store:get(item.key, item.default)
	local popWin

	if item.type == "boolean" then
		-- Toggle Boolean immediately
		self.store:set(item.key, not currentValue)
		self.modified = true
		return
	elseif item.type == "choice" or item.type == "peripheral" then
		local options = {}
		if item.type == "choice" then
			options = item.choices
		elseif item.type == "peripheral" then
			options = getAttachedPeripherals(item.peripheralType)
			if #options == 0 then
				local popW = math.min(44, w - 4)
				local popH = 5
				local popX = math.floor((w - popW) / 2) + 1
				local popY = math.floor((h - popH) / 2) + 1
				popWin = window.create(parentTerm, popX, popY, popW, popH, true)
				popWin.setBackgroundColor(colors.white)
				popWin.clear()
				drawBorder(popWin, 1, 1, popW, popH, colors.white, colors.gray)
				popWin.setCursorPos(3, 3)
				popWin.setTextColor(colors.red)
				popWin.write("Keine passenden Geraete!")
				sleep(1.5)
				popWin.setVisible(false)
				return
			end
		end

		local localIndex = 1
		for idx, opt in ipairs(options) do
			if tostring(opt) == tostring(currentValue) then
				localIndex = idx
				break
			end
		end

		local maxVisible = 6
		local numVisible = math.min(#options, maxVisible)
		local popW = math.min(44, w - 4)
		local popH = numVisible + 6
		local popX = math.floor((w - popW) / 2) + 1
		local popY = math.floor((h - popH) / 2) + 1

		popWin = window.create(parentTerm, popX, popY, popW, popH, true)

		local scrollOffset = 0
		local function updateScroll()
			if localIndex < 1 then
				localIndex = #options
			elseif localIndex > #options then
				localIndex = 1
			end

			if localIndex <= scrollOffset then
				scrollOffset = localIndex - 1
			elseif localIndex > scrollOffset + maxVisible then
				scrollOffset = localIndex - maxVisible
			end
		end

		local function drawPopup()
			popWin.setBackgroundColor(colors.white)
			popWin.clear()
			drawBorder(popWin, 1, 1, popW, popH, colors.white, colors.gray)

			-- Title
			popWin.setCursorPos(3, 2)
			popWin.setTextColor(colors.black)
			popWin.write("Aendere: " .. item.label)

			-- Separator under title
			popWin.setCursorPos(2, 3)
			popWin.setTextColor(colors.gray)
			popWin.write(string.rep("-", popW - 2))

			-- Draw options
			for i = 1, numVisible do
				local optIdx = i + scrollOffset
				local opt = options[optIdx]
				if opt then
					local y = 3 + i
					popWin.setCursorPos(3, y)
					if optIdx == localIndex then
						popWin.setBackgroundColor(colors.blue)
						popWin.setTextColor(colors.white)
						popWin.write(string.rep(" ", popW - 4))
						popWin.setCursorPos(4, y)
						popWin.write("> " .. tostring(opt))
					else
						popWin.setBackgroundColor(colors.white)
						popWin.setTextColor(colors.black)
						popWin.write(string.rep(" ", popW - 4))
						popWin.setCursorPos(4, y)
						popWin.write("  " .. tostring(opt))
					end
				end
			end

			-- Reset background for footer
			popWin.setBackgroundColor(colors.white)

			-- Separator above footer
			popWin.setCursorPos(2, popH - 2)
			popWin.setTextColor(colors.gray)
			popWin.write(string.rep("-", popW - 2))

			-- Instructions
			popWin.setCursorPos(3, popH - 1)
			popWin.setTextColor(colors.gray)
			local instStr = "Pfeiltasten: Wahl | Enter: OK"
			if popW < 32 then
				instStr = "Auf/Ab:Wahl Enter:OK"
			end
			popWin.write(instStr)
		end

		updateScroll()
		drawPopup()

		while true do
			local event, p1, p2, p3 = os.pullEvent()
			if event == "key" then
				if p1 == keys.up then
					localIndex = localIndex - 1
					updateScroll()
					drawPopup()
				elseif p1 == keys.down then
					localIndex = localIndex + 1
					updateScroll()
					drawPopup()
				elseif p1 == keys.enter then
					self.store:set(item.key, options[localIndex])
					self.modified = true
					break
				elseif p1 == keys["escape"] or p1 == keys["esc"] or p1 == 256 or p1 == 1 then
					break
				end
			elseif event == "mouse_click" then
				local x, y = p2, p3
				if x >= popX + 2 and x <= popX + popW - 3 then
					local clickY = y - popY - 3
					if clickY >= 1 and clickY <= numVisible then
						local clickedIdx = clickY + scrollOffset
						if clickedIdx >= 1 and clickedIdx <= #options then
							if localIndex == clickedIdx then
								self.store:set(item.key, options[localIndex])
								self.modified = true
								break
							else
								localIndex = clickedIdx
								updateScroll()
								drawPopup()
							end
						end
					end
				end
			elseif event == "mouse_scroll" then
				local direction = p1
				if direction < 0 then
					if localIndex > 1 then
						localIndex = localIndex - 1
						updateScroll()
						drawPopup()
					end
				else
					if localIndex < #options then
						localIndex = localIndex + 1
						updateScroll()
						drawPopup()
					end
				end
			end
		end

		popWin.setVisible(false)
	else
		-- Standard String/Number editor with standard height (7)
		local popW = 44
		local popH = 7
		local popX = math.floor((w - popW) / 2) + 1
		local popY = math.floor((h - popH) / 2) + 1
		popWin = window.create(parentTerm, popX, popY, popW, popH, true)
		popWin.setBackgroundColor(colors.white)
		popWin.clear()
		drawBorder(popWin, 1, 1, popW, popH, colors.white, colors.gray)

		popWin.setCursorPos(3, 2)
		popWin.setTextColor(colors.black)
		popWin.write("Aendere: " .. item.label)

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

		popWin.setVisible(false)
	end
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
