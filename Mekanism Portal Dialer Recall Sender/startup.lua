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

---@class RecallSender
---@field config RecallConfig
---@field modem table|nil
local RecallSender = {}
RecallSender.__index = RecallSender

--- Creates a new RecallSender
---@return RecallSender
function RecallSender.new()
    local self = setmetatable({
        config = { target = "Unknown", channel = 99 },
        modem = nil
    }, RecallSender)

    self:loadConfig()
    self:initHardware()
    return self
end

--- Load configuration from JSON file
function RecallSender:loadConfig()
    if fs.exists("config.json") then
        local f = fs.open("config.json", "r")
        if f then
            local data = f.readAll()
            f.close()
            self.config = textutils.unserialiseJSON(data) or self.config
        end
    else
        self:setupWizard()
    end
end

--- Save configuration to JSON file
function RecallSender:saveConfig()
    local f = fs.open("config.json", "w")
    if f then
        f.write(textutils.serialiseJSON(self.config))
        f.close()
    end
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
    print("Target:  " .. self.config.target)
    print("Channel: " .. self.config.channel)
    print("\nStatus:  Waiting for Redstone signal...")
    print("\n[Press 'C' for Configuration]")
end

--- Initial hardware check and setup
function RecallSender:initHardware()
    self.modem = peripheral.find("modem")
    if self.modem then
        local side = peripheral.getName(self.modem)
        if not rednet.isOpen(side) then
            rednet.open(side)
        end
    end
end

--- Interactive setup for first-time use
function RecallSender:setupWizard()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Recall Sender Setup ===\n")
    term.setTextColor(colors.yellow)
    write("Target Location Name: ")
    term.setTextColor(colors.white)
    self.config.target = read() or "Unknown"

    write("Communication Channel (default 99): ")
    local chanInput = read()
    self.config.channel = tonumber(chanInput) or 99

    self:saveConfig()
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
        print("1. Target Name       (Current: " .. self.config.target .. ")")
        print("2. Recall Channel    (Current: " .. self.config.channel .. ")")
        print("3. Save & Exit")
        print("4. Exit without saving")

        local _, key = os_pullEvent("key")
        if key == keys.one then
            term.setCursorPos(1, 8)
            write("New Target Name: ")
            local input = read()
            if input ~= "" then self.config.target = input end
        elseif key == keys.two then
            term.setCursorPos(1, 8)
            write("New Channel: ")
            local input = read()
            self.config.channel = tonumber(input) or self.config.channel
        elseif key == keys.three then
            self:saveConfig()
            self:drawTerminalHeader()
            return
        elseif key == keys.four then
            self:loadConfig()
            self:drawTerminalHeader()
            return
        end
    end
end

--- Broadcasts the recall signal
function RecallSender:broadcastRecall()
    term.setTextColor(colors.yellow)
    print("\n[!] Signal detected! Sending recall...")

    local msg = { command = "RECALL", target = self.config.target }
    if self.modem then
        self.modem.transmit(self.config.channel, self.config.channel, msg)
        rednet.broadcast(msg)
    end

    term.setTextColor(colors.green)
    print("[!] Success: Target '" .. self.config.target .. "' broadcasted.")
    term.setTextColor(colors.white)
end

--- Main runtime loop
function RecallSender:run()
    self:drawTerminalHeader()
    local messageTimer = nil

    while true do
        local event, p1, p2, p3 = os_pullEvent()

        if event == "redstone" then
            local triggered = false
            for _, side in ipairs(rs.getSides()) do
                if rs.getInput(side) then triggered = true break end
            end

            if triggered then
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