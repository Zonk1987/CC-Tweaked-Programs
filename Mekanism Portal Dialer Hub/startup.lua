--[[
================================================================================
Mekanism Portal Hub v1.0.119-main
================================================================================
Standardized Hub System for Interdimensional Portals.
Powered by Enterprise AppRuntime & Fiber Scheduler.
================================================================================
]]

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
	"/lib/core/runtime/?.lua",
}
local localPaths = {
	"/system/?.lua",
	"/ui/?.lua",
}
package.path = package.path .. ";" .. table.concat(corePaths, ";") .. ";" .. table.concat(localPaths, ";")

local AppRuntime = require("AppRuntime")
local HubApp = require("HubApp")

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

AppRuntime.run(HubApp, {
	title = "Portal Hub",
	configName = "config.json",
	defaultConfig = {
		hub_monitor = "top",
		hub_teleporter = "bottom",
		gridColumns = 4,
		gridRows = 4,
		recallChannel = 99,
	},
	schema = schema,
	requiredPeripherals = { "hub_monitor", "hub_teleporter" },
	logFile = "logs/portal.log",
}, ...)
