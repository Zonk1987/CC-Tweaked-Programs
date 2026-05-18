--- @diagnostic disable: undefined-global
-- RedstoneController: Generic redstone interaction helpers
-- Governed by AGENTS.md

local RedstoneController = {}

--- Pulses redstone on all sides of the computer
--- @param duration number|nil Pulse duration in seconds (default: 0.1)
function RedstoneController.pulseAll(duration)
	duration = duration or 0.1
	local sides = redstone.getSides()
	---@cast sides any
	for _, side in ipairs(sides) do
		redstone.setOutput(side, true)
	end
	os.sleep(duration)
	for _, side in ipairs(sides) do
		redstone.setOutput(side, false)
	end
end

--- Pulses redstone on a specific side
--- @param side string The side to pulse
--- @param duration number|nil Pulse duration in seconds (default: 0.1)
function RedstoneController.pulse(side, duration)
	if not side then
		return
	end
	duration = duration or 0.1
	redstone.setOutput(side, true)
	os.sleep(duration)
	redstone.setOutput(side, false)
end

--- Waits for a redstone signal on any side
--- @param timeout number|nil Optional timeout in seconds
--- @return string|nil side The side that received the signal, or nil on timeout
function RedstoneController.waitForSignal(timeout)
	local timer = timeout and os.startTimer(timeout) or nil
	while true do
		local event, p1 = os.pullEvent()
		if event == "redstone" then
			local sides = redstone.getSides()
			---@cast sides any
			for _, side in ipairs(sides) do
				if redstone.getInput(side) then
					return side
				end
			end
		elseif event == "timer" and p1 == timer then
			return nil
		end
	end
end

--- Checks if any side has a redstone input
--- @return boolean
function RedstoneController.anyInput()
	local sides = redstone.getSides()
	---@cast sides any
	for _, side in ipairs(sides) do
		if redstone.getInput(side) then
			return true
		end
	end
	return false
end

return RedstoneController
