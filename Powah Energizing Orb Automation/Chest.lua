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
local next = next
local os_epoch = os.epoch
local os_sleep = os.sleep

---@class Chest : InventoryComponent
local Chest = setmetatable({}, { __index = InventoryComponent })
Chest.__index = Chest

--- Creates a new Chest
---@param name string
---@return Chest
function Chest:new(name)
    local instance = InventoryComponent:new(name)
    setmetatable(instance, self)
    ---@cast instance Chest
    return instance
end

--- Transfers recipe ingredients to an orb
---@param recipe table
---@param orbName string
---@return boolean success
function Chest:transferRecipe(recipe, orbName)
    local itemsToTransfer = {}
    for k, v in pairs(recipe.ingredients) do
        itemsToTransfer[k] = v
    end

    local p = self:getPeripheral()
    if not p then return false end

    local timeoutStart = os_epoch("utc")

    while next(itemsToTransfer) ~= nil do
        if not self:isPresent() then return false end

        for slot, item in pairs(self:list()) do
            if itemsToTransfer[item.name] ~= nil then
                local needed = itemsToTransfer[item.name]
                local transferred = p.pushItems(orbName, slot, needed)

                local itemsLeft = needed - transferred
                if itemsLeft <= 0 then
                    itemsToTransfer[item.name] = nil
                else
                    itemsToTransfer[item.name] = itemsLeft
                end
            end
        end

        if (os_epoch("utc") - timeoutStart) > 5000 then
            return false
        end
        os_sleep(0.1)
    end
    return true
end

return Chest