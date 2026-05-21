--[[
================================================================================
Create Mechanical Crafter Automation v1.0.114-main
================================================================================
Automates Mechanical Crafter grids from the 'Create' mod.
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
