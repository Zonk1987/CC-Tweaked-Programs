local Dashboard = require("Dashboard")
local RecipeManager = require("RecipeManager")
local Chest = require("Chest")
local Orb = require("Orb")

-- Localize globals
local setmetatable = setmetatable
local peripheral = peripheral
local ipairs = ipairs
local pairs = pairs
local os_sleep = os.sleep
local os_epoch = os.epoch
local os_pullEvent = os.pullEvent
local parallel_waitForAll = parallel.waitForAll
local keys_r = keys.r

---@class PowahSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field activeJobs table<string, table>
local PowahSystem = {}
PowahSystem.__index = PowahSystem

--- Creates the main system
---@param chestName string
---@param recipeFile string
---@return PowahSystem
function PowahSystem:new(chestName, recipeFile)
    local instance = setmetatable({}, self)
    instance.chest = Chest:new(chestName)
    instance.dashboard = Dashboard:new()
    instance.recipeManager = RecipeManager:new(recipeFile, instance.dashboard)
    instance.activeJobs = {}
    return instance
end

--- Finds an orb without a current job
---@return Orb|nil
function PowahSystem:getFreeOrb()
    local allOrbsNames = { peripheral.find("powah:energizing_orb") }
    for _, orbPeripheral in ipairs(allOrbsNames) do
        local name = peripheral.getName(orbPeripheral)
        if not self.activeJobs[name] then
            local orb = Orb:new(name)
            if orb:isEmpty() then
                return orb
            end
        end
    end
    return nil
end

--- Monitors currently active crafting jobs
function PowahSystem:checkActiveJobs()
    for orbName, job in pairs(self.activeJobs) do
        local orb = Orb:new(orbName)
        if not orb:isPresent() then
            self.activeJobs[orbName] = nil
        else
            if orb:isEmpty() then
                self.dashboard:setLastCraft(job.recipeName)
                self.activeJobs[orbName] = nil
                self.dashboard:draw()
            else
                if (os_epoch("utc") - job.startTime) > 60000 then
                    self.dashboard:setError("Timeout in " .. orbName .. ". Recovering...")
                    orb:recover(self.chest.name)
                    self.activeJobs[orbName] = nil
                    os_sleep(1)
                    self.dashboard:setError("")
                end
            end
        end
    end
end

--- Main process loop logic
function PowahSystem:process()
    if not self.chest:isPresent() then
        self.dashboard:setError("Chest missing!")
        os_sleep(2)
        return
    end

    if self.dashboard.errorMsg == "Chest missing!" or self.dashboard.errorMsg == "No Orb found!" then 
        self.dashboard:setError("") 
    end

    self.dashboard:updateJobs(self.activeJobs)
    self:checkActiveJobs()

    local freeOrb = self:getFreeOrb()
    if freeOrb then
        local readyRecipe = self.recipeManager:findReadyRecipe(self.chest)
        if readyRecipe then
            self.dashboard:setStatus("Filling " .. freeOrb.name)
            local success = self.chest:transferRecipe(readyRecipe, freeOrb.name)
            
            if success then
                self.activeJobs[freeOrb.name] = {
                    startTime = os_epoch("utc"),
                    recipeName = readyRecipe.name
                }
                self.dashboard:draw()
            else
                self.dashboard:setError("Transfer Error! Starting Recovery...")
                freeOrb:recover(self.chest.name)
                os_sleep(1)
            end
        else
            self.dashboard:setStatus("Waiting for items...")
        end
    else
        local allOrbs = { peripheral.find("powah:energizing_orb") }
        if #allOrbs > 0 then
            self.dashboard:setStatus("All Orbs are busy...")
        else
            self.dashboard:setError("No Orb found!")
        end
    end
end

--- Runs the process continuously
function PowahSystem:mainLoop()
    while true do
        self:process()
        os_sleep(0.1)
    end
end

--- Listens to keyboard events
function PowahSystem:keyListener()
    while true do
        local event, key = os_pullEvent("key")
        if key == keys_r then
            self.dashboard:setStatus("Reloading recipes...")
            self.recipeManager:load()
            os_sleep(0.5)
            self.dashboard:setStatus("Waiting for items...")
        end
    end
end

--- Starts the system
function PowahSystem:start()
    if self.recipeManager:load() then
        parallel_waitForAll(
            function() self:mainLoop() end,
            function() self:keyListener() end
        )
    end
end

return PowahSystem
