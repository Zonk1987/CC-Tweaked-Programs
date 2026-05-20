--- @diagnostic disable: undefined-global
-- Logger: Universal Logging Utility with Log Rotation
-- Governed by AGENTS.md

local Logger = {}
Logger.__index = Logger

-- Standard Log Levels
local LEVELS = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
}

local LEVEL_NAMES = {
	[1] = "DEBUG",
	[2] = "INFO",
	[3] = "WARN",
	[4] = "ERROR",
}

--- Creates a new Logger instance
--- @param options table|nil Optional configurations
function Logger.new(options)
	options = options or {}
	local self = setmetatable({
		logPath = options.logPath or "/logs/latest.log",
		maxFileSize = options.maxFileSize or 51200, -- Default: 50 KB (50 * 1024)
		maxBackups = options.maxBackups or 5, -- Default: 5 backup files
		minLevel = LEVELS[options.minLevel] or LEVELS.INFO, -- Default Level: INFO
		disabled = false, -- Safety switch if disk is full
	}, Logger)

	-- Ensure the logs directory exists
	local dir = fs.getDir(self.logPath)
	if dir and dir ~= "" and dir ~= "." then
		if not fs.exists(dir) then
			pcall(fs.makeDir, dir)
		end
	end

	return self
end

--- Performs backup log rotation
function Logger:rotate()
	if self.disabled then
		return
	end

	local ok, err = pcall(function()
		-- 1. Delete the oldest backup if it exists
		local oldestPath = self.logPath:gsub("%.log$", "-" .. self.maxBackups .. ".log")
		if fs.exists(oldestPath) then
			fs.delete(oldestPath)
		end

		-- 2. Shift existing backups down (e.g. log-4 -> log-5)
		for i = self.maxBackups - 1, 1, -1 do
			local current = self.logPath:gsub("%.log$", "-" .. i .. ".log")
			local nextBackup = self.logPath:gsub("%.log$", "-" .. (i + 1) .. ".log")
			if fs.exists(current) then
				fs.move(current, nextBackup)
			end
		end

		-- 3. Move latest to log-1
		if fs.exists(self.logPath) then
			local log1 = self.logPath:gsub("%.log$", "-1.log")
			fs.move(self.logPath, log1)
		end
	end)

	if not ok then
		-- Disable file logging if rotation fails (e.g., out of disk space)
		self.disabled = true
		printError("Logger: Rotation failed: " .. tostring(err))
	end
end

--- Writes a message to the log file and optionally standard output
--- @param levelVal number The numeric log level
--- @param msg string The log message template
--- @param ... any Formatting arguments
function Logger:write(levelVal, msg, ...)
	if levelVal < self.minLevel then
		return
	end

	-- Format message using string.format if arguments are provided
	local formattedMsg = msg
	if select("#", ...) > 0 then
		local ok, res = pcall(string.format, msg, ...)
		if ok then
			formattedMsg = res
		end
	end

	local levelName = LEVEL_NAMES[levelVal] or "INFO"
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local logLine = string.format("[%s] [%s] %s\n", timestamp, levelName, formattedMsg)

	-- Output to file if not disabled
	if not self.disabled then
		local okWrite = pcall(function()
			-- Check file size and rotate if necessary
			if fs.exists(self.logPath) and fs.getSize(self.logPath) >= self.maxFileSize then
				self:rotate()
			end

			-- Append to the log file
			local f = fs.open(self.logPath, "a")
			if f then
				f.write(logLine)
				f.close()
			else
				error("Could not open log file for writing")
			end
		end)

		if not okWrite then
			self.disabled = true
			printError("Logger: File logging failed, disabling disk writes.")
		end
	end
end

--- Logs a message at DEBUG level
--- @param msg string Log message
--- @param ... any Formatting arguments
function Logger:debug(msg, ...)
	self:write(LEVELS.DEBUG, msg, ...)
end

--- Logs a message at INFO level
--- @param msg string Log message
--- @param ... any Formatting arguments
function Logger:info(msg, ...)
	self:write(LEVELS.INFO, msg, ...)
end

--- Logs a message at WARN level
--- @param msg string Log message
--- @param ... any Formatting arguments
function Logger:warn(msg, ...)
	self:write(LEVELS.WARN, msg, ...)
end

--- Logs a message at ERROR level
--- @param msg string Log message
--- @param ... any Formatting arguments
function Logger:error(msg, ...)
	self:write(LEVELS.ERROR, msg, ...)
end

return Logger
