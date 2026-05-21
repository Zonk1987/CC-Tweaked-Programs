-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
	__index = _ORIG_ENV,
	__newindex = function(t, key, value)
		error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
	end,
})

-- Localize globals
local setmetatable = setmetatable
local pairs = pairs
local tonumber = tonumber
local pcall = pcall

local InventoryAdapter = require("InventoryAdapter")
local ItemMatcher = require("ItemMatcher")
local Result = require("Result")

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
---@return Result
function Chest:transferRecipe(recipe, crafterGrid)
	local p = self:getNative()
	if not p then
		return Result.err("CHEST_MISSING", "Puffer-Kiste ist nicht angeschlossen.")
	end

	-- Find max index in ingredients to know how far to iterate
	local maxIndex = 0
	for k, _ in pairs(recipe.ingredients) do
		local numK = tonumber(k)
		if numK and numK > maxIndex then
			maxIndex = numK
		end
	end

	local chestItems = self:list() or {}

	for index = 1, maxIndex do
		local itemName = recipe.ingredients[index]
		-- Skip empty slots
		if itemName ~= nil and itemName ~= "null" and itemName ~= "" then
			local crafterName = crafterGrid:getCrafterName(index)
			if not crafterName then
				return Result.err(
					"MISSING_CRAFTER",
					"Kein Mechanical Crafter fuer Slot " .. index .. " gefunden.",
					"Bitte stelle sicher, dass das gesamte Crafter-Netzwerk verkabelt ist."
				)
			end

			local needed = 1
			local itemTransferred = false

			-- Find the item and push it once
			for slot, item in pairs(chestItems) do
				if ItemMatcher.matches(item, itemName) then
					-- Use direct call but wrap in pcall for safety
					local ok, moved = pcall(function()
						return self:pushItems(crafterName, slot, needed)
					end)

					if ok and moved == needed then
						itemTransferred = true
						-- Update local list to prevent double-spending the same slot in memory
						item.count = item.count - 1
						if item.count <= 0 then
							chestItems[slot] = nil
						end
						break
					elseif not ok then
						return Result.err(
							"NETWORK_ERROR",
							"Netzwerk-Fehler bei Uebertragung an " .. crafterName,
							"Bitte ueberpruefe Kabel/Modems zum Crafter."
						)
					elseif ok and moved == 0 then
						-- Try to diagnose why it moved 0
						local detailStr
						local pCrafter = peripheral.wrap(crafterName) --[[@as any]]
						if pCrafter then
							local listOk, listRes = pcall(function()
								return pCrafter.list()
							end)
							if listOk and listRes then
								local _, crafterItem = next(listRes)
								if crafterItem then
									detailStr = "Crafter enthaelt bereits: " .. crafterItem.name .. " x" .. crafterItem.count
								else
									detailStr = "Crafter ist leer, hat das Item aber dennoch abgelehnt!"
								end
							else
								local detOk, detRes = pcall(function()
									return pCrafter.getItemDetail(1)
								end)
								if detOk and detRes then
									detailStr = "Crafter enthaelt bereits: " .. detRes.name .. " x" .. detRes.count
								else
									detailStr = "Crafter ist leer (oder nicht lesbar), hat das Item abgelehnt."
								end
							end
						else
							detailStr = "Crafter ist offline oder nicht erreichbar!"
						end

						return Result.err(
							"CRAFTER_REJECTED",
							"Crafter " .. crafterName .. " hat das Item abgelehnt.",
							detailStr
						)
					end
				end
			end

			if not itemTransferred then
				return Result.err(
					"TRANSFER_FAILED",
					"Konnte Item '" .. itemName .. "' nicht an " .. crafterName .. " uebertragen.",
					"Fehlt das Item in der Kiste oder ist der Crafter blockiert?"
				)
			end
		end
	end

	return Result.ok(true)
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
