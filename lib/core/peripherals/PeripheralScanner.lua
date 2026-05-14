--- @diagnostic disable: undefined-global
-- PeripheralScanner: Generic peripheral discovery and resolution
-- Governed by AGENTS.md

local PeripheralScanner = {}

--- Find and wrap a peripheral by type
--- @param type string The peripheral type (e.g. "modem", "mekanism:teleporter")
--- @return table|nil peripheral, string|nil name
function PeripheralScanner.find(type)
    local obj = peripheral.find(type)
    if obj then
        return obj, peripheral.getName(obj)
    end
    return nil, nil
end

--- Wrap a peripheral by side/name with validation
--- @param name string The side or name of the peripheral
--- @param expectedType string|nil Optional type validation
--- @return table|nil peripheral
function PeripheralScanner.wrap(name, expectedType)
    if not name or name == "" then return nil end
    if not peripheral.isPresent(name) then return nil end
    
    if expectedType and peripheral.getType(name) ~= expectedType then
        return nil
    end
    
    return peripheral.wrap(name)
end

--- Returns a list of names for all peripherals of a specific type
--- @param type string
--- @return table list
function PeripheralScanner.listNames(type)
    local names = {}
    local found = { peripheral.find(type) }
    for _, obj in ipairs(found) do
        table.insert(names, peripheral.getName(obj))
    end
    return names
end

return PeripheralScanner
