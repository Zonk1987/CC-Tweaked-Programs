-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local http = http
local fs = fs
local textutils = textutils
local pcall = pcall


---@class UUIDService
---@field cache table<string, string>
---@field cacheFile string
local UUIDService = {}
UUIDService.__index = UUIDService

--- Creates a new UUIDService
---@param cacheFile string|nil
---@return UUIDService
function UUIDService.new(cacheFile)
    local self = setmetatable({
        cache = {},
        cacheFile = cacheFile or "player_names.json"
    }, UUIDService)
    self:load()
    return self
end

--- Loads cache from file
function UUIDService:load()
    if fs.exists(self.cacheFile) then
        local f = fs.open(self.cacheFile, "r")
        if f then
            local data = f.readAll()
            f.close()
            local decoded = textutils.unserialiseJSON(data)
            if decoded then self.cache = decoded end
        end
    end
end

--- Saves cache to file
function UUIDService:save()
    local f = fs.open(self.cacheFile, "w")
    if f then
        f.write(textutils.serialiseJSON(self.cache))
        f.close()
    end
end

--- Resolves a UUID to a player name using Mojang API
---@param uuid string
---@return string
function UUIDService:resolve(uuid)
    if not uuid or uuid == "Unknown" or #uuid < 20 then return uuid end
    if self.cache[uuid] then return self.cache[uuid] end
    if not http then return uuid end

    local cleanUUID = uuid:gsub("-", "")
    local url = "https://sessionserver.mojang.com/session/minecraft/profile/" .. cleanUUID

    local ok, response = pcall(http.get, url)
    if ok and response then
        local code = response.getResponseCode()
        local data = response.readAll()
        response.close()

        if code == 200 and data and #data > 0 then
            local decoded = textutils.unserialiseJSON(data)
            if decoded and decoded.name then
                self.cache[uuid] = decoded.name
                self:save()
                return decoded.name
            end
        elseif code == 429 then
            return "Rate Limited"
        end
    end

    return uuid
end

return UUIDService
