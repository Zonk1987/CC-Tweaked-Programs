--- @diagnostic disable: undefined-global
-- ButtonGrid: Generic button and touch interaction for monitors
-- Governed by AGENTS.md

local ButtonGrid = {}
ButtonGrid.__index = ButtonGrid

---@class ButtonGrid
---@field mon table Peripheral monitor object
---@field buttons table<string, table> Registered buttons
---@field colorOn number Color for active state
---@field colorOff number Color for inactive state
---@field activeKey string|nil Persistent selection
---@field flashKey string|nil Temporary highlight

--- Creates a new ButtonGrid instance
--- @param monitorName string The name of the monitor peripheral
--- @return ButtonGrid
function ButtonGrid.new(monitorName)
    local mon = peripheral.wrap(monitorName)
    if not mon then error("Monitor not found: " .. monitorName) end
    local self = setmetatable({
        mon = mon,
        buttons = {},
        colorOn = colors.lime,
        colorOff = colors.gray,
        activeKey = nil, -- Persistent selection
        flashKey = nil   -- Temporary highlight (for feedback)
    }, ButtonGrid)
    return self
end

--- Registers a button to the manager (Newest buttons have priority)
--- @param name string Unique name of the button
--- @param func function Callback function when clicked
--- @param xmin number Left boundary
--- @param xmax number Right boundary
--- @param ymin number Top boundary
--- @param ymax number Bottom boundary
--- @param noLabel boolean|nil If true, no label will be drawn
function ButtonGrid:add(name, func, xmin, xmax, ymin, ymax, noLabel)
    local isActive = (name == self.activeKey)
    -- Insert at the beginning of the list for highest click priority
    table.insert(self.buttons, 1, {
        name = name,
        func = func,
        active = isActive,
        xmin = xmin,
        xmax = xmax,
        ymin = ymin,
        ymax = ymax,
        noLabel = noLabel
    })
end

--- Resets the button registry
function ButtonGrid:resetButtons()
    self.buttons = {}
end

--- Clears the entire monitor and resets buttons
function ButtonGrid:clear()
    self:resetButtons()
    self.mon.setBackgroundColor(colors.black)
    self.mon.clear()
end

--- Clears a specific area and removes buttons within it
function ButtonGrid:clearArea(x1, y1, x2, y2)
    self.mon.setBackgroundColor(colors.black)
    for y = y1, y2 do
        self.mon.setCursorPos(x1, y)
        self.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    -- Filter out buttons in this area
    local newList = {}
    for _, btn in ipairs(self.buttons) do
        if not (btn.ymin >= y1 and btn.ymax <= y2) then
            table.insert(newList, btn)
        end
    end
    self.buttons = newList
end

--- Redraws all currently registered buttons
function ButtonGrid:draw()
    -- Draw in reverse for visual stacking (older buttons below newer ones)
    for i = #self.buttons, 1, -1 do
        local btn = self.buttons[i]
        self:drawButton(btn)
    end
end

--- Internal helper to draw a single button
function ButtonGrid:drawButton(btn)
    local isFlash = (btn.name == self.flashKey)
    local bgColor = (btn.active or isFlash) and self.colorOn or self.colorOff
    local fgColor = (btn.active or isFlash) and colors.black or colors.white

    self:drawButtonBox(btn.xmin, btn.ymin, btn.xmax, btn.ymax, bgColor)

    if not btn.noLabel then
        self.mon.setTextColor(fgColor)
        self.mon.setBackgroundColor(bgColor)
        local label = btn.name
        local w = btn.xmax - btn.xmin + 1
        if #label > w then label = label:sub(1, w) end
        local x = btn.xmin + math.floor((w - #label) / 2)
        local y = btn.ymin + math.floor((btn.ymax - btn.ymin) / 2)
        self.mon.setCursorPos(x, y)
        self.mon.write(label)
    end
end

--- Specialized frame for buttons with mirrored edge styling
function ButtonGrid:drawButtonBox(x1, y1, x2, y2, color)
    -- Graphics chars
    local h, v = string.char(140), string.char(149)

    -- Horizontal
    local hLine = string.rep(h, x2 - x1 + 1)
    self.mon.setTextColor(color); self.mon.setBackgroundColor(colors.black)
    self.mon.setCursorPos(x1, y1); self.mon.write(hLine)
    self.mon.setCursorPos(x1, y2); self.mon.write(hLine)

    -- Vertical (Mirrored logic)
    for y = y1 + 1, y2 - 1 do
        self.mon.setTextColor(color); self.mon.setBackgroundColor(colors.black)
        self.mon.setCursorPos(x1, y); self.mon.write(v)
        self.mon.setTextColor(colors.black); self.mon.setBackgroundColor(color)
        self.mon.setCursorPos(x2, y); self.mon.write(v)
    end

    -- Corners (Button-specific bridge blocks)
    self.mon.setTextColor(color); self.mon.setBackgroundColor(colors.black)
    self.mon.setCursorPos(x1, y1); self.mon.write(string.char(156)) -- TL
    self.mon.setTextColor(colors.black); self.mon.setBackgroundColor(color)
    self.mon.setCursorPos(x2, y1); self.mon.write(string.char(147)) -- TR (Bridge)
    self.mon.setTextColor(color); self.mon.setBackgroundColor(colors.black)
    self.mon.setCursorPos(x1, y2); self.mon.write(string.char(141)) -- BL
    self.mon.setCursorPos(x2, y2); self.mon.write(string.char(142)) -- BR (Bridge Mirror)
end

--- Draws a solid filled box (area fill)
function ButtonGrid:drawBox(x1, y1, x2, y2, color)
    color = color or colors.black
    self.mon.setBackgroundColor(color)
    for y = y1, y2 do
        self.mon.setCursorPos(x1, y)
        self.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    self.mon.setBackgroundColor(colors.black)
end

--- Alias for drawBox
function ButtonGrid:drawFilledBox(x1, y1, x2, y2, color)
    self:drawBox(x1, y1, x2, y2, color)
end

--- Draws a single horizontal fine line
function ButtonGrid:drawHorizontalLine(x1, x2, y, color)
    self.mon.setTextColor(color)
    self.mon.setCursorPos(x1, y)
    self.mon.write(string.rep(string.char(140), x2 - x1 + 1))
end

--- Draws a fine-line frame
function ButtonGrid:drawFineBox(x1, y1, x2, y2, color)
    self.mon.setTextColor(color)
    self.mon.setBackgroundColor(colors.black)

    local h = string.char(140)
    local v = string.char(149)

    -- Lines
    local hLine = string.rep(h, x2 - x1 + 1)
    self.mon.setCursorPos(x1, y1); self.mon.write(hLine)
    self.mon.setCursorPos(x1, y2); self.mon.write(hLine)
    for y = y1 + 1, y2 - 1 do
        self.mon.setCursorPos(x1, y); self.mon.write(v)
        self.mon.setCursorPos(x2, y); self.mon.write(v)
    end

    -- Corners
    self.mon.setCursorPos(x1, y1); self.mon.write(string.char(156)) -- TL
    self.mon.setCursorPos(x2, y1); self.mon.write(string.char(148)) -- TR
    self.mon.setCursorPos(x1, y2); self.mon.write(string.char(141)) -- BL
    self.mon.setCursorPos(x2, y2); self.mon.write(string.char(133)) -- BR
end

--- Flashes a button temporarily for feedback
--- @param key string The button name
--- @param duration number|nil
function ButtonGrid:flash(key, duration)
    self.flashKey = key
    os.startTimer(duration or 0.2)
end

--- Alias for flash
function ButtonGrid:setFlash(key, duration)
    self:flash(key, duration)
end

--- Handles touch events and dispatches callbacks
--- @param x number Touch X
--- @param y number Touch Y
--- @return boolean hit Whether a button was hit
function ButtonGrid:checkClick(x, y)
    for _, btn in ipairs(self.buttons) do
        if x >= btn.xmin and x <= btn.xmax and y >= btn.ymin and y <= btn.ymax then
            if btn.func then
                btn.func()
                return true
            end
        end
    end
    return false
end

--- Sets a button as permanently active
--- @param key string|nil The button name, or nil to clear
function ButtonGrid:setActive(key)
    self.activeKey = key
    for _, btn in ipairs(self.buttons) do
        btn.active = (btn.name == key)
    end
end

return ButtonGrid
