--[[
================================================================================
Mekanism Portal Recall Sender (V2.1 AGENTS Edition)
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

local ConfigStore = require("ConfigStore")
local PeripheralScanner = require("PeripheralScanner")
local RednetProtocol = require("RednetProtocol")
local RedstoneController = require("RedstoneController")

-- Localize globals
local fs = fs
local peripheral = peripheral
local rednet = rednet
local term = term
local colors = colors
local keys = keys
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local os_startTimer = os.startTimer
local rs = rs
local textutils = textutils
local string = string
local ipairs = ipairs
local tonumber = tonumber
local write = write
local read = read

---@class RecallConfig
---@field target string The name of this portal destination
---@field channel number The modem channel used for communication

---@class ConfigStore
---@field data table

---@class RecallSender
---@field configStore ConfigStore
---@field modem table|nil
local RecallSender = {}
RecallSender.__index = RecallSender

--- Creates a new RecallSender
---@return RecallSender
function RecallSender.new()
    local self = setmetatable({
        configStore = ConfigStore.new("config.json", { target = "Unknown", channel = 99 }),
        modem = nil
    }, RecallSender)

    if not fs.exists("config.json") then
        self:setupWizard()
    end
    
    self:initHardware()
    return self
end

--- Initial hardware check and setup
function RecallSender:initHardware()
    self.modem = PeripheralScanner.find("modem")
    RednetProtocol.openAuto()
end

--- Draws the terminal status screen
function RecallSender:drawTerminalHeader()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.cyan)
    print("Mekanism Portal Recall Sender v2.1")
    term.setTextColor(colors.gray)
    print("----------------------------------")
    term.setTextColor(colors.white)
    print("Target:  " .. self.configStore.data.target)
    print("Channel: " .. self.configStore.data.channel)
    print("\nStatus:  Waiting for Redstone signal...")
    print("\n[Press 'C' for Configuration]")
end

--- Interactive setup for first-time use
function RecallSender:setupWizard()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Recall Sender Setup ===\n")
    term.setTextColor(colors.yellow)
    write("Target Location Name: ")
    term.setTextColor(colors.white)
    self.configStore.data.target = read() or "Unknown"

    write("Communication Channel (default 99): ")
    local chanInput = read()
    self.configStore.data.channel = tonumber(chanInput) or 99

    self.configStore:save()
    print("\nSetup complete!")
    os_sleep(1)
end

--- Interactive configuration menu
function RecallSender:configMenu()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.cyan)
        print("=== Configuration Menu ===")
        term.setTextColor(colors.white)
        print("1. Target Name       (Current: " .. self.configStore.data.target .. ")")
        print("2. Recall Channel    (Current: " .. self.configStore.data.channel .. ")")
        print("3. Save & Exit")
        print("4. Exit without saving")

        local _, key = os_pullEvent("key")
        if key == keys.one then
            term.setCursorPos(1, 8)
            write("New Target Name: ")
            local input = read()
            if input ~= "" then self.configStore.data.target = input end
        elseif key == keys.two then
            term.setCursorPos(1, 8)
            write("New Channel: ")
            local input = read()
            self.configStore.data.channel = tonumber(input) or self.configStore.data.channel
        elseif key == keys.three then
            self.configStore:save()
            self:drawTerminalHeader()
            return
        elseif key == keys.four then
            self.configStore:load()
            self:drawTerminalHeader()
            return
        end
    end
end

--- Broadcasts the recall signal
function RecallSender:broadcastRecall()
    term.setTextColor(colors.yellow)
    print("\n[!] Signal detected! Sending recall...")

    local payload = { command = "RECALL", target = self.configStore.data.target }
    RednetProtocol.transmit(self.configStore.data.channel, payload)
    RednetProtocol.broadcast("mekanism_portal", "RECALL", { target = self.configStore.data.target })

    term.setTextColor(colors.lime)
    print("[!] Success: Target '" .. self.configStore.data.target .. "' broadcasted.")
    term.setTextColor(colors.white)
end

--- Main runtime loop
function RecallSender:run()
    self:drawTerminalHeader()
    local messageTimer = nil

    while true do
        local event, p1, p2, p3 = os_pullEvent()

        if event == "redstone" then
            if RedstoneController.anyInput() then
                self:broadcastRecall()
                messageTimer = os_startTimer(10)
            end

        elseif event == "timer" and p1 == messageTimer then
            self:drawTerminalHeader()

        elseif event == "key" and p1 == keys.c then
            self:configMenu()
        end
    end
end

-- Execution
local app = RecallSender.new()
app:run()