--[[
================================================================================
Fiber Module v1.0.0
================================================================================
A Fiber object wrapping a native Lua coroutine. Provides lifecycle tracking
and status management for cooperative multitasking in CC:Tweaked.
================================================================================
]]

local Fiber = {}
Fiber.__index = Fiber

-- Create a new Fiber wrapping a function
-- @param func [function] The function to execute inside the coroutine
-- @param name [string] An optional, human-readable name for logging & debugging
function Fiber.new(func, name)
	if type(func) ~= "function" then
		error("Fiber.new: func must be a function!", 2)
	end

	local self = setmetatable({}, Fiber)
	self.co = coroutine.create(func)
	self.name = name or "unnamed-fiber"
	self.status = "suspended" -- "suspended", "running", "dead"
	self.waitingForEvent = nil -- Specific event name this fiber is waiting for
	self.sleepTimerId = nil -- The CC:Tweaked timer ID if this fiber is sleeping
	self.wakeTime = nil -- Epoch time (in seconds) when this fiber should wake up
	return self
end

-- Check if the inner coroutine is alive
function Fiber:isAlive()
	return coroutine.status(self.co) ~= "dead"
end

-- Resume execution of the coroutine
-- @param ... [any] Values to pass to the coroutine
-- @return [boolean] Success status of the resume call
-- @return [any] The yield parameter or error message
function Fiber:resume(...)
	if not self:isAlive() then
		self.status = "dead"
		return false, "dead"
	end

	self.status = "running"
	local results = { coroutine.resume(self.co, ...) }
	local ok = results[1]

	if not self:isAlive() then
		self.status = "dead"
	else
		self.status = "suspended"
	end

	-- Return ok, and whatever was yielded or the error message
	return ok, unpack(results, 2)
end

return Fiber
