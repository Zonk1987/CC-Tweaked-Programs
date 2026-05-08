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
    setmetatable(instance, self)
    return instance
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
