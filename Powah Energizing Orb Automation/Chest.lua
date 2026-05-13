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

---@class Chest
---@field name string
---@field native any
local Chest = {}
Chest.__index = Chest

--- Creates a new Chest instance
---@param name string
---@return Chest
function Chest:new(name)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.native = peripheral.wrap(name)
    return instance
end

--- Checks if the chest is connected
---@return boolean
function Chest:isPresent()
    self.native = peripheral.wrap(self.name)
    return self.native ~= nil
end

--- Lists items in the chest
---@return table|nil
function Chest:list()
    if not self:isPresent() then return nil end
    return self.native.list()
end

--- Transfers recipe items to an orb
---@param recipe table
---@param orbName string
---@return boolean success
function Chest:transferRecipe(recipe, orbName)
    if not self:isPresent() then return false end
    
    local success = true
    for itemName, count in pairs(recipe.ingredients) do
        local transferred = 0
        local items = self.native.list()
        
        for slot, item in pairs(items) do
            if item.name == itemName then
                local toMove = count - transferred
                if toMove > 0 then
                    local moved = self.native.pushItems(orbName, slot, toMove)
                    transferred = transferred + moved
                end
            end
        end
        
        if transferred < count then
            success = false
        end
    end
    
    return success
end

return Chest