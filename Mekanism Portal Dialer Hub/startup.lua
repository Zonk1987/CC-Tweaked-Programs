--[[
================================================================================
Mekanism Portal Hub v1.0.078-main
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
package.path = package.path .. ";" .. table.concat(corePaths, ";")

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
	local monitor = peripheral.find("monitor")
	if not monitor then
		return false, "Kein Monitor gefunden."
	end
	monitorName = peripheral.getName(monitor)
	return true
end, {
	"Verbinde einen fortgeschrittenen Monitor (Advanced Monitor)",
	"direkt mit dem PC oder per Netzwerkkabel und Modems.",
	"Aktiviere Modems immer mit einem Rechtsklick!",
})

local tpName
boot:addStep("teleporter", "Teleporter Scan", function()
	local teleporter = peripheral.find("mekanism:teleporter")
		or peripheral.find("teleporter")
		or peripheral.find("mekanismteleporter")
	if not teleporter then
		return false, "Kein Mekanism Teleporter gefunden."
	end
	tpName = peripheral.getName(teleporter)
	return true
end, {
	"Verbinde den Mekanism Teleporter mit dem PC.",
	"Benutze dazu Modems und Netzwerkkabel.",
})

boot:addStep("modem", "Modem Scan", function()
	local modem = peripheral.find("modem")
	if not modem then
		return "WARN", "Kein Modem gefunden."
	end
	return true
end, {
	"Ein Modem ist optional, aber notwendig fuer den Empfang von",
	"Recall-Signalen (Recall-Sender) aus anderen Dimensionen.",
})

boot:run()

-- Initialization
local systemConfig = {
	monitorSide = monitorName,
	tpSide = tpName,
	gridColumns = 4,
	gridRows = 4,
	recallChannel = 99,
	maxButtons = 24,
}

local bm = ButtonGrid.new(monitorName)
bm.mon.setTextScale(0.5) -- Locked at 0.5: Changing this breaks the line/char UI rendering

local system = HubSystem.new({
	bm = bm,
	tpSide = tpName,
	config = systemConfig,
})

system:run()
