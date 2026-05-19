-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Localize globals
local setmetatable = setmetatable
local term = term
local colors = colors
local pairs = pairs

---@class Dashboard
---@field statusMsg string
---@field errorMsg string
---@field lastCraft string
---@field recipeCount number
---@field crafterCount number
---@field suppressDraw boolean
---@field missingData table|nil
---@field chestName string|nil
local Dashboard = {}
Dashboard.__index = Dashboard

--- Creates a new Dashboard instance
---@return Dashboard
function Dashboard.new()
	local self = setmetatable({
		statusMsg = "Starting System...",
		errorMsg = "",
		lastCraft = "-",
		recipeCount = 0,
		crafterCount = 0,
		suppressDraw = false,
		missingData = nil,
	}, Dashboard)
	return self
end

--- Sets the active crafter count
function Dashboard:setCrafterCount(count)
	self.crafterCount = count
end

--- Sets the recipe count
function Dashboard:setRecipeCount(count)
	self.recipeCount = count
end

--- Sets the status message and redraws
function Dashboard:setStatus(msg)
	self.statusMsg = msg
	self:draw()
end

--- Sets the error message and redraws
function Dashboard:setError(msg)
	self.errorMsg = msg
	self:draw()
end

--- Sets the last crafted recipe
function Dashboard:setLastCraft(recipeName)
	self.lastCraft = recipeName
end

--- Sets missing items data for display
function Dashboard:setMissingItems(data)
	self.missingData = data
end

--- Internal helper to draw the header
local function drawHeader()
	term.setTextColor(colors.cyan)
	print("===================================")
	term.setTextColor(colors.yellow)
	print("    Create Crafter System v1.0.070-main")
	term.setTextColor(colors.cyan)
	print("===================================")
end

--- Internal helper to draw the footer area
function Dashboard:drawFooter()
	term.setTextColor(colors.cyan)
	print("-----------------------------------")
	if self.errorMsg ~= "" then
		term.setTextColor(colors.red)
		print("ERROR: " .. self.errorMsg)
	else
		term.setTextColor(colors.lightGray)
		print("[R] Reload  [S] Record  [M] Manage")
	end
end

--- Draws the missing items section
function Dashboard:drawMissingItems()
	if not self.missingData then
		return
	end
	term.setTextColor(colors.yellow)
	print("Waiting to craft: " .. self.missingData.recipeName)
	print("Missing Items:")
	term.setTextColor(colors.lightGray)
	for name, count in pairs(self.missingData.items) do
		print("- " .. count .. "x " .. name)
	end
	term.setTextColor(colors.cyan)
	print("-----------------------------------")
end

--- Draws the full dashboard UI
function Dashboard:draw()
	if self.suppressDraw then
		return
	end
	local oldColor = term.getTextColor()
	term.clear()
	term.setCursorPos(1, 1)

	drawHeader()

	term.setTextColor(colors.white)
	term.write("Calibrated:  ")
	term.setTextColor(colors.lime)
	print(self.crafterCount .. " Crafters")

	term.setTextColor(colors.white)
	term.write("Status:      ")
	local statusColor = colors.white
	if self.statusMsg:find("Crafting") or self.statusMsg:find("Filling") then
		statusColor = colors.lime
	elseif self.statusMsg:find("Waiting") or self.statusMsg:find("Starting") then
		statusColor = colors.yellow
	end
	term.setTextColor(statusColor)
	print(self.statusMsg)

	term.setTextColor(colors.white)
	print("Last Job:    " .. self.lastCraft)
	print("Recipes:     " .. self.recipeCount)
	print("Buffer:      " .. (self.chestName or "Unknown"))

	term.setTextColor(colors.cyan)
	print("-----------------------------------")

	self:drawMissingItems()
	self:drawFooter()

	term.setTextColor(oldColor)
end

return Dashboard
