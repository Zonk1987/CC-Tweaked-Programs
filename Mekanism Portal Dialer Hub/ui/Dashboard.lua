-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Localize globals
local colors = colors
local string = string

local FrameRenderer = require("FrameRenderer")

---@class Dashboard
---@field drawOverlayFrame fun(bm: table, x1: number, y1: number, x2: number, y2: number, swap: table|nil, chars: table|nil)
---@field drawColorSwatchFrame fun(bm: table, x1: number, y1: number, x2: number, y2: number, color: number, swap?: table, chars?: table, frameOuterColor?: number, frameInnerColor?: number)
---@field drawSmallButtonFrame fun(bm: table, x1: number, y1: number, x2: number, y2: number, chars?: table, swap?: table)
---@field drawAppFrame fun(bm: table, w: number, h: number, title: string, frameColor: number, swap: table|nil, chars: table|nil)
local Dashboard = {}

--- Centralized visual configurations for the Hub UI components
Dashboard.Theme = {
	overlay = {
		swap = { bottom = true, right = true },
		chars = { H_TOP = 131, H_BOT = 143 }
	},
	swatch = {
		swap = { right = true, BR = true, BL = true },
		chars = { TR = 147, TL = 156, BL = 141, BR = 142 },
		outerColor = colors.lightGray,
		innerColor = colors.gray
	},
	smallBtn = {
		swap = { TL = true, BL = true },
		chars = { TL = 152, TR = 144, BL = 137, H_TOP = 140, H_BOT = 140 }
	},
	portalBtn = {
		chars = {
			H_TOP = 140,
			H_BOT = 140,
			V_LEFT = 149,
			V_RIGHT = 149,
			TL = 156,
			TR = 147,
			BL = 141,
			BR = 142
		}
	}
}

--- Draws a fancy window frame for overlays.
--- Uses FrameRenderer for correct, consistent character rendering.
---
--- @param bm   table  ButtonGrid instance (bm.mon = monitor/terminal)
--- @param x1   number Left edge
--- @param y1   number Top edge
--- @param x2   number Right edge
--- @param y2   number Bottom edge
--- @param swap table|nil Optional overrides for edge swaps
--- @param chars table|nil Optional overrides for characters
function Dashboard.drawOverlayFrame(bm, x1, y1, x2, y2, swap, chars)
	swap = swap or Dashboard.Theme.overlay.swap
	chars = chars or Dashboard.Theme.overlay.chars

	-- 1. Fill background
	bm:drawBox(x1, y1, x2, y2, colors.gray)

	-- 2. Draw border (white outer edge on gray background)
	FrameRenderer.drawFrame(bm.mon, x1, y1, x2, y2, colors.white, colors.gray, swap, chars)
end

--- Draws a color swatch frame around a color preview box.
--- The frame is drawn one cell OUTSIDE the swatch bounds (x1-1, y1-1, x2+1, y2+1).
---
--- @param bm        table  ButtonGrid instance
--- @param x1        number Swatch left edge
--- @param y1        number Swatch top edge
--- @param x2        number Swatch right edge
--- @param y2        number Swatch bottom edge
--- @param color     number The swatch fill color (used to fill the inner area)
--- @param swap            table|nil Optional overrides for edge swaps
--- @param chars           table|nil Optional overrides for characters
--- @param frameOuterColor number|nil Optional outer border color
--- @param frameInnerColor number|nil Optional inner border color
function Dashboard.drawColorSwatchFrame(bm, x1, y1, x2, y2, color, swap, chars, frameOuterColor, frameInnerColor)
	swap = swap or Dashboard.Theme.swatch.swap
	chars = chars or Dashboard.Theme.swatch.chars
	local outCol = frameOuterColor or Dashboard.Theme.swatch.outerColor
	local inCol = frameInnerColor or Dashboard.Theme.swatch.innerColor

	-- Fill with the actual color first
	bm:drawBox(x1, y1, x2, y2, color)

	-- Draw frame one cell outside the swatch
	FrameRenderer.drawFrame(bm.mon, x1 - 1, y1 - 1, x2 + 1, y2 + 1, outCol, inCol, swap, chars)
end

--- Draws a small button-style frame (used for Back / Random buttons).
---
--- @param bm   table  ButtonGrid instance
--- @param x1   number Left edge
--- @param y1   number Top edge
--- @param x2   number Right edge
--- @param y2   number Bottom edge
--- @param chars  table|nil Optional character overrides
--- @param swap   table|nil Optional swap overrides
function Dashboard.drawSmallButtonFrame(bm, x1, y1, x2, y2, chars, swap)
	local frameColor       = colors.black
	local buttonBG         = colors.gray
	chars                  = chars or Dashboard.Theme.smallBtn.chars
	swap                   = swap or Dashboard.Theme.smallBtn.swap
	local char_TL, char_TR = chars.TL or 151, chars.TR or 148
	local char_BL, char_BR = chars.BL or 130, chars.BR or 129
	local char_H_TOP       = chars.H_TOP or chars.H or 140
	local char_H_BOT       = chars.H_BOT or chars.H or 140

	bm:drawBox(x1, y1, x2, y2, buttonBG)

	local function apply(key, fg, bg)
		local s = swap[key]
		if type(s) == "table" then
			bm.mon.setTextColor(s.fg or fg)
			bm.mon.setBackgroundColor(s.bg or bg)
		elseif s then
			bm.mon.setTextColor(bg)
			bm.mon.setBackgroundColor(fg)
		else
			bm.mon.setTextColor(fg)
			bm.mon.setBackgroundColor(bg)
		end
	end

	apply("TL", buttonBG, frameColor)
	bm.mon.setCursorPos(x1, y1)
	bm.mon.write(string.char(char_TL))

	apply("TR", frameColor, buttonBG)
	bm.mon.setCursorPos(x2, y1)
	bm.mon.write(string.char(char_TR))

	apply("BL", buttonBG, frameColor)
	bm.mon.setCursorPos(x1, y2)
	bm.mon.write(string.char(char_BL))

	apply("BR", frameColor, buttonBG)
	bm.mon.setCursorPos(x2, y2)
	bm.mon.write(string.char(char_BR))

	local topStr = string.rep(string.char(char_H_TOP), x2 - x1 - 1)
	apply("top", frameColor, buttonBG)
	bm.mon.setCursorPos(x1 + 1, y1)
	bm.mon.write(topStr)

	local botStr = string.rep(string.char(char_H_BOT), x2 - x1 - 1)
	apply("bottom", frameColor, buttonBG)
	bm.mon.setCursorPos(x1 + 1, y2)
	bm.mon.write(botStr)
end

--- Draws the main application outer frame including top and bottom content dividers.
--- Uses FrameRenderer.drawDivider to correctly attach T-junctions to the outer frame.
---
--- @param bm           table   ButtonGrid instance
--- @param w            number  Width
--- @param h            number  Height
--- @param title        string  Title to display (centered)
--- @param frameColor   number  Color for the outer frame and dividers
--- @param swap         table|nil Optional overrides for edge swaps
--- @param chars        table|nil Optional overrides for characters
function Dashboard.drawAppFrame(bm, w, h, title, frameColor, swap, chars)
	swap = swap or {}
	-- 1. Draw outer box
	FrameRenderer.drawFrame(bm.mon, 1, 1, w, h, frameColor, colors.black, swap, chars)

	-- 2. Draw Title
	bm.mon.setTextColor(colors.white)
	bm.mon.setBackgroundColor(colors.black)

	-- Force clean spaces and wipe an extra cell on both sides to clear any graphical artifacts
	local cleanTitle = " " .. title:match("^%s*(.-)%s*$") .. " "
	local startX = math.floor((w - #cleanTitle) / 2) + 1

	bm.mon.setCursorPos(startX - 1, 2)
	bm.mon.write(" " .. cleanTitle .. " ")

	-- 3. Top Divider
	FrameRenderer.drawDivider(bm.mon, 1, w, 3, frameColor, colors.black, swap.right)

	-- 4. Bottom Divider
	FrameRenderer.drawDivider(bm.mon, 1, w, h - 4, frameColor, colors.black, swap.right)
end

return Dashboard
