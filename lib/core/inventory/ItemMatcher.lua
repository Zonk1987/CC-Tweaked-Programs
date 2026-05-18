--- @diagnostic disable: undefined-global
-- ItemMatcher: Generic item matching and counting utilities
-- Governed by AGENTS.md

local ItemMatcher = {}

--- Checks if an item matches a search string (supports fuzzy matching with '~')
--- @param item table The item object from inventory:list()
--- @param query string The item name or fuzzy query
--- @return boolean
function ItemMatcher.matches(item, query)
	if not item or not query then
		return false
	end

	local name = item.name:lower()
	local q = query:lower()

	if q:sub(1, 1) == "~" then
		-- Fuzzy match: check if the item name contains the query string
		return name:find(q:sub(2), 1, true) ~= nil
	end

	-- Exact match or prefix-agnostic match
	if name == q then
		return true
	end

	-- Try matching without 'minecraft:' prefix if one is missing
	local nameNoPrefix = name:match(":(.+)$") or name
	local qNoPrefix = q:match(":(.+)$") or q

	return nameNoPrefix == qNoPrefix
end

--- Counts matching items in an inventory list
--- @param query string The item name or fuzzy query
--- @param inventoryList table<number, table> The list of items from InventoryAdapter:list()
--- @return number totalCount
function ItemMatcher.count(query, inventoryList)
	local total = 0
	if not inventoryList then
		return 0
	end
	for _, item in pairs(inventoryList) do
		if ItemMatcher.matches(item, query) then
			total = total + item.count
		end
	end
	return total
end

--- Finds the first slot containing a matching item
--- @param query string The item name or fuzzy query
--- @param inventoryList table<number, table>
--- @return number|nil slot, table|nil item
function ItemMatcher.findFirst(query, inventoryList)
	if not inventoryList then
		return nil
	end
	for slot, item in pairs(inventoryList) do
		if ItemMatcher.matches(item, query) then
			return slot, item
		end
	end
	return nil
end

return ItemMatcher
