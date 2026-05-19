--- @diagnostic disable: undefined-global
-- RednetProtocol: Generic Rednet communication helpers
-- Governed by AGENTS.md

local HAL = require("HAL")

local RednetProtocol = {}

--- Opens rednet on the first available modem
--- @return string|nil side The side rednet was opened on, or nil
function RednetProtocol.openAuto()
	local modems = HAL.listNames("modem")
	if modems[1] then
		local side = modems[1]
		if not rednet.isOpen(side) then
			rednet.open(side)
		end
		return side
	end
	return nil
end

--- Checks if rednet is open on any modem
--- @return boolean
function RednetProtocol.isOpen()
	local modems = HAL.listNames("modem")
	for _, side in ipairs(modems) do
		if rednet.isOpen(side) then
			return true
		end
	end
	return false
end

--- Closes rednet on all modems
function RednetProtocol.closeAll()
	local modems = HAL.listNames("modem")
	for _, side in ipairs(modems) do
		if rednet.isOpen(side) then
			rednet.close(side)
		end
	end
end

--- Broadcasts a formatted message
--- @param protocol string
--- @param msgType string
--- @param data table
function RednetProtocol.broadcast(protocol, msgType, data)
	local payload = {
		protocol = protocol,
		command = msgType,
		timestamp = os.epoch("utc"),
	}
	for k, v in pairs(data) do
		payload[k] = v
	end
	rednet.broadcast(payload, protocol)
end

--- Sends a raw modem message
--- @param channel number Modem channel
--- @param payload table Data to send
function RednetProtocol.transmit(channel, payload)
	local modem = HAL.getModem()
	---@cast modem any
	if modem then
		modem.transmit(channel, os.getComputerID(), payload)
		return true
	end
	return false
end

--- Sends a rednet message to a specific target
--- @param targetId number
--- @param msgType string
--- @param data table
--- @param protocol string
function RednetProtocol.send(targetId, msgType, data, protocol)
	local payload = {
		protocol = protocol,
		type = msgType,
		timestamp = os.epoch("utc"),
	}
	for k, v in pairs(data) do
		payload[k] = v
	end
	rednet.send(targetId, payload, protocol)
end

return RednetProtocol
