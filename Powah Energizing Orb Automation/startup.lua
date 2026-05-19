--[[
================================================================================
Powah Energizing Orb Automation v1.0.070-main
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
	-- Prioritize typical dedicated chests/buffers
	local prioritized = {
		"minecraft:chest",
		"ironchest:diamond_chest",
		"expandedstorage:netherite_chest",
		"ae2:ingredient_buffer",
		"ae2:pattern_provider",
		"sophisticatedstorage:barrel",
		"sophisticatedstorage:chest",
		"ironbarrels:barrel",
		"barrel",
	}

	for _, typeName in ipairs(prioritized) do
		local found = peripheral.find(typeName)
		if found then
			chestPeripheral = found
			break
		end
	end

	-- Fallback: Any connected peripheral that has inventory capability,
	-- EXCEPT it must not be a powah energizing orb or an optional component like me_bridge/scanner
	if not chestPeripheral then
		local all = peripheral.getNames()
		for _, name in ipairs(all) do
			local pType = peripheral.getType(name)
			local isOrb = pType and (pType:find("energizing_orb") or pType:find("powah"))
			local isMeBridge = pType and (pType:find("meBridge") or pType:find("me_bridge"))
			local isScanner = pType and pType:find("ae2_scanner")

			if not isOrb and not isMeBridge and not isScanner then
				-- Check if it is an inventory
				local wrapped = peripheral.wrap(name)
				if
					peripheral.hasType(name, "inventory")
					or (type(wrapped) == "table" and type(wrapped["list"]) == "function")
				then
					chestPeripheral = wrapped
					break
				end
			end
		end
	end

	if not chestPeripheral then
		return false, "Keine Puffer-Kiste oder Puffer-Inventar gefunden."
	end
	return true
end, {
	"Setze eine Puffer-Kiste, einen ME Ingredient Buffer oder ein anderes",
	"Puffer-Inventar (z.B. Sophisticated Storage, Barrels, Backpacks) direkt",
	"neben den PC oder verbinde sie/ihn per Netzwerkkabel.",
	"Dieser Speicher empfaengt die Items vom AE2/Refined Storage System.",
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
