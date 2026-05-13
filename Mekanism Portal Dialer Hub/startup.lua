--[[
================================================================================
Mekanism Portal Dialer (V2.0 Modular Edition)
================================================================================

DESCRIPTION:
This script provides a professional, touch-enabled interface for Mekanism's
Teleporter Network. It features flicker-free double-buffered rendering,
automatic portal discovery, and a built-in color editor.

This edition features a modular OOP architecture, strict mode scoping,
and flicker-free UI updates via the PortalSystem class.

INSTALLATION:
To install this system on a new computer, run the universal installer:
pastebin run vYK0cPkU

HARDWARE SETUP:
1. Place an Advanced Computer.
2. Connect an Advanced Monitor (Recommended size: 4x3).
3. Connect one Mekanism Teleporter to the computer network using a
   Wired Modem and Networking Cable.
4. Ensure the Teleporter's Modem is turned ON (red ring).
5. (Optional) Connect a Modem for remote recall support.

CONFIGURATION:
Change the values in the `config` table below to customize your experience.
Adjust `gridColumns` and `gridRows` to match your monitor size.
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

-- Load the main system modules
local ButtonManager = require("ButtonManager")
local PortalSystem = require("PortalSystem")

-- ⚙️ CONFIGURATION
local config = {
    monitorSide = "top", -- Default monitor side
    tpSide = "back",     -- Default teleporter side
    textScale = 0.5,
    gridColumns = 4,     -- Number of buttons per row
    gridRows = 4,        -- Number of rows per page
    recallChannel = 99,  -- Channel for remote portal requests
    testModeCount = 0    -- Set to > 0 to show dummy buttons for UI testing
}
-- Calculate total buttons per page automatically
config.maxButtons = config.gridColumns * config.gridRows

-- 🚀 SYSTEM INITIALIZATION
local function main()
    -- Detect peripherals automatically
    local mon = peripheral.find("monitor")
    local tp = peripheral.find("teleporter")

    if not mon then error("Peripheral Error: Monitor not found!") end
    if not tp then error("Peripheral Error: Teleporter not found!") end

    local monName = peripheral.getName(mon)
    local tpName = peripheral.getName(tp)

    -- Initialize Manager
    local bm = ButtonManager:new(monName)
    bm.mon.setTextScale(config.textScale)

    -- Initialize Portal System
    local system = PortalSystem:new(tpName, bm, config)

    -- system:run() will now handle terminal header and monitor drawing
    system:run()
end

-- Run with error handling
local ok, err = pcall(main)
if not ok then
    -- Suppress "Terminated" message when Ctrl+T is used
    if tostring(err) ~= "Terminated" then
        term.setTextColor(colors.red)
        print("\nFatal Error: " .. tostring(err))
        term.setTextColor(colors.white)
    else
        term.setTextColor(colors.gray)
        print("\nSystem stopped by user.")
        term.setTextColor(colors.white)
    end
end