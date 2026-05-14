--[[
================================================================================
Create Mechanical Crafter - Standalone Recorder (V1.1 AGENTS Edition)
================================================================================
]]--

-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local fs = fs
local textutils = textutils
local peripheral = peripheral
local string = string
local ipairs = ipairs
local pairs = pairs
local table = table
local tonumber = tonumber
local io = io
local print = print

local args = { ... }
local recipeName = args[1]

if not recipeName then
    print("Enter recipe name:")
    recipeName = io.read() or "Unnamed"
    os.sleep(0.5)
end

print("Enter grid width (e.g. 5):")
local width = tonumber(io.read())
os.sleep(0.5)
if not width or width <= 0 then
    print("Invalid width!")
    return
end

if not fs.exists("crafter_mapping.json") then
    print("Error: Run startup.lua first to calibrate!")
    return
end

local mappingFile = fs.open("crafter_mapping.json", "r")
if not mappingFile then return end
local mappingData = textutils.unserializeJSON(mappingFile.readAll())
mappingFile.close()

print("Scanning...")
local keys, reverseKeys, patternRows, currentLine = {}, {}, {}, ""
local charCode, itemsFound = 65, 0

for i, name in ipairs(mappingData or {}) do
    local p = peripheral.wrap(name)
    local item = p and p.getItemDetail and p.getItemDetail(1)
    local char = "0"

    if item then
        itemsFound = itemsFound + 1
        if reverseKeys[item.name] then
            char = reverseKeys[item.name]
        else
            char = string.char(charCode)
            keys[char], reverseKeys[item.name], charCode = item.name, char, charCode + 1
        end
    end
    currentLine = currentLine .. char
    if i % width == 0 then
        table.insert(patternRows, currentLine)
        currentLine = ""
    end
end

if itemsFound == 0 then
    print("Crafters are empty!")
    return
end

local recipeFilename = "crafter_recipes.json"
local existing = {}
if fs.exists(recipeFilename) then
    local f = fs.open(recipeFilename, "r")
    if f then
        existing = textutils.unserializeJSON(f.readAll()) or {}
        f.close()
    end
end

table.insert(existing, { name = recipeName, keys = keys, pattern = patternRows })
local outFile = fs.open(recipeFilename, "w")
if outFile then
    outFile.write(textutils.serializeJSON(existing))
    outFile.close()
end

print("Saved '" .. recipeName .. "' to " .. recipeFilename)
