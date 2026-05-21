--[[
================================================================================
Result Module v1.0.0
================================================================================
A structured, machine-readable success and error representation pattern,
inspired by Rust's Result type. Helps replace error-prone raw string returns.
================================================================================
]]

---@class Result
---@field _ok boolean
---@field data any
---@field code string
---@field message string
---@field hint string
---@field severity string
local Result = {}
Result.__index = Result

-- Constructor for successful outcomes
-- @param data [any] The payload of the successful result
function Result.ok(data)
	local self = setmetatable({}, Result)
	self._ok = true
	self.data = data
	return self
end

-- Constructor for failed outcomes
-- @param code [string] A unique, machine-readable error code (e.g., "PERIPHERAL_MISSING")
-- @param message [string] A user-friendly, descriptive error message
-- @param hint [string] A helpful tip or action guiding the user to solve the issue
-- @param severity [string] "info", "warn", or "error" (default: "error")
function Result.err(code, message, hint, severity)
	local self = setmetatable({}, Result)
	self._ok = false
	self.code = code or "UNKNOWN_ERROR"
	self.message = message or "An unspecified error occurred."
	self.hint = hint or ""
	self.severity = severity or "error"
	return self
end

-- Check if the result was a success
function Result:isOk()
	return self._ok
end

-- Check if the result was a failure
function Result:isErr()
	return not self._ok
end

-- Safely unpacks the inner value. Throws an error if this is a failure.
function Result:unwrap()
	if not self._ok then
		error("Called unwrap() on an error Result! Code: " .. tostring(self.code) .. " - " .. tostring(self.message), 2)
	end
	return self.data
end

-- Safely unpacks the inner value or returns a provided default value.
function Result:unwrapOr(default)
	if not self._ok then
		return default
	end
	return self.data
end

-- Returns the structured error payload if this is an error, nil otherwise.
function Result:getError()
	if self._ok then
		return nil
	end
	return {
		code = self.code,
		message = self.message,
		hint = self.hint,
		severity = self.severity,
	}
end

return Result
