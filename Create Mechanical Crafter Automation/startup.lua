--[[
================================================================================
Create Mechanical Crafter Automation v1.0.028-main
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

-- Execution Setup: Smart discovery for the buffer inventory
local function findBufferChest()
    -- Prioritize specific modded types
    local prioritized = {
        "sophisticatedstorage:barrel",
        "sophisticatedstorage:chest",
        "ironbarrels:barrel",
        "expandedstorage:netherite_chest",
        "minecraft:chest",
        "barrel"
    }
    
    local candidates = {}
    for _, typeName in ipairs(prioritized) do
        local found = { peripheral.find(typeName) }
        for _, obj in ipairs(found) do
            table.insert(candidates, peripheral.getName(obj))
        end
    end
    
    -- Sort candidates: prefer network names (with :) over side names
    for _, name in ipairs(candidates) do
        if name:find(":") or name:find("_") then
            return name
        end
    end
    if candidates[1] then return candidates[1] end
    
    -- Fallback: Any inventory that isn't a mechanical crafter
    local all = peripheral.getNames()
    for _, name in ipairs(all) do
        if peripheral.getType(name) ~= "create:mechanical_crafter" and 
           peripheral.hasType(name, "inventory") then
            return name
        end
    end
    
    return "left" -- Absolute fallback
end

local chestName = findBufferChest()

print("Hardware Check:")
print("- Buffer Inventory: " .. chestName)
os.sleep(1)

---@type CrafterSystem
local system = CrafterSystem.new({
    chestName = chestName,
    recipeFile = "crafter_recipes.json"
})

-- Pass chest name to dashboard for display
system.dashboard.chestName = chestName

system:start()
