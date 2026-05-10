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
local print = print
local pairs = pairs
local term = term
local peripheral = peripheral

---@class Dashboard
---@field statusMsg string
---@field errorMsg string
---@field lastCraft string
---@field activeJobs table<string, table>
---@field recipeCount number
local Dashboard = {}
Dashboard.__index = Dashboard

--- Creates a new Dashboard instance
---@return Dashboard
function Dashboard:new()
    local instance = setmetatable({}, self)
    instance.statusMsg = "Starting System..."
    instance.errorMsg = ""
    instance.lastCraft = "-"
    instance.activeJobs = {}
    instance.recipeCount = 0
    return instance
end

--- Updates the list of active jobs
---@param jobs table<string, table>
function Dashboard:updateJobs(jobs)
    self.activeJobs = jobs
end

--- Sets the recipe count
---@param count number
function Dashboard:setRecipeCount(count)
    self.recipeCount = count
end

--- Sets the status message and redraws
---@param msg string
function Dashboard:setStatus(msg)
    self.statusMsg = msg
    self:draw()
end

--- Sets the error message and redraws
---@param msg string
function Dashboard:setError(msg)
    self.errorMsg = msg
    self:draw()
end

--- Sets the last crafted recipe
---@param recipeName string
function Dashboard:setLastCraft(recipeName)
    self.lastCraft = recipeName
end

local function setColor(color)
    if term.isColor() then
        term.setTextColor(color)
    end
end

--- Draws the dashboard to the terminal
function Dashboard:draw()
    local oldColor = term.getTextColor()
    term.clear()
    term.setCursorPos(1, 1)

    setColor(colors.cyan)
    print("===================================")
    print("   Powah System v5.0 (Modular)")
    print("===================================")

    local orbCount = #{ peripheral.find("powah:energizing_orb") }
    setColor(colors.white)
    print("Connected Orbs: " .. orbCount)

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
        print("[Press 'R' to reload JSON]")
    end

    setColor(oldColor)
end

return Dashboard