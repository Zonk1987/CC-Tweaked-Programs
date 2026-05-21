--[[
================================================================================
Mekanism Portal Recall Sender v1.0.136-main
================================================================================
Standardized Recall Sender for Interdimensional Portals.
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
local RecallSenderApp = require("RecallSenderApp")

local schema = {
	{ key = "target", label = "Ziel-Ort (Name)", type = "string", default = "Unknown" },
	{ key = "channel", label = "Modem-Kanal", type = "number", default = 99 },
}

AppRuntime.run(RecallSenderApp, {
	title = "Recall Sender",
	configName = "config.json",
	defaultConfig = {
		target = "Unknown",
		channel = 99,
	},
	schema = schema,
	logFile = "logs/recall_sender.log",
}, ...)
