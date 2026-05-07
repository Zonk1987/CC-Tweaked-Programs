-- Localize globals
local setmetatable = setmetatable
local peripheral = peripheral
local next = next

---@class InventoryComponent
---@field name string
local InventoryComponent = {}
InventoryComponent.__index = InventoryComponent

--- Creates a generic inventory component
---@param name string
---@return InventoryComponent
function InventoryComponent:new(name)
    local instance = setmetatable({}, self)
    instance.name = name
    return instance
end

--- Checks if the peripheral is present on the network
---@return boolean
function InventoryComponent:isPresent()
    return peripheral.isPresent(self.name)
end

--- Wraps and returns the peripheral
---@return table|nil
function InventoryComponent:getPeripheral()
    if self:isPresent() then
        return peripheral.wrap(self.name)
    end
    return nil
end

--- Lists the items in the inventory
---@return table
function InventoryComponent:list()
    local p = self:getPeripheral()
    if p then return p.list() end
    return {}
end

--- Checks if the inventory is completely empty
---@return boolean
function InventoryComponent:isEmpty()
    return not next(self:list())
end

return InventoryComponent
