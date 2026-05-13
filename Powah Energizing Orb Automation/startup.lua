--[[
================================================================================
Powah Energizing Orb Automation (V5.1 ME Bridge Edition)
================================================================================

DESCRIPTION:
This system fully automates the Powah Energizing Orb crafting process. 
It features a high-performance modular architecture with deep AE2 integration.

NEW IN V5.1:
- AE2 ME Bridge Integration: Read patterns directly from your ME network.
- Smart Importer: Press [I] to browse and add recipes automatically.
- Modpack Filter: Support for non-Powah recipes via [F] key.
- Bulk Support: Automatic multiplier calculation for large recipes.
- Pretty-JSON: Auto-formatted recipe file for easy manual editing.

HARDWARE SETUP:
1. Place an Advanced Computer.
2. Connect a Chest/Buffer next to it (e.g., "left"). This receives AE2 items.
3. Connect Powah Energizing Orbs via Cables and Wired Modems.
4. (Optional) Connect an ME Bridge for the automated import menu.
5. Set your AE2 Pattern Provider to "Blocking Mode" facing the Buffer Chest.

CONFIGURATION:
Scroll to the bottom of this file. Change "left" in `PowahSystem:new("left", ...)` 
to your buffer side or network ID (e.g., "minecraft:chest_0").

HOW TO ADD RECIPES:
The easiest way is using the AE2 Importer:
1. Create a Processing Pattern in AE2 and put it in a Provider.
2. Press [I] on the Computer Dashboard.
3. Select your recipe and press [ENTER] to sync it to 'rezepte.json'.

HOTKEYS:
- Press 'R' to hot-reload recipes.
- Press 'I' for the AE2 Import Menu.
================================================================================
]] --



-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Load the main system
local PowahSystem = require("PowahSystem")

-- Execution Setup
local chestName = peripheral.find("minecraft:chest") or peripheral.find("ironchest:diamond_chest") or peripheral.find("expandedstorage:netherite_chest") or "left"

-- Robust ME Bridge detection
local meBridge = peripheral.find("meBridge") or peripheral.find("me_bridge")
local meBridgeName = meBridge and peripheral.getName(meBridge)

print("Hardware Check:")
print("- Chest:   " .. chestName)
print("- ME Bridge: " .. (meBridgeName or "Not found"))
os.sleep(1)

local system = PowahSystem.new(chestName, "rezepte.json", meBridgeName)
system:start()