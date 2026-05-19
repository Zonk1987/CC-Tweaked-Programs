--[[
================================================================================
Mekanism Portal Hub v1.0.083-main
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

local boot = BootAssistant.new({
	title = "Portal Hub Loader",
	theme = "dark",
	enable_logging = true,
	log_file = "logs/portal_hub_boot.log",
})

local monitorName
boot:addStep("monitor", "Monitor Scan", function()
	local monitors = HAL.listNames("monitor")
	if #monitors == 0 then
		return false, "Kein Monitor gefunden."
	end
	monitorName = monitors[1]
	return true
end, {
	"Verbinde einen fortgeschrittenen Monitor (Advanced Monitor)",
	"direkt mit dem PC oder per Netzwerkkabel und Modems.",
	"Aktiviere Modems immer mit einem Rechtsklick!",
})

local tpName
boot:addStep("teleporter", "Teleporter Scan", function()
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
})

boot:run()

-- Register in HAL
HAL.register("hub_monitor", monitorName)
HAL.register("hub_teleporter", tpName)

-- Initialization
local systemConfig = {
	monitorSide = monitorName,
	tpSide = "hub_teleporter",
	gridColumns = 4,
	gridRows = 4,
	recallChannel = 99,
	maxButtons = 24,
}

local bm = ButtonGrid.new(monitorName)
bm.mon.setTextScale(0.5) -- Locked at 0.5: Changing this breaks the line/char UI rendering

local system = HubSystem.new({
	bm = bm,
	tpSide = "hub_teleporter",
	config = systemConfig,
})

system:run()
