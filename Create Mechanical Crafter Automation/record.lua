local fs = fs
local textutils = textutils
local peripheral = peripheral
local string_char = string.char

local args = { ... }
local recipeName = args[1]

if not recipeName then
    print("Bitte gib einen Namen fuer das Rezept ein:")
    recipeName = io.read()
end

print("Bitte gib die Breite deines Rechtecks an (z.B. 9):")
local width = tonumber(io.read())
if not width or width <= 0 then
    print("Ungueltige Breite!")
    return
end

if not fs.exists("crafter_mapping.json") then
    print("Fehler: crafter_mapping.json nicht gefunden.")
    print("Bitte starte zuerst startup.lua um dein Feld zu kalibrieren!")
    return
end

local mappingFile = fs.open("crafter_mapping.json", "r")
local mappingData = textutils.unserializeJSON(mappingFile.readAll())
mappingFile.close()

if not mappingData or #mappingData == 0 then
    print("Fehler beim Lesen der Kalibrierung.")
    return
end

print("Scanne Crafter...")

local keys = {}
local patternRows = {}
local currentPattern = ""
local nextKeyChar = string.byte("A")

for i, name in ipairs(mappingData) do
    local char = "0"
    local p = peripheral.wrap(name)

    if p and p.getItemDetail then
        local item = p.getItemDetail(1)
        if item then
            local itemName = item.name

            -- Check if we already have a key for this item
            local existingKey = nil
            for k, v in pairs(keys) do
                if v == itemName then
                    existingKey = k
                    break
                end
            end

            if existingKey then
                char = existingKey
            else
                char = string_char(nextKeyChar)
                keys[char] = itemName
                nextKeyChar = nextKeyChar + 1
            end
        end
    end

    currentPattern = currentPattern .. char

    if i % width == 0 then
        table.insert(patternRows, currentPattern)
        currentPattern = ""
    end
end

-- If there's an incomplete row at the end
if currentPattern ~= "" then
    table.insert(patternRows, currentPattern)
end

local newRecipe = {
    name = recipeName,
    keys = keys,
    pattern = patternRows
}

-- Load existing recipes
local existingRecipes = {}
local recipeFilename = "crafter_recipes.json"
if fs.exists(recipeFilename) then
    local file = fs.open(recipeFilename, "r")
    local data = textutils.unserializeJSON(file.readAll())
    file.close()
    if type(data) == "table" then
        existingRecipes = data
    end
end

table.insert(existingRecipes, newRecipe)

local file = fs.open(recipeFilename, "w")
file.write(textutils.serializeJSON(existingRecipes))
file.close()

print("Erfolgreich! Rezept '" .. recipeName .. "' wurde gespeichert.")
print("Du kannst die Items nun wieder aus den Craftern nehmen.")
