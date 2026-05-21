--[[
================================================================================
FlexLayout Module v1.0.0
================================================================================
A lightweight, declarative, responsive Flexbox-like layout engine for CC.
Simplifies layout calculation and rendering for multiple screen/monitor sizes.
================================================================================
]]

local FlexLayout = {}

-- Base Node class
local Node = {}
Node.__index = Node

function Node.new(props)
	local self = setmetatable({}, Node)
	self.type = props.type or "node"
	self.width = props.width -- absolute number or nil (auto)
	self.height = props.height -- absolute number or nil (auto)
	self.padding = props.padding or 0
	self.margin = props.margin or 0
	self.direction = props.direction or "column" -- "row", "column"
	self.justify = props.justify or "start" -- "start", "center", "end"
	self.align = props.align or "start" -- "start", "center", "end"
	self.children = props.children or {}
	self.text = props.text or ""
	self.fg = props.fg or colors.white
	self.bg = props.bg or colors.black
	self.onClick = props.onClick

	-- Calculated bounds during layout phase
	self.x = 0
	self.y = 0
	self.computedWidth = 0
	self.computedHeight = 0

	return self
end

-- Layout calculation (Pass 1: Auto-dimensions & coordinates)
function Node:computeLayout(x, y, parentW, parentH)
	self.x = x
	self.y = y
	self.computedWidth = self.width or parentW
	self.computedHeight = self.height or parentH

	if #self.children == 0 then
		return
	end

	-- Calculate layout for children
	local curX = x + self.padding
	local curY = y + self.padding
	local innerW = self.computedWidth - (2 * self.padding)
	local innerH = self.computedHeight - (2 * self.padding)

	if self.direction == "column" then
		-- Distribute children vertically
		local childH = math.floor(innerH / #self.children)
		for _, child in ipairs(self.children) do
			local childW = child.width or innerW
			-- Alignment horizontal
			local alignX = curX
			if self.align == "center" then
				alignX = curX + math.floor((innerW - childW) / 2)
			elseif self.align == "end" then
				alignX = curX + innerW - childW
			end

			child:computeLayout(alignX, curY, childW, child.height or childH)
			curY = curY + (child.height or childH)
		end
	elseif self.direction == "row" then
		-- Distribute children horizontally
		local childW = math.floor(innerW / #self.children)
		for _, child in ipairs(self.children) do
			local childH = child.height or innerH
			-- Alignment vertical
			local alignY = curY
			if self.align == "center" then
				alignY = curY + math.floor((innerH - childH) / 2)
			elseif self.align == "end" then
				alignY = curY + innerH - childH
			end

			child:computeLayout(curX, alignY, child.width or childW, childH)
			curX = curX + (child.width or childW)
		end
	end
end

-- Rendering phase (Draws onto VirtualCanvas)
-- @param canvas [VirtualCanvas] The virtual canvas to render on
function Node:render(canvas)
	-- 1. Draw background
	if self.bg then
		canvas:drawBox(self.x, self.y, self.computedWidth, self.computedHeight, self.bg)
	end

	-- 2. Draw content depending on node type
	if self.type == "label" or self.type == "button" then
		local textX = self.x + math.floor((self.computedWidth - #self.text) / 2)
		local textY = self.y + math.floor((self.computedHeight - 1) / 2)
		canvas:write(textX, textY, self.text, self.fg, self.bg)
	end

	-- 3. Render children
	for _, child in ipairs(self.children) do
		child:render(canvas)
	end
end

-- Handle touch/click events
-- @param x [number] Clicked X
-- @param y [number] Clicked Y
-- @return [boolean] Whether the click was handled
function Node:handleMouse(x, y)
	-- Check if click is inside bounds
	if x >= self.x and x < self.x + self.computedWidth and y >= self.y and y < self.y + self.computedHeight then
		if self.onClick then
			self.onClick()
			return true
		end

		-- Pass down to children
		for _, child in ipairs(self.children) do
			if child:handleMouse(x, y) then
				return true
			end
		end
	end
	return false
end

-- Declarative DSL API
function FlexLayout.Container(props)
	props.type = "container"
	return Node.new(props)
end

-- Declarative DSL Label
function FlexLayout.Label(props)
	props.type = "label"
	return Node.new(props)
end

-- Declarative DSL Button
function FlexLayout.Button(props)
	props.type = "button"
	props.fg = props.fg or colors.yellow
	props.bg = props.bg or colors.blue
	return Node.new(props)
end

return FlexLayout
