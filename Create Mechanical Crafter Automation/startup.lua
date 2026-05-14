--[[
================================================================================
Create Mechanical Crafter Automation (V2.1 AGENTS Edition)
================================================================================
Automates Mechanical Crafter grids from the 'Create' mod.
================================================================================
]]--

-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Configure library paths for lib/core
local corePaths = {
    "/lib/core/base/?.lua",
    "/lib/core/peripherals/?.lua",
    "/lib/core/inventory/?.lua",
    "/lib/core/recipes/?.lua",
    "/lib/core/ui/?.lua",
    "/lib/core/network/?.lua",
    "/lib/core/redstone/?.lua"
}
package.path = package.path .. ";" .. table.concat(corePaths, ";")

local CrafterSystem = require("CrafterSystem")

-- Execution Setup
local chestName = peripheral.find("minecraft:chest") 
               or peripheral.find("ironchest:diamond_chest") 
               or peripheral.find("expandedstorage:netherite_chest")
               or peripheral.find("barrel")
               or peripheral.find("ironbarrels:barrel")
               or "left"

print("Hardware Check:")
print("- Buffer Chest: " .. chestName)
os.sleep(1)

---@type CrafterSystem
local system = CrafterSystem.new({
    chestName = chestName,
    recipeFile = "crafter_recipes.json"
})

-- Pass chest name to dashboard for display
system.dashboard.chestName = chestName

system:start()
