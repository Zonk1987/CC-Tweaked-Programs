-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local peripheral = peripheral
local colors = colors
local setmetatable = setmetatable
local table_insert = table.insert
local math = math
local string = string
local ipairs = ipairs

---@class ButtonManager
---@field mon table Peripheral monitor object
---@field buttons table<string, table> Registered buttons
---@field colorOn number Color for active state
---@field colorOff number Color for inactive state
local ButtonManager = {}
ButtonManager.__index = ButtonManager

--- Creates a new ButtonManager instance
---@param monitorName string The name of the monitor peripheral
---@return ButtonManager
function ButtonManager.new(monitorName)
    local mon = peripheral.wrap(monitorName)
    if not mon then error("Monitor not found: " .. monitorName) end
    local self = setmetatable({
        mon = mon,
        buttons = {},
        colorOn = colors.lime,
        colorOff = colors.gray,
        activeKey = nil, -- Persistent selection
        flashKey = nil   -- Temporary highlight (for feedback)
    }, ButtonManager)
    return self
end

--- Registers a button to the manager (Newest buttons have priority)
---@param name string Unique name of the button
---@param func function Callback function when clicked
---@param xmin number Left boundary
---@param xmax number Right boundary
---@param ymin number Top boundary
---@param ymax number Bottom boundary
function ButtonManager:add(name, func, xmin, xmax, ymin, ymax, noLabel)
    local isActive = (name == self.activeKey)
    -- Insert at the beginning of the list for highest click priority
    table_insert(self.buttons, 1, {
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

--- Resets the button registry without clearing the monitor
function ButtonManager:resetButtons()
    self.buttons = {}
end

--- Clears the entire monitor and resets buttons
function ButtonManager:clear()
    self:resetButtons()
    self.mon.setBackgroundColor(colors.black)
    self.mon.clear()
end

--- Clears a specific area and removes buttons within it
---@param x1 number Left
---@param y1 number Top
---@param x2 number Right
---@param y2 number Bottom
function ButtonManager:clearArea(x1, y1, x2, y2)
    self.mon.setBackgroundColor(colors.black)
    for y = y1, y2 do
        self.mon.setCursorPos(x1, y)
        self.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    -- Filter out buttons in this area
    local newList = {}
    for _, btn in ipairs(self.buttons) do
        if not (btn.ymin >= y1 and btn.ymax <= y2) then
            table_insert(newList, btn)
        end
    end
    self.buttons = newList
end

--- Redraws all currently registered buttons (Draw in reverse for visual stacking)
function ButtonManager:draw()
    for i = #self.buttons, 1, -1 do
        local btn = self.buttons[i]
        local color = (btn.name == self.activeKey or btn.name == self.flashKey) and self.colorOn or self.colorOff
        if not btn.noLabel then
            self:fillRect(btn.name, color, btn)
        end
    end
end

--- Internal method to fill a button area with text
---@param text string The label
---@param color number The background color
---@param bData table The button boundaries
function ButtonManager:fillRect(text, color, bData)
    self.mon.setBackgroundColor(color)
    self.mon.setTextColor(colors.white)
    local yspot = math.floor((bData.ymin + bData.ymax) / 2)
    local xspot = math.floor((bData.xmax - bData.xmin - #text) / 2) + 1
    for j = bData.ymin, bData.ymax do
        self.mon.setCursorPos(bData.xmin, j)
        local line = string.rep(" ", bData.xmax - bData.xmin + 1)
        if j == yspot then
            line = string.rep(" ", xspot) .. text .. string.rep(" ", (bData.xmax - bData.xmin + 1) - #text - xspot)
        end
        self.mon.write(line)
    end
    self.mon.setBackgroundColor(colors.black)
end

--- Sets a button as active and redraws
---@param name string Name of the button to activate
function ButtonManager:setActive(name)
    self.activeKey = name
    self:draw()
end

--- Sets a temporary flash highlight and redraws
---@param name string Name of the button to flash
function ButtonManager:setFlash(name)
    self.flashKey = name
    self:draw()
end

--- Handles click events on the monitor
---@param x number X-coordinate of the click
---@param y number Y-coordinate of the click
---@return boolean Whether a button was triggered
function ButtonManager:checkClick(x, y)
    for _, btn in ipairs(self.buttons) do
        if x >= btn.xmin and x <= btn.xmax and y >= btn.ymin and y <= btn.ymax then
            btn.func()
            return true
        end
    end
    return false
end

--- Standard rectangular fill
function ButtonManager:drawBox(x1, y1, x2, y2, color)
    self.mon.setBackgroundColor(color)
    for y = y1, y2 do
        self.mon.setCursorPos(x1, y)
        self.mon.write(string.rep(" ", x2 - x1 + 1))
    end
    self.mon.setBackgroundColor(colors.black)
end

--- Draws a fine-line frame (optimised for main UI)
function ButtonManager:drawFineBox(x1, y1, x2, y2, color)
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

    -- Corners (Main Frame: Use standard corner characters)
    self.mon.setTextColor(color); self.mon.setBackgroundColor(colors.black)
    self.mon.setCursorPos(x1, y1); self.mon.write(string.char(156)) -- TL
    self.mon.setCursorPos(x2, y1); self.mon.write(string.char(148)) -- TR (Standard)
    self.mon.setCursorPos(x1, y2); self.mon.write(string.char(141)) -- BL
    self.mon.setCursorPos(x2, y2); self.mon.write(string.char(133)) -- BR (Standard)
end

--- Specialized frame for buttons with mirrored edge styling
function ButtonManager:drawButtonBox(x1, y1, x2, y2, color)
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

--- Draws a single horizontal fine line
function ButtonManager:drawHorizontalLine(x1, x2, y, color)
    self.mon.setTextColor(color)
    self.mon.setCursorPos(x1, y)
    self.mon.write(string.rep(string.char(140), x2 - x1 + 1))
end

return ButtonManager
