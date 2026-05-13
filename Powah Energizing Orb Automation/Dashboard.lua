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
local math = math

---@class Dashboard
---@field statusMsg string
---@field errorMsg string
---@field lastCraft string
---@field recipeCount number
---@field activeJobs table
local Dashboard = {}
Dashboard.__index = Dashboard

--- Creates a new Dashboard instance
---@return Dashboard
function Dashboard:new()
    local instance = setmetatable({}, self)
    instance.statusMsg = "Starting..."
    instance.errorMsg = ""
    instance.lastCraft = "None"
    instance.recipeCount = 0
    instance.activeJobs = {}
    instance.suppressDraw = false
    return instance
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

--- Internal helper for color drawing
local function setColor(color)
    term.setTextColor(color)
end

--- Draws the full dashboard UI
function Dashboard:draw()
    if self.suppressDraw then return end
    local oldColor = term.getTextColor()
    local w, h = term.getSize()
    
    term.clear()
    term.setCursorPos(1, 1)
    
    setColor(colors.yellow)
    print("=== Powah Energizing Automation ===")
    setColor(colors.cyan)
    print("-----------------------------------")
    
    setColor(colors.white)
    term.write("Status:      ")
    if self.statusMsg:find("Crafting") or self.statusMsg:find("Filling") or self.statusMsg:find("Processing") then
        setColor(colors.lime)
    elseif self.statusMsg:find("Waiting") or self.statusMsg:find("Starting") then
        setColor(colors.yellow)
    else
        setColor(colors.white)
    end
    print(self.statusMsg)

    setColor(colors.white)
    print("Last Job:    " .. self.lastCraft)
    if self.recipeCount > 0 then
        print("Recipes:     " .. self.recipeCount)
    end

    setColor(colors.cyan)
    print("-----------------------------------")

    local jobsFound = false
    if self.activeJobs then
        for name, job in pairs(self.activeJobs) do
            setColor(colors.lime)
            term.write("-> ")
            setColor(colors.white)
            print(job.recipeName .. " (" .. name .. ")")
            jobsFound = true
        end
    end
    if not jobsFound then
        setColor(colors.lightGray)
        print("No active crafting processes.")
    end

    setColor(colors.cyan)
    print("-----------------------------------")

    if self.errorMsg ~= "" then
        setColor(colors.red)
        print("ERROR: " .. self.errorMsg)
    else
        setColor(colors.lightGray)
        print("[R] Reload  [I] Import AE2")
    end

    setColor(oldColor)
end

return Dashboard