-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

---@class PortalConfig
---@field monitorSide string
---@field tpSide string
---@field textScale number
---@field gridColumns number
---@field gridRows number
---@field recallChannel number
---@field testModeCount number
---@field maxButtons number

---@class PortalSystem
---@field tp table The teleporter peripheral
---@field bm ButtonManager The button manager instance
---@field config PortalConfig System configuration
---@field frequencies table List of available frequencies
---@field currentPage number Currently displayed page
---@field totalPages number Total number of pages
---@field isEditMode boolean
---@field isBusy boolean
---@field lastColor string|nil
---@field portalColors table<string, string>
---@field playerNames table<string, string>
---@field mekColors string[]
---@field ccMap table<string, number>
---@field lastError string|nil
local PortalSystem = {}
PortalSystem.__index = PortalSystem

--- Creates a new PortalSystem instance
---@param tpPeripheral string
---@param bm ButtonManager
---@param config PortalConfig
---@return PortalSystem
function PortalSystem:new(tpPeripheral, bm, config)
    local tp = peripheral.wrap(tpPeripheral)
    if not tp then error("Teleporter not found: " .. tpPeripheral) end

    local instance = setmetatable({
        tp = tp,
        bm = bm,
        config = config,
        frequencies = {},
        currentPage = 1,
        totalPages = 1,
        isEditMode = false,
        isBusy = false,
        lastColor = nil,
        portalColors = {},
        playerNames = {},
        lastError = nil,
        activeOverlay = nil,
        buffer = nil,
        manualActive = nil, -- Lock for portal frequency synchronization
        monName = peripheral.getName(bm.mon.native or bm.mon), -- Store name safely
        tpName = tpPeripheral, -- Store name safely

        mekColors = {
            "WHITE", "YELLOW", "ORANGE", "RED", "PINK", "BRIGHT_PINK", "PURPLE", "INDIGO",
            "DARK_BLUE", "DARK_AQUA", "AQUA", "DARK_GREEN", "BRIGHT_GREEN", "BROWN", "GRAY", "DARK_GRAY", "BLACK"
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
            BLACK = colors.black
        }
    }, PortalSystem)

    instance:loadConfig() -- Load config from file
    instance:loadColors()
    instance:loadCache()
    return instance
end

--- Load configuration from JSON file
function PortalSystem:loadConfig()
    if fs.exists("config.json") then
        local f = fs.open("config.json", "r")
        local data = f.readAll()
        f.close()
        self.config = textutils.unserialiseJSON(data) or self.config
    end
end

--- Save configuration to JSON file
function PortalSystem:saveConfig()
    local f = fs.open("config.json", "w")
    f.write(textutils.serialiseJSON(self.config))
    f.close()
end

--- Draws the terminal status screen
function PortalSystem:drawTerminalHeader()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.cyan)
    print("Mekanism Portal Dialer v2.0")
    term.setTextColor(colors.gray)
    print("---------------------------")
    term.setTextColor(colors.white)
    print("Monitor:    " .. (self.monName or "Unknown"))
    print("Teleporter: " .. (self.tpName or "Unknown"))
    print("\n[Press 'C' on Computer for Configuration]")
    
    if self.config.testModeCount and self.config.testModeCount > 0 then
        term.setTextColor(colors.yellow)
        print("TEST MODE ACTIVE: " .. self.config.testModeCount .. " dummy buttons")
        term.setTextColor(colors.white)
    end
    print("\nSystem ready. Monitoring events...")
end

--- Interactive terminal configuration menu
function PortalSystem:configMenu()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.cyan)
        print("=== Portal Hub Configuration ===")
        term.setTextColor(colors.white)
        print("1. Recall Channel    (Current: " .. (self.config.recallChannel or 99) .. ")")
        print("2. Test Mode Count   (Current: " .. (self.config.testModeCount or 0) .. ")")
        print("3. Save & Exit")
        print("4. Exit without saving")
        print("\nPress key [1-4] to select.")

        local _, key = os.pullEvent("key")
        if key == keys.one then
            term.setCursorPos(1, 8)
            term.clearLine()
            term.setTextColor(colors.yellow)
            write("New Recall Channel (Default 99): ")
            term.setTextColor(colors.white)
            os.sleep(0.1)
            local input = read()
            if input ~= "" then
                self.config.recallChannel = tonumber(input) or self.config.recallChannel
            end
        elseif key == keys.two then
            term.setCursorPos(1, 8)
            term.clearLine()
            term.setTextColor(colors.yellow)
            write("New Test Mode Count (0 to disable): ")
            term.setTextColor(colors.white)
            os.sleep(0.1)
            local input = read()
            if input ~= "" then
                self.config.testModeCount = tonumber(input) or self.config.testModeCount
            end
        elseif key == keys.three then
            self:saveConfig()
            term.setTextColor(colors.green)
            print("\nSettings saved successfully!")
            os.sleep(1)
            self:drawTerminalHeader() -- Restore terminal
            self:draw()
            return
        elseif key == keys.four then
            self:loadConfig() -- Revert changes
            self:drawTerminalHeader() -- Restore terminal
            self:draw()
            return 
        end
    end
end

--- Loads fixed portal colors from file
function PortalSystem:loadColors()
    if fs.exists("portal_colors.json") then
        local f = fs.open("portal_colors.json", "r")
        local data = f.readAll()
        f.close()
        self.portalColors = textutils.unserialiseJSON(data) or {}
    end
end

--- Saves fixed portal colors to file
function PortalSystem:saveColors()
    local f = fs.open("portal_colors.json", "w")
    f.write(textutils.serialiseJSON(self.portalColors))
    f.close()
end

--- Picks the next color for a portal
function PortalSystem:getNextColor(portalName)
    local fixed = self.portalColors[portalName]
    if fixed then return fixed end

    -- Random logic: pick a color different from the last one
    local color = self.mekColors[math.random(1, #self.mekColors)]
    while color == self.lastColor do
        color = self.mekColors[math.random(1, #self.mekColors)]
    end
    return color
end

--- Refreshes the list of frequencies from the teleporter (or generates test data)
function PortalSystem:refresh()
    -- Check for Test Mode
    if self.config.testModeCount and self.config.testModeCount > 0 then
        self.frequencies = {}
        for i = 1, self.config.testModeCount do
            table.insert(self.frequencies, { key = "Test Portal " .. i, public = true })
        end
    else
        -- Normal Mode: Sync active portal (Only if not manually pinned)
        local ok, f = pcall(self.tp.getFrequency)
        if ok and f and f.key then
            if not self.manualActive then
                self.bm:setActive(f.key)
            end
        end
        -- Normal Mode: Fetch from Teleporter
        local ok, list = pcall(self.tp.getFrequencies)
        if not ok or not list then
            self.frequencies = {}
        else
            self.frequencies = list
            table.sort(self.frequencies, function(a, b) return a.key < b.key end)
        end
    end

    local max = self.config.maxButtons or 24
    self.totalPages = math.ceil(#self.frequencies / max)
    if self.totalPages < 1 then self.totalPages = 1 end
end

--- Draws the static frame and layout elements
function PortalSystem:draw()
    self:refresh()
    self.bm:resetButtons()

    local w, h = self.bm.mon.getSize()
    -- Permanently initialize buffer for flicker-free rendering
    if not self.buffer then
        self.buffer = window.create(self.bm.mon, 1, 1, w, h, false)
        self.bm.mon = self.buffer -- Redirect ButtonManager to the buffer
    end

    -- Prepare hidden frame
    self.buffer.setVisible(false)
    self.buffer.setBackgroundColor(colors.black)
    self.buffer.clear()

    -- Main Outer Tech Frame (Orange in Edit Mode)
    local frameColor = self.isEditMode and colors.orange or colors.cyan
    self.bm:drawFineBox(1, 1, w, h, frameColor)

    -- Header Section
    self.bm.mon.setTextColor(colors.white)
    local title = self.isEditMode and " EDIT MODE ACTIVE " or " MEKANISM PORTAL NETWORK "
    self.bm.mon.setCursorPos(math.floor((w - #title) / 2) + 1, 2)
    self.bm.mon.write(title)
    self.bm:drawHorizontalLine(2, w - 1, 3, frameColor)
    self.bm.mon.setCursorPos(1, 3); self.bm.mon.write(string.char(157))

    -- Edit Mode Toggle Button (¤ Symbol)
    local editSymbol = string.char(164)
    local editX = w - 2
    self.bm:add("TOGGLE_EDIT", function()
        self.isEditMode = not self.isEditMode
        self:draw()
        os.sleep(0.5) -- Cooldown to prevent accidental double-clicks
    end, editX - 1, w, 1, 3, true)

    self.bm.mon.setCursorPos(editX, 2)
    self.bm.mon.setTextColor(self.isEditMode and colors.orange or colors.white)
    self.bm.mon.write(editSymbol)

    -- Status Display Card (Always part of the dashboard)
    self:drawStatus()

    -- Navigation Area Separator (Matches frame color)
    self.bm.mon.setBackgroundColor(colors.black)
    self.bm:drawHorizontalLine(2, w - 1, h - 4, frameColor)
    self.bm.mon.setCursorPos(1, h - 4); self.bm.mon.write(string.char(157)) -- Left connection bridge

    -- Permanent Navigation Buttons (3 rows high for consistent feel)
    local navY = h - 3

    if self.currentPage > 1 then
        self.bm:drawButtonBox(3, navY, 15, h - 1, colors.gray)
        self.bm:add("PREV", function()
            self.bm:setFlash("PREV")
            os.sleep(0.1)
            self.bm.flashKey = nil -- Clear flash
            self.currentPage = self.currentPage - 1
            self:draw()
        end, 4, 14, navY + 1, navY + 1)
    end

    -- Refresh Button (Centered)
    local mid = math.floor(w / 2)
    self.bm:drawButtonBox(mid - 7, navY, mid + 7, h - 1, colors.gray)
    self.bm:add("REFRESH", function()
        self.bm:setFlash("REFRESH")
        os.sleep(0.1)
        self.bm.flashKey = nil -- Clear flash
        self:draw()
    end, mid - 6, mid + 6, navY + 1, navY + 1)

    if self.currentPage < self.totalPages then
        self.bm:drawButtonBox(w - 14, navY, w - 2, h - 1, colors.gray)
        self.bm:add("NEXT", function()
            self.bm:setFlash("NEXT")
            os.sleep(0.1)
            self.bm.flashKey = nil -- Clear flash
            self.currentPage = self.currentPage + 1
            self:draw()
        end, w - 13, w - 3, navY + 1, navY + 1)
    end

    -- 3. Content Grid
    self:drawContent()

    -- 4. FINAL STEP: Always draw the overlay LAST for correct Z-index
    if self.activeOverlay then
        self:drawColorOverlay(self.activeOverlay.name, self.activeOverlay.x, self.activeOverlay.y, true)
    end

    -- Flush buffer to monitor
    self.buffer.setVisible(true)
end

--- Draws the dynamic portal list (partial refresh area)
function PortalSystem:drawContent()
    local w, h = self.bm.mon.getSize()

    -- Grid Section
    local cols = self.config.gridColumns or 4
    local rows = self.config.gridRows or 6
    local startX = 3
    local endX = w - 2
    local totalWidth = endX - startX + 1
    local gapX = 2

    -- Calculate button width and the total width the grid will actually take
    local buttonWidth = math.floor((totalWidth - (cols - 1) * gapX) / cols)
    local gridWidth = (cols * buttonWidth) + ((cols - 1) * gapX)

    -- Calculate centering offset
    local offset = math.floor((totalWidth - gridWidth) / 2)
    startX = startX + offset

    local buttonHeight = 5
    local spacingY = 6

    local max = cols * rows
    local start = (self.currentPage - 1) * max + 1
    local finish = math.min(start + max - 1, #self.frequencies)

    -- 1. Register buttons and draw their backgrounds
    for i = start, finish do
        local rel = i - start
        local col = rel % cols
        local row = math.floor(rel / cols)
        local x = startX + col * (buttonWidth + gapX)
        local y = 10 + row * spacingY
        local f = self.frequencies[i]

        -- Frame color (Orange in Edit Mode)
        local bColor = self.isEditMode and colors.orange or colors.gray
        self.bm:drawButtonBox(x, y, x + buttonWidth - 1, y + 4, bColor)

        -- Determine background color (Normal vs Selected)
        local isSelected = (self.bm.activeKey == f.key or self.bm.flashKey == f.key)
        local bgColor = isSelected and self.bm.colorOn or colors.gray

        -- FILL the button background manually
        self.bm:drawBox(x + 1, y + 1, x + buttonWidth - 2, y + 3, bgColor)

        -- Register click zone (noLabel = true so we control the text rendering)
        self.bm:add(f.key, function()
            if self.isEditMode then
                os.sleep(0.2) -- Debounce to prevent click-through
                self:drawColorOverlay(f.key)
            else
                self:dial(f.key)
            end
        end, x + 1, x + buttonWidth - 2, y + 1, y + 3, true)

        -- Draw label and indicator ON TOP of our manual fill
        local textX = x + math.floor((buttonWidth - #f.key) / 2)
        local fixedCol = self.portalColors[f.key]

        self.bm.mon.setBackgroundColor(bgColor)

        -- Color Indicator (Only in Edit Mode)
        if fixedCol and self.isEditMode then
            self.bm.mon.setCursorPos(textX - 2, y + 2)
            self.bm.mon.setBackgroundColor(self.ccMap[fixedCol] or colors.white)
            self.bm.mon.setTextColor(self.ccMap[fixedCol] or colors.white)
            self.bm.mon.write(string.char(149))
        end

        self.bm.mon.setBackgroundColor(bgColor)
        self.bm.mon.setTextColor(colors.white)
        self.bm.mon.setCursorPos(textX, y + 2)
        self.bm.mon.write(f.key)
    end

    -- 2. Finalize UI drawing
    self.bm:draw() -- Draw utility buttons (Nav/Edit)
end

--- Dials a portal and applies the chosen color
function PortalSystem:dial(portalName)
    local color = self:getNextColor(portalName)

    -- 1. Immediate visual feedback (buffered)
    self.manualActive = portalName 
    self.bm:setActive(portalName)
    self:drawContent() 
    self:drawStatus()
    self.buffer.setVisible(true)
    
    -- 2. Apply frequency to teleporter
    if not (self.config.testModeCount and self.config.testModeCount > 0) then
        self.tp.setFrequency(portalName)
        os.sleep(0.3) -- Give the hardware some time
        pcall(self.tp.setFrequencyColor, color)
    else
        self.testSelectedFrequency = portalName
    end

    -- 3. Final redraw and release lock
    self:draw()
    os.sleep(0.2)
    self.manualActive = nil 
end

--- Draws a color selection overlay for a specific portal
function PortalSystem:drawColorOverlay(portalName, offsetX, offsetY, isRedraw)
    local w, h = self.bm.mon.getSize()
    local boxW, boxH = 38, 25

    -- Store overlay state for persistent rendering
    if not isRedraw then
        self.activeOverlay = { name = portalName, x = offsetX, y = offsetY }
    end

    -- Default to center if no offset provided
    offsetX = offsetX or math.floor((w - boxW) / 2)
    offsetY = offsetY or math.floor((h - boxH) / 2)

    -- Clamp offsets to screen
    local x1 = math.max(2, math.min(offsetX, w - boxW - 1))
    local y1 = math.max(2, math.min(offsetY, h - boxH - 1))
    local x2, y2 = x1 + boxW, y1 + boxH

    self.bm:resetButtons() -- Clear background buttons

    -- 0. Background Shield
    self.bm:add("OVERLAY_SHIELD", function() end, 1, w, 1, h, true)

    -- 1. Dim the background
    -- 2. Draw Window Frame
    self:drawOverlayFrame(x1, y1, x2, y2)

    -- Title Bar (Click to move)
    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setBackgroundColor(colors.gray)
    local title = "COLOR: " .. portalName
    local titleX = x1 + math.floor((boxW - #title) / 2)
    self.bm.mon.setCursorPos(titleX, y1 + 1)
    self.bm.mon.write(title)

    self.bm:add("MOVE_OVERLAY", function()
        -- Cycle through positions (Center -> Left -> Right)
        local nextX = x1
        if x1 == math.floor((w - boxW) / 2) then
            nextX = 3
        elseif x1 == 3 then
            nextX = w - boxW - 3
        else
            nextX = math.floor((w - boxW) / 2)
        end
        self.activeOverlay = { name = portalName, x = nextX, y = y1 }
        self:draw()
    end, x1 + 1, x2 - 1, y1 + 1, y1 + 1, true)

    -- Color Grid (4x4) with 1px spacing
    for i, colorName in ipairs(self.mekColors) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local bx = x1 + 4 + col * 8 -- Compact step
        local by = y1 + 3 + row * 4 -- Compact step

        -- Draw the custom frame
        self:drawColorSwatchFrame(bx, by, bx + 5, by + 1)

        -- Draw the actual color swatch
        self.bm:drawBox(bx, by, bx + 5, by + 1, self.ccMap[colorName])

        self.bm:add("SET_COL_" .. colorName, function()
            self.portalColors[portalName] = colorName
            self:saveColors()
            self.activeOverlay = nil -- Close window
            os.sleep(0.1)
            self:draw()
        end, bx, bx + 5, by, by + 1, true)
    end

    -- 4. Utility Buttons (Random / Back)
    local buttonY = y1 + boxH - 3

    -- RANDOM
    self:drawRandomButtonFrame(x1 + 3, buttonY)
    self.bm:add("RESET_BTN", function()
        self.portalColors[portalName] = nil
        self:saveColors()
        self.activeOverlay = nil -- Close window
        os.sleep(0.1)
        self:draw()
    end, x1 + 4, x1 + 13, buttonY, buttonY + 1, true)
    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setCursorPos(x1 + 5, buttonY + 1); self.bm.mon.write(" RANDOM ")

    -- BACK (Closes the window)
    self:drawBackButtonFrame(x2 - 13, buttonY)
    self.bm:add("BACK_BTN", function()
        self.activeOverlay = nil -- Clear overlay from memory
        self:draw()
    end, x2 - 12, x2 - 4, buttonY, buttonY + 1, true)
    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setCursorPos(x2 - 10, buttonY + 1); self.bm.mon.write(" BACK ")

    self.bm:draw()
end

--- CUSTOMIZABLE WINDOW DESIGN
--- Change this function to modify the look of the color selection window
function PortalSystem:drawOverlayFrame(x1, y1, x2, y2)
    -- 1. Fill background solidly
    for i = y1, y2 do
        self.bm.mon.setCursorPos(x1, i)
        self.bm.mon.setBackgroundColor(colors.gray)
        self.bm.mon.write(string.rep(" ", x2 - x1 + 1))
    end

    -- 2. Draw Fancy Border
    local frameFG = colors.white
    local frameBG = colors.gray

    local char_TL, char_TR = 151, 148
    local char_BL, char_BR = 138, 133
    local char_HO, char_HU = 131, 143
    local char_V = 149

    self.bm.mon.setTextColor(frameFG)
    self.bm.mon.setBackgroundColor(frameBG)

    -- Ecken
    self.bm.mon.setCursorPos(x1, y1); self.bm.mon.write(string.char(char_TL))
    self.bm.mon.setTextColor(frameBG)
    self.bm.mon.setBackgroundColor(frameFG)
    self.bm.mon.setCursorPos(x2, y1); self.bm.mon.write(string.char(char_TR))
    self.bm.mon.setCursorPos(x1, y2); self.bm.mon.write(string.char(char_BL))
    self.bm.mon.setCursorPos(x2, y2); self.bm.mon.write(string.char(char_BR))

    -- Horizontale Linien
    for i = x1 + 1, x2 - 1 do
        self.bm.mon.setTextColor(frameFG)
        self.bm.mon.setBackgroundColor(frameBG)
        self.bm.mon.setCursorPos(i, y1); self.bm.mon.write(string.char(char_HO))
        self.bm.mon.setTextColor(frameBG)
        self.bm.mon.setBackgroundColor(frameFG)
        self.bm.mon.setCursorPos(i, y2); self.bm.mon.write(string.char(char_HU))
    end

    -- Vertikale Linien
    for i = y1 + 1, y2 - 1 do
        self.bm.mon.setTextColor(frameFG)
        self.bm.mon.setBackgroundColor(frameBG)
        self.bm.mon.setCursorPos(x1, i); self.bm.mon.write(string.char(char_V))
        self.bm.mon.setTextColor(frameBG)
        self.bm.mon.setBackgroundColor(frameFG)
        self.bm.mon.setCursorPos(x2, i); self.bm.mon.write(string.char(char_V))
    end
end

--- CUSTOMIZABLE COLOR SWATCH DESIGN
--- Change this function to modify the frame around each color choice
function PortalSystem:drawColorSwatchFrame(x1, y1, x2, y2)
    -- 🎨 FARBEN
    local frameFG = colors.lightGray -- Farbe der kleinen Umrandung
    local frameBG = colors.gray      -- Hintergrund der Umrandung

    -- 📐 ZEICHEN (Character Codes)
    local char_TL = 159 -- Ecke Oben-Links
    local char_TR = 144 -- Ecke Oben-Rechts
    local char_BL = 130 -- Ecke Unten-Links
    local char_BR = 129 -- Ecke Unten-Rechts
    local char_HO = 143 -- Horizontale Linie
    local char_HU = 131 -- Horizontale Linie
    local char_V  = 149 -- Vertikale Linie

    self.bm.mon.setTextColor(frameBG)
    self.bm.mon.setBackgroundColor(frameFG)

    -- Ecken (TL, TR, BL, BR)
    self.bm.mon.setCursorPos(x1 - 1, y1 - 1); self.bm.mon.write(string.char(char_TL))
    self.bm.mon.setTextColor(frameFG)
    self.bm.mon.setBackgroundColor(frameBG)
    self.bm.mon.setCursorPos(x2 + 1, y1 - 1); self.bm.mon.write(string.char(char_TR))
    self.bm.mon.setCursorPos(x1 - 1, y2 + 1); self.bm.mon.write(string.char(char_BL))
    self.bm.mon.setCursorPos(x2 + 1, y2 + 1); self.bm.mon.write(string.char(char_BR))

    -- Horizontale Linien (Oben/Unten)
    for i = x1, x2 do
        self.bm.mon.setTextColor(frameBG)
        self.bm.mon.setBackgroundColor(frameFG)
        self.bm.mon.setCursorPos(i, y1 - 1); self.bm.mon.write(string.char(char_HO))
        self.bm.mon.setTextColor(frameFG)
        self.bm.mon.setBackgroundColor(frameBG)
        self.bm.mon.setCursorPos(i, y2 + 1); self.bm.mon.write(string.char(char_HU))
    end

    -- Vertikale Linien (Links/Rechts)
    for i = y1, y2 do
        self.bm.mon.setTextColor(frameBG)
        self.bm.mon.setBackgroundColor(frameFG)
        self.bm.mon.setCursorPos(x1 - 1, i); self.bm.mon.write(string.char(char_V))
        self.bm.mon.setTextColor(frameFG)
        self.bm.mon.setBackgroundColor(frameBG)
        self.bm.mon.setCursorPos(x2 + 1, i); self.bm.mon.write(string.char(char_V))
    end
end

--- DESIGN FOR RANDOM BUTTON
function PortalSystem:drawRandomButtonFrame(x1, y1, x2, y2)
    x2 = x2 or x1 + 10 -- Default width for RANDOM
    y2 = y2 or y1 + 2  -- Default height
    local frameColor = colors.black
    local buttonBG = colors.gray
    local char_TL, char_TR = 159, 144
    local char_BL, char_BR = 130, 129
    local char_H = 140

    self.bm.mon.setBackgroundColor(buttonBG)
    for y = y1, y2 do
        self.bm.mon.setCursorPos(x1, y); self.bm.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    self.bm.mon.setTextColor(buttonBG)
    self.bm.mon.setBackgroundColor(frameColor)
    self.bm.mon.setCursorPos(x1, y1); self.bm.mon.write(string.char(char_TL))
    self.bm.mon.setTextColor(frameColor)
    self.bm.mon.setBackgroundColor(buttonBG)
    self.bm.mon.setCursorPos(x2, y1); self.bm.mon.write(string.char(char_TR))
    self.bm.mon.setCursorPos(x1, y2); self.bm.mon.write(string.char(char_BL))
    self.bm.mon.setCursorPos(x2, y2); self.bm.mon.write(string.char(char_BR))
    for i = x1 + 1, x2 - 1 do
        self.bm.mon.setCursorPos(i, y1); self.bm.mon.write(string.char(char_H))
        self.bm.mon.setCursorPos(i, y2); self.bm.mon.write(string.char(char_H))
    end
end

--- DESIGN FOR BACK BUTTON
function PortalSystem:drawBackButtonFrame(x1, y1, x2, y2)
    x2 = x2 or x1 + 10 -- Default width for BACK
    y2 = y2 or y1 + 2  -- Default height
    local frameColor = colors.black
    local buttonBG = colors.gray
    local char_TL, char_TR = 159, 144
    local char_BL, char_BR = 130, 129
    local char_H = 140

    self.bm.mon.setBackgroundColor(buttonBG)
    for y = y1, y2 do
        self.bm.mon.setCursorPos(x1, y); self.bm.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    self.bm.mon.setTextColor(buttonBG)
    self.bm.mon.setBackgroundColor(frameColor)
    self.bm.mon.setCursorPos(x1, y1); self.bm.mon.write(string.char(char_TL))
    self.bm.mon.setTextColor(frameColor)
    self.bm.mon.setBackgroundColor(buttonBG)
    self.bm.mon.setCursorPos(x2, y1); self.bm.mon.write(string.char(char_TR))
    self.bm.mon.setCursorPos(x1, y2); self.bm.mon.write(string.char(char_BL))
    self.bm.mon.setCursorPos(x2, y2); self.bm.mon.write(string.char(char_BR))
    for i = x1 + 1, x2 - 1 do
        self.bm.mon.setCursorPos(i, y1); self.bm.mon.write(string.char(char_H))
        self.bm.mon.setCursorPos(i, y2); self.bm.mon.write(string.char(char_H))
    end
end

--- Updates the status display text (Opaque and targeted)
---@param force boolean|nil If true, bypasses overlay blocking
function PortalSystem:updateStatus(force)
    -- Block background updates if an overlay is active (unless forced)
    if self.activeOverlay and not force then return end

    local name = "NOT CONNECTED"
    local owner = ""
    local statusStr = "Ready"

    -- Check for Test Mode
    if self.config.testModeCount and self.config.testModeCount > 0 then
        name = self.testSelectedFrequency or "NONE"
        owner = "DevUser"
        statusStr = "TEST-MODE"
    else
        -- Normal Mode: Real Teleporter Data
        local ok, f = pcall(self.tp.getFrequency)
        local s = self.tp.getStatus()
        if ok and f and f.key then
            name = f.key
            -- Try mapping the UUID to a real name
            local rawOwner = f.owner or "Unknown"
            owner = self:resolveUUID(rawOwner)
        end
        statusStr = s:sub(1, 1):upper() .. s:sub(2)
    end

    -- Sync ButtonManager state (Only if not manually pinned)
    if name ~= "NOT CONNECTED" and name ~= "NONE" and not self.manualActive then
        self.bm.activeKey = name
    end

    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setBackgroundColor(colors.black)

    -- Overwrite with fixed width to prevent text residue
    local targetText = name .. (owner ~= "" and " (" .. owner .. ")" or "")
    self.bm.mon.setCursorPos(5, 6)
    self.bm.mon.write(string.format("TARGET: %-50s", targetText))
    self.bm.mon.setCursorPos(5, 7)
    local displayStatus = self.lastError or statusStr
    self.bm.mon.write(string.format("SYSTEM: %-50s", displayStatus))

    -- REDRAW GRID: Ensure selected portal turns green
    -- Only redraw if overlay is NOT open (to prevent overlay flickering)
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

    if self.buffer then self.buffer.setVisible(true) end
end

--- AUTOMATIC UUID RESOLVER (Mojang API)
function PortalSystem:resolveUUID(uuid)
    -- 1. Check local cache first
    if self.playerNames[uuid] then return self.playerNames[uuid] end

    -- 2. Skip "Unknown" or invalid
    if not uuid or uuid == "Unknown" or #uuid < 20 then return uuid end

    -- 3. Check if HTTP is available
    if not http then return uuid end

    -- 4. Clean UUID (Remove dashes for Mojang API)
    local cleanUUID = uuid:gsub("-", "")
    local url = "https://sessionserver.mojang.com/session/minecraft/profile/" .. cleanUUID

    -- 5. Async request to Mojang
    local ok, response = pcall(http.get, url)
    if ok and response then
        local code = response.getResponseCode()
        local data = response.readAll()
        response.close()

        if code == 200 and data and #data > 0 then
            local decoded = textutils.unserialiseJSON(data)
            if decoded and decoded.name then
                self.playerNames[uuid] = decoded.name
                self:saveCache() -- Persist name to cache file
                return decoded.name
            end
        elseif code == 429 then
            return "Rate Limited"
        end
    end

    return uuid -- Fallback if anything fails
end

--- PERSISTENT CACHE METHODS
function PortalSystem:saveCache()
    local f = fs.open("portal_owners.json", "w")
    if f then
        f.write(textutils.serialiseJSON(self.playerNames))
        f.close()
    end
end

function PortalSystem:loadCache()
    if fs.exists("portal_owners.json") then
        local f = fs.open("portal_owners.json", "r")
        if f then
            local data = f.readAll()
            f.close()
            local decoded = textutils.unserialiseJSON(data)
            if decoded then self.playerNames = decoded end
        end
    end
end

--- Draws ONLY the status area to prevent full-screen flashing
function PortalSystem:drawStatus()
    local w, h = self.bm.mon.getSize()
    self.bm:drawFineBox(3, 5, w - 2, 8, colors.lightGray)
    self:updateStatus(true) -- Force draw even if overlay is open
end

--- Main runtime loop
function PortalSystem:run()
    -- Initialize Communication (Dual Fallback)
    local modem = peripheral.find("modem")
    if modem then
        modem.open(self.config.recallChannel or 99)
        if not rednet.isOpen() then
            local side = peripheral.getName(modem)
            rednet.open(side)
        end
    end

    self:drawTerminalHeader()
    self:draw()
    while true do
        local event, side, x, y, message, dist = os.pullEvent()

        -- 1. Handle Touch Events
        if event == "monitor_touch" then
            if not self.isBusy then
                self.isBusy = true
                self.bm:checkClick(x, y)
                self:updateStatus()
                
                -- Flush event queue to prevent accidental multi-clicks during transitions
                local flushTimer = os.startTimer(0.5) 
                while true do
                    local ev = { os.pullEvent() }
                    if ev[1] == "timer" and ev[2] == flushTimer then break end
                end
                
                self.isBusy = false
            end

            -- 2. Handle Recall via Modem API (Channel 99)
        elseif event == "modem_message" and y == (self.config.recallChannel or 99) then
            if type(message) == "table" and message.command == "RECALL" then
                self.tp.setFrequency(message.target)
                self.bm:setActive(message.target)
                self:updateStatus()
            end

            -- 3. Handle Recall via Rednet
        elseif event == "rednet_message" then
            if type(y) == "table" and y.command == "RECALL" then
                self.tp.setFrequency(y.target)
                self.bm:setActive(y.target)
                self:updateStatus()
            end

        elseif event == "key" and side == keys.c then
            self:configMenu()
        end
    end
end

return PortalSystem