---@diagnostic disable: undefined-global, undefined-field
-- luacheck: globals peripheral
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

--- Get the type of a physical peripheral
--- @param name string
--- @return string|nil
function HAL.getType(name)
	if not name or name == "" then
		return nil
	end
	if not peripheral.isPresent(name) then
		return nil
	end
	return peripheral.getType(name)
end

--- Check if a peripheral is of a specific type or has a specific capability/type
--- @param name string
--- @param expectedType string
--- @return boolean
function HAL.hasType(name, expectedType)
	if not name or name == "" then
		return false
	end
	if not peripheral.isPresent(name) then
		return false
	end
	if expectedType == "inventory" then
		local device = peripheral.wrap(name)
		if device and type(device["list"]) == "function" and type(device["size"]) == "function" then
			return true
		end
	end
	if type(peripheral.hasType) == "function" then
		return peripheral.hasType(name, expectedType) == true
	end
	local t = peripheral.getType(name)
	return t == expectedType
end

--- Get all currently connected peripheral names
--- @return table list
function HAL.getNames()
	return peripheral.getNames()
end

--- Get the physical name of a wrapped peripheral object
--- @param wrappedObj table|nil
--- @return string|nil
function HAL.getName(wrappedObj)
	if not wrappedObj then
		return nil
	end
	return peripheral.getName(wrappedObj)
end

--- Get all methods of a physical peripheral
--- @param name string
--- @return table|nil
function HAL.getMethods(name)
	if not name or name == "" then
		return nil
	end
	if not peripheral.isPresent(name) then
		return nil
	end
	return peripheral.getMethods(name)
end

--- Returns a list of names for all peripherals of a specific type (proxy to PeripheralScanner)
--- @param expectedType string
--- @return table list
function HAL.listNames(expectedType)
	if expectedType == "inventory" then
		local names = {}
		local all = peripheral.getNames()
		for _, name in ipairs(all) do
			local device = peripheral.wrap(name)
			if device and type(device["list"]) == "function" and type(device["size"]) == "function" then
				table.insert(names, name)
			end
		end
		return names
	end
	return PeripheralScanner.listNames(expectedType)
end

--- Call a method on a physical peripheral
--- @param name string
--- @param method string
--- @param ... any
--- @return any
function HAL.call(name, method, ...)
	if not name or not method then
		return nil
	end
	return peripheral.call(name, method, ...)
end

return HAL
