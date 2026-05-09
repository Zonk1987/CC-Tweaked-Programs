-- Set module search path to include current directory
package.path = package.path .. ";./?.lua"

local CrafterSystem = require("CrafterSystem")

-- Configuration
local RECIPE_FILE = "crafter_recipes.json"

local function autoDetectChest()
    local allPeripherals = peripheral.getNames()
    local localFaces = {top=true, bottom=true, left=true, right=true, front=true, back=true}
    for _, name in ipairs(allPeripherals) do
        local pType = peripheral.getType(name)
        if pType ~= "create:mechanical_crafter" and peripheral.hasType(name, "inventory") then
            -- Ignore local faces to force the use of a networked inventory
            if not localFaces[name] then
                return name
            end
        end
    end
    return nil
end

local function main()
    local chestName = autoDetectChest()
    if not chestName then
        error("No buffer inventory found! Please connect a chest to the modem.")
    end
    local system = CrafterSystem:new(chestName, RECIPE_FILE)
    system:start()
end

local ok, err = pcall(main)
if not ok then
    term.clear()
    term.setCursorPos(1, 1)
    print("Fatal Error in CrafterSystem:")
    print(err)
end
