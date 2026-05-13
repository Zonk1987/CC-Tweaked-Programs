--[[
================================================================================
CC:Tweaked Developer Suite v4.0 [SUPERIOR EDITION]
================================================================================
Interactive Peripheral Inspection & Item Browsing System
================================================================================

DESCRIPTION:
An all-in-one developer tool for ComputerCraft: Tweaked.
- Inspect and explore connected peripherals and their methods.
- Browse inventory contents with real-time detail viewing.
- Quickly find technical Item Registry Names (required for recipes).
- Deep-dive into item components, NBT tags, and properties.

INSTALLATION:
To install on a new computer, use the universal installer:
pastebin run vYK0cPkU

USAGE:
Run the script and follow the on-screen menu to select peripherals.
Use arrow keys to navigate and 'Q' to return or exit.
================================================================================
]]--

local _ENV = setmetatable({}, { __index = _G })

local toolkit = {
    useRednet = false,
    modem = nil
}

--- Helper: Clear screen and draw header
local function header(title)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    print("=== " .. title .. " ===")
    term.setTextColor(colors.white)
    print("----------------------------------")
end

--- Specialized Item Browser for Inventories
function toolkit.itemBrowser(peripheralName)
    local inv = peripheral.wrap(peripheralName)
    local size = inv.size()
    local selected = 1
    
    while true do
        header("Browsing: " .. peripheralName)
        print("Use UP/DOWN to scroll, 'Q' to exit\n")
        
        -- Get item in current selected slot
        local detail = inv.getItemDetail(selected)
        
        -- Display Slots
        for i = selected - 2, selected + 2 do
            if i > 0 and i <= size then
                if i == selected then term.setTextColor(colors.green) write(" > ")
                else term.setTextColor(colors.gray) write("   ") end
                
                local item = inv.list()[i]
                if item then
                    print(string.format("Slot %d: %-15s x%d", i, item.name:gsub(".*:", ""), item.count))
                else
                    print(string.format("Slot %d: Empty", i))
                end
            end
        end
        
        -- Display Detail View (the "Professional Interface")
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

--- TOOL 1: Superior Peripheral Inspector
function toolkit.peripheralInspector()
    header("Superior Peripheral Inspector")
    local names = peripheral.getNames()
    for i, n in ipairs(names) do 
        print(i .. ". " .. n .. " [" .. (peripheral.getType(n) or "unknown") .. "]") 
    end
    write("\nSelect Device [1-" .. #names .. "]: ")
    os.sleep(0.1)
    local sel = tonumber(read())
    
    if sel and names[sel] then
        local pName = names[sel]
        local p = peripheral.wrap(pName)
        local methods = peripheral.getMethods(pName)
        local mIndex = 1
        
        while true do
            header("Inspector: " .. pName)
            print("Use UP/DOWN to select method, ENTER to execute")
            print("Press 'B' for Item Browser, 'Q' to exit\n")
            
            -- Method List
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
            elseif key == keys.b then
                if peripheral.hasType(pName, "inventory") then
                    toolkit.itemBrowser(pName)
                else
                    print("\nThis device is not an inventory!")
                    os.sleep(1)
                end
            elseif key == keys.q then break end
        end
    end
end

--- TOOL 2: Event Sniffer
function toolkit.eventSniffer()
    header("Event Sniffer (Press 'Q' to Exit)")
    while true do
        local event = { os.pullEvent() }
        if event[1] == "key" and event[2] == keys.q then break end
        term.setTextColor(colors.green)
        write(tostring(event[1]) .. ": ")
        term.setTextColor(colors.white)
        for i=2, #event do write(tostring(event[i]) .. "  ") end
        print("")
    end
end

--- TOOL 3: Redstone Monitor
function toolkit.redstoneMonitor()
    header("Redstone Monitor (Press 'Q' to Exit)")
    while true do
        term.setCursorPos(1, 4)
        for _, side in ipairs(rs.getSides()) do
            local analog = rs.getAnalogueInput(side)
            write(string.format("%-10s: ", side:upper()))
            if analog > 0 then term.setTextColor(colors.green) write("ACTIVE (" .. analog .. ")  \n")
            else term.setTextColor(colors.gray) write("INACTIVE      \n") end
        end
        local timer = os.startTimer(0.5)
        local ev, p1 = os.pullEvent()
        if ev == "key" and p1 == keys.q then break end
    end
end

--- TOOL 4: File Explorer
function toolkit.fileExplorer()
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
        os.sleep(0.1)
        local cmd = read()
        if cmd == "exit" then break
        elseif cmd == ".." then path = fs.getDir(path)
        elseif fs.isDir(fs.combine(path, cmd)) then path = fs.combine(path, cmd) end
    end
end

--- MAIN MENU
function toolkit.mainMenu()
    while true do
        header("Developer Suite v4.0 [SUPERIOR]")
        print("1. Superior Inspector (Methods & Browser)")
        print("2. Event Sniffer (Live OS Debug)")
        print("3. Redstone Analyzer (Live Inputs)")
        print("4. File Explorer (FileManager)")
        print("5. Network Scanner (Rednet)")
        print("6. Toggle Rednet/Modem")
        print("7. Exit")
        write("\nSelection: ")
        local _, key = os.pullEvent("key")
        if key == keys.one then toolkit.peripheralInspector()
        elseif key == keys.two then toolkit.eventSniffer()
        elseif key == keys.three then toolkit.redstoneMonitor()
        elseif key == keys.four then toolkit.fileExplorer()
        elseif key == keys.five then
            header("Network Scanner")
            if toolkit.modem then
                print("Modem Side: " .. peripheral.getName(toolkit.modem))
                print("Scanning Rednet IDs (1-50)...")
                local found = 0
                for i=1, 50 do 
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
                    write(".") -- Progress indicator
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
        elseif key == keys.six then
            toolkit.useRednet = not toolkit.useRednet
            term.setCursorPos(1, 15)
            term.clearLine()
            if toolkit.useRednet then
                toolkit.modem = peripheral.find("modem")
                if toolkit.modem then 
                    rednet.open(peripheral.getName(toolkit.modem)) 
                    term.setTextColor(colors.green)
                    print("Rednet enabled on " .. peripheral.getName(toolkit.modem))
                else 
                    term.setTextColor(colors.red)
                    print("Error: No modem found! Check your hardware.")
                    toolkit.useRednet = false -- Reset if failed
                end
            else 
                rednet.close() 
                term.setTextColor(colors.yellow)
                print("Rednet / Modem disabled.")
            end
            term.setTextColor(colors.white)
            os.sleep(1)
        elseif key == keys.seven then 
            os.sleep(0.1) -- Prevent '7' from leaking to terminal
            term.clear()
            term.setCursorPos(1, 1)
            break 
        end
    end
end

toolkit.mainMenu()