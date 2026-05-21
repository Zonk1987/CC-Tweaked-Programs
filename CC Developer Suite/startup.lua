--[[
================================================================================
CC:Tweaked Developer Suite v1.0.123-main
================================================================================
Advanced Hardware Inspection & Diagnostic Toolkit.
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
local DevSuiteApp = require("DevSuiteApp")

local schema = {
	{ key = "modem", label = "Drahtloses Modem", type = "peripheral", peripheralType = "modem", default = "back" },
	{ key = "drive", label = "Disk-Laufwerk", type = "peripheral", peripheralType = "drive", default = "top" },
}

AppRuntime.run(DevSuiteApp, {
	title = "DevSuite",
	configName = "config.json",
	defaultConfig = {
		modem = "back",
		drive = "top",
	},
	schema = schema,
	logFile = "logs/dev_suite.log",
}, ...)
