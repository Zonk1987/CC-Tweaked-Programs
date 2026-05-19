--- @diagnostic disable: undefined-global
-- InventoryAdapter: Generic inventory handling and peripheral wrapping
-- Governed by AGENTS.md

local HAL = require("HAL")

local InventoryAdapter = {}
InventoryAdapter.__index = InventoryAdapter

---@class InventoryAdapter
---@field name string The peripheral name
---@field native table|nil The wrapped peripheral object

--- Creates a new InventoryAdapter
--- @param name string The peripheral name (e.g. "minecraft:chest_0")
--- @return InventoryAdapter
function InventoryAdapter.new(name)
	local self = setmetatable({
		name = name,
		native = HAL.get(name),
	}, InventoryAdapter)
	return self
end

--- Checks if the peripheral is connected and valid
--- @return boolean
function InventoryAdapter:isPresent()
	if not self.name or self.name == "" then
		return false
	end
	local device = HAL.get(self.name)
	if device then
		self.native = device
		return true
	end
	self.native = nil
	return false
end

--- Returns the native peripheral object, ensuring it's still present
--- @return table|nil
function InventoryAdapter:getNative()
	if self:isPresent() then
		return self.native
	end
	return nil
end

--- Lists items in the inventory
--- @return table<number, table>|nil items, string|nil err
function InventoryAdapter:list()
	local p = self:getNative()
	if not p then
		return nil, "peripheral_missing"
	end
	if type(p.list) ~= "function" then
		return nil, "not_an_inventory"
	end

	local ok, items = pcall(p.list)
	if not ok then
		return nil, "list_failed"
	end
	return items or {}
end

--- Checks if the inventory is completely empty
--- @return boolean
function InventoryAdapter:isEmpty()
	local items = self:list()
	if not items then
		return true
	end
	return next(items) == nil
end

--- Pulls items from another inventory
--- @param fromName string Source inventory name
--- @param fromSlot number Source slot
--- @param count number|nil Amount to pull
--- @param toSlot number|nil Target slot
--- @return number|nil moved
function InventoryAdapter:pullItems(fromName, fromSlot, count, toSlot)
	local p = self:getNative()
	if p and p.pullItems then
		local ok, moved = pcall(p.pullItems, fromName, fromSlot, count, toSlot)
		return ok and moved or 0
	end
	return 0
end

--- Pushes items to another inventory
--- @param toName string Target inventory name
--- @param fromSlot number Source slot
--- @param count number|nil Amount to push
--- @param toSlot number|nil Target slot
--- @return number|nil moved
function InventoryAdapter:pushItems(toName, fromSlot, count, toSlot)
	local p = self:getNative()
	if p and p.pushItems then
		local ok, moved = pcall(p.pushItems, toName, fromSlot, count, toSlot)
		return ok and moved or 0
	end
	return 0
end

return InventoryAdapter
