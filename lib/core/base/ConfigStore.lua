--- @diagnostic disable: undefined-global
-- ConfigStore: Simple JSON-based table persistence
-- Governed by AGENTS.md

local ConfigStore = {}
ConfigStore.__index = ConfigStore

--- Creates a new ConfigStore
--- @param filename string The name of the config file
--- @param defaults table Default values if file doesn't exist
function ConfigStore.new(filename, defaults)
	local self = setmetatable({
		filename = filename,
		defaults = defaults or {},
		data = {},
	}, ConfigStore)
	for k, v in pairs(self.defaults) do
		self.data[k] = v
	end
	self:load()
	return self
end

--- Loads the config from file
--- @return boolean success
function ConfigStore:load()
	if not fs.exists(self.filename) then
		return false
	end

	local f = fs.open(self.filename, "r")
	if not f then
		return false
	end

	local content = f.readAll()
	f.close()

	local ok, decoded = pcall(textutils.unserializeJSON, content)
	if ok and type(decoded) == "table" then
		for k, v in pairs(decoded) do
			self.data[k] = v
		end
		return true
	end
	return false
end

--- Saves the config to file
--- @return boolean success
function ConfigStore:save()
	local f = fs.open(self.filename, "w")
	if not f then
		return false
	end

	local ok, content = pcall(textutils.serializeJSON, self.data)
	if ok then
		f.write(content)
		f.close()
		return true
	end

	f.close()
	return false
end

--- Gets a value from the config
--- @param key string
--- @param default any
--- @return any
function ConfigStore:get(key, default)
	if self.data[key] == nil then
		return default
	end
	return self.data[key]
end

--- Sets a value in the config and optionally saves
--- @param key string
--- @param value any
--- @param autoSave boolean|nil
function ConfigStore:set(key, value, autoSave)
	self.data[key] = value
	if autoSave then
		self:save()
	end
end

--- Clears the config data and restores defaults, then saves
function ConfigStore:clear()
	self.data = {}
	for k, v in pairs(self.defaults or {}) do
		self.data[k] = v
	end
	self:save()
end

return ConfigStore
