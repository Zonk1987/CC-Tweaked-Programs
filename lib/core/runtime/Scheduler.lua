--[[
================================================================================
Scheduler Module v1.0.0
================================================================================
The cooperative multitasking Scheduler for CC:Tweaked. Runs an event-loop
that pulls Minecraft system events and dispatches them to active Fibers.
================================================================================
]]

local Fiber = require("Fiber")

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new()
	local self = setmetatable({}, Scheduler)
	self.fibers = {}
	self.running = false
	self.activeFiber = nil
	return self
end

-- Spawn a new fiber and add it to the scheduler
-- @param func [function] The function to execute inside the fiber
-- @param name [string] An optional debug name
-- @return [Fiber] The created fiber instance
function Scheduler:spawn(func, name)
	local fiber = Fiber.new(func, name)
	table.insert(self.fibers, fiber)
	return fiber
end

-- Static helper function for fibers to sleep without blocking the thread
-- @param seconds [number] Time in seconds to sleep
function Scheduler.sleep(seconds)
	coroutine.yield("sleep", seconds or 0.05)
end

-- Static helper function for fibers to wait for a specific CC event
-- @param eventName [string] The event to wait for
-- @return [any] The event parameters returned by pullEvent
function Scheduler.waitEvent(eventName)
	return coroutine.yield(eventName)
end

-- The main event-driven scheduler loop
function Scheduler:run()
	self.running = true
	local pulledEvent = nil

	-- Preserve standard CC APIs
	local originalPullEventRaw = os.pullEventRaw
	local originalPullEvent = os.pullEvent
	local originalSleep = os.sleep

	-- Apply cooperative monkey-patches
	os.pullEventRaw = function(sFilter)
		if self.activeFiber and self.running then
			return coroutine.yield(sFilter)
		else
			return originalPullEventRaw(sFilter)
		end
	end

	os.pullEvent = function(sFilter)
		local eventData = { os.pullEventRaw(sFilter) }
		if eventData[1] == "terminate" then
			error("Terminated", 0)
		end
		return unpack(eventData)
	end

	os.sleep = function(seconds)
		if self.activeFiber and self.running then
			coroutine.yield("sleep", seconds or 0.05)
		else
			originalSleep(seconds)
		end
	end

	local function cleanup()
		-- Restore CC APIs
		os.pullEventRaw = originalPullEventRaw
		os.pullEvent = originalPullEvent
		os.sleep = originalSleep
		self.running = false
	end

	local ok, err = pcall(function()
		while self.running and #self.fibers > 0 do
			local deadIndices = {}

			-- 1. Run all fibers that are not waiting for an event or whose sleep timer expired
			for i, fiber in ipairs(self.fibers) do
				if fiber.status == "dead" or not fiber:isAlive() then
					table.insert(deadIndices, 1, i)
				else
					local shouldResume = false
					local resumeArgs = {}

					if not fiber.waitingForEvent and not fiber.sleepTimerId then
						-- Fiber is ready to run (unsuspended)
						shouldResume = true
					elseif fiber.waitingForEvent and pulledEvent then
						if fiber.waitingForEvent == true or pulledEvent[1] == fiber.waitingForEvent then
							-- Event the fiber was waiting for has occurred
							shouldResume = true
							resumeArgs = pulledEvent
						end
					elseif
						fiber.sleepTimerId
						and pulledEvent
						and pulledEvent[1] == "timer"
						and pulledEvent[2] == fiber.sleepTimerId
					then
						-- Sleep timer of the fiber has fired
						shouldResume = true
						fiber.sleepTimerId = nil
						fiber.wakeTime = nil
					end

					if shouldResume then
						fiber.waitingForEvent = nil
						self.activeFiber = fiber
						local resumeOk, action, param = fiber:resume(unpack(resumeArgs))
						self.activeFiber = nil

						if not resumeOk then
							-- Fiber crashed
							if term and term.isColor and term.isColor() then
								local prevColor = term.getTextColor()
								term.setTextColor(colors.red)
								print("[Scheduler ERROR] Fiber '" .. fiber.name .. "' crashed: " .. tostring(action))
								term.setTextColor(prevColor)
							else
								print("[Scheduler ERROR] Fiber '" .. fiber.name .. "' crashed: " .. tostring(action))
							end
							-- Force status to dead
							fiber.status = "dead"
						else
							-- Process yield command
							if action == "sleep" then
								local duration = tonumber(param) or 0.05
								fiber.sleepTimerId = os.startTimer(duration)
							else
								fiber.waitingForEvent = action or true
							end
						end
					end
				end
			end

			-- 2. Clean up dead fibers
			for _, idx in ipairs(deadIndices) do
				table.remove(self.fibers, idx)
			end

			-- 3. Yield to the CC OS and pull the next event
			if self.running and #self.fibers > 0 then
				-- We block and pull the next event using original to bypass monkey-patch
				local eventData = { originalPullEventRaw() }
				pulledEvent = eventData

				-- Support manual termination via terminate event (Ctrl+T)
				if eventData[1] == "terminate" then
					if term and term.isColor and term.isColor() then
						local prevColor = term.getTextColor()
						term.setTextColor(colors.yellow)
						print("\n[Scheduler] Termination request received. Shutting down...")
						term.setTextColor(prevColor)
					else
						print("\n[Scheduler] Termination request received. Shutting down...")
					end
					self:stop()
				end
			end
		end
	end)

	cleanup()

	if not ok then
		error(err, 0)
	end
end

-- Stop the scheduler loop
function Scheduler:stop()
	self.running = false
end

return Scheduler
