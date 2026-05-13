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
local pairs = pairs

---@class Orb
---@field name string
---@field native any
local Orb = {}
Orb.__index = Orb

--- Creates a new Orb instance
---@param name string
---@return Orb
function Orb:new(name)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.native = peripheral.wrap(name)
    return instance
end

--- Checks if the orb is connected
---@return boolean
function Orb:isPresent()
    self.native = peripheral.wrap(self.name)
    return self.native ~= nil
end

--- Checks if the orb has items
---@return boolean
function Orb:isEmpty()
    if not self:isPresent() then return true end
    local list = self.native.list()
    for _ in pairs(list) do return false end
    return true
end

--- Recovers items from the orb back to the chest
---@param chestName string
function Orb:recover(chestName)
    if not self:isPresent() then return end
    local list = self.native.list()
    for slot, _ in pairs(list) do
        self.native.pushItems(chestName, slot)
    end
end

return Orb