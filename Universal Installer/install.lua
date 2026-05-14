--[[
================================================================================
Zonk's Universal Installer (V3.1 AGENTS Edition)
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
local term = term
local colors = colors
local http = http
local textutils = textutils
local fs = fs
local shell = shell
local os = os
local string = string
local table = table
local ipairs = ipairs
local tonumber = tonumber
local write = write
local read = read
local pcall = pcall

-- Configuration
local owner = "Zonk1987"
local repo = "CC-Tweaked-Programs"
local branch = "main"
local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/"

-- Projects fallback (if API is down)
local fallbackProjects = {
    {
        name = "Powah Energizing Orb Automation",
        path = "Powah%20Energizing%20Orb%20Automation",
        files = { "startup.lua", "PowahSystem.lua", "RecipeManager.lua", "Dashboard.lua", "InventoryComponent.lua", "Orb.lua", "Chest.lua", "ImportMenu.lua", "README.md" }
    },
    {
        name = "Mekanism Portal Dialer Hub",
        path = "Mekanism%20Portal%20Dialer%20Hub",
        files = { "startup.lua", "PortalSystem.lua", "ButtonManager.lua", "UUIDService.lua", "PortalUI.lua", "README.md" }
    },
    {
        name = "Mekanism Portal Dialer Recall Sender",
        path = "Mekanism%20Portal%20Dialer%20Recall%20Sender",
        files = { "startup.lua", "README.md" }
    },
    {
        name = "CC Developer Suite",
        path = "CC%20Developer%20Suite",
        files = { "startup.lua", "README.md" }
    },
    {
        name = "Create Mechanical Crafter Automation",
        path = "Create%20Mechanical%20Crafter%20Automation",
        files = { "startup.lua", "CrafterSystem.lua", "RecipeManager.lua", "Dashboard.lua", "InventoryComponent.lua", "Chest.lua", "CrafterGrid.lua", "record.lua", "README.md" }
    }
}

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

--- Helper: Ensure URL is safe for CC (encode spaces)
local function safeUrl(url)
    return (url:gsub(" ", "%%20"))
end

local function header()
    clear()
    if term.isColor() then term.setTextColor(colors.cyan) end
    print("=======================================")
    print("      Zonk's CC-Tweaked Installer      ")
    print("=======================================")
    term.setTextColor(colors.white)
end

--- Main Installer Logic
local Installer = {
    projects = {},
    isApiDown = false
}

function Installer:fetchProjects()
    header()
    print("Connecting to GitHub...\n")
    local response = http.get(apiUrl)
    if response then
        local data = textutils.unserializeJSON(response.readAll())
        response.close()
        if data and not data.message then
            for _, item in ipairs(data) do
                if item.type == "dir" and not item.name:find("^%.") and item.name ~= "installer" then
                    table.insert(self.projects, {
                        name = item.name:gsub("%%20", " "),
                        path = item.name
                    })
                end
            end
            return
        end
    end
    
    self.isApiDown = true
    term.setTextColor(colors.yellow)
    print("Warning: GitHub API unreachable. Using fallback list...\n")
    self.projects = fallbackProjects
    os.sleep(1)
end

function Installer:selectProject()
    header()
    print("Select a project to install:\n")
    for i, project in ipairs(self.projects) do
        print(string.format("[%d] %s", i, project.name))
    end
    print("\n[Q] Quit")

    while true do
        write("\nChoice: ")
        local input = read()
        os.sleep(0.5)
        if input:lower() == "q" then return nil end
        local num = tonumber(input)
        if num and self.projects[num] then return self.projects[num] end
        print("Invalid choice!")
    end
end

function Installer:downloadFile(url, localPath)
    local resp = http.get(url)
    if resp then
        local f = fs.open(localPath, "w")
        if f then
            f.write(resp.readAll())
            f.close()
        end
        resp.close()
        return true
    end
    return false
end

function Installer:installProject(project)
    header()
    print("Installing: " .. project.name)
    print("Target: Root Directory (/)\n")

    if not self.isApiDown then
        local function downloadViaApi(path, currentTarget)
            local resp = http.get(safeUrl(apiUrl .. path))
            if not resp then return false end
            local items = textutils.unserializeJSON(resp.readAll())
            resp.close()

            if currentTarget ~= "" and not fs.exists(currentTarget) then
                fs.makeDir(currentTarget)
            end

            for _, item in ipairs(items) do
                local localPath = (currentTarget == "" and item.name or currentTarget .. "/" .. item.name)
                if item.type == "dir" then
                    if not downloadViaApi(item.path, localPath) then return false end
                else
                    print("Downloading: " .. item.name .. "...")
                    if not self:downloadFile(item.download_url, localPath) then return false end
                end
            end
            return true
        end
        return downloadViaApi(project.path, "")
    else
        for _, fileName in ipairs(project.files) do
            local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s/%s", owner, repo, branch, project.path, fileName)
            print("Downloading: " .. fileName .. "...")
            if not self:downloadFile(safeUrl(url), fileName) then return false end
        end
        return true
    end
end

function Installer:run()
    self:fetchProjects()
    local selected = self:selectProject()
    if not selected then return end

    if self:installProject(selected) then
        term.setTextColor(colors.lime)
        print("\nInstallation successful!")
        local selfPath = shell.getRunningProgram()
        if fs.exists(selfPath) and not selfPath:find("^rom/") and selfPath ~= "pastebin" then
            pcall(fs.delete, selfPath)
        end
        print("Rebooting in 3 seconds...")
        os.sleep(3)
        os.reboot()
    else
        term.setTextColor(colors.red)
        print("\nInstallation failed!")
    end
end

Installer:run()
