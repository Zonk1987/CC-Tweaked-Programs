-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local colors = colors
local string = string
local math = math

---@class Dashboard
local Dashboard = {}

--- Draws a fancy window frame for overlays
function Dashboard.drawOverlayFrame(bm, x1, y1, x2, y2)
    -- 1. Fill background solidly
    bm:drawBox(x1, y1, x2, y2, colors.gray)

    -- 2. Draw Fancy Border
    local frameFG = colors.white
    local frameBG = colors.gray

    local char_TL, char_TR = 151, 148
    local char_BL, char_BR = 138, 133
    local char_HO, char_HU = 131, 143
    local char_V = 149

    bm.mon.setTextColor(frameFG)
    bm.mon.setBackgroundColor(frameBG)

    -- Corners
    bm.mon.setCursorPos(x1, y1); bm.mon.write(string.char(char_TL))
    bm.mon.setTextColor(frameBG)
    bm.mon.setBackgroundColor(frameFG)
    bm.mon.setCursorPos(x2, y1); bm.mon.write(string.char(char_TR))
    bm.mon.setCursorPos(x1, y2); bm.mon.write(string.char(char_BL))
    bm.mon.setCursorPos(x2, y2); bm.mon.write(string.char(char_BR))

    -- Horizontal lines
    for i = x1 + 1, x2 - 1 do
        bm.mon.setTextColor(frameFG)
        bm.mon.setBackgroundColor(frameBG)
        bm.mon.setCursorPos(i, y1); bm.mon.write(string.char(char_HO))
        bm.mon.setTextColor(frameBG)
        bm.mon.setBackgroundColor(frameFG)
        bm.mon.setCursorPos(i, y2); bm.mon.write(string.char(char_HU))
    end

    -- Vertical lines
    for i = y1 + 1, y2 - 1 do
        bm.mon.setTextColor(frameFG)
        bm.mon.setBackgroundColor(frameBG)
        bm.mon.setCursorPos(x1, i); bm.mon.write(string.char(char_V))
        bm.mon.setTextColor(frameBG)
        bm.mon.setBackgroundColor(frameFG)
        bm.mon.setCursorPos(x2, i); bm.mon.write(string.char(char_V))
    end
end

--- Draws a specialized frame for color swatches
function Dashboard.drawColorSwatchFrame(bm, x1, y1, x2, y2)
    local frameFG = colors.lightGray
    local frameBG = colors.gray

    local char_TL, char_TR = 159, 144
    local char_BL, char_BR = 130, 129
    local char_HO, char_HU = 143, 131
    local char_V = 149

    bm.mon.setTextColor(frameBG)
    bm.mon.setBackgroundColor(frameFG)

    bm.mon.setCursorPos(x1 - 1, y1 - 1); bm.mon.write(string.char(char_TL))
    bm.mon.setTextColor(frameFG)
    bm.mon.setBackgroundColor(frameBG)
    bm.mon.setCursorPos(x2 + 1, y1 - 1); bm.mon.write(string.char(char_TR))
    bm.mon.setCursorPos(x1 - 1, y2 + 1); bm.mon.write(string.char(char_BL))
    bm.mon.setCursorPos(x2 + 1, y2 + 1); bm.mon.write(string.char(char_BR))

    for i = x1, x2 do
        bm.mon.setTextColor(frameBG)
        bm.mon.setBackgroundColor(frameFG)
        bm.mon.setCursorPos(i, y1 - 1); bm.mon.write(string.char(char_HO))
        bm.mon.setTextColor(frameFG)
        bm.mon.setBackgroundColor(frameBG)
        bm.mon.setCursorPos(i, y2 + 1); bm.mon.write(string.char(char_HU))
    end

    for i = y1, y2 do
        bm.mon.setTextColor(frameBG)
        bm.mon.setBackgroundColor(frameFG)
        bm.mon.setCursorPos(x1 - 1, i); bm.mon.write(string.char(char_V))
        bm.mon.setTextColor(frameFG)
        bm.mon.setBackgroundColor(frameBG)
        bm.mon.setCursorPos(x2 + 1, i); bm.mon.write(string.char(char_V))
    end
end

--- Draws a common button style frame (used for Back/Random)
function Dashboard.drawSmallButtonFrame(bm, x1, y1, x2, y2)
    local frameColor = colors.black
    local buttonBG = colors.gray
    local char_TL, char_TR = 159, 144
    local char_BL, char_BR = 130, 129
    local char_H = 140

    bm:drawBox(x1, y1, x2, y2, buttonBG)

    bm.mon.setTextColor(buttonBG)
    bm.mon.setBackgroundColor(frameColor)
    bm.mon.setCursorPos(x1, y1); bm.mon.write(string.char(char_TL))
    bm.mon.setTextColor(frameColor)
    bm.mon.setBackgroundColor(buttonBG)
    bm.mon.setCursorPos(x2, y1); bm.mon.write(string.char(char_TR))
    bm.mon.setCursorPos(x1, y2); bm.mon.write(string.char(char_BL))
    bm.mon.setCursorPos(x2, y2); bm.mon.write(string.char(char_BR))
    for i = x1 + 1, x2 - 1 do
        bm.mon.setCursorPos(i, y1); bm.mon.write(string.char(char_H))
        bm.mon.setCursorPos(i, y2); bm.mon.write(string.char(char_H))
    end
end

return Dashboard
