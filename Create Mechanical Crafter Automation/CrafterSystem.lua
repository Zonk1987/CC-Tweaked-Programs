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
local CrafterGrid = require("CrafterGrid")

-- Localize globals
local setmetatable = setmetatable
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local parallel_waitForAll = parallel.waitForAll
local keys_r = keys.r

---@class CrafterSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field crafterGrid CrafterGrid
---@field isCrafting boolean
local CrafterSystem = {}
CrafterSystem.__index = CrafterSystem

--- Creates the main system
---@param chestName string
---@param recipeFile string
---@return CrafterSystem
function CrafterSystem:new(chestName, recipeFile)
    local instance = setmetatable({}, self)
    instance.chest = Chest:new(chestName)
    instance.dashboard = Dashboard:new()
    instance.recipeManager = RecipeManager:new(recipeFile, instance.dashboard)
    instance.crafterGrid = CrafterGrid:new()
    instance.isCrafting = false
    instance.craftStartTime = 0
    instance.isRecording = false
    return instance
end

--- Main process loop logic
function CrafterSystem:process()
    if not self.chest:isPresent() then
        self.dashboard:setError("Buffer chest missing!")
        os_sleep(2)
        return
    end
    
    if self.crafterGrid:getCount() == 0 then
        self.crafterGrid:discoverCrafters()
        if self.crafterGrid:getCount() == 0 then
            self.dashboard:setError("No Mechanical Crafters found!")
            os_sleep(2)
            return
        end
    end

    if self.dashboard.errorMsg == "Buffer chest missing!" or self.dashboard.errorMsg == "No Mechanical Crafters found!" then 
        self.dashboard:setError("") 
    end

    self.dashboard:setCrafterCount(self.crafterGrid:getCount())

    -- If currently crafting, wait until the crafters are empty
    if self.isCrafting then
        self.dashboard:setStatus("Crafting in progress...")
        self.dashboard:setMissingItems(nil)
        self.dashboard:draw()
        
        -- Dynamically wait to save performance instead of spamming
        os_sleep(1) 
        
        if self.crafterGrid:isEmpty() then
            self.isCrafting = false
            self.dashboard:setError("")
            self.dashboard:setStatus("Waiting for items...")
        else
            if (os.epoch("utc") - self.craftStartTime) > 30000 then
                local jammedMsg = self.crafterGrid:getJammedItem()
                if jammedMsg then
                    self.dashboard:setError("JAMMED: " .. jammedMsg)
                else
                    self.dashboard:setError("JAMMED: Unknown item stuck!")
                end
            end
        end
        return
    end

    -- If grid is empty, check for new recipes
    if self.crafterGrid:isEmpty() then
        local readyRecipe = self.recipeManager:findReadyRecipe(self.chest, self.crafterGrid:getCount())
        
        if readyRecipe then
            self.dashboard:setStatus("Filling Crafters...")
            self.dashboard:setMissingItems(nil)
            self.dashboard:draw()
            local success, err = self.chest:transferRecipe(readyRecipe, self.crafterGrid)
            
            if success then
                self.isCrafting = true
                self.craftStartTime = os.epoch("utc")
                self.dashboard:setLastCraft(readyRecipe.name)
                self.dashboard:setStatus("Crafting " .. readyRecipe.name .. "...")
                self.dashboard:draw()
                
                -- Force redstone pulse on all sides to start recipes that don't fill the entire grid
                for _, side in ipairs(redstone.getSides()) do
                    redstone.setOutput(side, true)
                end
                os_sleep(0.1)
                for _, side in ipairs(redstone.getSides()) do
                    redstone.setOutput(side, false)
                end
            else
                self.dashboard:setError(err or "Transfer Error!")
                os_sleep(2)
                self.dashboard:setError("")
            end
        else
            self.dashboard:setStatus("Waiting for items...")
            local missing = self.recipeManager:getMissingItems(self.chest, self.crafterGrid:getCount())
            self.dashboard:setMissingItems(missing)
        end
    else
        if not self.isCrafting then
            self.isCrafting = true
            self.craftStartTime = os.epoch("utc")
        end
    end
    
    self.dashboard:draw()
end

--- Runs the process continuously
function CrafterSystem:mainLoop()
    while true do
        if not self.isRecording then
            self:process()
        end
        os_sleep(0.5)
    end
end

--- Listens to keyboard events
function CrafterSystem:keyListener()
    while true do
        local event, key = os_pullEvent("key")
        if key == keys_r then
            self.dashboard:setStatus("Reloading recipes...")
            self.recipeManager:load(self.crafterGrid:getCount())
            self.crafterGrid:discoverCrafters()
            os_sleep(0.5)
            self.dashboard:setStatus("Waiting for items...")
        elseif key == keys.s then
            self:recordNewRecipeFlow()
        end
    end
end

--- Interactive flow to record a new recipe
function CrafterSystem:recordNewRecipeFlow()
    self.isRecording = true
    self.dashboard.suppressDraw = true
    
    term.clear()
    term.setCursorPos(1, 1)
    
    if term.isColor() then term.setTextColor(colors.cyan) end
    print("===================================")
    print("      Record New Recipe")
    print("===================================")
    if term.isColor() then term.setTextColor(colors.white) end
    
    print("\n1. Place the items in the physical crafters")
    print("2. Enter the name of your new recipe")
    print("   (Leave blank and press ENTER to cancel)")
    print("")
    term.write("Recipe Name: ")
    
    -- Sleep briefly to consume the ghost "char" event from pressing 'S'
    os_sleep(0.1)
    
    local name = read()
    if name == "" then
        self.isRecording = false
        self.dashboard.suppressDraw = false
        self.dashboard:draw()
        return
    end
    
    self.dashboard.suppressDraw = false
    self.dashboard:setStatus("Recording " .. name .. "...")
    self.dashboard:draw()
    
    local success, err = self.recipeManager:recordRecipe(name, self.crafterGrid)
    
    if success then
        self.dashboard:setError("Recipe saved successfully!")
        self.recipeManager:load(self.crafterGrid:getCount())
    else
        self.dashboard:setError("Record Error: " .. (err or "Unknown"))
    end
    
    os_sleep(2)
    self.dashboard:setError("")
    self.dashboard:setStatus("Waiting for items...")
    
    self.isRecording = false
    self.dashboard:draw()
end

--- Starts the system
function CrafterSystem:start()
    self.recipeManager:load(self.crafterGrid:getCount())
    parallel_waitForAll(
        function() self:mainLoop() end,
        function() self:keyListener() end
    )
end

return CrafterSystem

