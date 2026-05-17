-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local OWNER = "Zonk1987"
local REPO = "CC-Tweaked-Programs"
local BRANCH = "main"

local REPO_URL = "https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/" .. BRANCH .. "/"

local MANIFEST_NAME = "manifest.lua"

local args = { ... }

--- Helper: Download a file from GitHub
local function downloadFile(url, path)
    print("Fetching: " .. url)
    local response, err = http.get(url)
    if not response then return false, "Connection failed: " .. (err or "unknown") end
    local content = response.readAll()
    response.close()
    
    if not content or content == "" then return false, "Empty response from server" end
    
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end
    
    local file = fs.open(path, "w")
    if not file then return false, "Could not open file for writing" end
    file.write(content)
    file.close()
    return true
end

--- Load and validate the manifest
local function loadManifest()
    if not fs.exists(MANIFEST_NAME) then
        print("Downloading manifest...")
        local ok, err = downloadFile(REPO_URL .. MANIFEST_NAME, MANIFEST_NAME)
        if not ok then return nil, "Failed to download manifest: " .. err end
    end
    
    local file = fs.open(MANIFEST_NAME, "r")
    local content = file.readAll()
    file.close()
    
    local fn, err = load(content, "manifest", "t", {})
    if not fn then return nil, "Manifest parse error: " .. err end
    
    local ok, manifest = pcall(fn)
    if not ok then return nil, "Manifest execution error: " .. manifest end
    if type(manifest) ~= "table" or type(manifest.packages) ~= "table" then
        return nil, "Invalid manifest shape"
    end
    
    return manifest
end

--- Helper: Check if a path is a safe relative path (no absolute, no traversal)
local function isSafeRelativePath(path)
    return type(path) == "string"
        and path ~= ""
        and path:sub(1, 1) ~= "/"
        and not path:find("%.%.")
end

--- Validate the manifest structure (for --validate flag)
local function validateManifest(manifest)
    print("Validating manifest...")
    local errors = {}
    for id, pkg in pairs(manifest.packages) do
        if type(pkg.name) ~= "string" or pkg.name == "" then table.insert(errors, id .. ": Missing name") end
        if type(pkg.files) ~= "table" then table.insert(errors, id .. ": Missing files table") end
        if type(pkg.dependencies) ~= "table" then table.insert(errors, id .. ": Missing dependencies table") end
        
        for _, file in ipairs(pkg.files or {}) do
            if not isSafeRelativePath(file.source) then 
                table.insert(errors, id .. ": Illegal or empty source path: " .. tostring(file.source)) 
            end
            if not isSafeRelativePath(file.target) then 
                table.insert(errors, id .. ": Illegal or empty target path: " .. tostring(file.target)) 
            end
        end
        
        for _, dep in ipairs(pkg.dependencies or {}) do
            if not manifest.packages[dep] then table.insert(errors, id .. ": Unknown dependency: " .. dep) end
        end
    end
    
    if #errors > 0 then
        for _, err in ipairs(errors) do print("  [ERROR] " .. err) end
        return false
    end
    print("  [OK] Manifest is valid.")
    return true
end

--- Resolve dependencies and files recursively
local function resolve(manifest, packageId, resolvedPkgs, filesToDownload)
    resolvedPkgs = resolvedPkgs or {}
    filesToDownload = filesToDownload or {}
    
    local pkg = manifest.packages[packageId]
    if not pkg then error("Unknown package: " .. packageId) end
    if resolvedPkgs[packageId] then return filesToDownload end
    
    resolvedPkgs[packageId] = true
    
    -- Resolve dependencies first
    for _, depId in ipairs(pkg.dependencies or {}) do
        resolve(manifest, depId, resolvedPkgs, filesToDownload)
    end
    
    -- Add files
    for _, file in ipairs(pkg.files or {}) do
        filesToDownload[file.target] = { source = file.source, sizeBytes = file.sizeBytes }
    end
    
    return filesToDownload, pkg
end

--- Perform the installation
local function install(packageId, manifest, isDryRun)
    local ok, result, targetPkg = pcall(resolve, manifest, packageId)
    if not ok or not targetPkg then
        print("Error: " .. tostring(result or "Unknown error"))
        return
    end
    
    print("\nPreparing installation for: " .. (targetPkg.name or packageId))
    if isDryRun then print("--- DRY RUN MODE ---") end
    
    local total = 0
    for _ in pairs(result) do total = total + 1 end

    local current = 0
    for target, fileData in pairs(result) do
        current = current + 1
        local source = fileData.source
        local expectedSize = fileData.sizeBytes

        if isDryRun then
            print(string.format("  [%d/%d] [PLAN] %s -> %s", current, total, source, target))
        else
            term.setTextColor(colors.gray)
            
            local skipDownload = false
            if expectedSize and fs.exists(target) then
                if fs.getSize(target) == expectedSize then
                    skipDownload = true
                end
            end

            if skipDownload then
                write(string.format("  [%d/%d] Checking %s... ", current, total, target))
                term.setTextColor(colors.blue)
                print("UP TO DATE")
            else
                write(string.format("  [%d/%d] Downloading %s... ", current, total, target))
                local success, err = downloadFile(REPO_URL .. source, target)
                if success then
                    -- Integrity verification
                    if expectedSize and fs.exists(target) then
                        local actualSize = fs.getSize(target)
                        if actualSize ~= expectedSize then
                            term.setTextColor(colors.orange)
                            print(string.format("WARN (%dB != %dB)", actualSize, expectedSize))
                        else
                            term.setTextColor(colors.lime)
                            print("OK")
                        end
                    else
                        term.setTextColor(colors.lime)
                        print("OK")
                    end
                else
                    term.setTextColor(colors.red)
                    print("FAILED")
                    print("    Error: " .. err)
                    term.setTextColor(colors.white)
                    return
                end
            end
        end
    end
    
    term.setTextColor(colors.white)
    print("\nTotal files processed: " .. total)
    if not isDryRun then
        print("Installation complete.")
        
        -- Cleanup
        if fs.exists(MANIFEST_NAME) then fs.delete(MANIFEST_NAME) end
        print("Cleanup: Removed manifest.")
        
        if targetPkg.entry and fs.exists(targetPkg.entry) then
            print("\nWould you like to run " .. targetPkg.entry .. " now? (y/n)")
            local ans = read()
            
            -- Delete self before potential long-running entry script
            local selfPath = shell.getRunningProgram()
            if fs.exists(selfPath) then 
                fs.delete(selfPath) 
                print("Cleanup: Removed installer.")
            end
            
            if ans:lower() == "y" then
                shell.run(targetPkg.entry)
            else
                print("Exit. You can start the app via: " .. targetPkg.entry)
            end
        else
            -- Delete self if no entry or dry run finished
            local selfPath = shell.getRunningProgram()
            if fs.exists(selfPath) then fs.delete(selfPath) end
        end
    end
end

----- Helper: Word wrap text for the description pane
local function drawWrappedText(text, x, y, width, center)
    local words = {}
    for word in text:gmatch("%S+") do table.insert(words, word) end
    
    local line = ""
    local currY = y
    local function writeLine(l)
        local drawX = x
        if center then
            drawX = x + math.floor((width - #l) / 2)
        end
        term.setCursorPos(drawX, currY)
        term.write(l:sub(1, width))
        currY = currY + 1
    end

    for _, word in ipairs(words) do
        if #line + #word + 1 > width then
            writeLine(line)
            line = word
        else
            line = line == "" and word or line .. " " .. word
        end
        -- Prevent vertical overflow
        local _, h = term.getSize()
        if currY > h - 3 then break end
    end
    writeLine(line)
    return currY
end

--- Main Entry Point
local function main()
    local manifest, err = loadManifest()
    if not manifest then
        print("Error: " .. err)
        return
    end
    
    local isDryRun = false
    local selectedPkgId = nil
    
    for _, arg in ipairs(args) do
        if arg == "--validate" then
            validateManifest(manifest)
            return
        elseif arg == "--dry-run" then
            isDryRun = true
        elseif manifest.packages[arg] then
            selectedPkgId = arg
        end
    end
    
    if selectedPkgId then
        install(selectedPkgId, manifest, isDryRun)
        return
    end
    
    -- Interactive Mode Setup
    local menu = {}
    for id, pkg in pairs(manifest.packages) do
        if not pkg.hidden then
            table.insert(menu, { id = id, name = pkg.name, desc = pkg.description })
        end
    end
    table.sort(menu, function(a, b) return a.id < b.id end)
    
    local selectedIndex = 1
    
    while true do
        local w, h = term.getSize()
        local leftWidth = math.floor(w * 0.45)
        local rightWidth = w - leftWidth - 4
        local rightX = leftWidth + 3
        
        term.setBackgroundColor(colors.black)
        term.clear()
        
        -- Dynamic Header
        local line = string.rep("=", w)
        local title = "Zonk's Universal Installer"
        local titleX = math.floor((w - #title) / 2) + 1
        
        term.setCursorPos(1, 1)
        term.setTextColor(colors.cyan)
        term.write(line)
        term.setCursorPos(titleX, 2)
        term.write(title)
        term.setCursorPos(1, 3)
        term.write(line)
        
        -- Draw Columns
        for i, item in ipairs(menu) do
            local y = i + 4
            if y > h - 2 then break end
            
            term.setCursorPos(1, y) -- Back to column 1
            local displayName = item.name:sub(1, leftWidth - 2)
            if i == selectedIndex then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.white)
                term.write("> " .. displayName .. string.rep(" ", leftWidth - #displayName - 1))
                term.setBackgroundColor(colors.black)
            else
                term.setTextColor(colors.lightGray)
                term.write("  " .. displayName)
            end
        end
        
        -- Separator
        term.setTextColor(colors.cyan)
        for y = 4, h - 2 do
            term.setCursorPos(leftWidth + 1, y)
            term.write("|")
        end
        
        -- Description Box
        local current = menu[selectedIndex]
        term.setTextColor(colors.yellow)
        local nextY = drawWrappedText(current.name:upper(), rightX, 4, rightWidth, true)
        
        term.setTextColor(colors.cyan)
        term.setCursorPos(rightX, nextY)
        term.write(string.rep("-", rightWidth))
        
        term.setTextColor(colors.white)
        drawWrappedText(current.desc, rightX, nextY + 2, rightWidth, false)
        
        -- Status Bar
        term.setTextColor(colors.gray)
        term.setCursorPos(2, h)
        term.write("[Arrows] Scroll | [Enter] Install | [Q] Quit")
        term.setTextColor(colors.white)
        
        -- Event Loop
        local _, key = os.pullEvent("key")
        if key == keys.up then
            selectedIndex = selectedIndex > 1 and selectedIndex - 1 or #menu
        elseif key == keys.down then
            selectedIndex = selectedIndex < #menu and selectedIndex + 1 or 1
        elseif key == keys.enter then
            term.clear()
            term.setCursorPos(1, 1)
            install(menu[selectedIndex].id, manifest, false)
            break
        elseif key == keys.q then
            term.clear()
            term.setCursorPos(1, 1)
            print("Exit.")
            break
        end
    end
end

main()
