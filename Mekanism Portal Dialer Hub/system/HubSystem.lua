-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})
local UUIDService = require("UUIDService")
local Dashboard = require("Dashboard")
local ConfigStore = require("ConfigStore")
local HAL = require("HAL")
local RednetProtocol = require("RednetProtocol")

-- Localize globals
local colors = colors
local term = term
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local os_startTimer = os.startTimer
local math = math
local table_insert = table.insert
local table_sort = table.sort
local ipairs = ipairs
local pcall = pcall
local string = string
local window = window
local keys = keys

---@class ConfigStore
---@field data table
---@field save fun(self: ConfigStore)
---@field load fun(self: ConfigStore)

---@class ButtonGrid
---@field mon table
---@field activeKey string|nil
---@field flashKey string|nil
---@field colorOn number
---@field buttons table
---@field setActive fun(self: ButtonGrid, key: string|nil)
---@field resetButtons fun(self: ButtonGrid)
---@field drawFineBox fun(self: ButtonGrid, x1: number, y1: number, x2: number, y2: number, color: number)
---@field drawHorizontalLine fun(self: ButtonGrid, x1: number, x2: number, y: number, color: number)
---@field add fun(self: ButtonGrid, name: string, callback: fun(), x1: number, x2: number, y1: number, y2: number, drawOnAdd?: boolean)
---@field setFlash fun(self: ButtonGrid, key: string)
---@field drawButtonBox fun(self: ButtonGrid, x1: number, y1: number, x2: number, y2: number, frameColor: number, bgColor: number)
---@field drawBox fun(self: ButtonGrid, x1: number, y1: number, x2: number, y2: number, color: number)
---@field checkClick fun(self: ButtonGrid, x: number, y: number)

---@class PortalConfig
---@field monitorSide string
---@field tpSide string
---@field textScale number
---@field gridColumns number
---@field gridRows number
---@field recallChannel number
---@field testModeCount number
---@field maxButtons number

---@class Logger

---@class HubSystem
---@field tp table The teleporter peripheral
---@field bm ButtonGrid The button manager instance
---@field configStore ConfigStore System configuration
---@field colorStore ConfigStore Color configuration
---@field frequencies table List of available frequencies
---@field currentPage number Currently displayed page
---@field totalPages number Total number of pages
---@field isEditMode boolean
---@field isBusy boolean
---@field lastColor string|nil
---@field portalColors table<string, string>
---@field uuidService UUIDService
---@field lastError string|nil
---@field monName string|nil
---@field tpName string|nil
---@field mekColors string[]
---@field ccMap table<string, number>
---@field manualActive string|nil
---@field isMovingOverlay boolean
---@field activeOverlay table|nil
---@field testSelectedFrequency string|nil
---@field buffer table|nil
---@field logger Logger|nil
---@field nativeMon table|nil
local HubSystem = {}
HubSystem.__index = HubSystem

--- Internal logging helper
---@param self table
---@param level string
---@param msg string
---@param ... any
local function log(self, level, msg, ...)
	if self.logger then
		local func = self.logger[level]
		if type(func) == "function" then
			func(self.logger, msg, ...)
		end
	end
end

--- Creates a new HubSystem instance
---@param options table
---@return HubSystem
function HubSystem.new(options)
	local tp = HAL.get(options.tpSide or "hub_teleporter")
	if not tp then
		error("Teleporter not found: " .. tostring(options.tpSide))
	end

	local self = setmetatable({
		tp = tp,
		bm = options.bm,
		logger = options.logger,
		configStore = ConfigStore.new("config.json", options.config or {}),
		colorStore = ConfigStore.new("portal_colors.json", {}),
		frequencies = {},
		currentPage = 1,
		totalPages = 1,
		isEditMode = false,
		isBusy = false,
		lastColor = nil,
		portalColors = {},
		uuidService = UUIDService.new("portal_owners.json"),
		lastError = nil,
		activeOverlay = nil,
		buffer = nil,
		manualActive = nil,
		monName = HAL.getName(options.bm.mon.native or options.bm.mon),
		tpName = options.tpSide,

		mekColors = {
			"WHITE",
			"YELLOW",
			"ORANGE",
			"RED",
			"PINK",
			"BRIGHT_PINK",
			"PURPLE",
			"INDIGO",
			"DARK_BLUE",
			"DARK_AQUA",
			"AQUA",
			"DARK_GREEN",
			"BRIGHT_GREEN",
			"BROWN",
			"GRAY",
			"DARK_GRAY",
			"BLACK",
		},
		ccMap = {
			WHITE = colors.white,
			YELLOW = colors.yellow,
			ORANGE = colors.orange,
			RED = colors.red,
			PINK = colors.pink,
			BRIGHT_PINK = colors.magenta,
			PURPLE = colors.purple,
			INDIGO = colors.blue,
			DARK_BLUE = colors.blue,
			DARK_AQUA = colors.cyan,
			AQUA = colors.lightBlue,
			DARK_GREEN = colors.green,
			BRIGHT_GREEN = colors.lime,
			BROWN = colors.brown,
			GRAY = colors.lightGray,
			DARK_GRAY = colors.gray,
			BLACK = colors.black,
		},
	}, HubSystem)

	RednetProtocol.openAuto()
	log(
		self,
		"info",
		"HubSystem initialized (monitor: %s, teleporter: %s)",
		self.monName or "Unknown",
		self.tpName or "Unknown"
	)
	return self
end

--- Draws the static frame and layout elements
function HubSystem:drawTerminalHeader()
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.cyan)
	print("Mekanism Portal Hub v1.0.123-main")
	term.setTextColor(colors.gray)
	local w, _ = term.getSize()
	print(string.rep("-", w))
	term.setTextColor(colors.white)
	print("Monitor:    " .. (self.monName or "Unknown"))
	print("Teleporter: " .. (self.tpName or "Unknown"))
	print("Modem:      " .. (self.modemSide or "Searching..."))
	print("\n[Press 'C' on Computer for Configuration]")

	if self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0 then
		term.setTextColor(colors.yellow)
		print("TEST MODE ACTIVE: " .. self.configStore.data.testModeCount .. " dummy buttons")
		term.setTextColor(colors.white)
	end
end

--- Interactive terminal configuration menu
function HubSystem:configMenu()
	log(self, "info", "Opened configuration menu on terminal.")
	while true do
		term.clear()
		term.setCursorPos(1, 1)
		term.setTextColor(colors.cyan)
		print("=== Portal Hub Configuration ===")
		term.setTextColor(colors.white)
		print("1. Recall Channel    (Current: " .. (self.configStore.data.recallChannel or 99) .. ")")
		print("2. Test Mode Count   (Current: " .. (self.configStore.data.testModeCount or 0) .. ")")
		print("3. Save & Exit")
		print("4. Exit without saving")

		local _, key = os_pullEvent("key")
		if key == keys.one then
			term.setCursorPos(1, 8)
			write("New Recall Channel: ")
			os_sleep(0.1) -- Clear event buffer
			local input = read()
			local newChannel = tonumber(input)
			if newChannel then
				self.configStore.data.recallChannel = newChannel
				log(self, "info", "Recall channel updated to %d.", newChannel)
			end
			os_sleep(0.5)
		elseif key == keys.two then
			term.setCursorPos(1, 8)
			write("New Test Mode Count: ")
			os_sleep(0.1) -- Clear event buffer
			local input = read()
			local newCount = tonumber(input)
			if newCount then
				self.configStore.data.testModeCount = newCount
				log(self, "info", "Test mode count updated to %d.", newCount)
			end
			os_sleep(0.5)
		elseif key == keys.three then
			self.configStore:save()
			log(self, "info", "Configuration saved.")
			self:drawTerminalHeader()
			self:draw()
			return
		elseif key == keys.four then
			self.configStore:load()
			log(self, "info", "Exited configuration menu without saving.")
			self:drawTerminalHeader()
			self:draw()
			return
		end
	end
end

--- Picks the next color for a portal
function HubSystem:getNextColor(portalName)
	local fixed = self.colorStore.data[portalName]
	if fixed then
		return fixed
	end

	local color = self.mekColors[math.random(1, #self.mekColors)]
	while color == self.lastColor do
		color = self.mekColors[math.random(1, #self.mekColors)]
	end
	return color
end

--- Refreshes the list of frequencies from the teleporter
function HubSystem:refresh()
	if self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0 then
		self.frequencies = {}
		for i = 1, self.configStore.data.testModeCount do
			table_insert(self.frequencies, { key = "Test Portal " .. i, public = true })
		end
	else
		local ok, f = pcall(self.tp.getFrequency)
		if ok and f and f.key and not self.manualActive then
			self.bm:setActive(f.key)
		end
		local ok_list, list = pcall(self.tp.getFrequencies)
		if not ok_list or not list then
			self.frequencies = {}
		else
			self.frequencies = list
			table_sort(self.frequencies, function(a, b)
				return a.key < b.key
			end)
		end
	end

	local max = self.configStore.data.maxButtons or 16
	self.totalPages = math.ceil(#self.frequencies / max)
	if self.totalPages < 1 then
		self.totalPages = 1
	end

	-- Reset to page 1 if current page is now out of bounds
	if self.currentPage > self.totalPages then
		self.currentPage = 1
	end
end

--- Draws the static frame and layout elements
function HubSystem:draw()
	self:refresh()
	self.bm:resetButtons()

	local w, h = self.bm.mon.getSize()
	if not self.buffer then
		if type(self.bm.mon.flush) == "function" then
			self.buffer = self.bm.mon
		else
			self.buffer = window.create(self.bm.mon, 1, 1, w, h, false)
			self.bm.mon = self.buffer
		end
	end

	self.buffer.setVisible(false)
	self.buffer.setBackgroundColor(colors.black)
	self.buffer.clear()

	local frameColor = self.isEditMode and colors.orange or colors.cyan
	self.bm:drawFineBox(1, 1, w, h, frameColor)

	self.bm.mon.setTextColor(colors.white)
	local title = self.isEditMode and " EDIT MODE ACTIVE " or " MEKANISM PORTAL NETWORK "
	self.bm.mon.setCursorPos(math.floor((w - #title) / 2) + 1, 2)
	self.bm.mon.write(title)
	self.bm:drawHorizontalLine(2, w - 1, 3, frameColor)
	self.bm.mon.setCursorPos(1, 3)
	self.bm.mon.write(string.char(157))

	local editX = w - 2
	self.bm:add("TOGGLE_EDIT", function()
		self.isEditMode = not self.isEditMode
		self:draw()
		os_sleep(0.5)
	end, editX - 1, w, 1, 3, true)

	self.bm.mon.setCursorPos(editX, 2)
	self.bm.mon.setTextColor(self.isEditMode and colors.orange or colors.white)
	self.bm.mon.write(string.char(164))

	self:drawStatus(true)
	self.bm.mon.setBackgroundColor(colors.black)
	self.bm:drawHorizontalLine(2, w - 1, h - 4, frameColor)
	self.bm.mon.setCursorPos(1, h - 4)
	self.bm.mon.write(string.char(157))

	local navY = h - 3
	if self.currentPage > 1 then
		local isPrevFlash = (self.bm.flashKey == "PREV")
		local prevCol = isPrevFlash and colors.lime or colors.gray
		local prevBG = isPrevFlash and colors.lime or colors.gray

		-- Manual Fill
		self.bm.mon.setBackgroundColor(prevBG)
		for row = navY, h - 1 do
			self.bm.mon.setCursorPos(3, row)
			self.bm.mon.write(string.rep(" ", 13))
		end

		self.bm:drawButtonBox(3, navY, 15, h - 1, prevCol, prevBG)
		self.bm:add("PREV", function()
			self.bm:setFlash("PREV")
			self.currentPage = self.currentPage - 1
			self:draw()
		end, 4, 14, navY + 1, navY + 1)
		self.bm.mon.setTextColor(isPrevFlash and colors.black or colors.white)
		self.bm.mon.setBackgroundColor(isPrevFlash and colors.lime or colors.gray)
		self.bm.mon.setCursorPos(6, navY + 1)
		self.bm.mon.write(" PREV ")
	end

	local mid = math.floor(w / 2)
	local isRefreshFlash = (self.bm.flashKey == "REFRESH")
	local refreshCol = isRefreshFlash and colors.lime or colors.gray
	local refreshBG = isRefreshFlash and colors.lime or colors.gray

	-- Manual Fill
	self.bm.mon.setBackgroundColor(refreshBG)
	for row = navY, h - 1 do
		self.bm.mon.setCursorPos(mid - 7, row)
		self.bm.mon.write(string.rep(" ", 15))
	end

	self.bm:drawButtonBox(mid - 7, navY, mid + 7, h - 1, refreshCol, refreshBG)
	self.bm:add("REFRESH", function()
		self.bm:setFlash("REFRESH")
		self:draw()
	end, mid - 6, mid + 6, navY + 1, navY + 1)
	self.bm.mon.setTextColor(isRefreshFlash and colors.black or colors.white)
	self.bm.mon.setBackgroundColor(isRefreshFlash and colors.lime or colors.gray)
	self.bm.mon.setCursorPos(mid - 4, navY + 1)
	self.bm.mon.write(" REFRESH ")

	if self.currentPage < self.totalPages then
		local isNextFlash = (self.bm.flashKey == "NEXT")
		local nextCol = isNextFlash and colors.lime or colors.gray
		local nextBG = isNextFlash and colors.lime or colors.gray

		-- Manual Fill
		self.bm.mon.setBackgroundColor(nextBG)
		for row = navY, h - 1 do
			self.bm.mon.setCursorPos(w - 14, row)
			self.bm.mon.write(string.rep(" ", 13))
		end

		self.bm:drawButtonBox(w - 14, navY, w - 2, h - 1, nextCol, nextBG)
		self.bm:add("NEXT", function()
			self.bm:setFlash("NEXT")
			self.currentPage = self.currentPage + 1
			self:draw()
		end, w - 13, w - 3, navY + 1, navY + 1)
		self.bm.mon.setTextColor(isNextFlash and colors.black or colors.white)
		self.bm.mon.setBackgroundColor(isNextFlash and colors.lime or colors.gray)
		self.bm.mon.setCursorPos(w - 11, navY + 1)
		self.bm.mon.write(" NEXT ")
	end

	self:drawContent()
	if self.activeOverlay then
		self:drawColorOverlay(self.activeOverlay.name, self.activeOverlay.x, self.activeOverlay.y, true)
	end
	self.buffer.setVisible(true)
end

--- Draws the dynamic portal list
function HubSystem:drawContent()
	local w = self.bm.mon.getSize()
	local cols, rows = self.configStore.data.gridColumns or 4, self.configStore.data.gridRows or 4
	local startX, endX, gapX = 3, w - 2, 2
	local totalWidth = endX - startX + 1
	local buttonWidth = math.floor((totalWidth - (cols - 1) * gapX) / cols)
	local gridWidth = (cols * buttonWidth) + ((cols - 1) * gapX)
	startX = startX + math.floor((totalWidth - gridWidth) / 2)

	local spacingY = 6
	local max = cols * rows
	local start = (self.currentPage - 1) * max + 1
	local finish = math.min(start + max - 1, #self.frequencies)

	for i = start, finish do
		local rel = i - start
		local bx = startX + (rel % cols) * (buttonWidth + gapX)
		local by = 10 + math.floor(rel / cols) * spacingY
		local f = self.frequencies[i]

		local bColor = self.isEditMode and colors.orange or colors.gray
		local isSelected = (self.bm.activeKey == f.key or self.bm.flashKey == f.key)
		local bgColor = isSelected and self.bm.colorOn or colors.gray
		local fgColor = isSelected and colors.black or colors.white

		-- Register button for click handling
		self.bm:add(f.key, function()
			if self.isEditMode then
				os_sleep(0.2)
				self:drawColorOverlay(f.key)
			else
				self:dial(f.key)
			end
		end, bx + 1, bx + buttonWidth - 2, by + 1, by + 3, true)

		-- 1. Fill the entire button area manually with the background color
		self.bm.mon.setBackgroundColor(bgColor)
		for row = by, by + 4 do
			self.bm.mon.setCursorPos(bx, row)
			self.bm.mon.write(string.rep(" ", buttonWidth))
		end

		-- 2. Draw the frame on top
		self.bm:drawButtonBox(bx, by, bx + buttonWidth - 1, by + 4, bColor, bgColor)

		-- Draw Label AFTER boxes
		local label = f.key
		if #label > buttonWidth - 2 then
			label = label:sub(1, buttonWidth - 4) .. ".."
		end
		local tx = bx + math.floor((buttonWidth - #label) / 2)
		local ty = by + 2

		self.bm.mon.setTextColor(fgColor)
		self.bm.mon.setBackgroundColor(bgColor)
		self.bm.mon.setCursorPos(tx, ty)
		self.bm.mon.write(label)

		-- Fixed Color Indicator
		local fixedCol = self.colorStore.data[f.key]
		if fixedCol and self.isEditMode then
			local pCol = self.ccMap[fixedCol] or colors.white
			-- Draw a 2-pixel wide accent stripe with a half-width separator
			for row = by + 1, by + 3 do
				-- The Color (2 pixels wide)
				self.bm.mon.setCursorPos(bx + 1, row)
				self.bm.mon.setBackgroundColor(pCol)
				self.bm.mon.write("  ")

				-- The "Half-Width" Separator
				self.bm.mon.setCursorPos(bx + 3, row)
				self.bm.mon.setBackgroundColor(bgColor) -- Match button background
				self.bm.mon.setTextColor(colors.black) -- Black thin line
				self.bm.mon.write(string.char(149))
			end
		end
	end
end

--- Dials a portal
function HubSystem:dial(portalName)
	local color = self:getNextColor(portalName)
	log(self, "info", "Dialing portal '%s' with color '%s'", portalName, color)
	self.manualActive = portalName
	self.bm:setActive(portalName)
	self:drawContent()
	self:drawStatus(true)
	self.buffer.setVisible(true)

	if not (self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0) then
		self.tp.setFrequency(portalName)
		os_sleep(0.3)
		log(self, "debug", "Set frequency color on teleporter to '%s'", color)
		pcall(self.tp.setFrequencyColor, color)
	else
		self.testSelectedFrequency = portalName
	end

	self:draw()
	os_sleep(0.2)
	self.manualActive = nil
end

--- Draws a color selection overlay
function HubSystem:drawColorOverlay(portalName, offsetX, offsetY, isRedraw)
	local w, h = self.bm.mon.getSize()
	local boxW, boxH = 39, 26

	-- Position Logic with Safety Margin (protects monitor borders)
	local curX = offsetX or (self.activeOverlay and self.activeOverlay.x) or math.floor((w - boxW) / 2)
	local curY = offsetY or (self.activeOverlay and self.activeOverlay.y) or math.floor((h - boxH) / 2)

	-- Keep at least 3 pixels away from edges to protect the main orange border
	local x1 = math.max(3, math.min(curX, w - boxW - 2))
	local y1 = math.max(4, math.min(curY, h - boxH - 2))

	if not isRedraw then
		self.activeOverlay = { name = portalName, x = x1, y = y1 }
	end

	-- Create an isolated sub-window for the overlay
	local win = window.create(self.buffer, x1, y1, boxW, boxH, true)
	win.setBackgroundColor(colors.gray)
	win.clear()

	local oldMon = self.bm.mon
	self.bm.mon = win -- Redirect button manager to sub-window

	self.bm:resetButtons()
	-- Overlay Shield still on main buffer to block background clicks
	self.bm:add("OVERLAY_SHIELD", function() end, 1, w, 1, h, true)

	-- Draw frame (coordinates now relative to 'win', so 1,1 to boxW, boxH)
	Dashboard.drawOverlayFrame(self.bm, 1, 1, boxW, boxH)

	-- Window Title with Move Action
	win.setTextColor(colors.white)
	win.setBackgroundColor(colors.gray)
	local title = "COLOR: " .. portalName
	if self.isMovingOverlay then
		title = "[ CLICK NEW POSITION ]"
	end
	if #title > boxW - 4 then
		title = title:sub(1, boxW - 6) .. ".."
	end
	win.setCursorPos(math.floor((boxW - #title) / 2) + 1, 2)
	win.write(title)

	-- Register title as a "Move" button
	self.bm:add("MOVE_WINDOW", function()
		self.isMovingOverlay = true
		self:draw()
	end, x1, x1 + boxW - 1, y1, y1 + 2, true)

	for i, colorName in ipairs(self.mekColors) do
		local bx = 4 + ((i - 1) % 4) * 9
		local by = 4 + math.floor((i - 1) / 4) * 4
		local swatchColor = self.ccMap[colorName] or colors.white
		self.bm:drawBox(bx, by, bx + 5, by + 1, swatchColor)
		Dashboard.drawColorSwatchFrame(self.bm, bx, by, bx + 5, by + 1, swatchColor)

		-- Button coordinates MUST be absolute for the ButtonManager's click detection
		self.bm:add("SET_COL_" .. colorName, function()
			self.colorStore.data[portalName] = colorName
			self.colorStore:save()
			log(self, "info", "Assigned custom color '%s' to portal '%s'", colorName, portalName)
			self.activeOverlay = nil
			self.bm.mon = oldMon
			os_sleep(0.1)
			self:draw()
		end, x1 + bx - 1, x1 + bx + 4, y1 + by - 1, y1 + by)
	end

	local buttonY = boxH - 2
	Dashboard.drawSmallButtonFrame(self.bm, 3, buttonY - 1, 12, buttonY + 1)
	self.bm:add("RESET_BTN", function()
		self.colorStore.data[portalName] = nil
		self.colorStore:save()
		log(self, "info", "Reset color assignment for portal '%s' to random", portalName)
		self.activeOverlay = nil
		self.bm.mon = oldMon
		os_sleep(0.1)
		self:draw()
	end, x1 + 2, x1 + 11, y1 + buttonY - 2, y1 + buttonY)
	win.setCursorPos(4, buttonY)
	win.write(" RANDOM ")

	Dashboard.drawSmallButtonFrame(self.bm, boxW - 12, buttonY - 1, boxW - 3, buttonY + 1)
	self.bm:add("BACK_BTN", function()
		self.activeOverlay = nil
		self.bm.mon = oldMon
		self:draw()
	end, x1 + boxW - 13, x1 + boxW - 4, y1 + buttonY - 2, y1 + buttonY)
	win.setCursorPos(boxW - 10, buttonY)
	win.write(" BACK ")

	self.bm.mon = oldMon -- Restore main monitor for safety
end

--- Draws the status display (target frequency and system state)
---@param force? boolean If true, ignore overlay state
function HubSystem:drawStatus(force)
	if self.activeOverlay and not force then
		return
	end
	local name, owner = "NOT CONNECTED", ""
	local statusStr
	if self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0 then
		name, owner, statusStr = self.testSelectedFrequency or "NONE", "DevUser", "TEST-MODE"
	else
		local ok, f = pcall(self.tp.getFrequency)
		if ok and f and f.key then
			name = f.key
			owner = self.uuidService:resolve(f.owner or "Unknown")
		end
		if type(self.tp.getStatus) == "function" then
			statusStr = self.tp.getStatus()
			statusStr = statusStr:sub(1, 1):upper() .. statusStr:sub(2)
		else
			statusStr = "Ready (No Status API)"
		end
	end

	if name ~= "NOT CONNECTED" and name ~= "NONE" and not self.manualActive then
		self.bm.activeKey = name
	end

	-- Draw Frame around status (Kept safe from edges)
	local w = self.bm.mon.getSize()
	Dashboard.drawOverlayFrame(self.bm, 3, 5, w - 3, 8)

	-- Explicitly fill the ENTIRE interior with gray
	self.bm:drawBox(4, 6, w - 4, 7, colors.gray)

	self.bm.mon.setBackgroundColor(colors.gray)
	self.bm.mon.setTextColor(colors.white)

	local innerW = w - 7 -- From col 4 to w-4
	local targetText = " TARGET: " .. name .. (owner ~= "" and " (" .. owner .. ")" or "")
	local systemText = " SYSTEM: " .. (self.lastError or statusStr)

	-- Manual padding to fill the entire inner width
	local targetLine = targetText .. string.rep(" ", math.max(0, innerW - #targetText))
	local systemLine = systemText .. string.rep(" ", math.max(0, innerW - #systemText))

	self.bm.mon.setCursorPos(4, 6)
	self.bm.mon.write(targetLine:sub(1, innerW))
	self.bm.mon.setCursorPos(4, 7)
	self.bm.mon.write(systemLine:sub(1, innerW))

	local isOverlayOpen = false
	for _, btn in ipairs(self.bm.buttons) do
		if btn.name == "OVERLAY_SHIELD" then
			isOverlayOpen = true
			break
		end
	end

	if not isOverlayOpen then
		self:drawContent()
	end
	if self.buffer then
		self.buffer.setVisible(true)
	end
end

--- Main runtime loop
function HubSystem:run()
	local side = RednetProtocol.openAuto()
	self.modemSide = side or "None"

	if side then
		HAL.call(side, "open", self.configStore.data.recallChannel or 99)
	end
	log(
		self,
		"info",
		"HubSystem running. Modem state: channel %d on side %s",
		self.configStore.data.recallChannel or 99,
		self.modemSide
	)
	self:drawTerminalHeader()
	self:draw()
	while true do
		local ev, _, x, y, message = os_pullEvent()
		if ev == "monitor_touch" and not self.isBusy then
			if self.isMovingOverlay then
				-- Move Mode Logic
				self.isMovingOverlay = false
				if self.activeOverlay then
					self.activeOverlay.x = x - math.floor(39 / 2) -- Center on click
					self.activeOverlay.y = y - 1 -- Header offset
				end
				self:draw()
			else
				-- Standard Click Logic
				self.isBusy = true
				self.bm:checkClick(x, y)
				self:drawStatus()
				local t = os_startTimer(0.5)
				while true do
					local e = { os_pullEvent() }
					if e[1] == "timer" and e[2] == t then
						break
					end
				end
				self.bm.flashKey = nil
				self:draw()
				self.isBusy = false
			end
		elseif ev == "modem_message" then
			local channel, msg = x, message
			if channel == (self.configStore.data.recallChannel or 99) then
				if type(msg) == "table" and msg.command == "RECALL" then
					log(self, "info", "Received RECALL command via modem for portal: %s", msg.target)
					self:dial(msg.target)
				end
			end
		elseif ev == "rednet_message" then
			local msg = x
			if type(msg) == "table" and msg.command == "RECALL" then
				log(self, "info", "Received RECALL command via Rednet for portal: %s", msg.target)
				self:dial(msg.target)
			end
		elseif ev == "key" and _ == keys.c then
			self:configMenu()
		end
	end
end

return HubSystem
