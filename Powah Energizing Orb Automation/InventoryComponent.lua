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
---@field native any
local InventoryComponent = {}
InventoryComponent.__index = InventoryComponent

--- Creates a new instance
---@param name string
---@return InventoryComponent
function InventoryComponent:new(name)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.native = peripheral.wrap(name)
    return instance
end

--- Checks if the peripheral is connected
---@return boolean
function InventoryComponent:isPresent()
    self.native = peripheral.wrap(self.name)
    return self.native ~= nil
end

--- Generic list items function
---@return table|nil
function InventoryComponent:list()
    if not self:isPresent() then return nil end
    return self.native.list()
end

return InventoryComponent