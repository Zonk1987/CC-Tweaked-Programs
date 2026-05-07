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

--- Draws the dashboard to the terminal
function Dashboard:draw()
    term.clear()
    term.setCursorPos(1, 1)
    print("===================================")
    print("   Powah System v5.0 (Modular)")
    print("===================================")

    local orbCount = #{ peripheral.find("powah:energizing_orb") }
    print("Connected Orbs: " .. orbCount)
    print("Status:      " .. self.statusMsg)
    print("Last Job:    " .. self.lastCraft)
    if self.recipeCount > 0 then
        print("Recipes:     " .. self.recipeCount)
    end
    print("-----------------------------------")

    local jobsFound = false
    if self.activeJobs then
        for name, job in pairs(self.activeJobs) do
            print("-> " .. job.recipeName .. " (" .. name .. ")")
            jobsFound = true
        end
    end
    if not jobsFound then
        print("No active crafting processes.")
    end
    print("-----------------------------------")

    if self.errorMsg ~= "" then
        print("ERROR: " .. self.errorMsg)
    else
        print("[Press 'R' to reload JSON]")
    end
end

return Dashboard
