local baseUrl = "https://raw.githubusercontent.com/Zonk1987/CC-Tweaked/main/Powah%20Energizing%20Orb%20Automation%20V4%20OOP%20Modular/"

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
