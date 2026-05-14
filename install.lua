-- STRICT MODE (SAFE VERSION)
local _ORIG_ENV = _ENV
local _ENV = setmetatable({}, {
    __index = _ORIG_ENV,
    __newindex = function(t, key, value)
        error("Strict Mode: Forgot 'local' before variable '" .. tostring(key) .. "'!", 2)
    end
})

local REPO_URL = "https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/"
local MANIFEST_NAME = "manifest.lua"

local args = { ... }

--- Helper: Download a file from GitHub
local function downloadFile(url, path)
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

--- Validate the manifest structure (for --validate flag)
local function validateManifest(manifest)
    print("Validating manifest...")
    local errors = {}
    for id, pkg in pairs(manifest.packages) do
        if type(pkg.name) ~= "string" or pkg.name == "" then table.insert(errors, id .. ": Missing name") end
        if type(pkg.files) ~= "table" then table.insert(errors, id .. ": Missing files table") end
        if type(pkg.dependencies) ~= "table" then table.insert(errors, id .. ": Missing dependencies table") end
        
        for _, file in ipairs(pkg.files or {}) do
            if not file.source or file.source == "" then table.insert(errors, id .. ": Empty source path") end
            if not file.target or file.target == "" then table.insert(errors, id .. ": Empty target path") end
            if file.target and (file.target:sub(1,1) == "/" or file.target:find("%.%.")) then
                table.insert(errors, id .. ": Illegal target path: " .. file.target)
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
        filesToDownload[file.target] = file.source
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
    for target, source in pairs(result) do
        current = current + 1
        if isDryRun then
            print(string.format("  [%d/%d] [PLAN] %s -> %s", current, total, source, target))
        else
            term.setTextColor(colors.gray)
            write(string.format("  [%d/%d] Downloading %s... ", current, total, target))
            local success, err = downloadFile(REPO_URL .. source, target)
            if success then
                term.setTextColor(colors.lime)
                print("OK")
            else
                term.setTextColor(colors.red)
                print("FAILED")
                print("    Error: " .. err)
                term.setTextColor(colors.white)
                return
            end
        end
    end
    
    term.setTextColor(colors.white)
    print("\nTotal files processed: " .. total)
    if not isDryRun then
        print("Installation complete.")
        if targetPkg.entry and fs.exists(targetPkg.entry) then
            print("\nWould you like to run " .. targetPkg.entry .. " now? (y/n)")
            local ans = read()
            if ans:lower() == "y" then
                shell.run(targetPkg.entry)
            end
        end
    end
end

--- Main Entry Point
local function main()
    local manifest, err = loadManifest()
    if not manifest then
        print("Error: " .. err)
        return
    end
    
    local isDryRun = false
    local selectedPkg = nil
    
    for _, arg in ipairs(args) do
        if arg == "--validate" then
            validateManifest(manifest)
            return
        elseif arg == "--dry-run" then
            isDryRun = true
        elseif manifest.packages[arg] then
            selectedPkg = arg
        end
    end
    
    if selectedPkg then
        install(selectedPkg, manifest, isDryRun)
        return
    end
    
    -- Interactive Mode
    term.clear()
    term.setCursorPos(1,1)
    print("=======================================")
    print("      Zonk's Universal Installer       ")
    print("=======================================\n")
    
    local menu = {}
    for id, pkg in pairs(manifest.packages) do
        if not pkg.hidden then
            table.insert(menu, { id = id, name = pkg.name, desc = pkg.description })
        end
    end
    table.sort(menu, function(a, b) return a.id < b.id end)
    
    for i, item in ipairs(menu) do
        print(string.format("[%d] %s", i, item.name))
        term.setTextColor(colors.gray)
        print("    " .. item.desc)
        term.setTextColor(colors.white)
    end
    print("\n[Q] Quit")
    
    while true do
        write("\nChoice: ")
        local input = read()
        if input:lower() == "q" then return end
        local num = tonumber(input)
        if num and menu[num] then
            install(menu[num].id, manifest, false)
            break
        end
        print("Invalid choice.")
    end
end

main()
