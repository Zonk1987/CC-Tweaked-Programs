--[[
================================================================================
Powah Energizing Orb Automation v1.0.055-main
================================================================================

DESCRIPTION:
This system fully automates the Powah Energizing Orb crafting process.
It features a high-performance modular architecture with deep AE2 integration.

CHANGELOG:
- Compliant with AGENTS.md rules.
- Modular UI handling (ImportMenu).
- Improved peripheral validation.

HARDWARE SETUP:
1. Place an Advanced Computer.
2. Connect a Chest/Buffer next to it (e.g., "left"). This receives AE2 items.
3. Connect Powah Energizing Orbs via Cables and Wired Modems.
4. (Required) Connect an ME Bridge for the automated pattern import menu.
5. Set your AE2 Pattern Provider to "Blocking Mode" facing the Buffer Chest.
================================================================================
]]
--

-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Configure library paths for lib/core
local corePaths = {
	"/lib/core/base/?.lua",
	"/lib/core/peripherals/?.lua",
	"/lib/core/inventory/?.lua",
	"/lib/core/recipes/?.lua",
	"/lib/core/ui/?.lua",
	"/lib/core/network/?.lua",
	"/lib/core/redstone/?.lua",
}
package.path = package.path .. ";" .. table.concat(corePaths, ";")

-- Load the main system
local PowahSystem = require("PowahSystem")

-- Execution Setup
local chestPeripheral = peripheral.find("minecraft:chest")
	or peripheral.find("ironchest:diamond_chest")
	or peripheral.find("expandedstorage:netherite_chest")
local chestName = chestPeripheral and peripheral.getName(chestPeripheral) or "left"

-- Robust ME Bridge & Scanner detection
local meBridge = peripheral.find("meBridge") or peripheral.find("me_bridge")
local meBridgeName = meBridge and peripheral.getName(meBridge)

local aeScanner = peripheral.find("ae2_scanner")
local aeScannerName = aeScanner and peripheral.getName(aeScanner)

print("Hardware Check:")
print("- Chest:      " .. chestName)
print("- ME Bridge:  " .. (meBridgeName or "Not found"))
print("- AE Scanner: " .. (aeScannerName or "None detected"))
if aeScannerName then
	local pType = peripheral.getType(aeScannerName)
	print("  -> Found at: " .. aeScannerName)
	print("  -> Type:     " .. (pType or "unknown"))
end
os.sleep(1)

local system = PowahSystem.new({
	chestName = chestName,
	recipeFile = "powah_recipes.json",
	meBridgeName = meBridgeName,
	aeScannerName = aeScannerName,
})

system:start()
