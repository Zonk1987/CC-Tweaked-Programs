--[[
================================================================================
AppRuntime Module v1.0.0
================================================================================
The universal Enterprise Kernel & Bootstrap engine for all applications.
Manages strict scope execution, CLI options, Config Store, Boot Assistant,
background watchdogs (Self-Healing), Safe Mode Boot and the Fiber Scheduler.
================================================================================
]]

local ConfigStore = require("ConfigStore")
local ConfigGUI = require("ConfigGUI")
local BootAssistant = require("boot_assistant")
local Logger = require("Logger")
local HAL = require("HAL")
local EventBus = require("EventBus")
local Scheduler = require("Scheduler")
local Result = require("Result")

local AppRuntime = {}
AppRuntime.__index = AppRuntime

-- Helper: Enable Strict Mode on a given environment/table
local function enableStrictMode(env)
	local mt = getmetatable(env) or {}
	mt.__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end
	setmetatable(env, mt)
end

-- Helper: Clean terminal display
local function clearScreen()
	term.clear()
	term.setCursorPos(1, 1)
end

-- Safe Mode emergency terminal interface
local function runSafeMode(appName, configStore, logFilePath)
	while true do
		clearScreen()
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		print("==================================================")
		print("          EMERGENCY SAFE MODE TERMINAL            ")
		print("==================================================")
		if term.isColor() then
			term.setTextColor(colors.white)
		end
		print("App: " .. tostring(appName))
		print("Status: Main automation threads are SUSPENDED.\n")
		print("1) System-Logs anzeigen")
		print("2) Konfiguration zuruecksetzen (Defaults)")
		print("3) Diagnose-Report exportieren (diagnostics.json)")
		print("4) System normal neu starten")
		print("5) Beenden & Zurueck zu Shell")
		print("==================================================")

		write("\nAuswahl (1-5): ")
		local input = read()

		if input == "1" then
			clearScreen()
			print("--- System-Logs (Letzte 20 Zeilen) ---")
			-- Try reading logs from logs/ directory
			local logFile = logFilePath or ("logs/" .. appName:lower():gsub("%s+", "_") .. ".log")
			if fs.exists(logFile) then
				local f = fs.open(logFile, "r")
				local lines = {}
				local line = f.readLine()
				while line do
					table.insert(lines, line)
					line = f.readLine()
				end
				f.close()

				local startIdx = math.max(1, #lines - 20)
				for i = startIdx, #lines do
					print(lines[i])
				end
			else
				print("Keine Logdatei unter '" .. logFile .. "' gefunden.")
			end
			print("\nDruecke Enter zum Fortfahren...")
			read()
		elseif input == "2" then
			clearScreen()
			print("Konfiguration wird zurueckgesetzt...")
			configStore:clear()
			print("Konfiguration geloescht und auf Defaults zurueckgesetzt!")
			print("\nDruecke Enter zum Fortfahren...")
			read()
		elseif input == "3" then
			clearScreen()
			print("Erstelle Diagnostics-Bundle...")
			local diagnostics = {
				appName = appName,
				time = os.time(),
				day = os.day(),
				computerId = os.computerID(),
				computerLabel = os.computerLabel() or "none",
				peripherals = {},
				config = configStore.data or {},
			}

			local names = peripheral.getNames()
			for _, name in ipairs(names) do
				diagnostics.peripherals[name] = peripheral.getType(name)
			end

			local f = fs.open("diagnostics.json", "w")
			f.write(textutils.serialiseJSON(diagnostics))
			f.close()

			print("Diagnostics exportiert nach 'diagnostics.json'!")
			print("\nDruecke Enter zum Fortfahren...")
			read()
		elseif input == "4" then
			clearScreen()
			print("Starte System neu...")
			os.sleep(1)
			os.reboot()
		elseif input == "5" then
			clearScreen()
			print("Safe Mode beendet.")
			return
		end
	end
end

-- Main entry point of the AppRuntime Kernel
-- @param appClass [table] The system/app class (must have a .new constructor and :run method)
-- @param options [table] Options containing:
--   - title: Human readable app name
--   - configName: Name of the json configuration file
--   - defaultConfig: Default keys/values for the config
--   - schema: ConfigGUI schema for interactive setup
--   - requiredPeripherals: List of required peripheral keys (e.g. { "hub_monitor", "hub_teleporter" })
--   - logFile: Path to the log file
-- @param ... [any] Forwarded CLI arguments from startup.lua
function AppRuntime.run(appClass, options, ...)
	if type(appClass) ~= "table" then
		error("AppRuntime.run: appClass must be a table module!", 2)
	end

	-- 1. Enable strict mode for the caller's environment
	enableStrictMode(getfenv(2))

	-- 2. Parse CLI Arguments
	local args = { ... }
	local isSafeMode = false
	local isConfigMode = false

	for _, arg in ipairs(args) do
		if arg == "--safe" or arg == "-s" then
			isSafeMode = true
		elseif arg == "--config" or arg == "-c" then
			isConfigMode = true
		end
	end

	-- 3. Initialize Config Store
	local configStore = ConfigStore.new(options.configName or "config.json", options.defaultConfig or {})
	local schema = options.schema or {}

	-- 4. Config Mode execution
	if isConfigMode then
		local gui = ConfigGUI.new(configStore, schema)
		gui:run()
		clearScreen()
		print("Konfiguration erfolgreich gespeichert.")
		return
	end

	-- 5. Safe Mode execution
	if isSafeMode then
		runSafeMode(options.title or "CC-App", configStore, options.logFile)
		return
	end

	-- 6. Initialize BootAssistant (Peripherie-Checks)
	local boot = BootAssistant.new({
		title = (options.title or "App") .. " Bootloader",
		theme = "dark",
		enable_logging = true,
		log_file = "logs/boot.log",
		onSetup = function()
			local gui = ConfigGUI.new(configStore, schema)
			gui:run()
		end,
	})

	-- Populate boot assistant steps using the deklared schema
	for _, item in ipairs(schema) do
		if item.type == "peripheral" then
			boot:addStep(item.key, item.label .. " Check", function()
				local configuredName = configStore:get(item.key, item.default)
				if configuredName and HAL.wrap(configuredName) then
					local pType = HAL.getType(configuredName)
					if pType and (not item.peripheralType or pType:find(item.peripheralType)) then
						return Result.ok(configuredName)
					end
				end

				-- Auto-detect typical peripherals of this type
				if item.peripheralType then
					local found = HAL.listNames(item.peripheralType)
					if found[1] then
						configStore:set(item.key, found[1], true)
						return Result.ok(found[1])
					end
				end

				return Result.err(
					"PERIPHERAL_MISSING",
					"Geraet '" .. item.label .. "' nicht gefunden.",
					"Bitte verbinde ein passendes Geraet vom Typ '" .. tostring(item.peripheralType or "unbekannt") .. "'"
				)
			end, {
				"Bitte verbinde ein passendes Geraet vom Typ '" .. tostring(item.peripheralType or "unbekannt") .. "'",
				"mit dem Computer (physisch oder per Modems/Netzwerk).",
				"Aktiviere Modems immer mit einem Rechtsklick!",
			})
		end
	end

	-- Run boot steps
	boot:run()

	-- Register confirmed peripherals in HAL
	for _, item in ipairs(schema) do
		if item.type == "peripheral" then
			local configuredName = configStore:get(item.key, item.default)
			HAL.register(item.key, configuredName)
		end
	end

	-- 7. Core Logger initialization
	local logPath = options.logFile or ("logs/" .. (options.title or "app"):lower():gsub("%s+", "_") .. ".log")
	local logger = Logger.new({ logPath = logPath })
	logger:info("==================================================")
	logger:info(tostring(options.title) .. " gestartet.")
	logger:info("==================================================")

	-- 8. Spawn Scheduler & Main Fibers
	local scheduler = Scheduler.new()

	-- Watchdog Background Fiber (Self-Healing)
	if options.requiredPeripherals and #options.requiredPeripherals > 0 then
		scheduler:spawn(function()
			while scheduler.running do
				Scheduler.sleep(5) -- Monitor every 5 seconds

				for _, pKey in ipairs(options.requiredPeripherals) do
					local pName = configStore:get(pKey)
					local wrapped = pName and HAL.wrap(pName)

					if not wrapped then
						logger:warn(
							"Watchdog: Hardware-Verbindung zu '"
								.. tostring(pKey)
								.. "' ("
								.. tostring(pName)
								.. ") verloren!"
						)
						EventBus:emit("PERIPHERAL_LOST", pKey)

						-- Attempt reconnection every 2 seconds
						local reconnected = false
						while not reconnected and scheduler.running do
							Scheduler.sleep(2)
							-- Refresh HAL scan
							HAL.scan()
							if pName and HAL.wrap(pName) then
								reconnected = true
								logger:info(
									"Watchdog: Hardware '" .. tostring(pKey) .. "' erfolgreich wieder verbunden!"
								)
								EventBus:emit("PERIPHERAL_RESTORED", pKey)
							end
						end
					end
				end
			end
		end, "Watchdog-System")
	end

	-- App Main Instantiation & Spawn
	local appInstance = appClass.new({
		config = configStore,
		logger = logger,
		scheduler = scheduler,
	})

	scheduler:spawn(function()
		local ok, err = pcall(function()
			appInstance:run()
		end)

		if not ok then
			logger:error("Main App execution crash: " .. tostring(err))
			if appInstance.shutdown then
				pcall(function()
					appInstance:shutdown()
				end)
			end
			error(err)
		end
	end, "App-Main")

	-- 9. Start Scheduler event loop
	scheduler:run()

	-- Geordnetes Beenden
	if appInstance.shutdown then
		pcall(function()
			appInstance:shutdown()
		end)
	end
	logger:info(tostring(options.title) .. " geordnet beendet.")
end

return AppRuntime
