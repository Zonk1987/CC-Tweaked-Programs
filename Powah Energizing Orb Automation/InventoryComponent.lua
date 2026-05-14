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

--- Creates a new instance
---@param name string
---@return InventoryComponent
function InventoryComponent.new(name)
    local self = setmetatable({}, InventoryComponent)
    self.name = name
    self.native = peripheral.wrap(name)
    return self
end

--- Checks if the peripheral is connected and valid
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

--- Generic list items function
---@return table|nil, string|nil
function InventoryComponent:list()
    if not self:isPresent() then
        return nil, "peripheral_missing"
    end

    if type(self.native.list) ~= "function" then
        return nil, "not_an_inventory"
    end

    return self.native.list()
end

return InventoryComponent