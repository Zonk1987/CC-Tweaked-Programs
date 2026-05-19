--- @diagnostic disable: undefined-global
-- HAL: Hardware Abstraction Layer gateway for unified peripheral resolution
-- Governed by AGENTS.md

local PeripheralScanner = require("PeripheralScanner")

local HAL = {}
local mappings = {}

--- Register a logical name to a physical name or side
--- @param logicalName string
--- @param physicalName string
function HAL.register(logicalName, physicalName)
	mappings[logicalName] = physicalName
end

--- Get a wrapped peripheral by its logical name or fallback search
--- @param logicalName string
--- @param expectedType string|nil
--- @return table|nil
function HAL.get(logicalName, expectedType)
	local name = mappings[logicalName] or logicalName
	local device = PeripheralScanner.wrap(name, expectedType)
	if device then
		return device
	end

	-- Fallback search by type if name wrapping fails
	local found = PeripheralScanner.find(expectedType or logicalName)
	if found then
		return found
	end

	return nil
end

--- Wrap a side or name with validation (proxy to PeripheralScanner)
--- @param name string
--- @param expectedType string|nil
--- @return table|nil
function HAL.wrap(name, expectedType)
	return PeripheralScanner.wrap(name, expectedType)
end

--- Check if a logical device is present
--- @param logicalName string
--- @param expectedType string|nil
--- @return boolean
function HAL.isPresent(logicalName, expectedType)
	local name = mappings[logicalName] or logicalName
	if name and peripheral.isPresent(name) then
		if expectedType and peripheral.getType(name) ~= expectedType then
			return false
		end
		return true
	end
	-- Fallback search check
	local found = PeripheralScanner.find(expectedType or logicalName)
	return found ~= nil
end

--- Get standard peripherals by type / logical name
function HAL.getModem()
	return HAL.get("modem", "modem")
end

function HAL.getMonitor()
	return HAL.get("monitor", "monitor")
end

function HAL.getInventory(logicalName)
	return HAL.get(logicalName or "inventory", "inventory")
end

function HAL.getTeleporter()
	return HAL.get("teleporter", "mekanism:teleporter")
		or HAL.get("teleporter", "teleporter")
		or HAL.get("teleporter", "mekanismteleporter")
end

return HAL
