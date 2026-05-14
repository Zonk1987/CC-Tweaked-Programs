--- @diagnostic disable: undefined-global
-- ButtonManager: Generic button and touch interaction for monitors
-- Governed by AGENTS.md

local ButtonManager = {}
ButtonManager.__index = ButtonManager

--- Creates a new ButtonManager instance
--- @param monitorName string The name of the monitor peripheral
--- @return ButtonManager
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
--- @param name string Unique name of the button
--- @param func function Callback function when clicked
--- @param xmin number Left boundary
--- @param xmax number Right boundary
--- @param ymin number Top boundary
--- @param ymax number Bottom boundary
--- @param noLabel boolean|nil If true, no label will be drawn
function ButtonManager:add(name, func, xmin, xmax, ymin, ymax, noLabel)
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
            table.insert(newList, btn)
        end
    end
    self.buttons = newList
end

--- Redraws all currently registered buttons
function ButtonManager:draw()
    -- Draw in reverse for visual stacking (older buttons below newer ones)
    for i = #self.buttons, 1, -1 do
        local btn = self.buttons[i]
        self:drawButton(btn)
    end
end

--- Internal helper to draw a single button
function ButtonManager:drawButton(btn)
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

--- Low-level box drawing helper
function ButtonManager:drawButtonBox(x1, y1, x2, y2, color)
    self.mon.setBackgroundColor(color)
    for y = y1, y2 do
        self.mon.setCursorPos(x1, y)
        self.mon.write(string.rep(" ", x2 - x1 + 1))
    end
end

--- Simple box filler without button logic
function ButtonManager:drawBox(x1, y1, x2, y2, color)
    self:drawButtonBox(x1, y1, x2, y2, color)
end

--- Flashes a button temporarily for feedback
--- @param key string The button name
--- @param duration number|nil
function ButtonManager:flash(key, duration)
    self.flashKey = key
    os.startTimer(duration or 0.2)
end

--- Handles touch events and dispatches callbacks
--- @param x number Touch X
--- @param y number Touch Y
--- @return boolean hit Whether a button was hit
function ButtonManager:checkClick(x, y)
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
function ButtonManager:setActive(key)
    self.activeKey = key
    for _, btn in ipairs(self.buttons) do
        btn.active = (btn.name == key)
    end
end

--- Alias for flash
function ButtonManager:setFlash(key, duration)
    self:flash(key, duration)
end

return ButtonManager
