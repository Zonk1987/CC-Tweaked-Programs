--[[
================================================================================
Create Mechanical Crafter Automation v1.0.107-main
================================================================================
Automates Mechanical Crafter grids from the 'Create' mod.
Powered by Enterprise AppRuntime & Fiber Scheduler.
================================================================================
]]

local AppRuntime = require("AppRuntime")
local CrafterApp = require("CrafterApp")

local schema = {
	{ key = "buffer", label = "Puffer-Inventar", type = "peripheral", peripheralType = "inventory", default = "left" },
	{
		key = "color",
		label = "Textfarbe",
		type = "choice",
		choices = { "white", "yellow", "orange", "red", "blue", "green", "black" },
		default = "white",
	},
}

AppRuntime.run(CrafterApp, {
	title = "Mechanical Crafter",
	configName = "config.json",
	defaultConfig = {
		buffer = "left",
		color = "white",
	},
	schema = schema,
	requiredPeripherals = { "buffer" },
	logFile = "logs/crafter.log",
}, ...)
