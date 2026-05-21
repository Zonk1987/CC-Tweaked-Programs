--[[
================================================================================
CC:Tweaked Developer Suite v1.0.107-main
================================================================================
Advanced Hardware Inspection & Diagnostic Toolkit.
Powered by Enterprise AppRuntime & Fiber Scheduler.
================================================================================
]]

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
