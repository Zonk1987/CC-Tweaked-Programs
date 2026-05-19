-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

local InventoryAdapter = require("InventoryAdapter")
local ItemMatcher = require("ItemMatcher")

---@class Chest : InventoryAdapter
local Chest = setmetatable({}, { __index = InventoryAdapter })
Chest.__index = Chest

--- Creates a new Chest instance
---@param name string
---@return Chest
function Chest.new(name)
	local self = InventoryAdapter.new(name)
	---@cast self Chest
	return setmetatable(self, Chest)
end

--- Transfers recipe items to an orb
---@param recipe table
---@param orbName string
---@return boolean success, string|nil err
function Chest:transferRecipe(recipe, orbName)
	local p = self:getNative()
	if not p then
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

		for slot, item in pairs(items) do
			if ItemMatcher.matches(item, itemName) then
				local toMove = count - transferred
				if toMove > 0 then
					local moved = self:pushItems(orbName, slot, toMove)
					transferred = transferred + (moved or 0)
				end
			end
		end

		if transferred < count then
			return false, "insufficient_items:" .. itemName
		end
	end

	return true
end

--- Checks if the peripheral is connected and valid (delegated to InventoryAdapter)
---@return boolean
function Chest:isPresent()
	return InventoryAdapter.isPresent(self)
end

--- Returns the native peripheral object (delegated to InventoryAdapter)
---@return any
function Chest:getNative()
	return InventoryAdapter.getNative(self)
end

--- Lists items in the inventory (delegated to InventoryAdapter)
---@return table<number, table>|nil items, string|nil err
function Chest:list()
	return InventoryAdapter.list(self)
end

--- Pushes items to another inventory (delegated to InventoryAdapter)
---@param toName string
---@param fromSlot number
---@param count number|nil
---@param toSlot number|nil
---@return number|nil
function Chest:pushItems(toName, fromSlot, count, toSlot)
	return InventoryAdapter.pushItems(self, toName, fromSlot, count, toSlot)
end

return Chest
