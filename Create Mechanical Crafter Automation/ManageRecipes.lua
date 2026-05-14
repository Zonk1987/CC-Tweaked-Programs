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
local keys_x = keys.x
local keys_q = keys.q

---@class ManageRecipes
---@field recipeManager any
---@field dashboard any
local ManageRecipes = {}
ManageRecipes.__index = ManageRecipes

--- Creates a new ManageRecipes instance
---@param options table
---@return ManageRecipes
function ManageRecipes.new(options)
    local self = setmetatable({}, ManageRecipes)
    self.recipeManager = options.recipeManager
    self.dashboard = options.dashboard
    return self
end

--- Summarizes ingredient counts for a recipe
local function getIngredientSummary(recipe)
    local summary = {}
    for _, row in ipairs(recipe.pattern) do
        for i = 1, #row do
            local char = row:sub(i, i)
            if char ~= "0" and char ~= "-" then
                local name = recipe.keys[char]
                if name then
                    summary[name] = (summary[name] or 0) + 1
                end
            end
        end
    end
    return summary
end

--- Main UI loop for managing recipes
function ManageRecipes:open()
    self.dashboard.suppressDraw = true
    local selected = 1
    local w, h = term.getSize()
    local listWidth = math.floor(w * 0.45)

    while true do
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        term.write("=== Manage Recipes (" .. #self.recipeManager.recipes .. ") ===")
        term.setCursorPos(1, 2)
        term.setTextColor(colors.gray)
        term.write(string.rep("-", w))

        -- Left Side: Recipe List
        local maxLines = h - 4
        local offset = (selected > maxLines / 2) and (selected - math.floor(maxLines / 2)) or 0
        offset = math.min(offset, math.max(0, #self.recipeManager.recipes - maxLines))

        for i = 1, maxLines do
            local idx = i + offset
            if idx > #self.recipeManager.recipes then break end

            term.setCursorPos(1, i + 2)
            local r = self.recipeManager.recipes[idx]
            
            term.setTextColor(idx == selected and colors.lime or colors.white)
            term.write(idx == selected and ">" or " ")
            
            local name = r.name
            if #name > listWidth - 3 then
                name = name:sub(1, listWidth - 5) .. ".."
            end
            term.write(name)
        end

        -- Vertical Separator
        term.setTextColor(colors.gray)
        for i = 3, h - 1 do
            term.setCursorPos(listWidth + 1, i)
            term.write("|")
        end

        -- Right Side: Recipe Details
        local current = self.recipeManager.recipes[selected]
        if current then
            local detailX = listWidth + 3
            local detailW = w - detailX + 1
            
            term.setCursorPos(detailX, 3)
            term.setTextColor(colors.yellow)
            local title = current.name
            if #title > detailW then title = title:sub(1, detailW - 2) .. ".." end
            term.write(title)

            term.setCursorPos(detailX, 4)
            term.setTextColor(colors.gray)
            term.write(string.rep("-", detailW))

            local summary = getIngredientSummary(current)
            local line = 5
            for name, count in pairs(summary) do
                if line >= h then break end
                term.setCursorPos(detailX, line)
                term.setTextColor(colors.white)
                term.write(count .. "x ")
                
                local shortName = name:match("([^:]+)$") or name
                if #shortName > detailW - 4 then
                    shortName = shortName:sub(1, detailW - 6) .. ".."
                end
                term.write(shortName)
                line = line + 1
            end
        end

        -- Footer
        term.setCursorPos(1, h)
        term.setTextColor(colors.gray)
        term.write("Arrows | X:Delete | Q:Exit")

        local _, key = os_pullEvent("key")
        if key == keys_up and selected > 1 then 
            selected = selected - 1
        elseif key == keys_down and selected < #self.recipeManager.recipes then 
            selected = selected + 1
        elseif key == keys_x then
            local r = self.recipeManager.recipes[selected]
            if r then
                self.recipeManager:removeRecipeByName(r.name)
                if selected > #self.recipeManager.recipes then
                    selected = math.max(1, #self.recipeManager.recipes)
                end
                term.setCursorPos(2, h-1)
                term.setTextColor(colors.orange)
                term.write("DELETED " .. r.name:sub(1, 10))
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

return ManageRecipes
