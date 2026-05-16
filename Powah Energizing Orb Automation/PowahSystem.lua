-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})
local Dashboard = require("Dashboard")
local RecipeManager = require("RecipeManager")
local Chest = require("Chest")
local Orb = require("Orb")
local ImportMenu = require("ImportMenu")

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
local keys_i = keys.i

---@class PowahSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field activeJobs table<string, table>
---@field meBridge any|nil
---@field aeScanner any|nil
local PowahSystem = {}
PowahSystem.__index = PowahSystem

--- Creates the main system
---@param options table
---@return PowahSystem
function PowahSystem.new(options)
    local self = setmetatable({}, PowahSystem)
    self.chest = Chest.new(options.chestName)
    self.dashboard = Dashboard.new()
    self.recipeManager = RecipeManager.new(options.recipeFile or "powah_recipes.json", self.dashboard)
    self.activeJobs = {}
    self.meBridge = options.meBridgeName and peripheral.wrap(options.meBridgeName) or nil
    self.aeScanner = options.aeScannerName and peripheral.wrap(options.aeScannerName) or nil
    return self
end

--- Finds an orb without a current job
---@return Orb|nil
function PowahSystem:getFreeOrb()
    local allOrbsNames = { peripheral.find("powah:energizing_orb") }
    for _, orbPeripheral in ipairs(allOrbsNames) do
        local name = peripheral.getName(orbPeripheral)
        if not self.activeJobs[name] then
            local orb = Orb.new(name)
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
        local orb = Orb.new(orbName)
        if not orb:isPresent() then
            self.activeJobs[orbName] = nil
        else
            if orb:isEmpty() then
                self.dashboard:setLastCraft(job.recipeName)
                self.activeJobs[orbName] = nil
                self.dashboard:draw()
            else
                -- Timeout check (1 minute)
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
            local success, err = self.chest:transferRecipe(readyRecipe, freeOrb.name)

            if success then
                self.activeJobs[freeOrb.name] = {
                    startTime = os_epoch("utc"),
                    recipeName = readyRecipe.name
                }
                self.dashboard:draw()
            else
                self.dashboard:setError("Transfer: " .. (err or "unknown"))
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
        local _, key = os_pullEvent("key")
        if key == keys_r then
            self.dashboard:setStatus("Reloading recipes...")
            self.recipeManager:load()
            os_sleep(0.5)
            self.dashboard:setStatus("Waiting for items...")
        elseif key == keys_i then
            local menu = ImportMenu.new({
                meBridge = self.meBridge,
                aeScanner = self.aeScanner,
                recipeManager = self.recipeManager,
                dashboard = self.dashboard
            })
            local ok, err = menu:open()
            if not ok then
                if err == "me_bridge_missing" then
                    self.dashboard:setError("No ME Bridge found!")
                elseif err == "no_patterns_found" then
                    self.dashboard:setError("No patterns found!")
                end
                os_sleep(1.5)
                self.dashboard:setError("")
            end
        end
    end
end

--- Starts the system
function PowahSystem:start()
    self.recipeManager:load()
    parallel_waitForAll(
        function() self:mainLoop() end,
        function() self:keyListener() end
    )
end

return PowahSystem