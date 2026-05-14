-- Configuration
local owner = "Zonk1987"
local repo = "CC-Tweaked-Programs"
local branch = "main"
local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/"
local rawUrl = "https://raw.githubusercontent.com/" .. owner .. "/" .. repo .. "/" .. branch .. "/"

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

-- Hardcoded fallback list with file manifests
local fallbackProjects = {
    { 
        name = "Powah Energizing Orb Automation", 
        path = "Powah%20Energizing%20Orb%20Automation",
        files = { "startup.lua", "PowahSystem.lua", "RecipeManager.lua", "Dashboard.lua", "InventoryComponent.lua", "Orb.lua", "Chest.lua", "README.md" }
    },
    { 
        name = "Mekanism Portal Dialer Hub", 
        path = "Mekanism%20Portal%20Dialer%20Hub",
        files = { "startup.lua", "PortalSystem.lua", "README.md" }
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
        files = { "startup.lua", "README.md" }
    }
}

clear()
if term.isColor() then term.setTextColor(colors.cyan) end
print("=======================================")
print("      Zonk's CC-Tweaked Installer      ")
print("=======================================")
if term.isColor() then term.setTextColor(colors.white) end
print("Connecting to GitHub...\n")

-- Attempt to fetch root contents via API
local projects = {}
local isApiDown = false
local response = http.get(apiUrl)

if response then
    local responseData = response.readAll()
    response.close()
    local data = textutils.unserializeJSON(responseData)
    
    if data and not data.message then
        for _, item in ipairs(data) do
            if item.type == "dir" and not item.name:find("^%.") and item.name ~= "installer" then
                table.insert(projects, { 
                    name = item.name:gsub("%%20", " "), 
                    path = item.name 
                })
            end
        end
    else
        isApiDown = true
    end
else
    isApiDown = true
end

-- If API failed or returned empty, use fallback list
if #projects == 0 or isApiDown then
    if term.isColor() then term.setTextColor(colors.yellow) end
    print("Warning: GitHub API unreachable.")
    print("Using built-in project list...\n")
    projects = fallbackProjects
    isApiDown = true
    os.sleep(1)
end

-- User Selection Menu
clear()
if term.isColor() then term.setTextColor(colors.cyan) end
print("=======================================")
print("      Zonk's CC-Tweaked Installer      ")
print("=======================================")
if term.isColor() then term.setTextColor(colors.white) end
print("Select a project to install:\n")

for i, project in ipairs(projects) do
    print(string.format("[%d] %s", i, project.name))
end

print("\n[Q] Quit")

local selectedProject
while true do
    write("\nChoice: ")
    local input = read()
    if input:lower() == "q" then return end

    local num = tonumber(input)
    if num and projects[num] then
        selectedProject = projects[num]
        break
    else
        print("Invalid choice!")
    end
end

-- Setup installation
local targetDir = "" -- Install directly to root
clear()
print("Installing: " .. selectedProject.name)
print("Target: Root Directory (/)")
print("---------------------------------------\n")

--- Helper: Ensure URL is safe for CC (encode spaces)
local function safeUrl(url)
    return (url:gsub(" ", "%%20"))
end

--- Smart download function (Handles API or Fallback)
local function executeDownload()
    local success = true
    
    -- If API works, use recursive discovery
    if not isApiDown then
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
                    local fResp = http.get(item.download_url)
                    if fResp then
                        local f = fs.open(localPath, "w")
                        f.write(fResp.readAll())
                        f.close()
                        fResp.close()
                    else
                        return false
                    end
                end
            end
            return true
        end
        success = downloadViaApi(selectedProject.path, targetDir)
    else
        -- FALLBACK: Use raw URLs with known file list
        for _, fileName in ipairs(selectedProject.files) do
            local branches_to_try = { branch, "master", "main" }
            local success_file = false
            
            for _, b in ipairs(branches_to_try) do
                local currentRawUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/", owner, repo, b)
                local url = safeUrl(currentRawUrl .. selectedProject.path .. "/" .. fileName)
                
                local resp = http.get(url)
                if resp then
                    print("Downloading: " .. fileName .. "...")
                    local localPath = (targetDir == "" and fileName or targetDir .. "/" .. fileName)
                    local f = fs.open(localPath, "w")
                    f.write(resp.readAll())
                    f.close()
                    resp.close()
                    success_file = true
                    break
                end
            end
            
            if not success_file then
                print("Failed: " .. fileName)
                success = false
            end
        end
    end
    return success
end

-- Execute
if executeDownload() then
    if term.isColor() then term.setTextColor(colors.lime) end
    print("\nInstallation successful!")
    
    local selfPath = shell.getRunningProgram()
    if fs.exists(selfPath) and not selfPath:find("^rom/") and selfPath ~= "pastebin" then
        pcall(fs.delete, selfPath)
    end
    
    print("Rebooting in 3 seconds...")
    os.sleep(3)
    os.reboot()
else
    if term.isColor() then term.setTextColor(colors.red) end
    print("\nInstallation failed!")
    print("Check your connection to raw.githubusercontent.com")
end