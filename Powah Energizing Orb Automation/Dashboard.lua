-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local setmetatable = setmetatable
local term = term
local colors = colors
local pairs = pairs
local string = string

---@class Dashboard
---@field statusMsg string
---@field errorMsg string
---@field lastCraft string
---@field recipeCount number
---@field activeJobs table
---@field suppressDraw boolean
local Dashboard = {}
Dashboard.__index = Dashboard

--- Creates a new Dashboard instance
---@return Dashboard
function Dashboard.new()
    local self = setmetatable({
        statusMsg = "Starting...",
        errorMsg = "",
        lastCraft = "None",
        recipeCount = 0,
        activeJobs = {},
        suppressDraw = false
    }, Dashboard)
    return self
end

--- Updates the current status message
---@param msg string
function Dashboard:setStatus(msg)
    self.statusMsg = msg
    self:draw()
end

--- Updates the last crafted item name
---@param msg string
function Dashboard:setLastCraft(msg)
    self.lastCraft = msg
end

--- Updates the number of loaded recipes
---@param count number
function Dashboard:setRecipeCount(count)
    self.recipeCount = count
end

--- Updates the error message
---@param msg string
function Dashboard:setError(msg)
    self.errorMsg = msg
    self:draw()
end

--- Updates the active jobs table
---@param jobs table
function Dashboard:updateJobs(jobs)
    self.activeJobs = jobs
    self:draw()
end

--- Draws the header section
local function drawHeader()
    term.setTextColor(colors.yellow)
    print("=== Powah Energizing Automation ===")
    term.setTextColor(colors.cyan)
    print("-----------------------------------")
end

--- Draws the footer section
function Dashboard:drawFooter()
    term.setTextColor(colors.cyan)
    print("-----------------------------------")
    if self.errorMsg ~= "" then
        term.setTextColor(colors.red)
        print("ERROR: " .. self.errorMsg)
    else
        term.setTextColor(colors.lightGray)
        print("[R] Reload  [I] Import AE2")
    end
end

--- Draws the full dashboard UI
function Dashboard:draw()
    if self.suppressDraw then return end
    local oldColor = term.getTextColor()
    term.clear()
    term.setCursorPos(1, 1)

    drawHeader()

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
    if self.recipeCount > 0 then
        print("Recipes:     " .. self.recipeCount)
    end

    term.setTextColor(colors.cyan)
    print("-----------------------------------")

    local jobsFound = false
    for name, job in pairs(self.activeJobs or {}) do
        term.setTextColor(colors.lime)
        term.write("-> ")
        term.setTextColor(colors.white)
        print(job.recipeName .. " (" .. name .. ")")
        jobsFound = true
    end
    if not jobsFound then
        term.setTextColor(colors.lightGray)
        print("No active crafting processes.")
    end

    self:drawFooter()
    term.setTextColor(oldColor)
end

return Dashboard