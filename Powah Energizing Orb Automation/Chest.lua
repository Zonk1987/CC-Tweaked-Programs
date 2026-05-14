-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local InventoryComponent = require("InventoryComponent")

---@class Chest : InventoryComponent
local Chest = setmetatable({}, { __index = InventoryComponent })
Chest.__index = Chest

--- Creates a new Chest instance
---@param name string
---@return Chest
function Chest.new(name)
    local self = InventoryComponent.new(name)
    ---@cast self Chest
    return setmetatable(self, Chest)
end

--- Transfers recipe items to an orb
---@param recipe table
---@param orbName string
---@return boolean success, string|nil err
function Chest:transferRecipe(recipe, orbName)
    if not self:isPresent() then
        return false, "chest_missing"
    end

    if not orbName or orbName == "" then
        return false, "invalid_orb_name"
    end

    local items, err = self:list()
    if not items then
        return false, err
    end

    for itemName, count in pairs(recipe.ingredients) do
        local transferred = 0

        -- We re-scan list if multiple slots have same item
        for slot, item in pairs(items) do
            if item.name == itemName then
                local toMove = count - transferred
                if toMove > 0 then
                    local ok, moved = pcall(self.native.pushItems, orbName, slot, toMove)
                    if ok then
                        transferred = transferred + (moved or 0)
                    end
                end
            end
        end

        if transferred < count then
            return false, "insufficient_items:" .. itemName
        end
    end

    return true
end

return Chest