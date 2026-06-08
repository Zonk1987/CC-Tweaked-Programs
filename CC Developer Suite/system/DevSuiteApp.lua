--[[
================================================================================
DevSuiteApp Module v1.0.0
================================================================================
Standardized stateful Application controller for CC:Tweaked Developer Suite.
Powered by Enterprise AppRuntime & Fiber Scheduler.
================================================================================
]]

local HAL = require("HAL")
local Scheduler = require("Scheduler")
local RednetProtocol = require("RednetProtocol")

local DevSuiteApp = {}
DevSuiteApp.__index = DevSuiteApp

function DevSuiteApp.new(options)
	local self = setmetatable({
		config = options.config,
		logger = options.logger,
		scheduler = options.scheduler,
		running = false,
	}, DevSuiteApp)
	return self
end

local function header(title)
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.yellow)
	local w, _ = term.getSize()
	local titleStr = "=== " .. title .. " ==="
	local pad = math.max(0, math.floor((w - #titleStr) / 2))
	print(string.rep(" ", pad) .. titleStr)
	term.setTextColor(colors.white)
	print(string.rep("-", w))
end

--- Specialized Item Browser for Inventories
function DevSuiteApp:itemBrowser(peripheralName)
	local inv = HAL.wrap(peripheralName)
	if not inv then
		return
	end
	---@cast inv any
	if not inv.size then
		return
	end
	local size = inv.size()
	local selected = 1

	while self.running do
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
		local w, _ = term.getSize()
		local detailTitle = "--- Slot " .. selected .. " Details ---"
		local pad = math.max(0, math.floor((w - #detailTitle) / 2))
		print("\n" .. string.rep(" ", pad) .. detailTitle)
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

		local _, key = Scheduler.waitEvent("key")
		if key == keys.up and selected > 1 then
			selected = selected - 1
		elseif key == keys.down and selected < size then
			selected = selected + 1
		elseif key == keys.q then
			break
		end
	end
end

--- Superior Peripheral Inspector
function DevSuiteApp:peripheralInspector()
	header("Superior Peripheral Inspector")
	local names = HAL.getNames()
	if #names == 0 then
		print("No peripherals found!")
		Scheduler.sleep(1.5)
		return
	end

	for i, n in ipairs(names) do
		print(i .. ". " .. n .. " [" .. (HAL.getType(n) or "unknown") .. "]")
	end
	write("\nSelect Device [1-" .. #names .. "]: ")
	local sel = tonumber(read())
	Scheduler.sleep(0.5)

	if sel and names[sel] then
		local pName = names[sel]
		local p = HAL.wrap(pName)
		local methods = HAL.getMethods(pName)
		if not p or not methods then
			return
		end
		---@cast p any
		local mIndex = 1

		while self.running do
			header("Inspector: " .. pName)
			print("UP/DOWN:Select | ENTER:Execute | B:Browser | Q:Exit\n")

			for i = mIndex - 3, mIndex + 3 do
				if i > 0 and i <= #methods then
					if i == mIndex then
						term.setTextColor(colors.lime)
						write(" [*] ")
					else
						term.setTextColor(colors.gray)
						write(" [ ] ")
					end
					print(methods[i])
				end
			end

			local _, key = Scheduler.waitEvent("key")
			if key == keys.up and mIndex > 1 then
				mIndex = mIndex - 1
			elseif key == keys.down and mIndex < #methods then
				mIndex = mIndex + 1
			elseif key == keys.enter then
				header("Executing: " .. methods[mIndex])
				print("Result:")
				local ok, res = pcall(p[methods[mIndex]])
				term.setTextColor(ok and colors.green or colors.red)
				print(textutils.serialize(res, { compact = false, allow_repetitions = false }))
				term.setTextColor(colors.white)
				print("\nPress any key...")
				Scheduler.waitEvent("key")
				Scheduler.sleep(0.5)
			elseif key == keys.b then
				if HAL.hasType(pName, "inventory") then
					self:itemBrowser(pName)
				else
					print("\nThis device is not an inventory!")
					Scheduler.sleep(1)
				end
			elseif key == keys.q then
				break
			end
		end
	end
end

--- Event Sniffer
function DevSuiteApp:eventSniffer()
	header("Event Sniffer (Press 'Q' to Exit)")
	while self.running do
		local event = { Scheduler.waitEvent() }
		if event[1] == "key" and event[2] == keys.q then
			break
		end
		term.setTextColor(colors.green)
		write(tostring(event[1]) .. ": ")
		term.setTextColor(colors.white)
		for i = 2, #event do
			write(tostring(event[i]) .. "  ")
		end
		print("")
	end
end

--- Redstone Monitor
function DevSuiteApp:redstoneMonitor()
	header("Redstone Monitor (Press 'Q' to Exit)")
	while self.running do
		term.setCursorPos(1, 4)
		local sides = redstone.getSides() --[[@as table]]
		for _, side in ipairs(sides) do
			local analog = redstone.getAnalogueInput(side)
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

		-- Spawn a tiny sleep to not burn CPU, while waiting for redstone or key event
		self.scheduler:spawn(function()
			Scheduler.sleep(0.1)
			os.queueEvent("redstone_tick")
		end, "DevSuiteApp-RedstoneTick")

		local ev, p1 = Scheduler.waitEvent()
		if ev == "key" and p1 == keys.q then
			break
		end
	end
end

--- File Explorer (Interactive Version)
function DevSuiteApp:fileExplorer()
	local path = ""
	local selected = 1

	while self.running do
		local _, h = term.getSize()
		header("File Explorer: /" .. path)
		local list = fs.list(path)
		table.sort(list, function(a, b)
			local aDir = fs.isDir(fs.combine(path, a))
			local bDir = fs.isDir(fs.combine(path, b))
			if aDir ~= bDir then
				return aDir
			end
			return a:lower() < b:lower()
		end)

		-- Add ".." to the top if not in root
		if path ~= "" then
			table.insert(list, 1, "..")
		end

		local maxLines = h - 5
		local offset = (selected > maxLines / 2) and (selected - math.floor(maxLines / 2)) or 0
		offset = math.min(offset, math.max(0, #list - maxLines))

		local w, _ = term.getSize()
		for i = 1, maxLines do
			local idx = i + offset
			if idx > #list then
				break
			end

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
				write("\164 " .. f)
			else
				term.setTextColor(colors.white)
				write("  " .. f)
			end

			-- File Size
			if not isDir and f ~= ".." then
				local size = fs.getSize(full)
				local sizeStr = size .. " B"
				if size > 1024 then
					sizeStr = string.format("%.1f KB", size / 1024)
				end

				term.setCursorPos(w - #sizeStr, i + 3)
				term.setTextColor(colors.gray)
				write(sizeStr)
			end
		end

		term.setCursorPos(1, h)
		term.setTextColor(colors.gray)
		write("Enter:View | E:Edit | Q:Exit")

		local _, key = Scheduler.waitEvent("key")
		if key == keys.up and selected > 1 then
			selected = selected - 1
		elseif key == keys.down and selected < #list then
			selected = selected + 1
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
		elseif key == keys.q then
			break
		end
	end
end

--- Network Scanner
function DevSuiteApp:networkScanner()
	if RednetProtocol.isOpen() then
		local activeModem = HAL.getModem()
		print("Modem Side: " .. (activeModem and HAL.getName(activeModem) or "unknown"))
		print("Scanning Rednet IDs (1-50)...")
		local found = 0
		for i = 1, 50 do
			if i ~= os.getComputerID() then
				RednetProtocol.send(i, "PING", { data = "ping_test" }, "ping_test")
			end
		end

		local start = os.clock()
		while os.clock() - start < 2 do
			-- Tiny sleep to process events kooperativ
			Scheduler.sleep(0.1)
			-- Check if rednet ping response is available
			local id = rednet.receive("ping_test", 0.1)
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
	Scheduler.sleep(0.1)
	Scheduler.waitEvent("key")
	Scheduler.sleep(0.5)
end

--- Toggle Rednet
function DevSuiteApp:toggleRednet()
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
	Scheduler.sleep(1)
end

function DevSuiteApp:run()
	self.running = true
	self.logger:info("DevSuiteApp gestartet.")

	while self.running do
		header("Developer Suite v1.0.157-main")
		print("1. Superior Inspector (Methods & Browser)")
		print("2. Event Sniffer (Live OS Debug)")
		print("3. Redstone Analyzer (Live Inputs)")
		print("4. File Explorer (FileManager)")
		print("5. Network Scanner (Rednet)")
		print("6. Toggle Rednet/Modem")
		print("7. Exit")
		write("\nSelection: ")

		local _, key = Scheduler.waitEvent("key")
		Scheduler.sleep(0.5)

		if key == keys.one then
			self:peripheralInspector()
		elseif key == keys.two then
			self:eventSniffer()
		elseif key == keys.three then
			self:redstoneMonitor()
		elseif key == keys.four then
			self:fileExplorer()
		elseif key == keys.five then
			self:networkScanner()
		elseif key == keys.six then
			self:toggleRednet()
		elseif key == keys.seven then
			self.running = false
			term.clear()
			term.setCursorPos(1, 1)
			break
		end
	end
end

function DevSuiteApp:shutdown()
	self.running = false
	self.logger:info("DevSuiteApp heruntergefahren.")
end

return DevSuiteApp
