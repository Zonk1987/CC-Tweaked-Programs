--[[
================================================================================
Zonk's Universal Installer (Legacy Wrapper)
================================================================================
This file is preserved for backward compatibility. 
It redirects to the new root-level manifest-driven installer.
================================================================================
]]--

local ROOT_INSTALLER_URL = "https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua"
local TEMP_PATH = "install_new.lua"

print("Redirecting to the new manifest-driven installer...")

local response = http.get(ROOT_INSTALLER_URL)
if not response then
    print("Error: Could not connect to the update server.")
    return
end

local content = response.readAll()
response.close()

local file = fs.open(TEMP_PATH, "w")
if not file then
    print("Error: Could not write temporary installer.")
    return
end

file.write(content)
file.close()

print("Launching new installer...\n")
os.sleep(1)
shell.run(TEMP_PATH)

-- Optional: Cleanup the temporary installer after run if it wasn't replaced
if fs.exists(TEMP_PATH) then
    fs.delete(TEMP_PATH)
end
