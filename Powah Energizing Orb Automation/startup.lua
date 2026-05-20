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
local localPaths = {
	"/system/?.lua",
	"/ui/?.lua",
}
package.path = package.path .. ";" .. table.concat(corePaths, ";") .. ";" .. table.concat(localPaths, ";")

-- Load the main system
local HAL = require("HAL")
local PowahSystem = require("PowahSystem")
local BootAssistant = require("boot_assistant")
local ConfigStore = require("ConfigStore")
local ConfigGUI = require("ConfigGUI")

local configStore = ConfigStore.new("config.json", {
	buffer = "left",
	me_bridge = "back",
	ae_scanner = "top",
})

local schema = {
	{ key = "buffer", label = "Puffer-Kiste", type = "peripheral", peripheralType = "inventory", default = "left" },
	{ key = "me_bridge", label = "ME Bridge", type = "peripheral", peripheralType = "meBridge", default = "back" },
	{ key = "ae_scanner", label = "AE Scanner", type = "peripheral", peripheralType = "ae2_scanner", default = "top" },
}

-- Check CLI Arguments
local args = { ... }
local shouldRunConfig = false
for _, arg in ipairs(args) do
	if arg == "--config" or arg == "-c" then
		shouldRunConfig = true
	end
end

if shouldRunConfig then
	local gui = ConfigGUI.new(configStore, schema)
	gui:run()
	term.clear()
	term.setCursorPos(1, 1)
	print("Setup abgeschlossen.")
	return
end

local boot = BootAssistant.new({
	title = "Powah Automation Loader",
	theme = "dark",
	enable_logging = true,
	log_file = "logs/powah_boot.log",
	onSetup = function()
		local gui = ConfigGUI.new(configStore, schema)
		gui:run()
	end,
})

local chestName = configStore:get("buffer", "left")
local chestPeripheral
boot:addStep("chest", "Puffer-Kiste Check", function()
	-- 1. Check if configured chest exists and is an inventory
	if chestName and HAL.wrap(chestName) and HAL.hasType(chestName, "inventory") then
		chestPeripheral = HAL.wrap(chestName)
		return true
	end

	-- 2. Prioritize typical dedicated chests/buffers
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
		local found = HAL.listNames(typeName)
		if found[1] then
			chestName = found[1]
			chestPeripheral = HAL.wrap(found[1])
			configStore:set("buffer", chestName, true)
			break
		end
	end

	-- Fallback: Any connected peripheral that has inventory capability,
	-- EXCEPT it must not be a powah energizing orb or an optional component like me_bridge/scanner
	if not chestPeripheral then
		local all = HAL.getNames()
		for _, name in ipairs(all) do
			local pType = HAL.getType(name)
			local isOrb = pType and (pType:find("energizing_orb") or pType:find("powah"))
			local isMeBridge = pType and (pType:find("meBridge") or pType:find("me_bridge"))
			local isScanner = pType and pType:find("ae2_scanner")

			if not isOrb and not isMeBridge and not isScanner then
				-- Check if it is an inventory
				local wrapped = HAL.wrap(name)
				if
					HAL.hasType(name, "inventory")
					or (type(wrapped) == "table" and type(wrapped["list"]) == "function")
				then
					chestName = name
					chestPeripheral = wrapped
					configStore:set("buffer", chestName, true)
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

local meBridgeName = configStore:get("me_bridge", "back")
boot:addStep("me_bridge", "ME Bridge Check", function()
	if meBridgeName and HAL.wrap(meBridgeName) then
		local pType = HAL.getType(meBridgeName)
		if pType and (pType:find("meBridge") or pType:find("me_bridge")) then
			return true
		end
	end

	local bridges = HAL.listNames("meBridge")
	if #bridges == 0 then
		bridges = HAL.listNames("me_bridge")
	end
	if #bridges == 0 then
		return false, "Keine ME Bridge gefunden."
	end
	meBridgeName = bridges[1]
	configStore:set("me_bridge", meBridgeName, true)
	return true
end, {
	"Eine ME Bridge ist erforderlich fuer den Betrieb",
	"und das automatische Rezept-Import-Menue.",
	"Verbinde eine ME Bridge (AP) ueber ein Netzwerkkabel.",
})

local aeScannerName = configStore:get("ae_scanner", "top")
boot:addStep("scanner", "AE2 Scanner Check", function()
	if aeScannerName and HAL.wrap(aeScannerName) then
		local pType = HAL.getType(aeScannerName)
		if pType and pType:find("ae2_scanner") then
			return true
		end
	end

	local scanners = HAL.listNames("ae2_scanner")
	if #scanners == 0 then
		return "WARN", "Kein AE2 Scanner gefunden."
	end
	aeScannerName = scanners[1]
	configStore:set("ae_scanner", aeScannerName, true)
	return true
end, {
	"Ein AE2 Scanner ist optional, hilft aber bei",
	"der Erfassung des AE2-Netzwerkstatus.",
})

boot:addStep("orbs", "Energizing Orbs Scan", function()
	local orbs = HAL.listNames("powah:energizing_orb")
	if #orbs == 0 then
		return "WARN", "Keine Energizing Orbs gefunden."
	end
	return true
end, {
	"Verbinde die Energizing Orbs ueber Netzwerkkabel",
	"und kabelgebundene Modems (Wired Modems) mit dem PC.",
	"Aktiviere die Modems mit einem Rechtsklick!",
})

boot:run()

-- Register in HAL
HAL.register("buffer", chestName)
if meBridgeName then
	HAL.register("me_bridge", meBridgeName)
end
if aeScannerName then
	HAL.register("ae_scanner", aeScannerName)
end

local system = PowahSystem.new({
	chestName = "buffer",
	recipeFile = "powah_recipes.json",
	meBridgeName = meBridgeName and "me_bridge" or nil,
	aeScannerName = aeScannerName and "ae_scanner" or nil,
})

system:run()
