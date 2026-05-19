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
local BootAssistant = require("boot_assistant")

local boot = BootAssistant.new({
	title = "Powah Automation Loader",
	theme = "dark",
	enable_logging = true,
	log_file = "logs/powah_boot.log",
})

local chestPeripheral
boot:addStep("chest", "Puffer-Kiste Check", function()
	chestPeripheral = peripheral.find("minecraft:chest")
		or peripheral.find("ironchest:diamond_chest")
		or peripheral.find("expandedstorage:netherite_chest")
	if not chestPeripheral then
		return false, "Keine Kiste gefunden."
	end
	return true
end, {
	"Setze eine Kiste (z.B. minecraft:chest, ironchest:diamond_chest) direkt neben den PC.",
	"Diese Kiste empfaengt die Items vom AE2-System.",
})

local meBridgeName
boot:addStep("me_bridge", "ME Bridge Check", function()
	local meBridge = peripheral.find("meBridge") or peripheral.find("me_bridge")
	if not meBridge then
		return "WARN", "Keine ME Bridge gefunden."
	end
	meBridgeName = peripheral.getName(meBridge)
	return true
end, {
	"Eine ME Bridge ist optional, wird aber fuer das",
	"automatische Rezept-Import-Menue benoetigt.",
	"Verbinde eine ME Bridge (AP) ueber ein Netzwerkkabel.",
})

local aeScannerName
boot:addStep("scanner", "AE2 Scanner Check", function()
	local aeScanner = peripheral.find("ae2_scanner")
	if not aeScanner then
		return "WARN", "Kein AE2 Scanner gefunden."
	end
	aeScannerName = peripheral.getName(aeScanner)
	return true
end, {
	"Ein AE2 Scanner ist optional, hilft aber bei",
	"der Erfassung des AE2-Netzwerkstatus.",
})

boot:addStep("orbs", "Energizing Orbs Scan", function()
	local orbs = peripheral.find("powah:energizing_orb")
	if not orbs then
		return "WARN", "Keine Energizing Orbs gefunden."
	end
	return true
end, {
	"Verbinde die Energizing Orbs ueber Netzwerkkabel",
	"und kabelgebundene Modems (Wired Modems) mit dem PC.",
	"Aktiviere die Modems mit einem Rechtsklick!",
})

boot:run()

-- Execution Setup
local chestName = chestPeripheral and peripheral.getName(chestPeripheral) or "left"

local system = PowahSystem.new({
	chestName = chestName,
	recipeFile = "powah_recipes.json",
	meBridgeName = meBridgeName,
	aeScannerName = aeScannerName,
})

system:start()
