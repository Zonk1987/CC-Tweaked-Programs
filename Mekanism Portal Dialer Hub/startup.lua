--[[
================================================================================
Mekanism Portal Hub (V2.2 AGENTS Edition)
================================================================================
Standardized Hub System for Interdimensional Portals.
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

-- Configure library paths for lib/core
local corePaths = {
    "/lib/core/base/?.lua",
    "/lib/core/peripherals/?.lua",
    "/lib/core/inventory/?.lua",
    "/lib/core/recipes/?.lua",
    "/lib/core/ui/?.lua",
    "/lib/core/network/?.lua",
    "/lib/core/redstone/?.lua"
}
package.path = package.path .. ";" .. table.concat(corePaths, ";")

local HubSystem = require("HubSystem")
local ButtonGrid = require("ButtonGrid")
local PeripheralScanner = require("PeripheralScanner")

-- Hardware Discovery
local _, monitorName = PeripheralScanner.find("monitor")
local _, tpName = PeripheralScanner.find("mekanism:teleporter")

if not monitorName or not tpName then
    error("Critical Hardware Missing: Monitor or Teleporter not found!")
end

-- Initialization
local bm = ButtonGrid.new(monitorName)
bm.mon.setTextScale(0.5)

local system = HubSystem.new({
    bm = bm,
    tpSide = tpName,
    config = {
        monitorSide = monitorName,
        tpSide = tpName,
        gridColumns = 4,
        gridRows = 4,
        recallChannel = 99,
        maxButtons = 24
    }
})

system:run()