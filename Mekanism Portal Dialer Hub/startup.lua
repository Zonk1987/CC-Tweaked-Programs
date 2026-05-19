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
}
package.path = package.path .. ";" .. table.concat(corePaths, ";")

local HubSystem = require("HubSystem")
local ButtonGrid = require("ButtonGrid")

-- Hardware Discovery
local function findHardware()
	local monitor = peripheral.find("monitor")
	local teleporter = peripheral.find("mekanism:teleporter")
		or peripheral.find("teleporter")
		or peripheral.find("mekanismteleporter")

	local monitorName = monitor and peripheral.getName(monitor)
	local tpName = teleporter and peripheral.getName(teleporter)

	print("Hardware Scan:")
	print("- Monitor:    " .. (monitorName or "MISSING"))
	print("- Teleporter: " .. (tpName or "MISSING"))

	return monitorName, tpName
end

local monitorName, tpName = findHardware()

if not monitorName or not tpName then
	error("Critical Hardware Missing! Check Modems & Connections.")
end

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
