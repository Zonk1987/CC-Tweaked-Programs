--[[
================================================================================
Powah Energizing Orb Automation v1.0.136-main
================================================================================
Automates Powah Energizing Orbs with AE2 integration.
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
local PowahApp = require("PowahApp")

local schema = {
	{ key = "buffer", label = "Puffer-Kiste", type = "peripheral", peripheralType = "inventory", default = "left" },
	{ key = "me_bridge", label = "ME Bridge", type = "peripheral", peripheralType = "meBridge", default = "back" },
	{ key = "ae_scanner", label = "AE Scanner", type = "peripheral", peripheralType = "ae2_scanner", default = "top" },
}

AppRuntime.run(PowahApp, {
	title = "Powah Automation",
	configName = "config.json",
	defaultConfig = {
		buffer = "left",
		me_bridge = "back",
		ae_scanner = "top",
	},
	schema = schema,
	requiredPeripherals = { "buffer", "me_bridge" },
	logFile = "logs/powah.log",
}, ...)
