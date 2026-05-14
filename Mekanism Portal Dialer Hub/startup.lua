--[[
================================================================================
Mekanism Portal Dialer Hub (V2.1 AGENTS Edition)
================================================================================
]]--

-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local ButtonManager = require("ButtonManager")
local PortalSystem = require("PortalSystem")

-- Default Configuration
local config = {
    monitorSide = "top",
    tpSide = "back",
    textScale = 0.5,
    gridColumns = 4,
    gridRows = 4,
    recallChannel = 99,
    testModeCount = 0,
    maxButtons = 16
}

-- Hardware Detection
local monitor = peripheral.find("monitor")
local monitorName = monitor and peripheral.getName(monitor) or config.monitorSide

local teleporter = peripheral.find("mekanism:teleporter") or peripheral.find("teleporter")
local tpSide = teleporter and peripheral.getName(teleporter) or config.tpSide

print("Hardware Detection:")
print("- Monitor:    " .. monitorName)
print("- Teleporter: " .. tpSide)
os.sleep(1)

-- Initialization
local bm = ButtonManager.new(monitorName)
bm.mon.setTextScale(config.textScale)

local system = PortalSystem.new({
    tpSide = tpSide,
    bm = bm,
    config = config
})

system:run()