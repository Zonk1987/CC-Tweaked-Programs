--[[
================================================================================
Create Mechanical Crafter Automation v1.0.070-main
================================================================================
Automates Mechanical Crafter grids from the 'Create' mod.
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
	"/lib/core/logger/?.lua",
}
local localPaths = {
	"/system/?.lua",
	"/ui/?.lua",
}
package.path = package.path .. ";" .. table.concat(corePaths, ";") .. ";" .. table.concat(localPaths, ";")

local HAL = require("HAL")
local CrafterSystem = require("CrafterSystem")
local BootAssistant = require("boot_assistant")
local ConfigStore = require("ConfigStore")
local ConfigGUI = require("ConfigGUI")
local Logger = require("Logger")

local configStore = ConfigStore.new("config.json", {
	buffer = "left",
	color = "white",
})

local schema = {
	{ key = "buffer", label = "Puffer-Inventar", type = "peripheral", peripheralType = "inventory", default = "left" },
	{
		key = "color",
		label = "Textfarbe",
		type = "choice",
		choices = { "white", "yellow", "orange", "red", "blue", "green", "black" },
		default = "white",
	},
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
	title = "Crafter Loader",
	theme = "dark",
	enable_logging = true,
	log_file = "logs/crafter_boot.log",
	onSetup = function()
		local gui = ConfigGUI.new(configStore, schema)
		gui:run()
	end,
})

-- Execution Setup: Smart discovery for the buffer inventory
local chestName = configStore:get("buffer", "left")
boot:addStep("chest", "Puffer-Inventar Check", function()
	-- 1. Check if configured chest exists and is an inventory
	if chestName and HAL.wrap(chestName) and HAL.hasType(chestName, "inventory") then
		return true
	end

	-- 2. Prioritize specific modded types if configured doesn't exist
	local prioritized = {
		"sophisticatedstorage:barrel",
		"sophisticatedstorage:chest",
		"ironbarrels:barrel",
		"expandedstorage:netherite_chest",
		"minecraft:chest",
		"barrel",
	}

	local candidates = {}
	for _, typeName in ipairs(prioritized) do
		local found = HAL.listNames(typeName)
		for _, name in ipairs(found) do
			table.insert(candidates, name)
		end
	end

	-- Sort candidates: prefer network names (with :) over side names
	for _, name in ipairs(candidates) do
		if name:find(":") or name:find("_") then
			chestName = name
			configStore:set("buffer", chestName, true)
			return true
		end
	end
	if candidates[1] then
		chestName = candidates[1]
		configStore:set("buffer", chestName, true)
		return true
	end

	-- Fallback: Any inventory that isn't a mechanical crafter
	local all = HAL.getNames()
	for _, name in ipairs(all) do
		if HAL.getType(name) ~= "create:mechanical_crafter" and HAL.hasType(name, "inventory") then
			chestName = name
			configStore:set("buffer", chestName, true)
			return true
		end
	end

	chestName = "left"
	return "WARN", "Standard 'left' wird als Fallback genutzt."
end, {
	"Setze eine Puffer-Kiste oder ein anderes Puffer-Inventar",
	"direkt neben den PC oder verbinde es per Netzwerkkabel.",
	"Dieses Inventar empfaengt die Crafting-Items.",
})

boot:addStep("calibration", "Crafter Kalibrierung", function()
	if not fs.exists("crafter_mapping.json") then
		return "WARN", "Kalibrierung fehlt."
	end

	local file = fs.open("crafter_mapping.json", "r")
	if not file then
		return "WARN", "Mapping-Datei konnte nicht gelesen werden."
	end

	local content = file.readAll()
	file.close()

	if not content or content == "" then
		return "WARN", "Mapping-Datei ist leer."
	end

	local mapping = textutils.unserializeJSON(content, {})
	if not mapping or #mapping == 0 then
		return "WARN", "Keine Crafter kalibriert."
	end

	-- Verify connected crafters
	local missingCount = 0
	for _, name in ipairs(mapping) do
		if not HAL.wrap(name) then
			missingCount = missingCount + 1
		end
	end

	if missingCount > 0 then
		return "WARN", missingCount .. " von " .. #mapping .. " Craftern fehlen!"
	end

	return true
end, {
	"Das System prueft, ob die Crafter-Kalibrierung existiert.",
	"Falls diese fehlt oder unvollstaendig ist, startet beim",
	"Verlassen des Boot-Screens das interaktive Setup-Menue.",
})

boot:run()

-- Register chest in HAL
HAL.register("buffer", chestName)

-- Initialize Logger instance
local logger = Logger.new({ logPath = "logs/crafter.log" })

---@type CrafterSystem
local system = CrafterSystem.new({
	chestName = "buffer",
	recipeFile = "crafter_recipes.json",
	logger = logger,
})

-- Pass chest name to dashboard for display
system.dashboard.chestName = chestName

system:run()
