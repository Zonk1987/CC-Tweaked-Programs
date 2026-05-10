-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})
local InventoryComponent = require("InventoryComponent")

-- Localize globals
local setmetatable = setmetatable
local pairs = pairs

---@class Orb : InventoryComponent
local Orb = setmetatable({}, { __index = InventoryComponent })
Orb.__index = Orb

--- Creates a new Orb
---@param name string
---@return Orb
function Orb:new(name)
    local instance = InventoryComponent:new(name)
    ---@cast instance Orb
    return setmetatable(instance, self)
end

--- Recovers items back to a chest
---@param targetChestName string
function Orb:recover(targetChestName)
    local p = self:getPeripheral()
    if not p then return end
    for slot, item in pairs(p.list()) do
        p.pushItems(targetChestName, slot)
    end
end

return Orb
