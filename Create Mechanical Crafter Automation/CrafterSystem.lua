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
local ManageRecipes = require("ManageRecipes")
local RedstoneController = require("RedstoneController")

-- Localize globals
local setmetatable = setmetatable
local os_sleep = os.sleep
local os_epoch = os.epoch
local os_pullEvent = os.pullEvent
local parallel_waitForAll = (parallel --[[@as any]]).waitForAll

local colors = colors
local keys = keys
local keys_r = keys.r
local keys_s = keys.s
local keys_m = keys.m

---@class CrafterSystem
---@field chest Chest
---@field dashboard Dashboard
---@field recipeManager RecipeManager
---@field crafterGrid CrafterGrid
---@field isCrafting boolean
---@field craftStartTime number
---@field isRecording boolean
---@field manageRecipes ManageRecipes
local CrafterSystem = {}
CrafterSystem.__index = CrafterSystem

--- Creates the main system
---@param options table
---@return CrafterSystem
function CrafterSystem.new(options)
    local self = setmetatable({}, CrafterSystem)
    self.chest = Chest.new(options.chestName)
    self.dashboard = Dashboard.new()
    self.recipeManager = RecipeManager.new(options.recipeFile or "crafter_recipes.json", self.dashboard)
    self.crafterGrid = CrafterGrid.new()
    self.isCrafting = false
    self.craftStartTime = 0
    self.isRecording = false
    self.manageRecipes = ManageRecipes.new({
        recipeManager = self.recipeManager,
        dashboard = self.dashboard
    })
    return self
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

    -- Clear transient errors
    if self.dashboard.errorMsg == "Buffer chest missing!" or self.dashboard.errorMsg == "No Mechanical Crafters found!" then
        self.dashboard:setError("")
    end

    self.dashboard:setCrafterCount(self.crafterGrid:getCount())

    if self.isCrafting then
        self:handleOngoingCraft()
    else
        self:handleNewCraft()
    end

    self.dashboard:draw()
end

--- Logic for when a craft is currently in progress
function CrafterSystem:handleOngoingCraft()
    self.dashboard:setStatus("Crafting in progress...")
    self.dashboard:setMissingItems(nil)
    self.dashboard:draw()

    os_sleep(1)

    if self.crafterGrid:isEmpty() then
        self.isCrafting = false
        self.dashboard:setError("")
        self.dashboard:setStatus("Waiting for items...")
    else
        -- Jam detection (30 seconds)
        if (os_epoch("utc") - self.craftStartTime) > 30000 then
            local jammedMsg = self.crafterGrid:getJammedItem()
            self.dashboard:setError("JAMMED: " .. (jammedMsg or "Unknown item stuck!"))
        end
    end
end

--- Logic for starting a new craft
function CrafterSystem:handleNewCraft()
    if not self.crafterGrid:isEmpty() then
        self.isCrafting = true
        self.craftStartTime = os_epoch("utc")
        return
    end

    local readyRecipe = self.recipeManager:findReadyRecipe(self.chest, self.crafterGrid:getCount())
    if readyRecipe then
        self.dashboard:setStatus("Filling Crafters...")
        self.dashboard:setMissingItems(nil)
        self.dashboard:draw()

        local success, err = self.chest:transferRecipe(readyRecipe, self.crafterGrid)
        if success then
            self.isCrafting = true
            self.craftStartTime = os_epoch("utc")
            self.dashboard:setLastCraft(readyRecipe.name)
            self.dashboard:setStatus("Crafting " .. readyRecipe.name .. "...")
            RedstoneController.pulseAll()
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
        local _, key = os_pullEvent("key")
        if key == keys_r then
            self.dashboard:setStatus("Reloading recipes...")
            self.recipeManager:load(self.crafterGrid:getCount())
            self.crafterGrid:discoverCrafters()
            os_sleep(0.5)
            self.dashboard:setStatus("Waiting for items...")
        elseif key == keys_s then
            self:recordNewRecipeFlow()
        elseif key == keys_m then
            self.manageRecipes:open()
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
    term.setTextColor(colors.white)
    print("\n1. Place the items in the physical crafters")
    print("2. Enter the name of your new recipe")
    print("   (Leave blank and press ENTER to cancel)")
    term.write("\nRecipe Name: ")

    os_sleep(0.1) -- Debounce
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
        -- Start crafting the recorded recipe immediately
        RedstoneController.pulseAll()
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
