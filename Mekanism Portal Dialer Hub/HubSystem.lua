-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})
local UUIDService = require("UUIDService")
local Dashboard = require("Dashboard")
local ConfigStore = require("ConfigStore")
local PeripheralScanner = require("PeripheralScanner")
local RednetProtocol = require("RednetProtocol")
local ButtonGrid = require("ButtonGrid")

-- Localize globals
local peripheral = peripheral
local colors = colors
local fs = fs
local textutils = textutils
local term = term
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local os_startTimer = os.startTimer
local math = math
local table_insert = table.insert
local table_sort = table.sort
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local string = string
local window = window
local keys = keys
local rednet = rednet

---@class ConfigStore
---@field data table

---@class ButtonGrid
---@field mon table
---@field activeKey string|nil
---@field flashKey string|nil

---@class PortalConfig
---@field monitorSide string
---@field tpSide string
---@field textScale number
---@field gridColumns number
---@field gridRows number
---@field recallChannel number
---@field testModeCount number
---@field maxButtons number

---@class HubSystem
---@field tp table The teleporter peripheral
---@field bm ButtonGrid The button manager instance
---@field configStore ConfigStore System configuration
---@field frequencies table List of available frequencies
---@field currentPage number Currently displayed page
---@field totalPages number Total number of pages
---@field isEditMode boolean
---@field isBusy boolean
---@field lastColor string|nil
---@field portalColors table<string, string>
---@field uuidService UUIDService
---@field lastError string|nil
local HubSystem = {}
HubSystem.__index = HubSystem

--- Creates a new HubSystem instance
---@param options table
---@return HubSystem
function HubSystem.new(options)
    local tp = PeripheralScanner.wrap(options.tpSide)
    if not tp then error("Teleporter not found: " .. options.tpSide) end

    local self = setmetatable({
        tp = tp,
        bm = options.bm,
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
        monName = peripheral.getName(options.bm.mon.native or options.bm.mon),
        tpName = options.tpSide,

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
    }, HubSystem)

    RednetProtocol.openAuto()
    return self
end


--- Draws the static frame and layout elements
function HubSystem:drawTerminalHeader()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.cyan)
    print("Mekanism Portal Hub v2.2")
    term.setTextColor(colors.gray)
    print("---------------------------")
    term.setTextColor(colors.white)
    print("Monitor:    " .. (self.monName or "Unknown"))
    print("Teleporter: " .. (self.tpName or "Unknown"))
    print("\n[Press 'C' on Computer for Configuration]")

    if self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0 then
        term.setTextColor(colors.yellow)
        print("TEST MODE ACTIVE: " .. self.configStore.data.testModeCount .. " dummy buttons")
        term.setTextColor(colors.white)
    end
end

--- Interactive terminal configuration menu
function HubSystem:configMenu()
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
            local input = read()
            self.configStore.data.recallChannel = tonumber(input) or self.configStore.data.recallChannel
            os_sleep(0.5)
        elseif key == keys.two then
            term.setCursorPos(1, 8)
            write("New Test Mode Count: ")
            local input = read()
            self.configStore.data.testModeCount = tonumber(input) or self.configStore.data.testModeCount
            os_sleep(0.5)
        elseif key == keys.three then
            self.configStore:save()
            self:drawTerminalHeader()
            self:draw()
            return
        elseif key == keys.four then
            self.configStore:load()
            self:drawTerminalHeader()
            self:draw()
            return
        end
    end
end


--- Picks the next color for a portal
function HubSystem:getNextColor(portalName)
    local fixed = self.colorStore.data[portalName]
    if fixed then return fixed end

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
            table_sort(self.frequencies, function(a, b) return a.key < b.key end)
        end
    end

    local max = self.configStore.data.maxButtons or 24
    self.totalPages = math.ceil(#self.frequencies / max)
    if self.totalPages < 1 then self.totalPages = 1 end
end

--- Draws the static frame and layout elements
function HubSystem:draw()
    self:refresh()
    self.bm:resetButtons()

    local w, h = self.bm.mon.getSize()
    if not self.buffer then
        self.buffer = window.create(self.bm.mon, 1, 1, w, h, false)
        self.bm.mon = self.buffer
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
    self.bm.mon.setCursorPos(1, 3); self.bm.mon.write(string.char(157))

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
    self.bm.mon.setCursorPos(1, h - 4); self.bm.mon.write(string.char(157))

    local navY = h - 3
    if self.currentPage > 1 then
        local isPrevFlash = (self.bm.flashKey == "PREV")
        local prevCol = isPrevFlash and colors.lime or colors.gray
        self.bm:drawButtonBox(3, navY, 15, h - 1, prevCol)
        self.bm:add("PREV", function()
            self.bm:setFlash("PREV")
            self.currentPage = self.currentPage - 1
            self:draw()
        end, 4, 14, navY + 1, navY + 1)
        self.bm.mon.setTextColor(isPrevFlash and colors.black or colors.white)
        self.bm.mon.setBackgroundColor(isPrevFlash and colors.lime or colors.gray)
        self.bm.mon.setCursorPos(6, navY + 1); self.bm.mon.write(" PREV ")
    end

    local mid = math.floor(w / 2)
    local isRefreshFlash = (self.bm.flashKey == "REFRESH")
    local refreshCol = isRefreshFlash and colors.lime or colors.gray
    self.bm:drawButtonBox(mid - 7, navY, mid + 7, h - 1, refreshCol)
    self.bm:add("REFRESH", function()
        self.bm:setFlash("REFRESH")
        self:draw()
    end, mid - 6, mid + 6, navY + 1, navY + 1)
    self.bm.mon.setTextColor(isRefreshFlash and colors.black or colors.white)
    self.bm.mon.setBackgroundColor(isRefreshFlash and colors.lime or colors.gray)
    self.bm.mon.setCursorPos(mid - 4, navY + 1); self.bm.mon.write(" REFRESH ")

    if self.currentPage < self.totalPages then
        local isNextFlash = (self.bm.flashKey == "NEXT")
        local nextCol = isNextFlash and colors.lime or colors.gray
        self.bm:drawButtonBox(w - 14, navY, w - 2, h - 1, nextCol)
        self.bm:add("NEXT", function()
            self.bm:setFlash("NEXT")
            self.currentPage = self.currentPage + 1
            self:draw()
        end, w - 13, w - 3, navY + 1, navY + 1)
        self.bm.mon.setTextColor(isNextFlash and colors.black or colors.white)
        self.bm.mon.setBackgroundColor(isNextFlash and colors.lime or colors.gray)
        self.bm.mon.setCursorPos(w - 11, navY + 1); self.bm.mon.write(" NEXT ")
    end

    self:drawContent()
    if self.activeOverlay then
        self:drawColorOverlay(self.activeOverlay.name, self.activeOverlay.x, self.activeOverlay.y, true)
    end
    self.buffer.setVisible(true)
end

--- Draws the dynamic portal list
function HubSystem:drawContent()
    local w, h = self.bm.mon.getSize()
    local cols, rows = self.configStore.data.gridColumns or 4, self.configStore.data.gridRows or 4
    local startX, endX, gapX = 3, w - 2, 2
    local totalWidth = endX - startX + 1
    local buttonWidth = math.floor((totalWidth - (cols - 1) * gapX) / cols)
    local gridWidth = (cols * buttonWidth) + ((cols - 1) * gapX)
    startX = startX + math.floor((totalWidth - gridWidth) / 2)

    local buttonHeight, spacingY = 5, 6
    local max = cols * rows
    local start = (self.currentPage - 1) * max + 1
    local finish = math.min(start + max - 1, #self.frequencies)

    for i = start, finish do
        local rel = i - start
        local x = startX + (rel % cols) * (buttonWidth + gapX)
        local y = 10 + math.floor(rel / cols) * spacingY
        local f = self.frequencies[i]

        local bColor = self.isEditMode and colors.orange or colors.gray
        self.bm:drawButtonBox(x, y, x + buttonWidth - 1, y + 4, bColor)

        local isSelected = (self.bm.activeKey == f.key or self.bm.flashKey == f.key)
        local bgColor = isSelected and self.bm.colorOn or colors.gray
        self.bm:drawBox(x + 1, y + 1, x + buttonWidth - 2, y + 3, bgColor)

        self.bm:add(f.key, function()
            if self.isEditMode then
                os_sleep(0.2)
                self:drawColorOverlay(f.key)
            else
                self:dial(f.key)
            end
        end, x + 1, x + buttonWidth - 2, y + 1, y + 3, true)

        local textX = x + math.floor((buttonWidth - #f.key) / 2)
        local fixedCol = self.colorStore.data[f.key]
        self.bm.mon.setBackgroundColor(bgColor)
        if fixedCol and self.isEditMode then
            local pCol = self.ccMap[fixedCol] or colors.white
            self.bm.mon.setCursorPos(textX - 2, y + 2)
            self.bm.mon.setTextColor(pCol)
            self.bm.mon.setBackgroundColor(pCol)
            self.bm.mon.write(string.char(149))
            self.bm.mon.setBackgroundColor(bgColor)
        end
        self.bm.mon.setTextColor(colors.white)
        self.bm.mon.setCursorPos(textX, y + 2); self.bm.mon.write(f.key)
    end
    self.bm:draw()
end

--- Dials a portal
function HubSystem:dial(portalName)
    local color = self:getNextColor(portalName)
    self.manualActive = portalName
    self.bm:setActive(portalName)
    self:drawContent()
    self:drawStatus(true)
    self.buffer.setVisible(true)

    if not (self.configStore.data.testModeCount and self.configStore.data.testModeCount > 0) then
        self.tp.setFrequency(portalName)
        os_sleep(0.3)
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
    local boxW, boxH = 38, 25
    if not isRedraw then self.activeOverlay = { name = portalName, x = offsetX, y = offsetY } end
    offsetX = offsetX or math.floor((w - boxW) / 2)
    offsetY = offsetY or math.floor((h - boxH) / 2)
    local x1 = math.max(2, math.min(offsetX, w - boxW - 1))
    local y1 = math.max(2, math.min(offsetY, h - boxH - 1))
    local x2, y2 = x1 + boxW, y1 + boxH

    self.bm:resetButtons()
    self.bm:add("OVERLAY_SHIELD", function() end, 1, w, 1, h, true)
    Dashboard.drawOverlayFrame(self.bm, x1, y1, x2, y2)

    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setBackgroundColor(colors.gray)
    local title = "COLOR: " .. portalName
    self.bm.mon.setCursorPos(x1 + math.floor((boxW - #title) / 2), y1 + 1); self.bm.mon.write(title)

    for i, colorName in ipairs(self.mekColors) do
        local bx = x1 + 4 + ((i - 1) % 4) * 8
        local by = y1 + 3 + math.floor((i - 1) / 4) * 4
        Dashboard.drawColorSwatchFrame(self.bm, bx, by, bx + 5, by + 1)
        self.bm:drawBox(bx, by, bx + 5, by + 1, self.ccMap[colorName])
        self.bm:add("SET_COL_" .. colorName, function()
            self.colorStore.data[portalName] = colorName
            self.colorStore:save()
            self.activeOverlay = nil
            os_sleep(0.1); self:draw()
        end, bx, bx + 5, by, by + 1, true)
    end

    local buttonY = y1 + boxH - 3
    Dashboard.drawSmallButtonFrame(self.bm, x1 + 3, buttonY, x1 + 13, buttonY + 2)
    self.bm:add("RESET_BTN", function()
        self.colorStore.data[portalName] = nil; self.colorStore:save()
        self.activeOverlay = nil; os_sleep(0.1); self:draw()
    end, x1 + 4, x1 + 13, buttonY, buttonY + 1, true)
    self.bm.mon.setCursorPos(x1 + 5, buttonY + 1); self.bm.mon.write(" RANDOM ")

    Dashboard.drawSmallButtonFrame(self.bm, x2 - 13, buttonY, x2 - 3, buttonY + 2)
    self.bm:add("BACK_BTN", function()
        self.activeOverlay = nil; self:draw()
    end, x2 - 12, x2 - 4, buttonY, buttonY + 1, true)
    self.bm.mon.setCursorPos(x2 - 10, buttonY + 1); self.bm.mon.write(" BACK ")
    self.bm:draw()
end

--- Draws the status display (target frequency and system state)
---@param force? boolean If true, ignore overlay state
function HubSystem:drawStatus(force)
    if self.activeOverlay and not force then return end
    local name, owner, statusStr = "NOT CONNECTED", "", "Ready"
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


    -- Draw Frame around status
    local w, h = self.bm.mon.getSize()
    Dashboard.drawOverlayFrame(self.bm, 3, 5, w - 2, 8)

    self.bm.mon.setCursorPos(5, 6)
    self.bm.mon.setTextColor(colors.white)
    self.bm.mon.setBackgroundColor(colors.gray)
    self.bm.mon.write(string.format("TARGET: %-30s", name .. (owner ~= "" and " (" .. owner .. ")" or "")))
    self.bm.mon.setCursorPos(5, 7)
    self.bm.mon.write(string.format("SYSTEM: %-30s", self.lastError or statusStr))

    local isOverlayOpen = false
    for _, btn in ipairs(self.bm.buttons) do
        if btn.name == "OVERLAY_SHIELD" then
            isOverlayOpen = true
            break
        end
    end
    if not isOverlayOpen then self:drawContent() end
    if self.buffer then self.buffer.setVisible(true) end
end

--- Main runtime loop
function HubSystem:run()
    local side = RednetProtocol.openAuto()
    if side then
        peripheral.call(side, "open", self.configStore.data.recallChannel or 99)
    end
    self:drawTerminalHeader(); self:draw()
    while true do
        local ev, side, x, y, message = os_pullEvent()
        if ev == "monitor_touch" and not self.isBusy then
            self.isBusy = true; self.bm:checkClick(x, y); self:drawStatus()
            local t = os_startTimer(0.5)
            while true do
                local e = { os_pullEvent() }
                if e[1] == "timer" and e[2] == t then break end
            end
            self.bm.flashKey = nil
            self:draw()
            self.isBusy = false
        elseif ev == "modem_message" and y == (self.configStore.data.recallChannel or 99) then
            if type(message) == "table" and message.command == "RECALL" then
                self.tp.setFrequency(message.target); self.bm:setActive(message.target); self:drawStatus()
            end
        elseif ev == "rednet_message" and type(y) == "table" and y.command == "RECALL" then
            self.tp.setFrequency(y.target); self.bm:setActive(y.target); self:drawStatus()
        elseif ev == "key" and side == keys.c then
            self:configMenu()
        end
    end
end

return HubSystem
