-- STRICT MODE (SAFE VERSION): Prevent accidental global variables only in THIS file
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})
local Dashboard = require("Dashboard")
local RecipeManager = require("RecipeManager")
local Chest = require("Chest")
local Orb = require("Orb")

-- Localize globals
local setmetatable = setmetatable
local peripheral = peripheral
local ipairs = ipairs
local pairs = pairs
local os_sleep = os.sleep
local os_epoch = os.epoch
local os_pullEvent = os.pullEvent
local parallel_waitForAll = parallel.waitForAll
local keys_r = keys.r
local keys_i = keys.i

---@class PowahSystem
---@field chest any
---@field dashboard any
---@field recipeManager RecipeManager
---@field activeJobs table<string, table>
---@field meBridge any|nil
local PowahSystem = {}
PowahSystem.__index = PowahSystem

--- Creates the main system
---@param chestName string
---@param recipeFile string
---@param meBridgeName string|nil
---@return PowahSystem
function PowahSystem.new(chestName, recipeFile, meBridgeName)
    ---@type PowahSystem
    local instance = setmetatable({}, PowahSystem)
    instance.chest = Chest:new(chestName)
    instance.dashboard = Dashboard:new()
    instance.recipeManager = RecipeManager:new(recipeFile, instance.dashboard)
    instance.activeJobs = {}
    instance.meBridge = meBridgeName and peripheral.wrap(meBridgeName) or nil
    return instance
end

--- Finds an orb without a current job
---@return any|nil
function PowahSystem:getFreeOrb()
    local allOrbsNames = { peripheral.find("powah:energizing_orb") }
    for _, orbPeripheral in ipairs(allOrbsNames) do
        local name = peripheral.getName(orbPeripheral)
        if not self.activeJobs[name] then
            local orb = Orb:new(name)
            if orb:isEmpty() then
                return orb
            end
        end
    end
    return nil
end

--- Monitors currently active crafting jobs
function PowahSystem:checkActiveJobs()
    for orbName, job in pairs(self.activeJobs) do
        local orb = Orb:new(orbName)
        if not orb:isPresent() then
            self.activeJobs[orbName] = nil
        else
            if orb:isEmpty() then
                self.dashboard:setLastCraft(job.recipeName)
                self.activeJobs[orbName] = nil
                self.dashboard:draw()
            else
                if (os_epoch("utc") - job.startTime) > 60000 then
                    self.dashboard:setError("Timeout in " .. orbName .. ". Recovering...")
                    orb:recover(self.chest.name)
                    self.activeJobs[orbName] = nil
                    os_sleep(1)
                    self.dashboard:setError("")
                end
            end
        end
    end
end

--- Main process loop logic
function PowahSystem:process()
    if not self.chest:isPresent() then
        self.dashboard:setError("Chest missing!")
        os_sleep(2)
        return
    end

    if self.dashboard.errorMsg == "Chest missing!" or self.dashboard.errorMsg == "No Orb found!" then 
        self.dashboard:setError("") 
    end

    self.dashboard:updateJobs(self.activeJobs)
    self:checkActiveJobs()

    local freeOrb = self:getFreeOrb()
    if freeOrb then
        local readyRecipe = self.recipeManager:findReadyRecipe(self.chest)
        if readyRecipe then
            self.dashboard:setStatus("Filling " .. freeOrb.name)
            local success = self.chest:transferRecipe(readyRecipe, freeOrb.name)
            
            if success then
                self.activeJobs[freeOrb.name] = {
                    startTime = os_epoch("utc"),
                    recipeName = readyRecipe.name
                }
                self.dashboard:draw()
            else
                self.dashboard:setError("Transfer Error! Starting Recovery...")
                freeOrb:recover(self.chest.name)
                os_sleep(1)
            end
        else
            self.dashboard:setStatus("Waiting for items...")
        end
    else
        local allOrbs = { peripheral.find("powah:energizing_orb") }
        if #allOrbs > 0 then
            self.dashboard:setStatus("All Orbs are busy...")
        else
            self.dashboard:setError("No Orb found!")
        end
    end
end

--- Runs the process continuously
function PowahSystem:mainLoop()
    while true do
        self:process()
        os_sleep(0.1)
    end
end

--- Listens to keyboard events
function PowahSystem:keyListener()
    while true do
        local event, key = os_pullEvent("key")
        if key == keys_r then
            self.dashboard:setStatus("Reloading recipes...")
            self.recipeManager:load()
            os_sleep(0.5)
            self.dashboard:setStatus("Waiting for items...")
        elseif key == keys_i then
            self:importAE2Recipes()
        end
    end
end

--- Interactive AE2 recipe import via ME Bridge
function PowahSystem:importAE2Recipes()
    if not self.meBridge then
        self.dashboard:setError("No ME Bridge found!")
        os_sleep(1.5)
        self.dashboard:setError("")
        return
    end

    self.dashboard.suppressDraw = true
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.yellow)
    local showAllMods = false
    local powahPatterns = {}

    local function scanPatterns()
        powahPatterns = {}
        local allPatterns = self.meBridge.getPatterns()
        for _, p in ipairs(allPatterns) do
            local isPowah = p.outputs and p.outputs[1] and p.outputs[1].name:find("powah:")
            if showAllMods or isPowah then
                table.insert(powahPatterns, p)
            end
        end
    end

    scanPatterns()

    if #powahPatterns == 0 then
        print("\nNo Powah patterns found in AE2!")
        os_sleep(2)
        self.dashboard.suppressDraw = false
        self.dashboard:draw()
        return
    end

    local selected = 1
    local w, h = term.getSize()
    
    while true do
        term.clear()
        -- Header
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        local modeText = showAllMods and "ALL MODS" or "POWAH ONLY"
        term.write("=== AE2 [" .. modeText .. "] (" .. #powahPatterns .. ") ===")
        term.setCursorPos(1, 2)
        term.setTextColor(colors.gray)
        term.write(string.rep("-", w))

        -- Left Side: Pattern List
        local listWidth = 24
        local maxLines = h - 4
        for i = 1, maxLines do
            local idx = i + (selected > maxLines/2 and selected - math.floor(maxLines/2) or 0)
            if idx > #powahPatterns then break end
            
            term.setCursorPos(1, i + 2)
            local p = powahPatterns[idx]
            
            -- Use Beautiful Name for the list too
            local pName = p.outputs[1].displayName or p.outputs[1].name
            pName = pName:gsub("[%[%]]", "") -- Strip brackets
            
            -- Check if already imported (ID-based Ingredient Matching)
            local isImported = false
            for _, r in ipairs(self.recipeManager.recipes) do
                local match = true
                local ingCount = 0
                
                -- Check if every ingredient in the AE2 pattern exists in this JSON recipe
                for _, ing in ipairs(p.inputs) do
                        local item = ing.primaryInput or ing
                        if item.name then
                            ingCount = ingCount + 1
                            local totalCount = (item.count or 1) * (ing.multiplier or 1)
                            if r.ingredients[item.name] ~= totalCount then
                                match = false break
                            end
                        end
                end
                
                -- Also check if the counts match (to avoid partial matches)
                local jsonIngCount = 0
                for _ in pairs(r.ingredients) do jsonIngCount = jsonIngCount + 1 end
                
                if match and ingCount == jsonIngCount then
                    -- Bonus: Also check name if you want, but IDs are the main factor now
                    isImported = true break
                end
            end
            
            -- Draw Status Bullet (Char 149)
            term.setTextColor(isImported and colors.green or colors.red)
            write(string.char(149) .. " ")
            
            -- Draw Selection Marker
            term.setTextColor(idx == selected and colors.lime or colors.white)
            write(idx == selected and ">" or " ")
            
            -- Smart Truncate Name
            local maxNameLen = listWidth - 5
            if #pName > maxNameLen then
                pName = pName:sub(1, maxNameLen - 2) .. ".."
            end
            write(pName)
        end

        -- Vertical Separator
        term.setTextColor(colors.gray)
        for i = 3, h - 1 do
            term.setCursorPos(listWidth + 1, i)
            write("|")
        end

        -- Right Side: Details
        local current = powahPatterns[selected]
        local outName = current.outputs[1].displayName or current.outputs[1].name
        outName = outName:gsub("[%[%]]", "") -- Strip brackets
        
        local maxDetailWidth = w - (listWidth + 3)
        
        -- Smart Word Wrap & Centering Logic
        local words = {}
        for word in outName:gmatch("%S+") do table.insert(words, word) end
        
        local line1, line2 = "", ""
        for _, word in ipairs(words) do
            if #line1 == 0 then line1 = word
            elseif #line1 + 1 + #word <= maxDetailWidth then line1 = line1 .. " " .. word
            elseif #line2 == 0 then line2 = word
            elseif #line2 + 1 + #word <= maxDetailWidth then line2 = line2 .. " " .. word
            end
        end
        
        -- Draw Centered Name
        term.setTextColor(colors.yellow)
        local startY = 3
        local off1 = math.floor((maxDetailWidth - #line1) / 2)
        term.setCursorPos(listWidth + 3 + off1, startY)
        write(line1)
        
        local separatorY = 4
        local ingredientStartY = 5
        
        if #line2 > 0 then
            local off2 = math.floor((maxDetailWidth - #line2) / 2)
            term.setCursorPos(listWidth + 3 + off2, startY + 1)
            write(line2)
            separatorY = 5
            ingredientStartY = 6
        end
        
        -- Draw Separator
        term.setTextColor(colors.gray)
        term.setCursorPos(listWidth + 3, separatorY)
        write(string.rep("-", maxDetailWidth))
        
        -- Draw Ingredients
        term.setTextColor(colors.white)
        if current.inputs then
            for i, ing in ipairs(current.inputs) do
                local drawY = (i - 1) * 2 + ingredientStartY
                if drawY > (h - 2) then break end
                
                local item = ing.primaryInput or ing
                local itemName = item.displayName or item.name or "Unknown"
                itemName = itemName:gsub("[%[%]]", "")
                local count = item.count or 0
                
                -- Line 1: Count + DisplayName
                term.setCursorPos(listWidth + 3, drawY)
                local totalCount = (item.count or 0) * (ing.multiplier or 1)
                local ingPrefix = string.format("%dx ", totalCount)
                
                local maxIngNameWidth = maxDetailWidth - #ingPrefix
                if #itemName > maxIngNameWidth then
                    itemName = itemName:sub(1, maxIngNameWidth - 2) .. ".."
                end
                write(ingPrefix .. itemName)
                
                -- Line 2: technical ID (small and gray)
                term.setCursorPos(listWidth + 3, drawY + 1)
                term.setTextColor(colors.gray)
                local idText = " ID: " .. (item.name or "???")
                if #idText > maxDetailWidth then
                    idText = idText:sub(1, maxDetailWidth - 2) .. ".."
                end
                write(idText)
                term.setTextColor(colors.white)
            end
        end

        -- Footer
        term.setCursorPos(1, h)
        term.setTextColor(colors.gray)
        term.write("Arrows:Scroll | ENTER:Import | F:Filter | Q:Exit")

        local _, key = os_pullEvent("key")
        if key == keys.up and selected > 1 then selected = selected - 1
        elseif key == keys.down and selected < #powahPatterns then selected = selected + 1
        elseif key == keys.f then
            showAllMods = not showAllMods
            term.setCursorPos(1, 1)
            term.setTextColor(colors.cyan)
            print("\nRescanning...          ")
            scanPatterns()
            selected = 1
        elseif key == keys.enter then
            local cleanName = (current.outputs[1].displayName or current.outputs[1].name):gsub("[%[%]]", "")
            local recipe = {
                name = cleanName,
                ingredients = {}
            }
            for _, ing in ipairs(current.inputs) do
                local item = ing.primaryInput or ing
                if item.name then
                    local totalCount = (item.count or 1) * (ing.multiplier or 1)
                    recipe.ingredients[item.name] = totalCount
                end
            end
            self.recipeManager:addRecipe(recipe)
            -- Small visual feedback
            term.setCursorPos(listWidth + 3, h-1)
            term.setTextColor(colors.lime)
            write("IMPORT SUCCESS!")
            os_sleep(0.5)
        elseif key == keys.q then
            break
        end
    end
    
    self.dashboard.suppressDraw = false
    self.dashboard:draw()
end

--- Starts the system
function PowahSystem:start()
    self.recipeManager:load()
    parallel_waitForAll(
        function() self:mainLoop() end,
        function() self:keyListener() end
    )
end

return PowahSystem