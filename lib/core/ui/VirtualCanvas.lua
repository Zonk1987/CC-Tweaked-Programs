--[[
================================================================================
VirtualCanvas Module v1.0.0
================================================================================
Double-buffering terminal canvas for CC:Tweaked.
Maintains a virtual screen matrix in RAM and performs line-by-line diff
optimizations on flush() to completely eliminate flicker and lag.
================================================================================
]]

local VirtualCanvas = {}
VirtualCanvas.__index = VirtualCanvas

function VirtualCanvas.new(device)
	local self = setmetatable({}, VirtualCanvas)
	self.device = device -- Can be a wrapped peripheral or "term"
	self.width = 0
	self.height = 0
	self.current = {}
	self.previous = {}

	-- Auto-detect size if device is available
	if device then
		local w, h = device.getSize()
		self:setSize(w, h)
	end

	return self
end

-- Resize or initialize buffers
-- @param w [number] Screen width
-- @param h [number] Screen height
function VirtualCanvas:setSize(w, h)
	self.width = w or 1
	self.height = h or 1

	self.current = {}
	self.previous = {}

	for y = 1, self.height do
		self.current[y] = {}
		self.previous[y] = {}
		for x = 1, self.width do
			self.current[y][x] = { char = " ", fg = colors.white, bg = colors.black }
			self.previous[y][x] = { char = " ", fg = colors.white, bg = colors.black }
		end
	end
end

-- Clear the current buffer with a background color
-- @param bgCol [number] Background color
function VirtualCanvas:clear(bgCol)
	bgCol = bgCol or colors.black
	for y = 1, self.height do
		for x = 1, self.width do
			local cell = self.current[y][x]
			cell.char = " "
			cell.fg = colors.white
			cell.bg = bgCol
		end
	end
end

-- Set a single cell in the current buffer
-- @param x [number] X coordinate (1-based)
-- @param y [number] Y coordinate (1-based)
-- @param char [string] Single character
-- @param fgCol [number] Text color
-- @param bgCol [number] Background color
function VirtualCanvas:setPixel(x, y, char, fgCol, bgCol)
	if x < 1 or x > self.width or y < 1 or y > self.height then
		return
	end

	local cell = self.current[y][x]
	cell.char = tostring(char):sub(1, 1) or " "
	if fgCol then
		cell.fg = fgCol
	end
	if bgCol then
		cell.bg = bgCol
	end
end

-- Write a string to the current buffer
-- @param x [number] Start X coordinate
-- @param y [number] Y coordinate
-- @param text [string] Text to write
-- @param fgCol [number] Text color
-- @param bgCol [number] Background color
function VirtualCanvas:write(x, y, text, fgCol, bgCol)
	if y < 1 or y > self.height then
		return
	end
	text = tostring(text)

	for i = 1, #text do
		local curX = x + i - 1
		if curX >= 1 and curX <= self.width then
			local cell = self.current[y][curX]
			cell.char = text:sub(i, i)
			if fgCol then
				cell.fg = fgCol
			end
			if bgCol then
				cell.bg = bgCol
			end
		end
	end
end

-- Draw a filled box in the current buffer
-- @param x [number] Start X
-- @param y [number] Start Y
-- @param w [number] Width
-- @param h [number] Height
-- @param bgCol [number] Fill color
function VirtualCanvas:drawBox(x, y, w, h, bgCol)
	for curY = y, y + h - 1 do
		if curY >= 1 and curY <= self.height then
			for curX = x, x + w - 1 do
				if curX >= 1 and curX <= self.width then
					local cell = self.current[curY][curX]
					cell.char = " "
					cell.bg = bgCol or colors.black
				end
			end
		end
	end
end

-- Perform diff and write changes to physical screen
-- @param targetDevice [table] Optional device to draw to (defaults to self.device)
function VirtualCanvas:flush(targetDevice)
	local dev = targetDevice or self.device
	if not dev then
		return
	end

	-- Diff algorithm with run-length optimization (horizontal clustering)
	for y = 1, self.height do
		local x = 1
		while x <= self.width do
			local curCell = self.current[y][x]
			local prevCell = self.previous[y][x]

			-- Check if the cell has changed
			if curCell.char ~= prevCell.char or curCell.fg ~= prevCell.fg or curCell.bg ~= prevCell.bg then
				-- Start a contiguous horizontal write cluster
				local clusterX = x
				local clusterText = {}
				local clusterFg = curCell.fg
				local clusterBg = curCell.bg

				-- Scan ahead for contiguous cells with the SAME fg and bg colors.
				-- IMPORTANT: a cell may only join the cluster if its colors match,
				-- because the whole cluster is drawn with one fg/bg pair. A dirty
				-- cell with different colors ends this cluster and starts its own
				-- on the next outer-loop iteration (otherwise it would be painted
				-- in the wrong colors and the diff buffer would mask it forever).
				while x <= self.width do
					local nextCur = self.current[y][x]
					local nextPrev = self.previous[y][x]

					local isSameColor = nextCur.fg == clusterFg and nextCur.bg == clusterBg
					if not isSameColor then
						break
					end

					table.insert(clusterText, nextCur.char)
					-- Update previous buffer in-place to keep sync
					nextPrev.char = nextCur.char
					nextPrev.fg = nextCur.fg
					nextPrev.bg = nextCur.bg
					x = x + 1
				end

				-- Draw the collected cluster
				if #clusterText > 0 then
					dev.setCursorPos(clusterX, y)
					dev.setTextColor(clusterFg)
					dev.setBackgroundColor(clusterBg)
					dev.write(table.concat(clusterText))
				end
			else
				x = x + 1
			end
		end
	end
end

return VirtualCanvas
