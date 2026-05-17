--- @diagnostic disable: undefined-global
-- Manifest for Zonk's CC-Tweaked Programs
-- Governed by AGENTS.md

return {
    packages = {
        ------------------------------------------------------------------------
        -- CORE PACKAGES (Shared Libraries)
        ------------------------------------------------------------------------
        ["core.base"] = {
            name = "Core Base",
            description = "Fundamental utilities (Config, Logger).",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/base/ConfigStore.lua", target = "lib/core/base/ConfigStore.lua", sizeBytes = 1880 },
            },
        },
        ["core.peripherals"] = {
            name = "Core Peripherals",
            description = "Peripheral discovery and wrapping.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/peripherals/PeripheralScanner.lua", target = "lib/core/peripherals/PeripheralScanner.lua", sizeBytes = 1374 },
            },
        },
        ["core.network"] = {
            name = "Core Network",
            description = "Rednet and modem communication protocols.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/network/RednetProtocol.lua", target = "lib/core/network/RednetProtocol.lua", sizeBytes = 2300 },
            },
        },
        ["core.redstone"] = {
            name = "Core Redstone",
            description = "Redstone interaction helpers.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/redstone/RedstoneController.lua", target = "lib/core/redstone/RedstoneController.lua", sizeBytes = 1874 },
            },
        },
        ["core.ui"] = {
            name = "Core UI",
            description = "Generic monitor and button handling.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/ui/ButtonGrid.lua", target = "lib/core/ui/ButtonGrid.lua", sizeBytes = 7724 },
            },
        },
        ["core.inventory"] = {
            name = "Core Inventory",
            description = "Standardized inventory handling and item matching.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/inventory/InventoryAdapter.lua", target = "lib/core/inventory/InventoryAdapter.lua", sizeBytes = 2947 },
                { source = "lib/core/inventory/ItemMatcher.lua", target = "lib/core/inventory/ItemMatcher.lua", sizeBytes = 1977 },
            },
        },
        ["core.recipes"] = {
            name = "Core Recipes",
            description = "JSON-backed recipe storage and management.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/recipes/RecipeStore.lua", target = "lib/core/recipes/RecipeStore.lua", sizeBytes = 2150 },
            },
        },

        ------------------------------------------------------------------------
        -- APPLICATION PACKAGES (User Programs)
        ------------------------------------------------------------------------
        ["create_crafter"] = {
            name = "Create Mechanical Crafter Automation",
            description = "Fully automated grid crafting for the Create mod with in-game recording.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.redstone", "core.inventory", "core.recipes" },
            files = {
                { source = "Create%20Mechanical%20Crafter%20Automation/startup.lua", target = "startup.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/CrafterSystem.lua", target = "CrafterSystem.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/RecipeManager.lua", target = "RecipeManager.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/Dashboard.lua", target = "Dashboard.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/Chest.lua", target = "Chest.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/CrafterGrid.lua", target = "CrafterGrid.lua" },
                { source = "Create%20Mechanical%20Crafter%20Automation/ManageRecipes.lua", target = "ManageRecipes.lua" },
            },
        },
        ["powah_orb"] = {
            name = "Powah Energizing Orb Automation",
            description = "Multi-orb parallel processing with AE2 pattern import support.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.inventory", "core.recipes" },
            files = {
                { source = "Powah%20Energizing%20Orb%20Automation/startup.lua", target = "startup.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/PowahSystem.lua", target = "PowahSystem.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/RecipeManager.lua", target = "RecipeManager.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/Dashboard.lua", target = "Dashboard.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/Orb.lua", target = "Orb.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/Chest.lua", target = "Chest.lua" },
                { source = "Powah%20Energizing%20Orb%20Automation/ImportMenu.lua", target = "ImportMenu.lua" },
            },
        },
        ["mekanism_portal_hub"] = {
            name = "Mekanism Portal Dialer Hub",
            description = "Premium touch-screen frequency manager for Mekanism Teleporters.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.base", "core.peripherals", "core.network", "core.ui" },
            files = {
                { source = "Mekanism%20Portal%20Dialer%20Hub/startup.lua", target = "startup.lua" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/HubSystem.lua", target = "HubSystem.lua" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/UUIDService.lua", target = "UUIDService.lua" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/Dashboard.lua", target = "Dashboard.lua" },
            },
        },
        ["mekanism_recall_sender"] = {
            name = "Mekanism Portal Recaller",
            description = "Remote trigger for the Portal Hub system.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.base", "core.peripherals", "core.network", "core.redstone" },
            files = {
                { source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua", target = "startup.lua" },
            },
        },

        ------------------------------------------------------------------------
        -- META & DEVELOPER PACKAGES (Tools)
        ------------------------------------------------------------------------
        ["developer_suite"] = {
            name = "CC Developer Suite",
            description = "Advanced hardware inspection and diagnostic toolkit.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.network" },
            files = {
                { source = "CC%20Developer%20Suite/startup.lua", target = "startup.lua" },
            },
        },
    },
}
