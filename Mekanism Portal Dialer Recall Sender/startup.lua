--[[
================================================================================
Mekanism Portal Recall Sender (V2.0 Professional)
================================================================================

DESCRIPTION:
This script acts as a remote trigger for the Mekanism Portal Hub. 
When it receives a redstone signal (e.g. from a button or pressure plate), 
it broadcasts a "RECALL" command to the Hub to dial this specific location.

FEATURES:
- Interactive Setup Wizard on first run.
- On-the-fly configuration menu (Press 'C').
- Dual-path transmission (Modem API & Rednet).
- Automatic modem detection.

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

---@class RecallConfig
---@field target string The name of this portal destination
---@field channel number The modem channel used for communication

---@class RecallSender
---@field config RecallConfig
---@field modem table|nil
local RecallSender = {}
RecallSender.__index = RecallSender

function RecallSender:new()
    local instance = setmetatable({
        config = { target = "Unknown", channel = 99 },
        modem = nil
    }, self)
    
    instance:loadConfig()
    instance:initHardware()
    return instance
end

--- Load configuration from JSON file
function RecallSender:loadConfig()
    if fs.exists("config.json") then
        local f = fs.open("config.json", "r")
        local data = f.readAll()
        f.close()
        self.config = textutils.unserialiseJSON(data) or self.config
    else
        self:setupWizard()
    end
end

--- Save configuration to JSON file
function RecallSender:saveConfig()
    local f = fs.open("config.json", "w")
    f.write(textutils.serialiseJSON(self.config))
    f.close()
end

--- Draws the terminal status screen
function RecallSender:drawTerminalHeader()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.cyan)
    print("Mekanism Portal Recall Sender v2.0")
    term.setTextColor(colors.gray)
    print("----------------------------------")
    term.setTextColor(colors.white)
    print("Target:  " .. self.config.target)
    print("Channel: " .. self.config.channel)
    print("\nStatus:  Waiting for Redstone signal...")
    term.setTextColor(colors.white)
    print("\n[Press 'C' on Computer for Configuration]")
end

--- Initial hardware check and setup
function RecallSender:initHardware()
    self.modem = peripheral.find("modem")
    if not self.modem then
        term.setTextColor(colors.red)
        print("Error: No wireless modem found!")
        term.setTextColor(colors.white)
    else
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
    print("=== Recall Sender Setup ===")
    print("No configuration found. Let's set it up.\n")
    
    term.setTextColor(colors.yellow)
    write("Target Location Name: ")
    term.setTextColor(colors.white)
    self.config.target = read()
    
    term.setTextColor(colors.yellow)
    write("Communication Channel (default 99): ")
    term.setTextColor(colors.white)
    local chanInput = read()
    self.config.channel = tonumber(chanInput) or 99
    
    self:saveConfig()
    print("\nSetup complete! Saved to config.json.")
    os.sleep(1)
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
        print("\nPress key [1-4] to select.")
        
        local _, key = os.pullEvent("key")
        if key == keys.one then
            term.setCursorPos(1, 8)
            term.clearLine()
            term.setTextColor(colors.yellow)
            write("New Target Name: ")
            term.setTextColor(colors.white)
            os.sleep(0.1)
            local input = read()
            if input ~= "" then
                self.config.target = input
            end
        elseif key == keys.two then
            term.setCursorPos(1, 8)
            term.clearLine()
            term.setTextColor(colors.yellow)
            write("New Channel (Default 99): ")
            term.setTextColor(colors.white)
            os.sleep(0.1)
            local input = read()
            if input ~= "" then
                self.config.channel = tonumber(input) or self.config.channel
            end
        elseif key == keys.three then
            self:saveConfig()
            term.setTextColor(colors.green)
            print("\nSettings saved successfully!")
            os.sleep(1)
            self:drawTerminalHeader() -- Restore screen
            return
        elseif key == keys.four then
            self:loadConfig() -- Revert to last saved
            self:drawTerminalHeader() -- Restore screen
            return
        end
    end
end

--- Main runtime loop
function RecallSender:run()
    self:drawTerminalHeader()
    local messageTimer = nil
    
    while true do
        -- Handle events (Redstone, Config Key, or Timer)
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "redstone" then
            local triggered = false
            for _, side in ipairs(rs.getSides()) do
                if rs.getInput(side) then triggered = true break end
            end
            
            if triggered then
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
                
                -- Start timer to clear messages after 10 seconds
                messageTimer = os.startTimer(10)
            end
            
        elseif event == "timer" and p1 == messageTimer then
            -- Refresh terminal to clear old messages
            self:drawTerminalHeader()
            
        elseif event == "key" and p1 == keys.c then
            self:configMenu()
        end
    end
end

-- Execution
local app = RecallSender:new()
app:run()