-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local setmetatable = setmetatable
local peripheral = peripheral

---@class InventoryComponent
---@field name string
---@field native table|nil
local InventoryComponent = {}
InventoryComponent.__index = InventoryComponent

--- Creates a generic inventory component
---@param name string
---@return InventoryComponent
function InventoryComponent.new(name)
    local self = setmetatable({}, InventoryComponent)
    self.name = name
    self.native = peripheral.wrap(name)
    return self
end

--- Checks if the peripheral is present on the network
---@return boolean
function InventoryComponent:isPresent()
    if not self.name or self.name == "" then return false end
    local device = peripheral.wrap(self.name)
    if device then
        self.native = device
        return true
    end
    self.native = nil
    return false
end

--- Wraps and returns the peripheral
---@return table|nil
function InventoryComponent:getPeripheral()
    if self:isPresent() then
        return self.native
    end
    return nil
end

--- Lists the items in the inventory
---@return table
function InventoryComponent:list()
    local p = self:getPeripheral()
    if p and p.list then return p.list() or {} end
    return {}
end

--- Checks if the inventory is completely empty
---@return boolean
function InventoryComponent:isEmpty()
    local items = self:list()
    for _ in pairs(items) do return false end
    return true
end

return InventoryComponent
