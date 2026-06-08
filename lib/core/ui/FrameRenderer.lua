---@diagnostic disable: undefined-global
--[[
================================================================================
FrameRenderer Module v1.0.0
================================================================================
Draws 2.5-D style window frames using CC:Tweaked sub-pixel block characters.

Character reference (verified against ButtonGrid.drawFineBox):
  TL corner : char 156  -- FG pixels on top-left area
  TR corner : char 148  -- FG pixels on top-right area
  BL corner : char 141  -- FG pixels on bottom-left area
  BR corner : char 133  -- FG pixels on bottom-right area
  H-line    : char 140  -- FG pixels as thin horizontal centre bar
  V-line    : char 149  -- FG pixels on left column

Color convention for all elements:
  FG = outerColor  (the border / outer-edge colour)
  BG = innerColor  (the fill / inner-edge colour)

This means drawFrame(mon, x1, y1, x2, y2, colors.white, colors.gray)
produces a white border on a gray-filled box.
================================================================================
--]]

-- Localize globals (strict-mode safe)
local colors = colors
local string = string

local FrameRenderer = {}

-- ---------------------------------------------------------------------------
-- Constants / Config
-- ---------------------------------------------------------------------------

--- Character configuration for drawing frames.
--- These can be adjusted at runtime to use a different character set.
FrameRenderer.CHARS = {
	TL = 151, -- Top-Left corner
	TR = 148, -- Top-Right corner
	BL = 138, -- Bottom-Left corner
	BR = 133, -- Bottom-Right corner
	H_OUTER = 140, -- Horizontal outer edge
	V_OUTER = 149, -- Vertical outer edge
	H_MID = 140, -- Horizontal middle line
	V_MID = 149, -- Vertical middle line
	T_LEFT = 157, -- T-Junction (Left)
	T_RIGHT = 145, -- T-Junction (Right, drawn inverted)
}

-- ---------------------------------------------------------------------------
-- Private helpers
-- ---------------------------------------------------------------------------

--- Apply FG / BG colors and position the cursor.
local function prepare(mon, x, y, outerColor, innerColor)
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	mon.setCursorPos(x, y)
end

--- Return (a, b) normally, (b, a) when swapped is true, or custom colors if swapped is a table.
--- Used by drawFrame to apply per-element colour order.
local function pick(swapped, outer, inner)
	if type(swapped) == "table" then
		return swapped.fg or outer, swapped.bg or inner
	elseif swapped then
		return inner, outer
	end
	return outer, inner
end

-- ---------------------------------------------------------------------------
-- Corner functions
-- ---------------------------------------------------------------------------

--- Draws the top-left corner character.
--- @param mon     table  CC:Tweaked monitor / terminal
--- @param x       number Column position
--- @param y       number Row position
--- @param outerColor number Border colour
--- @param innerColor number Fill colour
--- @param charOverride number|nil Character to draw
function FrameRenderer.drawTopLeft(mon, x, y, outerColor, innerColor, charOverride)
	prepare(mon, x, y, outerColor, innerColor)
	mon.write(string.char(charOverride or FrameRenderer.CHARS.TL))
end

--- Draws the top-right corner character.
--- @param charOverride number|nil
function FrameRenderer.drawTopRight(mon, x, y, outerColor, innerColor, charOverride)
	prepare(mon, x, y, outerColor, innerColor)
	mon.write(string.char(charOverride or FrameRenderer.CHARS.TR))
end

--- Draws the bottom-left corner character.
--- @param charOverride number|nil
function FrameRenderer.drawBottomLeft(mon, x, y, outerColor, innerColor, charOverride)
	prepare(mon, x, y, outerColor, innerColor)
	mon.write(string.char(charOverride or FrameRenderer.CHARS.BL))
end

--- Draws the bottom-right corner character.
--- @param charOverride number|nil
function FrameRenderer.drawBottomRight(mon, x, y, outerColor, innerColor, charOverride)
	prepare(mon, x, y, outerColor, innerColor)
	mon.write(string.char(charOverride or FrameRenderer.CHARS.BR))
end

-- ---------------------------------------------------------------------------
-- Edge functions
-- ---------------------------------------------------------------------------

--- Draws a horizontal edge using the configured H_OUTER character.
--- Direction is controlled by colour order:
---   FG=outerColor, BG=innerColor → outerColor on top    (use for top edge)
---   FG=innerColor, BG=outerColor → outerColor on bottom (use for bottom edge)
---
--- @param mon        table
--- @param x1         number Start column
--- @param x2         number End column
--- @param y          number Row
--- @param outerColor number
--- @param innerColor number
--- @param charOverride number|nil
function FrameRenderer.drawHorizontalEdge(mon, x1, x2, y, outerColor, innerColor, charOverride)
	if x2 < x1 then
		return
	end
	prepare(mon, x1, y, outerColor, innerColor)
	mon.write(string.rep(string.char(charOverride or FrameRenderer.CHARS.H_OUTER), x2 - x1 + 1))
end

--- Aliases kept for backward compatibility.
FrameRenderer.drawTopEdge = FrameRenderer.drawHorizontalEdge
FrameRenderer.drawBottomEdge = FrameRenderer.drawHorizontalEdge

--- Draws a vertical edge using char 149 (▌ = U+258C, left half block).
--- Both the left and right frame edges use this same character.
--- Direction is controlled by colour order:
---   FG=outerColor, BG=innerColor → outerColor pixel on LEFT side  (use for left edge)
---   FG=innerColor, BG=outerColor → outerColor pixel on RIGHT side (use for right edge via swap)
---
--- @param mon        table
--- @param x          number Column
--- @param y1         number Start row
--- @param y2         number End row
--- @param outerColor number
--- @param innerColor number
--- @param charOverride number|nil
function FrameRenderer.drawVerticalEdge(mon, x, y1, y2, outerColor, innerColor, charOverride)
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	for y = y1, y2 do
		mon.setCursorPos(x, y)
		mon.write(string.char(charOverride or FrameRenderer.CHARS.V_OUTER))
	end
end

-- ---------------------------------------------------------------------------
-- Middle Line functions
-- ---------------------------------------------------------------------------

--- Draws a horizontal middle line (separator).
function FrameRenderer.drawHorizontalMid(mon, x1, x2, y, outerColor, innerColor)
	if x2 < x1 then
		return
	end
	prepare(mon, x1, y, outerColor, innerColor)
	mon.write(string.rep(string.char(FrameRenderer.CHARS.H_MID), x2 - x1 + 1))
end

--- Draws a horizontal divider line with T-junctions on both ends.
--- @param rightAligned boolean|nil If true, the right T-Junction is drawn inverted to match a right-aligned wall.
function FrameRenderer.drawDivider(mon, x1, x2, y, outerColor, innerColor, rightAligned)
	if x2 <= x1 + 1 then
		return
	end

	-- Left T-Junction
	prepare(mon, x1, y, outerColor, innerColor)
	mon.write(string.char(FrameRenderer.CHARS.T_LEFT))

	-- Middle line
	FrameRenderer.drawHorizontalMid(mon, x1 + 1, x2 - 1, y, outerColor, innerColor)

	-- Right T-Junction
	if rightAligned then
		prepare(mon, x2, y, innerColor, outerColor) -- Swap FG/BG for right side mirror
		mon.write(string.char(FrameRenderer.CHARS.T_RIGHT))
	else
		-- Default (left-aligned right wall) uses standard vertical edge (149)
		prepare(mon, x2, y, outerColor, innerColor)
		mon.write(string.char(FrameRenderer.CHARS.V_OUTER))
	end
end

--- Draws a vertical middle line (separator).
function FrameRenderer.drawVerticalMid(mon, x, y1, y2, outerColor, innerColor)
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	for y = y1, y2 do
		mon.setCursorPos(x, y)
		mon.write(string.char(FrameRenderer.CHARS.V_MID))
	end
end

--- Alias kept for backward compatibility.
FrameRenderer.drawLeftEdge = FrameRenderer.drawVerticalEdge

-- ---------------------------------------------------------------------------
-- Builder function
-- ---------------------------------------------------------------------------

--- Draws a complete frame with corners and all four edges.
---
--- Per-element colour order can be flipped via the optional `swap` table.
--- When swap[key] = true, the FG and BG colours are swapped for that element:
---   swap.TL, swap.TR, swap.BL, swap.BR  -- individual corners
---   swap.top, swap.bottom               -- horizontal edges
---   swap.left, swap.right               -- vertical edges
---
--- Usage examples:
---   -- Standard frame: white border on gray fill
---   FrameRenderer.drawFrame(bm.mon, x1, y1, x2, y2, colors.white, colors.gray)
---
---   -- Inverted top edge and right vertical only:
---   FrameRenderer.drawFrame(bm.mon, x1, y1, x2, y2, colors.white, colors.gray, {
---     top   = true,
---     right = true,
---   })
---
--- @param mon        table   CC:Tweaked monitor / terminal
--- @param x1         number  Left edge column
--- @param y1         number  Top edge row
--- @param x2         number  Right edge column
--- @param y2         number  Bottom edge row
--- @param outerColor number  Border / outer-edge colour (default FG)
--- @param innerColor number  Fill / inner-edge colour (default BG)
--- @param swap       table|nil  Optional per-element swap flags (see above)
--- @param chars      table|nil  Optional character overrides: { TL=156, H_OUTER=140, etc. }
function FrameRenderer.drawFrame(mon, x1, y1, x2, y2, outerColor, innerColor, swap, chars)
	if x2 < x1 or y2 < y1 then
		return
	end
	swap = swap or {}
	chars = chars or {}

	-- Corners
	local outColor, inColor = pick(swap.TL, outerColor, innerColor)
	FrameRenderer.drawTopLeft(mon, x1, y1, outColor, inColor, chars.TL)

	outColor, inColor = pick(swap.TR, outerColor, innerColor)
	FrameRenderer.drawTopRight(mon, x2, y1, inColor, outColor, chars.TR)

	outColor, inColor = pick(swap.BL, outerColor, innerColor)
	FrameRenderer.drawBottomLeft(mon, x1, y2, inColor, outColor, chars.BL)

	outColor, inColor = pick(swap.BR, outerColor, innerColor)
	FrameRenderer.drawBottomRight(mon, x2, y2, inColor, outColor, chars.BR)

	-- Horizontal edges (between corners)
	-- Top: uses normal colour order
	-- Bottom: swap colour order if needed (e.g., if using char 131)
	if x2 > x1 + 1 then
		outColor, inColor = pick(swap.top, outerColor, innerColor)
		FrameRenderer.drawHorizontalEdge(mon, x1 + 1, x2 - 1, y1, outColor, inColor, chars.H_TOP or chars.H_OUTER)

		outColor, inColor = pick(swap.bottom, outerColor, innerColor)
		FrameRenderer.drawHorizontalEdge(mon, x1 + 1, x2 - 1, y2, outColor, inColor, chars.H_BOT or chars.H_OUTER)
	end

	-- Vertical edges (between corners)
	-- Left: normal colour order → outerColor on left half
	-- Right: swap colour order → outerColor on right half
	if y2 > y1 + 1 then
		outColor, inColor = pick(swap.left, outerColor, innerColor)
		FrameRenderer.drawVerticalEdge(mon, x1, y1 + 1, y2 - 1, outColor, inColor, chars.V_LEFT or chars.V_OUTER)

		outColor, inColor = pick(swap.right, outerColor, innerColor)
		FrameRenderer.drawVerticalEdge(mon, x2, y1 + 1, y2 - 1, outColor, inColor, chars.V_RIGHT or chars.V_OUTER)
	end
end

--- Draws a button-style frame with mirrored right-side styling.
--- The right vertical uses inverted FG/BG to make the outer colour appear on the right edge,
--- creating a visually symmetric frame. Uses bridge corner characters for TR and BR.
---
--- Characters: 156 (TL), 147 (TR bridge), 141 (BL), 142 (BR bridge), 140 (H), 149 (V)
---
--- Usage example:
---   FrameRenderer.drawButtonFrame(bm.mon, x1, y1, x2, y2, colors.gray, colors.black)
---
--- @param mon        table  CC:Tweaked monitor / terminal
--- @param x1         number Left edge column
--- @param y1         number Top edge row
--- @param x2         number Right edge column
--- @param y2         number Bottom edge row
--- @param outerColor number Button / border colour
--- @param innerColor number Background colour (defaults to colors.black)
--- @param chars      table|nil Optional overrides for characters
function FrameRenderer.drawButtonFrame(mon, x1, y1, x2, y2, outerColor, innerColor, chars)
	innerColor = innerColor or colors.black
	chars = chars or {}

	local c_H_TOP = string.char(chars.H_TOP or chars.H or 140)
	local c_H_BOT = string.char(chars.H_BOT or chars.H or 140)
	local c_V_LEFT = string.char(chars.V_LEFT or chars.V or 149)
	local c_V_RIGHT = string.char(chars.V_RIGHT or chars.V or 149)
	local c_TL = string.char(chars.TL or 156)
	local c_TR = string.char(chars.TR or 147)
	local c_BL = string.char(chars.BL or 141)
	local c_BR = string.char(chars.BR or 142)

	-- Horizontal edges (top and bottom)
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	if x2 >= x1 then
		mon.setCursorPos(x1, y1)
		mon.write(string.rep(c_H_TOP, x2 - x1 + 1))
		mon.setCursorPos(x1, y2)
		mon.write(string.rep(c_H_BOT, x2 - x1 + 1))
	end

	-- Vertical edges
	for y = y1 + 1, y2 - 1 do
		-- Left: outerColor on left half
		mon.setTextColor(outerColor)
		mon.setBackgroundColor(innerColor)
		mon.setCursorPos(x1, y)
		mon.write(c_V_LEFT)
		-- Right: outerColor on right half (swap FG/BG so BG=outerColor fills the right side)
		mon.setTextColor(innerColor)
		mon.setBackgroundColor(outerColor)
		mon.setCursorPos(x2, y)
		mon.write(c_V_RIGHT)
	end

	-- Corners (all use outerColor FG on innerColor BG, except TR which is swapped)
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	mon.setCursorPos(x1, y1)
	mon.write(c_TL) -- TL

	-- Swapped TR corner
	mon.setTextColor(innerColor)
	mon.setBackgroundColor(outerColor)
	mon.setCursorPos(x2, y1)
	mon.write(c_TR) -- TR (Swapped)

	-- Restore normal colors for bottom corners
	mon.setTextColor(outerColor)
	mon.setBackgroundColor(innerColor)
	mon.setCursorPos(x1, y2)
	mon.write(c_BL) -- BL
	mon.setCursorPos(x2, y2)
	mon.write(c_BR) -- BR bridge mirror
end

return FrameRenderer
