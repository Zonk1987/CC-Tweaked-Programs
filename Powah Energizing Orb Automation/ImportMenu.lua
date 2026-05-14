-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

-- Localize globals
local term = term
local colors = colors
local os_sleep = os.sleep
local os_pullEvent = os.pullEvent
local string = string
local math = math
local table_insert = table.insert
local ipairs = ipairs
local pairs = pairs
local keys = keys
local keys_up = keys.up
local keys_down = keys.down
local keys_f = keys.f
local keys_enter = keys.enter
local keys_q = keys.q
local keys_x = keys.x

---@class ImportMenu
---@field meBridge any
---@field recipeManager any
---@field dashboard any
local ImportMenu = {}
ImportMenu.__index = ImportMenu

--- Creates a new ImportMenu instance
---@param options table
---@return ImportMenu
function ImportMenu.new(options)
    local self = setmetatable({}, ImportMenu)
    self.meBridge = options.meBridge
    self.recipeManager = options.recipeManager
    self.dashboard = options.dashboard
    return self
end

--- Internal helper to check if a pattern is already in the recipe manager
---@param pattern table
---@return boolean
function ImportMenu:isAlreadyImported(pattern)
    for _, recipe in ipairs(self.recipeManager.recipes) do
        local match = true
        local ingCount = 0

        for _, ing in ipairs(pattern.inputs) do
            local item = ing.primaryInput or ing
            if item.name then
                ingCount = ingCount + 1
                local totalCount = (item.count or 1) * (ing.multiplier or 1)
                if recipe.ingredients[item.name] ~= totalCount then
                    match = false
                    break
                end
            end
        end

        local jsonIngCount = 0
        for _ in pairs(recipe.ingredients) do jsonIngCount = jsonIngCount + 1 end

        if match and ingCount == jsonIngCount then
            return true
        end
    end
    return false
end

--- Main UI loop for the import menu
function ImportMenu:open()
    if not self.meBridge then
        return false, "me_bridge_missing"
    end

    self.dashboard.suppressDraw = true
    local showAllMods = false
    local patterns = {}

    local function scanPatterns()
        patterns = {}
        local allPatterns = self.meBridge.getPatterns()
        for _, p in ipairs(allPatterns) do
            local isPowah = p.outputs and p.outputs[1] and p.outputs[1].name:find("powah:")
            if showAllMods or isPowah then
                table_insert(patterns, p)
            end
        end
    end

    scanPatterns()

    if #patterns == 0 then
        self.dashboard.suppressDraw = false
        return false, "no_patterns_found"
    end

    local selected = 1
    local w, h = term.getSize()

    while true do
        term.clear()
        -- Header
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        local modeText = showAllMods and "ALL MODS" or "POWAH ONLY"
        term.write("=== AE2 [" .. modeText .. "] (" .. #patterns .. ") ===")
        term.setCursorPos(1, 2)
        term.setTextColor(colors.gray)
        term.write(string.rep("-", w))

        -- Left Side: Pattern List
        local listWidth = 24
        local maxLines = h - 4
        for i = 1, maxLines do
            local idx = i + (selected > maxLines/2 and selected - math.floor(maxLines/2) or 0)
            if idx > #patterns then break end

            term.setCursorPos(1, i + 2)
            local p = patterns[idx]
            local pName = (p.outputs[1].displayName or p.outputs[1].name):gsub("[%[%]]", "")

            local isImported = self:isAlreadyImported(p)

            term.setTextColor(isImported and colors.green or colors.red)
            term.write(string.char(149) .. " ")

            term.setTextColor(idx == selected and colors.lime or colors.white)
            term.write(idx == selected and ">" or " ")

            local maxNameLen = listWidth - 5
            if #pName > maxNameLen then
                pName = pName:sub(1, maxNameLen - 2) .. ".."
            end
            term.write(pName)
        end

        -- Vertical Separator
        term.setTextColor(colors.gray)
        for i = 3, h - 1 do
            term.setCursorPos(listWidth + 1, i)
            term.write("|")
        end

        -- Right Side: Details
        local current = patterns[selected]
        local outName = (current.outputs[1].displayName or current.outputs[1].name):gsub("[%[%]]", "")
        local maxDetailWidth = w - (listWidth + 3)

        -- Basic wrap
        local line1 = outName:sub(1, maxDetailWidth)
        local line2 = outName:sub(maxDetailWidth + 1, maxDetailWidth * 2)

        term.setTextColor(colors.yellow)
        local off1 = math.floor((maxDetailWidth - #line1) / 2)
        term.setCursorPos(listWidth + 3 + off1, 3)
        term.write(line1)

        local separatorY = 4
        if #line2 > 0 then
            local off2 = math.floor((maxDetailWidth - #line2) / 2)
            term.setCursorPos(listWidth + 3 + off2, 4)
            term.write(line2)
            separatorY = 5
        end

        term.setTextColor(colors.gray)
        term.setCursorPos(listWidth + 3, separatorY)
        term.write(string.rep("-", maxDetailWidth))

        -- Ingredients
        local ingredientStartY = separatorY + 1
        if current.inputs then
            for i, ing in ipairs(current.inputs) do
                local drawY = (i - 1) * 2 + ingredientStartY
                if drawY > (h - 2) then break end

                local item = ing.primaryInput or ing
                local itemName = (item.displayName or item.name or "Unknown"):gsub("[%[%]]", "")
                local totalCount = (item.count or 0) * (ing.multiplier or 1)

                term.setTextColor(colors.white)
                term.setCursorPos(listWidth + 3, drawY)
                term.write(string.format("%dx %s", totalCount, itemName:sub(1, maxDetailWidth - 5)))

                term.setCursorPos(listWidth + 3, drawY + 1)
                term.setTextColor(colors.gray)
                term.write(" ID: " .. (item.name or "???"):sub(1, maxDetailWidth - 5))
            end
        end

        -- Footer
        term.setCursorPos(1, h)
        term.setTextColor(colors.gray)
        term.write("Arrows | ENTER:Import | X:Del | F:Filter | Q:Exit")

        local _, key = os_pullEvent("key")
        if key == keys_up and selected > 1 then selected = selected - 1
        elseif key == keys_down and selected < #patterns then selected = selected + 1
        elseif key == keys_f then
            showAllMods = not showAllMods
            scanPatterns()
            selected = 1
        elseif key == keys_enter then
            local cleanName = (current.outputs[1].displayName or current.outputs[1].name):gsub("[%[%]]", "")
            local recipe = { name = cleanName, ingredients = {} }
            for _, ing in ipairs(current.inputs) do
                local item = ing.primaryInput or ing
                if item.name then
                    recipe.ingredients[item.name] = (item.count or 1) * (ing.multiplier or 1)
                end
            end
            self.recipeManager:addRecipe(recipe)
            term.setCursorPos(listWidth + 3, h-1)
            term.setTextColor(colors.lime)
            term.write("IMPORT SUCCESS!")
            os_sleep(0.5)
        elseif key == keys_x then
            local cleanName = (current.outputs[1].displayName or current.outputs[1].name):gsub("[%[%]]", "")
            if self.recipeManager:removeRecipeByName(cleanName) then
                term.setCursorPos(listWidth + 3, h-1)
                term.setTextColor(colors.orange)
                term.write("RECIPE DELETED!")
                os_sleep(0.5)
            end
        elseif key == keys_q then
            break
        end
    end

    self.dashboard.suppressDraw = false
    self.dashboard:draw()
    return true
end

return ImportMenu
