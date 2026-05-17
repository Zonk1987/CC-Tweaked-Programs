--[[
================================================================================
CC:Tweaked Developer Suite v1.0.022-main
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

local RednetProtocol = require("RednetProtocol")

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
            term.setTextColor(colors.white)
            write(string.format("%-10s: ", side:upper()))
            if analog > 0 then
                term.setTextColor(colors.green)
                write("ACTIVE (" .. analog .. ")  \n")
            else
                term.setTextColor(colors.gray)
                write("INACTIVE      \n")
            end
        end
        os.startTimer(0.1)
        local ev, p1 = os.pullEvent()
        if ev == "key" and p1 == keys.q then break end
    end
end

--- File Explorer (Interactive Version)
function DevToolkit.fileExplorer()
    local path = ""
    local selected = 1
    local w, h = term.getSize()

    while true do
        header("File Explorer: /" .. path)
        local list = fs.list(path)
        table.sort(list, function(a, b)
            local aDir = fs.isDir(fs.combine(path, a))
            local bDir = fs.isDir(fs.combine(path, b))
            if aDir ~= bDir then return aDir end
            return a:lower() < b:lower()
        end)
        
        -- Add ".." to the top if not in root
        if path ~= "" then table.insert(list, 1, "..") end

        local maxLines = h - 5
        local offset = (selected > maxLines / 2) and (selected - math.floor(maxLines / 2)) or 0
        offset = math.min(offset, math.max(0, #list - maxLines))

        for i = 1, maxLines do
            local idx = i + offset
            if idx > #list then break end
            
            term.setCursorPos(1, i + 3)
            local f = list[idx]
            local full = fs.combine(path, f)
            local isDir = fs.isDir(full)
            
            if idx == selected then
                term.setTextColor(colors.lime)
                write("> ")
            else
                term.setTextColor(colors.gray)
                write("  ")
            end

            if f == ".." then
                term.setTextColor(colors.yellow)
                write("[ BACK ]")
            elseif isDir then
                term.setTextColor(colors.cyan)
                write("\164 " .. f) -- Folder icon char
            else
                term.setTextColor(colors.white)
                write("  " .. f)
            end

            -- File Size
            if not isDir and f ~= ".." then
                local size = fs.getSize(full)
                local sizeStr = size .. " B"
                if size > 1024 then sizeStr = string.format("%.1f KB", size/1024) end
                
                term.setCursorPos(w - #sizeStr, i + 3)
                term.setTextColor(colors.gray)
                write(sizeStr)
            end
        end

        term.setCursorPos(1, h)
        term.setTextColor(colors.gray)
        write("Enter:View | E:Edit | Q:Exit")

        local _, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then selected = selected - 1
        elseif key == keys.down and selected < #list then selected = selected + 1
        elseif key == keys.enter then
            local f = list[selected]
            local full = fs.combine(path, f)
            if f == ".." then
                path = fs.getDir(path)
                selected = 1
            elseif fs.isDir(full) then
                path = full
                selected = 1
            else
                -- Open file in VIEW mode
                term.clear()
                shell.run("view", full)
            end
        elseif key == keys.e then
            local f = list[selected]
            local full = fs.combine(path, f)
            if f ~= ".." and not fs.isDir(full) then
                -- Open file in EDIT mode
                term.clear()
                shell.run("edit", full)
            end
        elseif key == keys.backspace then
            path = fs.getDir(path)
            selected = 1
        elseif key == keys.q then break end
    end
end

--- Network Scanner
function DevToolkit.networkScanner()
    if RednetProtocol.isOpen() then
        print("Modem Side: " .. (peripheral.find("modem") and peripheral.getName(peripheral.find("modem")) or "unknown"))
        print("Scanning Rednet IDs (1-50)...")
        local found = 0
        for i = 1, 50 do
            if i ~= os.getComputerID() then
                RednetProtocol.send(i, "PING", { data = "ping_test" }, "ping_test")
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
    if not RednetProtocol.isOpen() then
        local side = RednetProtocol.openAuto()
        if side then
            term.setTextColor(colors.green)
            print("\nRednet enabled on " .. side)
        else
            term.setTextColor(colors.red)
            print("\nError: No modem found!")
        end
    else
        RednetProtocol.closeAll()
        term.setTextColor(colors.yellow)
        print("\nRednet / Modem disabled.")
    end
    term.setTextColor(colors.white)
    os.sleep(1)
end

--- Main Menu
function DevToolkit.mainMenu()
    while true do
        header("Developer Suite v1.0.022-main")
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