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
local ipairs = ipairs
local fs = fs
local textutils = textutils
local term = term
local keys = keys
local os_pullEvent = os.pullEvent
local os_sleep = os.sleep

---@class CrafterGrid
---@field crafters table<number, string>
---@field cachedPeripherals table<number, table>
local CrafterGrid = {}
CrafterGrid.__index = CrafterGrid

--- Creates a new CrafterGrid instance
---@return CrafterGrid
function CrafterGrid.new()
    local self = setmetatable({
        crafters = {},
        cachedPeripherals = {}
    }, CrafterGrid)
    self:discoverCrafters()
    return self
end

--- Runs the interactive setup for assigning crafter slots via modem clicks
function CrafterGrid:runInteractiveCalibration()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== INITIAL SETUP: CRAFTER CALIBRATION ===")
    print("1. Connect all Mechanical Crafters with Wired Modems.")
    print("2. Click the modems ONE BY ONE in order:")
    print("   left-to-right, top-to-bottom.\n")
    print("[Press ENTER when all modems are activated]")
    print("------------------------------------------")

    self.crafters = {}
    while true do
        local event, param1 = os_pullEvent()
        if event == "peripheral" then
            if peripheral.getType(param1) == "create:mechanical_crafter" then
                self.crafters[#self.crafters + 1] = param1
                print("Crafter #" .. #self.crafters .. " connected: " .. param1)
            end
        elseif event == "key" and param1 == keys.enter then
            if #self.crafters > 0 then break end
            print("Error: Connect at least one crafter!")
        end
    end

    local file = fs.open("crafter_mapping.json", "w")
    if file then
        file.write(textutils.serializeJSON(self.crafters))
        file.close()
    end
    print("\nCalibration saved!")
    os_sleep(1.5)
end

--- Discovers and sorts all connected mechanical crafters
function CrafterGrid:discoverCrafters()
    if fs.exists("crafter_mapping.json") then
        local file = fs.open("crafter_mapping.json", "r")
        if file then
            local content = file.readAll()
            file.close()
            if content then
                local mapping = textutils.unserializeJSON(content, {})
                if mapping and #mapping > 0 then
                    self.crafters = mapping
                    self:cachePeripherals()
                    return
                end
            end
        end
    end

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
        if p and p.getItemDetail and p.getItemDetail(1) then
            return false
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