-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

local OWNER = "Zonk1987"
local REPO = "CC-Tweaked-Programs"
local BRANCH = "main"

local REPO_URL = "https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. BRANCH .. "/"

local MANIFEST_NAME = "manifest.lua"
local INSTALLER_VERSION = "1.1.3"

local args = { ... }

--- Helper: Download a file from GitHub
local function downloadFile(url, path)
	print("Fetching: " .. url)
	local response, err = http.get(url)
	if not response then
		return false, "Connection failed: " .. (err or "unknown")
	end
	local content = response.readAll()
	response.close()

	if not content or content == "" then
		return false, "Empty response from server"
	end

	local dir = fs.getDir(path)
	if dir ~= "" and not fs.exists(dir) then
		fs.makeDir(dir)
	end

	local file = fs.open(path, "w")
	if not file then
		return false, "Could not open file for writing"
	end
	file.write(content)
	file.close()
	return true
end

local PALETTE = {
	[colors.black] = 0x121214, -- Canvas / Hintergrund (sehr edles Dunkelgrau)
	[colors.white] = 0xF5F6FA, -- Haupttext (sehr edles Off-White)
	[colors.gray] = 0x4A4D5A, -- Trennlinien & Rahmen
	[colors.blue] = 0x1F3A60, -- Header-Hintergrund (Premium-Dunkelblau)
	[colors.cyan] = 0x00B0FF, -- Akzentfarbe / Titel / Rahmen-Deko (Helles Cyan)
	[colors.green] = 0x00E676, -- Erfolgsmeldungen (OK / CACHED)
	[colors.yellow] = 0xFFD740, -- Warnungen & Highlights
	[colors.red] = 0xFF5252, -- Fehler (FAIL / ERROR)
	[colors.lightGray] = 0x1E1E24, -- Selektierte Items Hintergrund (Anthrazit)
}

local oldPalette = {}

local function applyPalette()
	for color, hex in pairs(PALETTE) do
		local r, g, b = term.getPaletteColor(color)
		oldPalette[color] = { r, g, b }
		term.setPaletteColor(color, hex)
	end
end

local function restorePalette()
	for color, rgb in pairs(oldPalette) do
		term.setPaletteColor(color, rgb[1], rgb[2], rgb[3])
	end
end

--- Helper: Fetch URL content as string
local function fetchUrl(url)
	local response, err = http.get(url)
	if not response then
		return nil, "Connection failed: " .. (err or "unknown")
	end
	local content = response.readAll()
	response.close()
	return content
end

--- Helper: Parse version constant from file content
local function parseVersion(content)
	if not content then
		return nil
	end
	return content:match('local%s+INSTALLER_VERSION%s*=%s*"([^"]+)"')
end

--- Helper: Parse semantic version string into major, minor, patch numbers
local function parseSemVer(verStr)
	local major, minor, patch = verStr:match("^(%d+)%.(%d+)%.(%d+)$")
	if major then
		return tonumber(major), tonumber(minor), tonumber(patch)
	end
	return 0, 0, 0
end

--- Helper: Check if remote version is newer than current version
local function isVersionNewer(currentVer, remoteVer)
	local curMaj, curMin, curPat = parseSemVer(currentVer)
	local remMaj, remMin, remPat = parseSemVer(remoteVer)

	if remMaj > curMaj then
		return true
	end
	if remMaj < curMaj then
		return false
	end

	if remMin > curMin then
		return true
	end
	if remMin < curMin then
		return false
	end

	return remPat > curPat
end

local protectedPatterns = {
	"^config%.json$",
	"^recipes%.json$",
	"^crafter_mapping%.json$",
	"^%.env$",
	"%.local%.json$",
	"^user_.*%.json$",
}

--- Helper: Check if file path matches protected patterns
local function isProtected(path)
	local filename = fs.getName(path)
	for _, pattern in ipairs(protectedPatterns) do
		if filename:find(pattern) then
			return true
		end
	end
	return false
end

--- Helper: Check if installer itself has an update, apply it and restart if so
local function checkForSelfUpdate()
	local selfPath = shell.getRunningProgram()
	local isDryRun = false
	for _, arg in ipairs(args) do
		if arg == "--dry-run" then
			isDryRun = true
		end
	end
	if isDryRun or not selfPath or selfPath == "shell" then
		return false
	end

	term.setTextColor(colors.yellow)
	print("Checking for installer updates...")
	term.setTextColor(colors.white)

	local remoteUrl = REPO_URL .. "install.lua?nocache=" .. os.epoch("utc")
	local content, err = fetchUrl(remoteUrl)
	if not content then
		term.setTextColor(colors.red)
		print("Warning: Could not check for updates (" .. tostring(err) .. ")")
		term.setTextColor(colors.white)
		os.sleep(5)
		return false
	end

	local remoteVer = parseVersion(content)
	if not remoteVer then
		-- Remote has no version key, meaning it is older than 1.1.0. Skip update.
		term.setTextColor(colors.cyan)
		print("Installer is up to date (Version: " .. INSTALLER_VERSION .. ")")
		term.setTextColor(colors.white)
		os.sleep(5)
		return false
	end

	if isVersionNewer(INSTALLER_VERSION, remoteVer) then
		term.setTextColor(colors.cyan)
		print(string.format("New installer version found: %s (Current: %s)", remoteVer, INSTALLER_VERSION))
		print("Upgrading installer...")

		local file = fs.open(selfPath, "w")
		if not file then
			term.setTextColor(colors.red)
			print("Error: Could not overwrite installer file")
			term.setTextColor(colors.white)
			os.sleep(5)
			return false
		end
		file.write(content)
		file.close()

		term.setTextColor(colors.lime)
		print("Installer upgraded successfully! Restarting in 5 seconds...")
		term.setTextColor(colors.white)
		os.sleep(5)

		shell.run(selfPath, unpack(args))
		return true
	else
		term.setTextColor(colors.cyan)
		print("Installer is up to date (Version: " .. INSTALLER_VERSION .. ")")
		term.setTextColor(colors.white)
		os.sleep(5)
		return false
	end
end

--- Load and validate the manifest
local function loadManifest()
	print("Downloading manifest...")
	local ok, err = downloadFile(REPO_URL .. MANIFEST_NAME .. "?nocache=" .. os.epoch("utc"), MANIFEST_NAME)
	if not ok then
		if fs.exists(MANIFEST_NAME) then
			term.setTextColor(colors.yellow)
			print("Warning: Failed to download latest manifest (" .. tostring(err) .. "). Using cached local version.")
			term.setTextColor(colors.white)
			os.sleep(2)
		else
			return nil, "Failed to download manifest: " .. err
		end
	end

	local file = fs.open(MANIFEST_NAME, "r")
	if not file then
		return nil, "Could not open manifest file"
	end
	local content = file.readAll()
	file.close()

	if not content then
		return nil, "Manifest file is empty"
	end

	-- loadstring is the Lua 5.1 compatible equivalent of load(chunk, name)
	-- The sandbox env ({}) is set on the returned function via setfenv.
	local fn, parseErr = loadstring(content, "manifest")
	if fn then
		setfenv(fn, {})
	end
	if not fn then
		return nil, "Manifest parse error: " .. parseErr
	end

	local pcallOk, manifest = pcall(fn)
	if not pcallOk then
		return nil, "Manifest execution error: " .. manifest
	end
	if type(manifest) ~= "table" or type(manifest.packages) ~= "table" then
		return nil, "Invalid manifest shape"
	end

	return manifest
end

--- Helper: Check if a path is a safe relative path (no absolute, no traversal)
local function isSafeRelativePath(path)
	return type(path) == "string" and path ~= "" and path:sub(1, 1) ~= "/" and not path:find("%.%.")
end

--- Validate the manifest structure (for --validate flag)
local function validateManifest(manifest)
	print("Validating manifest...")
	local errors = {}
	for id, pkg in pairs(manifest.packages) do
		if type(pkg.name) ~= "string" or pkg.name == "" then
			table.insert(errors, id .. ": Missing name")
		end
		if type(pkg.files) ~= "table" then
			table.insert(errors, id .. ": Missing files table")
		end
		if type(pkg.dependencies) ~= "table" then
			table.insert(errors, id .. ": Missing dependencies table")
		end

		for _, file in ipairs(pkg.files or {}) do
			if not isSafeRelativePath(file.source) then
				table.insert(errors, id .. ": Illegal or empty source path: " .. tostring(file.source))
			end
			if not isSafeRelativePath(file.target) then
				table.insert(errors, id .. ": Illegal or empty target path: " .. tostring(file.target))
			end
			if file.sizeBytes ~= nil and (type(file.sizeBytes) ~= "number" or file.sizeBytes < 0) then
				table.insert(errors, id .. ": Invalid sizeBytes (must be >= 0): " .. tostring(file.source))
			end
			if
				file.hash ~= nil and (type(file.hash) ~= "string" or #file.hash ~= 64 or file.hash:find("[^0-9a-fA-F]"))
			then
				table.insert(errors, id .. ": Invalid SHA256 hash (must be 64 hex chars): " .. tostring(file.source))
			end
		end

		for _, dep in ipairs(pkg.dependencies or {}) do
			if not manifest.packages[dep] then
				table.insert(errors, id .. ": Unknown dependency: " .. dep)
			end
		end
	end

	if #errors > 0 then
		for _, err in ipairs(errors) do
			print("  [ERROR] " .. err)
		end
		return false
	end
	print("  [OK] Manifest is valid.")
	return true
end

--- Resolve dependencies and files recursively
local function resolve(manifest, packageId, resolvedPkgs, filesToDownload)
	resolvedPkgs = resolvedPkgs or {}
	filesToDownload = filesToDownload or {}

	local pkg = manifest.packages[packageId]
	if not pkg then
		error("Unknown package: " .. packageId)
	end
	if resolvedPkgs[packageId] then
		return filesToDownload
	end

	resolvedPkgs[packageId] = true

	-- Resolve dependencies first
	for _, depId in ipairs(pkg.dependencies or {}) do
		resolve(manifest, depId, resolvedPkgs, filesToDownload)
	end

	-- Add files
	for _, file in ipairs(pkg.files or {}) do
		filesToDownload[file.target] = { source = file.source, sizeBytes = file.sizeBytes, hash = file.hash }
	end

	return filesToDownload, pkg
end

--- Save the version-fingerprint cache
local function saveInstallState(state)
	local stateFile = ".install_state.json"
	local f = fs.open(stateFile, "w")
	if f then
		f.write(textutils.serializeJSON(state))
		f.close()
	end
end

--- Load the version-fingerprint cache (maps installed file paths to their manifest hash).
--- Purpose: detect whether a file's manifest version has changed since the last install,
--- allowing "CACHED" skips without re-downloading. This is NOT a cryptographic
--- download verifier — transport integrity is guaranteed by HTTPS.
local function loadInstallState()
	local stateFile = ".install_state.json"
	if fs.exists(stateFile) then
		local f = fs.open(stateFile, "r")
		if f then
			local data = f.readAll()
			f.close()
			local ok, state = pcall(textutils.unserializeJSON, data)
			if ok and type(state) == "table" then
				if state.stateVersion == 2 and type(state.files) == "table" then
					return state
				else
					-- Migration v1 -> v2
					local migratedFiles = {}
					for path, entry in pairs(state) do
						if type(path) == "string" and path ~= "stateVersion" and path ~= "files" then
							if type(entry) == "table" then
								migratedFiles[path] = {
									hash = entry.hash,
									sizeBytes = entry.sizeBytes,
								}
							elseif type(entry) == "string" then
								migratedFiles[path] = {
									hash = entry,
									sizeBytes = nil,
								}
							end
						end
					end
					local newState = {
						stateVersion = 2,
						files = migratedFiles,
					}
					saveInstallState(newState)
					return newState
				end
			end
		end
	end
	return {
		stateVersion = 2,
		files = {},
	}
end

--- Perform the installation
local function install(packageId, manifest, isDryRun, isForce)
	local ok, result, targetPkg = pcall(resolve, manifest, packageId)
	if not ok or not targetPkg then
		print("Error: " .. tostring(result or "Unknown error"))
		return
	end

	print("\nPreparing installation for: " .. (targetPkg.name or packageId))
	if isDryRun then
		print("--- DRY RUN MODE ---")
	end

	local total = 0
	for _ in pairs(result) do
		total = total + 1
	end

	local stats = {
		cached = 0,
		updated = 0,
		preserved = 0,
		failed = 0,
	}

	local backups = {}

	local function rollback()
		term.setTextColor(colors.red)
		print("\nInstallation failed! Initiating rollback...")
		for target, info in pairs(backups) do
			if info.action == "restore" then
				if fs.exists(target) then
					fs.delete(target)
				end
				fs.copy(target .. ".bak", target)
				fs.delete(target .. ".bak")
			elseif info.action == "delete" then
				if fs.exists(target) then
					fs.delete(target)
				end
			end
		end
		term.setTextColor(colors.lime)
		print("Rollback completed successfully. System state restored.")
		term.setTextColor(colors.white)
	end

	local installState = loadInstallState()
	local current = 0
	for target, fileData in pairs(result) do
		current = current + 1
		local source = fileData.source
		local expectedSize = fileData.sizeBytes
		local expectedHash = fileData.hash

		local lastInstalledHash, lastInstalledSize
		local stateEntry = installState.files[target]
		if type(stateEntry) == "table" then
			lastInstalledHash = stateEntry.hash
			lastInstalledSize = stateEntry.sizeBytes
		end

		local isFileProtected = fs.exists(target) and isProtected(target)

		if isDryRun then
			if isFileProtected then
				print(string.format("  [%d/%d] [PLAN] Preserve protected: %s", current, total, target))
				stats.preserved = stats.preserved + 1
			else
				local wouldBackup = false
				if fs.exists(target) and lastInstalledSize then
					local currentSize = fs.getSize(target)
					if currentSize ~= lastInstalledSize then
						wouldBackup = true
					end
				end
				if wouldBackup then
					print(string.format("  [%d/%d] [PLAN] Backup & Update: %s -> %s", current, total, source, target))
				else
					print(string.format("  [%d/%d] [PLAN] Update: %s -> %s", current, total, source, target))
				end
				stats.updated = stats.updated + 1
			end
		else
			local skipDownload = false

			-- Version-fingerprint check: compare the manifest hash (= the version ID written
			-- by CI at build time) against the hash stored locally after the last install.
			-- If they match, this exact version is already on disk — skip the download.
			-- Also verifies the file physically exists and the size is a quick sanity check.
			-- NOTE: We do not recompute SHA256 locally (no native CC:Tweaked API; a pure-Lua
			-- implementation would be too slow). Transport integrity is covered by HTTPS.
			if
				not isForce
				and expectedHash
				and fs.exists(target)
				and lastInstalledHash == expectedHash
				and (not expectedSize or fs.getSize(target) == expectedSize)
			then
				skipDownload = true
			end

			if isFileProtected then
				write(string.format("  [%d/%d] Preserving %s... ", current, total, target))
				term.setTextColor(colors.yellow)
				print("PRESERVED")
				term.setTextColor(colors.white)
				stats.preserved = stats.preserved + 1
			elseif skipDownload then
				write(string.format("  [%d/%d] Skipping %s... ", current, total, target))
				term.setTextColor(colors.blue)
				print("CACHED")
				stats.cached = stats.cached + 1
			else
				-- Create backup/transaction record
				local backupPath = target .. ".bak"
				if fs.exists(target) then
					-- Check for manual tweaks/modifications warning
					local isTweaked = false
					if lastInstalledSize then
						local currentSize = fs.getSize(target)
						if currentSize ~= lastInstalledSize then
							isTweaked = true
						end
					end
					if isTweaked then
						term.setTextColor(colors.yellow)
						print(string.format("\n  [WARN] Local modifications detected in %s!", target))
						write(string.format("  Creating backup: %s ... ", backupPath))
						if fs.exists(backupPath) then
							fs.delete(backupPath)
						end
						fs.copy(target, backupPath)
						term.setTextColor(colors.lime)
						print("OK")
						term.setTextColor(colors.white)
					else
						-- Silent backup for transaction rollback
						if fs.exists(backupPath) then
							fs.delete(backupPath)
						end
						fs.copy(target, backupPath)
					end
					backups[target] = { action = "restore" }
				else
					backups[target] = { action = "delete" }
				end

				write(string.format("  [%d/%d] Downloading %s... ", current, total, target))
				local success, err = downloadFile(REPO_URL .. source, target)
				if success then
					-- NOTE: SHA256 cannot be computed locally in CC Lua (no native API, pure-Lua
					-- implementation would freeze the computer). Trust model instead:
					--   1. HTTPS guarantees the download was not tampered in transit.
					--   2. sizeBytes is a fast sanity check for truncated/incomplete downloads.
					--   3. hash is stored in state so the *next* run can skip correctly.
					if expectedSize and fs.exists(target) then
						local actualSize = fs.getSize(target)
						if actualSize ~= expectedSize then
							-- Delete the corrupted/truncated file to prevent a broken partial install.
							fs.delete(target)
							term.setTextColor(colors.red)
							print(
								string.format(
									"FAILED (size mismatch: got %dB, expected %dB — file removed)",
									actualSize,
									expectedSize
								)
							)
							term.setTextColor(colors.white)
							stats.failed = stats.failed + 1
							rollback()
							return
						end
					end
					term.setTextColor(colors.lime)
					print("OK")
					stats.updated = stats.updated + 1
					-- Store the manifest hash and size as the version fingerprint for this file.
					-- On the next install run, this allows skipping the download if the
					-- manifest version hasn't changed.
					if expectedHash then
						installState.files[target] = {
							hash = expectedHash,
							sizeBytes = fs.getSize(target),
						}
						saveInstallState(installState)
					end
				else
					term.setTextColor(colors.red)
					print("FAILED")
					print("    Error: " .. err)
					term.setTextColor(colors.white)
					stats.failed = stats.failed + 1
					rollback()
					return
				end
			end
		end
	end

	term.setTextColor(colors.white)
	print("\nTotal files processed: " .. total)

	-- Beautiful Stats Summary
	write("  Results: ")
	term.setTextColor(colors.blue)
	write(stats.cached .. " cached")
	term.setTextColor(colors.gray)
	write(", ")
	term.setTextColor(colors.green)
	write(stats.updated .. " updated")
	term.setTextColor(colors.gray)
	write(", ")
	term.setTextColor(colors.yellow)
	write(stats.preserved .. " preserved")
	term.setTextColor(colors.gray)
	write(", ")
	term.setTextColor(colors.red)
	write(stats.failed .. " failed")
	term.setTextColor(colors.white)
	print("\n")

	if not isDryRun then
		print("Installation complete.")

		-- Cleanup
		if fs.exists(MANIFEST_NAME) then
			fs.delete(MANIFEST_NAME)
		end
		print("Cleanup: Removed manifest.")

		-- Clean up temporary rollback backup files
		for target, info in pairs(backups) do
			if info.action == "restore" then
				local backupPath = target .. ".bak"
				if fs.exists(backupPath) then
					fs.delete(backupPath)
				end
			end
		end

		if targetPkg.entry and fs.exists(targetPkg.entry) then
			print("\nWould you like to run " .. targetPkg.entry .. " now? (y/n)")
			local ans = read()

			-- Delete self before potential long-running entry script
			local selfPath = shell.getRunningProgram()
			if fs.exists(selfPath) then
				fs.delete(selfPath)
				print("Cleanup: Removed installer.")
			end

			if ans and ans:lower() == "y" then
				shell.run(targetPkg.entry)
			else
				print("Exit. You can start the app via: " .. targetPkg.entry)
			end
		else
			-- Delete self if no entry or dry run finished
			local selfPath = shell.getRunningProgram()
			if fs.exists(selfPath) then
				fs.delete(selfPath)
			end
		end
	end
end

----- Helper: Word wrap text for the description pane
local function drawWrappedText(text, x, y, width, center)
	local words = {}
	for word in text:gmatch("%S+") do
		table.insert(words, word)
	end

	local line = ""
	local currY = y
	local function writeLine(l)
		local drawX = x
		if center then
			drawX = x + math.floor((width - #l) / 2)
		end
		term.setCursorPos(drawX, currY)
		term.write(l:sub(1, width))
		currY = currY + 1
	end

	for _, word in ipairs(words) do
		if #line + #word + 1 > width then
			writeLine(line)
			line = word
		else
			line = line == "" and word or line .. " " .. word
		end
		-- Prevent vertical overflow
		local _, h = term.getSize()
		if currY > h - 3 then
			break
		end
	end
	writeLine(line)
	return currY
end

--- Main Entry Point
local function main()
	applyPalette()

	local ok, err = pcall(function()
		local ok_check, updated = pcall(checkForSelfUpdate)
		if ok_check and updated then
			return
		end
		if not ok_check then
			term.setTextColor(colors.red)
			print("Error checking for updates: " .. tostring(updated))
			term.setTextColor(colors.white)
			os.sleep(5)
		end

		local manifest, err_manifest = loadManifest()
		if not manifest then
			term.setTextColor(colors.red)
			print("Error: " .. err_manifest)
			term.setTextColor(colors.white)
			os.sleep(5)
			return
		end

		local isDryRun = false
		local isForce = false
		local selectedPkgId = nil

		for _, arg in ipairs(args) do
			if arg == "--validate" then
				validateManifest(manifest)
				return
			elseif arg == "--dry-run" then
				isDryRun = true
			elseif arg == "--force" or arg == "-f" then
				isForce = true
			elseif manifest.packages[arg] then
				selectedPkgId = arg
			end
		end

		if selectedPkgId then
			install(selectedPkgId, manifest, isDryRun, isForce)
			return
		end

		-- Interactive Mode Setup
		local menu = {}
		for id, pkg in pairs(manifest.packages) do
			if not pkg.hidden then
				table.insert(menu, { id = id, name = pkg.name, desc = pkg.description })
			end
		end
		table.sort(menu, function(a, b)
			return a.id < b.id
		end)

		local selectedIndex = 1

		while true do
			local w, h = term.getSize()
			local leftWidth = math.floor(w * 0.45)
			local rightWidth = w - leftWidth - 4
			local rightX = leftWidth + 3

			term.setBackgroundColor(colors.black)
			term.clear()

			-- Premium Header (Gefüllter blauer Header-Balken wie beim Boot-Assistenten)
			term.setBackgroundColor(colors.blue)
			term.setTextColor(colors.white)
			for y = 1, 3 do
				term.setCursorPos(1, y)
				term.write(string.rep(" ", w))
			end
			local title = "ZONK'S UNIVERSAL INSTALLER"
			local titleX = math.floor((w - #title) / 2) + 1
			term.setCursorPos(titleX, 2)
			term.write(title)
			term.setBackgroundColor(colors.black)

			-- Draw Columns
			for i, item in ipairs(menu) do
				local y = i + 4
				if y > h - 2 then
					break
				end

				term.setCursorPos(1, y)
				local displayName = item.name:sub(1, leftWidth - 2)
				if i == selectedIndex then
					term.setBackgroundColor(colors.lightGray)
					term.setTextColor(colors.cyan)
					term.write("> " .. displayName .. string.rep(" ", leftWidth - #displayName - 1))
					term.setBackgroundColor(colors.black)
				else
					term.setTextColor(colors.white)
					term.write("  " .. displayName)
				end
			end

			-- Separator (Dezenter als das grelle Cyan)
			term.setTextColor(colors.gray)
			for y = 4, h - 2 do
				term.setCursorPos(leftWidth + 1, y)
				term.write("|")
			end

			-- Description Box
			local current = menu[selectedIndex]
			term.setTextColor(colors.yellow)
			local nextY = drawWrappedText(current.name:upper(), rightX, 5, rightWidth, true)

			term.setTextColor(colors.gray)
			term.setCursorPos(rightX, nextY)
			term.write(string.rep("-", rightWidth))

			term.setTextColor(colors.white)
			drawWrappedText(current.desc, rightX, nextY + 2, rightWidth, false)

			-- Status Bar
			term.setTextColor(colors.gray)
			term.setCursorPos(2, h)
			term.write("[Arrows] Scroll | [Enter] Install | [Q] Quit")
			term.setTextColor(colors.white)

			-- Event Loop
			local _, key = os.pullEvent("key")
			if key == keys.up then
				selectedIndex = selectedIndex > 1 and selectedIndex - 1 or #menu
			elseif key == keys.down then
				selectedIndex = selectedIndex < #menu and selectedIndex + 1 or 1
			elseif key == keys.enter then
				term.clear()
				term.setCursorPos(1, 1)
				install(menu[selectedIndex].id, manifest, false, isForce)
				break
			elseif key == keys.q then
				term.clear()
				term.setCursorPos(1, 1)
				print("Exit.")
				break
			end
		end
	end)

	restorePalette()

	if not ok then
		error(err, 0)
	end
end

main()
