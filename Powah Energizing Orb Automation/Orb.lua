-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local InventoryComponent = require("InventoryComponent")

---@class Orb : InventoryComponent
local Orb = setmetatable({}, { __index = InventoryComponent })
Orb.__index = Orb

--- Creates a new Orb instance
---@param name string
---@return Orb
function Orb.new(name)
    local self = InventoryComponent.new(name)
    ---@cast self Orb
    return setmetatable(self, Orb)
end

--- Checks if the orb has items
---@return boolean
function Orb:isEmpty()
    local items, err = self:list()
    if not items then return true end

    for _ in pairs(items) do
        return false
    end
    return true
end

--- Recovers items from the orb back to the chest
---@param targetName string
---@return boolean, string|nil
function Orb:recover(targetName)
    if not targetName or targetName == "" then
        return false, "invalid_target"
    end

    local items, err = self:list()
    if not items then
        return false, err
    end

    for slot, _ in pairs(items) do
        local ok, err = pcall(self.native.pushItems, targetName, slot)
        if not ok then
            return false, tostring(err)
        end
    end

    return true
end

return Orb