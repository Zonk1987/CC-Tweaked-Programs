--[[
================================================================================
CC:Tweaked Developer Suite v4.1 (AGENTS Edition)
================================================================================
Interactive Peripheral Inspection & Item Browsing System
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
local term = term
local colors = colors
local peripheral = peripheral
local string = string
local math = math
local table = table
local os = os
local keys = keys
local read = read
local write = write
local pcall = pcall
local textutils = textutils
local ipairs = ipairs
local pairs = pairs
local rs = rs
local fs = fs
local rednet = rednet

---@class DevToolkit
---@field useRednet boolean
---@field modem table|nil
local DevToolkit = {
    useRednet = false,
    modem = nil
}

--- Helper: Clear screen and draw header
local function header(title)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.yellow)
    print("=== " .. title .. " ===")
    term.setTextColor(colors.white)
    print("----------------------------------")
end

--- Specialized Item Browser for Inventories
function DevToolkit.itemBrowser(peripheralName)
    local inv = peripheral.wrap(peripheralName)
    if not inv or not inv.size then return end
    local size = inv.size()
    local selected = 1

    while true do
        header("Browsing: " .. peripheralName)
        print("Use UP/DOWN to scroll, 'Q' to exit\n")

        local detail = inv.getItemDetail(selected)
        local itemList = inv.list()

        for i = selected - 2, selected + 2 do
            if i > 0 and i <= size then
                if i == selected then
                    term.setTextColor(colors.green)
                    write(" > ")
                else
                    term.setTextColor(colors.gray)
                    write("   ")
                end

                local item = itemList[i]
                if item then
                    print(string.format("Slot %d: %-15s x%d", i, item.name:gsub(".*:", ""), item.count))
                else
                    print(string.format("Slot %d: Empty", i))
                end
            end
        end

        term.setTextColor(colors.yellow)
        print("\n--- Slot " .. selected .. " Details ---")
        term.setTextColor(colors.white)
        if detail then
            for k, v in pairs(detail) do
                if type(v) ~= "table" then
                    print(string.format("%-10s: %s", k, tostring(v)))
                end
            end
        else
            print("No item data available.")
        end

        local _, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then selected = selected - 1
        elseif key == keys.down and selected < size then selected = selected + 1
        elseif key == keys.q then break end
    end
end

--- Superior Peripheral Inspector
function DevToolkit.peripheralInspector()
    header("Superior Peripheral Inspector")
    local names = peripheral.getNames()
    if #names == 0 then
        print("No peripherals found!")
        os.sleep(1.5)
        return
    end

    for i, n in ipairs(names) do
        print(i .. ". " .. n .. " [" .. (peripheral.getType(n) or "unknown") .. "]")
    end
    write("\nSelect Device [1-" .. #names .. "]: ")
    local sel = tonumber(read())
    os.sleep(0.5)

    if sel and names[sel] then
        local pName = names[sel]
        local p = peripheral.wrap(pName)
        local methods = peripheral.getMethods(pName)
        local mIndex = 1

        while true do
            header("Inspector: " .. pName)
            print("UP/DOWN:Select | ENTER:Execute | B:Browser | Q:Exit\n")

            for i = mIndex - 3, mIndex + 3 do
                if i > 0 and i <= #methods then
                    if i == mIndex then term.setTextColor(colors.lime) write(" [*] ")
                    else term.setTextColor(colors.gray) write(" [ ] ") end
                    print(methods[i])
                end
            end

            local _, key = os.pullEvent("key")
            if key == keys.up and mIndex > 1 then mIndex = mIndex - 1
            elseif key == keys.down and mIndex < #methods then mIndex = mIndex + 1
            elseif key == keys.enter then
                header("Executing: " .. methods[mIndex])
                print("Result:")
                local ok, res = pcall(p[methods[mIndex]])
                term.setTextColor(ok and colors.green or colors.red)
                print(textutils.serialize(res))
                term.setTextColor(colors.white)
                print("\nPress any key...")
                os.pullEvent("key")
                os.sleep(0.5)
            elseif key == keys.b then
                if peripheral.hasType(pName, "inventory") then
                    DevToolkit.itemBrowser(pName)
                else
                    print("\nThis device is not an inventory!")
                    os.sleep(1)
                end
            elseif key == keys.q then break end
        end
    end
end

--- Event Sniffer
function DevToolkit.eventSniffer()
    header("Event Sniffer (Press 'Q' to Exit)")
    while true do
        local event = { os.pullEvent() }
        if event[1] == "key" and event[2] == keys.q then break end
        term.setTextColor(colors.green)
        write(tostring(event[1]) .. ": ")
        term.setTextColor(colors.white)
        for i = 2, #event do write(tostring(event[i]) .. "  ") end
        print("")
    end
end

--- Redstone Monitor
function DevToolkit.redstoneMonitor()
    header("Redstone Monitor (Press 'Q' to Exit)")
    while true do
        term.setCursorPos(1, 4)
        for _, side in ipairs(rs.getSides()) do
            local analog = rs.getAnalogueInput(side)
            write(string.format("%-10s: ", side:upper()))
            if analog > 0 then
                term.setTextColor(colors.green)
                write("ACTIVE (" .. analog .. ")  \n")
            else
                term.setTextColor(colors.gray)
                write("INACTIVE      \n")
            end
        end
        local timer = os.startTimer(0.5)
        local ev, p1 = os.pullEvent()
        if ev == "key" and p1 == keys.q then break end
    end
end

--- File Explorer
function DevToolkit.fileExplorer()
    local path = ""
    while true do
        header("File Explorer: /" .. path)
        local list = fs.list(path)
        table.sort(list)
        print(".. (Back)")
        for _, f in ipairs(list) do
            local full = fs.combine(path, f)
            if fs.isDir(full) then term.setTextColor(colors.cyan) write("[DIR] ")
            else term.setTextColor(colors.white) write("      ") end
            print(f .. " (" .. fs.getSize(full) .. " bytes)")
        end
        write("\nEnter dir or 'exit': ")
        local cmd = read()
        if cmd == "exit" then break
        elseif cmd == ".." then path = fs.getDir(path)
        elseif fs.isDir(fs.combine(path, cmd)) then path = fs.combine(path, cmd) end
    end
end

--- Network Scanner
function DevToolkit.networkScanner()
    header("Network Scanner")
    if DevToolkit.modem then
        print("Modem Side: " .. peripheral.getName(DevToolkit.modem))
        print("Scanning Rednet IDs (1-50)...")
        local found = 0
        for i = 1, 50 do
            if i ~= os.getComputerID() then
                rednet.send(i, "PING", "ping_test")
            end
        end

        local start = os.clock()
        while os.clock() - start < 2 do
            local id = rednet.receive("ping_test", 0.5)
            if id then
                term.setTextColor(colors.green)
                print(" [+] Found Computer ID: " .. id)
                term.setTextColor(colors.white)
                found = found + 1
            end
            write(".")
        end
        print("\n\nScan finished.")
        term.setTextColor(found > 0 and colors.green or colors.yellow)
        print("Summary: Found " .. found .. " computer(s).")
        term.setTextColor(colors.white)
    else
        term.setTextColor(colors.red)
        print("Error: No modem found! Enable it with [6].")
        term.setTextColor(colors.white)
    end
    print("\nPress any key to return...")
    os.sleep(0.1)
    os.pullEvent("key")
    os.sleep(0.5)
end

--- Toggle Rednet
function DevToolkit.toggleRednet()
    DevToolkit.useRednet = not DevToolkit.useRednet
    if DevToolkit.useRednet then
        DevToolkit.modem = peripheral.find("modem")
        if DevToolkit.modem then
            rednet.open(peripheral.getName(DevToolkit.modem))
            term.setTextColor(colors.green)
            print("\nRednet enabled on " .. peripheral.getName(DevToolkit.modem))
        else
            term.setTextColor(colors.red)
            print("\nError: No modem found!")
            DevToolkit.useRednet = false
        end
    else
        rednet.close()
        term.setTextColor(colors.yellow)
        print("\nRednet / Modem disabled.")
    end
    term.setTextColor(colors.white)
    os.sleep(1)
end

--- Main Menu
function DevToolkit.mainMenu()
    while true do
        header("Developer Suite v4.1 [AGENTS]")
        print("1. Superior Inspector (Methods & Browser)")
        print("2. Event Sniffer (Live OS Debug)")
        print("3. Redstone Analyzer (Live Inputs)")
        print("4. File Explorer (FileManager)")
        print("5. Network Scanner (Rednet)")
        print("6. Toggle Rednet/Modem")
        print("7. Exit")
        write("\nSelection: ")
        local _, key = os.pullEvent("key")
        os.sleep(0.5)
        if key == keys.one then DevToolkit.peripheralInspector()
        elseif key == keys.two then DevToolkit.eventSniffer()
        elseif key == keys.three then DevToolkit.redstoneMonitor()
        elseif key == keys.four then DevToolkit.fileExplorer()
        elseif key == keys.five then DevToolkit.networkScanner()
        elseif key == keys.six then DevToolkit.toggleRednet()
        elseif key == keys.seven then
            os.sleep(0.1)
            term.clear()
            term.setCursorPos(1, 1)
            break
        end
    end
end

DevToolkit.mainMenu()