--[[
================================================================================
Mekanism Portal Hub v1.0.070-main
================================================================================
Standardized Hub System for Interdimensional Portals.
================================================================================
]]
--

-- STRICT MODE (SAFE VERSION)
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
local HubSystem = require("HubSystem")
local ButtonGrid = require("ButtonGrid")
local BootAssistant = require("boot_assistant")
local ConfigStore = require("ConfigStore")
local ConfigGUI = require("ConfigGUI")
local Logger = require("Logger")

local configStore = ConfigStore.new("config.json", {
	hub_monitor = "top",
	hub_teleporter = "bottom",
	gridColumns = 4,
	gridRows = 4,
	recallChannel = 99,
})

local schema = {
	{ key = "hub_monitor", label = "Hub Monitor", type = "peripheral", peripheralType = "monitor", default = "top" },
	{
		key = "hub_teleporter",
		label = "Hub Teleporter",
		type = "peripheral",
		peripheralType = "teleporter",
		default = "bottom",
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
	title = "Portal Hub Loader",
	theme = "dark",
	enable_logging = true,
	log_file = "logs/portal_hub_boot.log",
	onSetup = function()
		local gui = ConfigGUI.new(configStore, schema)
		gui:run()
	end,
})

local monitorName = configStore:get("hub_monitor", "top")
boot:addStep("monitor", "Monitor Scan", function()
	if monitorName and HAL.wrap(monitorName) then
		local pType = HAL.getType(monitorName)
		if pType and pType:find("monitor") then
			return true
		end
	end

	local monitors = HAL.listNames("monitor")
	if #monitors == 0 then
		return false, "Kein Monitor gefunden."
	end
	monitorName = monitors[1]
	configStore:set("hub_monitor", monitorName, true)
	return true
end, {
	"Verbinde einen fortgeschrittenen Monitor (Advanced Monitor)",
	"direkt mit dem PC oder per Netzwerkkabel und Modems.",
	"Aktiviere Modems immer mit einem Rechtsklick!",
})

local tpName = configStore:get("hub_teleporter", "bottom")
boot:addStep("teleporter", "Teleporter Scan", function()
	if tpName and HAL.wrap(tpName) then
		local pType = HAL.getType(tpName)
		if pType and (pType:find("teleporter") or pType:find("portal")) then
			return true
		end
	end

	local teleporters = HAL.listNames("mekanism:teleporter")
	if #teleporters == 0 then
		teleporters = HAL.listNames("teleporter")
	end
	if #teleporters == 0 then
		teleporters = HAL.listNames("mekanismteleporter")
	end
	if #teleporters == 0 then
		return false, "Kein Mekanism Teleporter gefunden."
	end
	tpName = teleporters[1]
	configStore:set("hub_teleporter", tpName, true)
	return true
end, {
	"Verbinde den Mekanism Teleporter mit dem PC.",
	"Benutze dazu Modems und Netzwerkkabel.",
})

boot:addStep("modem", "Modem Scan", function()
	local modems = HAL.listNames("modem")
	if #modems == 0 then
		return "WARN", "Kein Modem gefunden."
	end
	return true
end, {
	"Ein Modem ist optional, aber notwendig fuer den Empfang von",
	"Recall-Signalen (Recall-Sender) aus anderen Dimensionen.",
	"Aktiviere Modems immer mit einem Rechtsklick!",
})

boot:run()

-- Register in HAL
HAL.register("hub_monitor", monitorName)
HAL.register("hub_teleporter", tpName)

-- Initialization
local systemConfig = {
	monitorSide = monitorName,
	tpSide = "hub_teleporter",
	gridColumns = configStore:get("gridColumns", 4),
	gridRows = configStore:get("gridRows", 4),
	recallChannel = configStore:get("recallChannel", 99),
	maxButtons = 24,
}

local bm = ButtonGrid.new(monitorName)
bm.mon.setTextScale(0.5) -- Locked at 0.5: Changing this breaks the line/char UI rendering

-- Initialize Logger instance
local logger = Logger.new({ logPath = "logs/portal.log" })

local system = HubSystem.new({
	bm = bm,
	tpSide = "hub_teleporter",
	config = systemConfig,
	logger = logger,
})

system:run()
