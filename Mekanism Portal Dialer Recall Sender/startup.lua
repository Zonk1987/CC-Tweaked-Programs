--[[
================================================================================
Mekanism Portal Recall Sender v1.0.107-main
================================================================================
Standardized Recall Sender for Interdimensional Portals.
Powered by Enterprise AppRuntime & Fiber Scheduler.
================================================================================
]]

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
