-- Localize globals
local setmetatable = setmetatable
local print = print
local term = term
local peripheral = peripheral

---@class Dashboard
---@field statusMsg string
---@field errorMsg string
---@field lastCraft string
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
    instance.recipeCount = 0
    instance.crafterCount = 0
    instance.suppressDraw = false
    instance.missingData = nil
    return instance
end

--- Sets the active crafter count
---@param count number
function Dashboard:setCrafterCount(count)
    self.crafterCount = count
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

--- Sets missing items data for display
---@param data table|nil
function Dashboard:setMissingItems(data)
    self.missingData = data
end

local function setColor(color)
    if term.isColor() then
        term.setTextColor(color)
    end
end

--- Draws the dashboard to the terminal
function Dashboard:draw()
    if self.suppressDraw then return end
    local oldColor = term.getTextColor()
    term.clear()
    term.setCursorPos(1, 1)
    
    setColor(colors.cyan)
    print("===================================")
    print("   Create Crafter System v1.0")
    print("===================================")
    
    setColor(colors.white)
    print("Calibrated Crafters: " .. self.crafterCount)
    
    term.write("Status:      ")
    if self.statusMsg:find("Crafting") or self.statusMsg:find("Filling") then
        setColor(colors.lime)
    elseif self.statusMsg:find("Waiting") then
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

    if self.missingData then
        setColor(colors.yellow)
        print("Waiting to craft: " .. self.missingData.recipeName)
        print("Missing Items:")
        setColor(colors.lightGray)
        for name, count in pairs(self.missingData.items) do
            print("- " .. count .. "x " .. name)
        end
        setColor(colors.cyan)
        print("-----------------------------------")
    end

    if self.errorMsg ~= "" then
        setColor(colors.red)
        print("ERROR: " .. self.errorMsg)
    else
        setColor(colors.lightGray)
        print("[Press 'R' to reload | 'S' to record new]")
    end
    
    setColor(oldColor)
end

return Dashboard
