local InventoryComponent = require("InventoryComponent")

-- Localize globals
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
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
    return instance
end

--- Transfers recipe ingredients to the crafter grid
---@param recipe table
---@param crafterGrid CrafterGrid
---@return boolean success
function Chest:transferRecipe(recipe, crafterGrid)
    local p = self:getPeripheral()
    if not p then return false end

    local timeoutStart = os_epoch("utc")

    -- Find max index in ingredients to know how far to iterate
    local maxIndex = 0
    for k, _ in pairs(recipe.ingredients) do
        local numK = tonumber(k)
        if numK and numK > maxIndex then
            maxIndex = numK
        end
    end

    for index = 1, maxIndex do
        local itemName = recipe.ingredients[index]
        -- Skip empty slots
        if itemName ~= nil and itemName ~= "null" and itemName ~= "" then
            local crafterName = crafterGrid:getCrafterName(index)
            if not crafterName then
                return false -- missing crafter for this slot
            end
            
            local needed = 1
            local itemTransferred = false
            
            -- Find the item and push it once
            for slot, item in pairs(self:list()) do
                local isMatch = false
                if itemName:sub(1,1) == "~" then
                    -- Plain text search, ignoring regex magic characters
                    isMatch = item.name:find(itemName:sub(2), 1, true) ~= nil
                else
                    isMatch = (item.name == itemName)
                end

                if isMatch then
                    local ok, transferred = pcall(p.pushItems, crafterName, slot, needed)
                    if not ok then
                        return false, "Crafter " .. crafterName .. " is missing! Recalibrate!"
                    end
                    if transferred == needed then
                        itemTransferred = true
                        break
                    end
                end
            end

            -- If we couldn't transfer the item (e.g. someone took it out mid-transfer)
            -- we immediately abort the entire recipe transfer to avoid getting stuck
            if not itemTransferred then
                return false, "Missing items mid-transfer!"
            end
        end
    end
    
    return true
end

return Chest
