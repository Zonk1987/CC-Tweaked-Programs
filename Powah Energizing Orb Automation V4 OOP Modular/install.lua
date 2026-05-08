local baseUrl = "https://raw.githubusercontent.com/YOUR_GITHUB_NAME/YOUR_REPOSITORY/main/"

local files = {
    "Dashboard.lua",
    "RecipeManager.lua",
    "InventoryComponent.lua",
    "Chest.lua",
    "Orb.lua",
    "PowahSystem.lua",
    "startup"
}

print("Installing Powah Automation System...")

for _, file in ipairs(files) do
    print("Downloading " .. file .. "...")
    -- Use quiet mode for wget if desired, but default is fine
    shell.run("wget", baseUrl .. file, file)
end

print("\nInstallation complete! Rebooting computer in 3 seconds...")
os.sleep(3)
os.reboot()
