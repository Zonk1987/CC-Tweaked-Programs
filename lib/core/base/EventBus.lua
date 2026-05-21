--[[
================================================================================
EventBus Module v1.0.0
================================================================================
A central, decoupled event dispatcher implementation for CC:Tweaked.
Allows safe, non-blocking asynchronous system-wide event broadcasting.
================================================================================
]]

local EventBus = {}
EventBus.__index = EventBus

local function logError(msg)
	if term and term.isColor and term.isColor() then
		local prevColor = term.getTextColor()
		term.setTextColor(colors.red)
		print(msg)
		term.setTextColor(prevColor)
	else
		print(msg)
	end
end

function EventBus.new()
	local self = setmetatable({}, EventBus)
	self.listeners = {}
	return self
end

-- Subscribe a listener function to a specific event
-- @param eventName [string] The event to listen to
-- @param callback [function] The function to call when the event is emitted
-- @return [function] An unsubscribe function to easily unbind this listener
function EventBus:on(eventName, callback)
	if type(eventName) ~= "string" or type(callback) ~= "function" then
		error("EventBus.on: eventName must be a string and callback must be a function!", 2)
	end

	if not self.listeners[eventName] then
		self.listeners[eventName] = {}
	end

	table.insert(self.listeners[eventName], callback)

	-- Return clean unsubscribe function
	return function()
		self:off(eventName, callback)
	end
end

-- Unsubscribe a listener function from a specific event
-- @param eventName [string] The event to unbind from
-- @param callback [function] The function that was registered
function EventBus:off(eventName, callback)
	if not self.listeners[eventName] then
		return
	end

	for i, registeredCallback in ipairs(self.listeners[eventName]) do
		if registeredCallback == callback then
			table.remove(self.listeners[eventName], i)
			break
		end
	end
end

-- Broadcast an event to all registered listeners.
-- Listeners are called safely wrapped in pcall to prevent failures in one listener
-- from bricking the entire event loop or other listeners.
-- @param eventName [string] The event to emit
-- @param ... [any] Any additional arguments to pass to the callbacks
function EventBus:emit(eventName, ...)
	if type(eventName) ~= "string" then
		error("EventBus.emit: eventName must be a string!", 2)
	end

	local callbacks = self.listeners[eventName]
	if not callbacks then
		return
	end

	-- We copy the list to prevent concurrent modification errors (e.g. if a listener unsubscribes itself during execution)
	local callbacksCopy = {}
	for _, cb in ipairs(callbacks) do
		table.insert(callbacksCopy, cb)
	end

	for _, callback in ipairs(callbacksCopy) do
		local ok, err = pcall(callback, ...)
		if not ok then
			logError("[EventBus ERROR] Error executing listener for event '" .. eventName .. "': " .. tostring(err))
		end
	end
end

-- Global shared instance (Singleton Pattern)
local globalInstance = EventBus.new()

-- Also export class constructor for isolated scopes
globalInstance.new = EventBus.new

return globalInstance
