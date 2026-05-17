-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local InventoryAdapter = require("InventoryAdapter")

---@class Orb : InventoryAdapter
local Orb = setmetatable({}, { __index = InventoryAdapter })
Orb.__index = Orb

--- Creates a new Orb instance
---@param name string
---@return Orb
function Orb.new(name)
    local self = InventoryAdapter.new(name)
    ---@cast self Orb
    return setmetatable(self, Orb)
end

--- Checks if the orb has items
---@return boolean
function Orb:isEmpty()
    local items = self:list()
    if not items then return true end

    return next(items) == nil
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
        local ok, pushErr = pcall(self.native.pushItems, targetName, slot)
        if not ok then
            return false, tostring(pushErr)
        end
    end

    return true
end

return Orb