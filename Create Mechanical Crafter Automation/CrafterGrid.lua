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
local table_sort = table.sort
local ipairs = ipairs

---@class CrafterGrid
---@field crafters table<number, string>
---@field cachedPeripherals table<number, table>
local CrafterGrid = {}
CrafterGrid.__index = CrafterGrid

--- Creates a new CrafterGrid instance and discovers crafters
---@return CrafterGrid
function CrafterGrid:new()
    local instance = setmetatable({}, self)
    instance.cachedPeripherals = {}
    instance:discoverCrafters()
    return instance
end

--- Runs the interactive setup for assigning crafter slots via modem clicks
function CrafterGrid:runInteractiveCalibration()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== INITIAL SETUP: CRAFTER CALIBRATION ===")
    print("1. Connect all Mechanical Crafters with Wired Modems.")
    print("2. Make sure all modem red rings are OFF initially.")
    print("3. Now click the modems ONE BY ONE to turn them on,")
    print("   in order: left-to-right, top-to-bottom.")
    print("")
    print("[Press ENTER when all modems are turned on]")
    print("-----------------------------------------------------")

    self.crafters = {}
    
    while true do
        local event, param1 = os.pullEvent()
        
        if event == "peripheral" then
            if peripheral.getType(param1) == "create:mechanical_crafter" then
                -- Add to mapping
                self.crafters[#self.crafters + 1] = param1
                print("Crafter #" .. #self.crafters .. " connected: " .. param1)
            end
        elseif event == "key" then
            if param1 == keys.enter then
                if #self.crafters > 0 then
                    break
                else
                    print("Error: You must turn on at least one modem!")
                end
            end
        end
    end

    -- Save to JSON
    local file = fs.open("crafter_mapping.json", "w")
    file.write(textutils.serializeJSON(self.crafters))
    file.close()

    term.clear()
    term.setCursorPos(1, 1)
    print("Calibration saved successfully!")
    os.sleep(1.5)
end

--- Discovers and sorts all connected mechanical crafters
function CrafterGrid:discoverCrafters()
    -- Try loading calibration mapping first
    if fs.exists("crafter_mapping.json") then
        local file = fs.open("crafter_mapping.json", "r")
        local content = file.readAll()
        file.close()
        
        local mapping = textutils.unserializeJSON(content)
        if mapping and #mapping > 0 then
            self.crafters = mapping
            self:cachePeripherals()
            return
        end
    end

    -- If no mapping exists, start interactive setup!
    self:runInteractiveCalibration()
    self:cachePeripherals()
end

--- Caches the peripheral objects for massive performance improvements
function CrafterGrid:cachePeripherals()
    self.cachedPeripherals = {}
    for i, name in ipairs(self.crafters) do
        self.cachedPeripherals[i] = peripheral.wrap(name)
    end
end

--- Returns the name of the crafter at the given index
---@param index number
---@return string|nil
function CrafterGrid:getCrafterName(index)
    return self.crafters[index]
end

--- Checks if all connected crafters are completely empty
---@return boolean
function CrafterGrid:isEmpty()
    for _, p in ipairs(self.cachedPeripherals) do
        -- getItemDetail is significantly faster than list() for single-slot inventories
        if p and p.getItemDetail then
            if p.getItemDetail(1) ~= nil then
                return false
            end
        end
    end
    return true
end

--- Finds which item is jamming the crafters
---@return string|nil
function CrafterGrid:getJammedItem()
    for i, p in ipairs(self.cachedPeripherals) do
        if p and p.getItemDetail then
            local item = p.getItemDetail(1)
            if item then
                return "Crafter #" .. i .. " has " .. item.name
            end
        end
    end
    return nil
end

--- Gets the number of connected crafters
---@return number
function CrafterGrid:getCount()
    return #self.crafters
end

return CrafterGrid