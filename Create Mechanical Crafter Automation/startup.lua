--[[
================================================================================
Create Mechanical Crafter Automation (CC:Tweaked)
================================================================================

DESCRIPTION:
This script automates the full crafting cycle for the Create mod's Mechanical
Crafters. It reads a recipe file, detects the correct ingredients in the buffer
chest, distributes them into the correct crafter slots, and triggers crafting
via a redstone pulse. Designed for seamless AE2 / RS Blocking Mode integration.

INSTALLATION:
Run the universal installer on your ComputerCraft terminal:
  pastebin run vYK0cPkU

HARDWARE SETUP:
1. Place an Advanced Computer.
2. Build a Mechanical Crafter grid (e.g. 3x3, 5x5, 9x9).
3. Attach a Wired Modem to every Mechanical Crafter and connect them
   to the Computer via Networking Cables. Turn all modems ON (red ring).
4. Place a Buffer Chest or Barrel next to the Computer, also with a modem.
5. Connect Redstone from any side of the Computer to at least one Crafter.
6. (Optional) Use an AE2 Pattern Provider or RS Crafter in Blocking Mode
   to automate ingredient delivery to the buffer chest.

CALIBRATION (first run only):
On first start, the system will guide you through a modem-click calibration
to learn your grid layout. Calibration is saved in crafter_mapping.json.
Delete this file to recalibrate.

RECORDING RECIPES (in-game):
1. Manually place recipe items into the Mechanical Crafters.
2. Press 'S' on the terminal, type a name and press Enter.
3. The system scans the grid, saves the recipe and reloads automatically.

CONFIGURATION:
No manual config file needed. The buffer chest is auto-detected from the
modem network (local side inventories are intentionally ignored).
Edit crafter_recipes.json to add fuzzy matching with '~' prefix.

HOTKEYS:
  S  ->  Record a new recipe from the current crafter layout
  R  ->  Hot-reload crafter_recipes.json without restarting
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
-- Set module search path to include current directory
package.path = package.path .. ";./?.lua"

local CrafterSystem = require("CrafterSystem")

-- Configuration
local RECIPE_FILE = "crafter_recipes.json"

local function autoDetectChest()
    local allPeripherals = peripheral.getNames()
    local localFaces = {top=true, bottom=true, left=true, right=true, front=true, back=true}
    for _, name in ipairs(allPeripherals) do
        local pType = peripheral.getType(name)
        if pType ~= "create:mechanical_crafter" and peripheral.hasType(name, "inventory") then
            -- Ignore local faces to force the use of a networked inventory
            if not localFaces[name] then
                return name
            end
        end
    end
    return nil
end

local function main()
    local chestName = autoDetectChest()
    if not chestName then
        error("No buffer inventory found! Please connect a chest to the modem.")
    end
    local system = CrafterSystem:new(chestName, RECIPE_FILE)
    system:start()
end

local ok, err = pcall(main)
if not ok then
    term.clear()
    term.setCursorPos(1, 1)
    print("Fatal Error in CrafterSystem:")
    print(err)
end

