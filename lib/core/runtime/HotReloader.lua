local EventBus = require("EventBus")
local Scheduler = require("Scheduler")

local HotReloader = {}

-- Safe list of globals and core Lua modules that should never be purged
local PRESERVED_MODULES = {
	["_G"] = true,
	["package"] = true,
	["coroutine"] = true,
	["table"] = true,
	["io"] = true,
	["os"] = true,
	["string"] = true,
	["math"] = true,
	["debug"] = true,
	["bit32"] = true,
	["utf8"] = true,
	["cc.expect"] = true,
	["cc.completion"] = true,
	["cc.strings"] = true,
	["cc.require"] = true,
}

--- Purges the `package.loaded` cache of all custom modules.
function HotReloader.purgeCache()
	local toClear = {}
	for k, _ in pairs(package.loaded) do
		if not PRESERVED_MODULES[k] then
			table.insert(toClear, k)
		end
	end
	for _, k in ipairs(toClear) do
		package.loaded[k] = nil
	end
end

--- Recursively collects all .lua files in the given directories
local function collectFiles(directories)
	local files = {}
	for _, dir in ipairs(directories) do
		if fs.exists(dir) and fs.isDir(dir) then
			local function scan(path)
				for _, item in ipairs(fs.list(path)) do
					local fullPath = fs.combine(path, item)
					if fs.isDir(fullPath) then
						scan(fullPath)
					elseif fullPath:sub(-4) == ".lua" then
						table.insert(files, fullPath)
					end
				end
			end
			scan(dir)
		end
	end
	return files
end

--- Spawns a background worker to watch for file changes
---@param directories table List of directories to watch
---@param scheduler table The app's scheduler
---@param logger table The app's logger
function HotReloader.startWatcher(directories, scheduler, logger)
	scheduler:spawn(function()
		local fileTimes = {}

		-- Initial scan
		local files = collectFiles(directories)
		for _, file in ipairs(files) do
			local ok, attr = pcall(fs.attributes, file)
			if ok and attr then
				fileTimes[file] = attr.modified
			end
		end

		if logger then
			logger:info("HotReloader: Watching " .. #files .. " files in " .. #directories .. " directories.")
		end

		while scheduler.running do
			Scheduler.sleep(1) -- Check every 1 second

			local changed = false
			local changedFile = nil

			-- Re-scan to detect changes or newly added files
			local currentFiles = collectFiles(directories)
			for _, file in ipairs(currentFiles) do
				local ok, attr = pcall(fs.attributes, file)
				if not ok or not attr then
					if fileTimes[file] then
						changed = true
						changedFile = file
						break
					end
				else
					local mtime = attr.modified
					if not fileTimes[file] or fileTimes[file] ~= mtime then
						changed = true
						changedFile = file
						break
					end
				end
			end

			if changed then
				if logger then
					logger:warn("HotReloader: File changed -> " .. changedFile)
					logger:warn("HotReloader: Requesting soft reboot...")
				end
				EventBus:emit("APP_REBOOT_REQUESTED", changedFile)
				-- Stop watching, wait for reboot
				break
			end
		end
	end, "HotReloader-Watcher")
end

return HotReloader
