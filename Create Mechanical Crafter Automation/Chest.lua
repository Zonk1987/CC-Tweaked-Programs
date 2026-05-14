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
local ipairs = ipairs
local tonumber = tonumber
local os_epoch = os.epoch
local pcall = pcall

local InventoryAdapter = require("InventoryAdapter")
local ItemMatcher = require("ItemMatcher")

---@class Chest : InventoryAdapter
local Chest = setmetatable({}, { __index = InventoryAdapter })
Chest.__index = Chest

--- Creates a new Chest
---@param name string
---@return Chest
function Chest.new(name)
    local self = InventoryAdapter.new(name)
    ---@cast self Chest
    return setmetatable(self, Chest)
end

--- Transfers recipe ingredients to the crafter grid
---@param recipe table
---@param crafterGrid CrafterGrid
---@return boolean success, string|nil err
function Chest:transferRecipe(recipe, crafterGrid)
    local p = self:getPeripheral()
    if not p then return false, "chest_missing" end

    -- Find max index in ingredients to know how far to iterate
    local maxIndex = 0
    for k, _ in pairs(recipe.ingredients) do
        local numK = tonumber(k)
        if numK and numK > maxIndex then
            maxIndex = numK
        end
    end

    local chestItems = self:list()

    for index = 1, maxIndex do
        local itemName = recipe.ingredients[index]
        -- Skip empty slots
        if itemName ~= nil and itemName ~= "null" and itemName ~= "" then
            local crafterName = crafterGrid:getCrafterName(index)
            if not crafterName then
                return false, "missing_crafter_for_slot:" .. index
            end

            local needed = 1
            local itemTransferred = false

            -- Find the item and push it once
            for slot, item in pairs(chestItems) do
                if ItemMatcher.matches(item, itemName) then
                    local moved = self:pushItems(crafterName, slot, needed)
                    if moved == needed then
                        itemTransferred = true
                        -- Update local list to prevent double-spending the same slot in memory
                        item.count = item.count - 1
                        if item.count <= 0 then chestItems[slot] = nil end
                        break
                    end
                end
            end

            if not itemTransferred then
                return false, "Missing items mid-transfer: " .. itemName
            end
        end
    end

    return true
end

return Chest
