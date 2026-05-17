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
                { source = "lib/core/base/ConfigStore.lua", target = "lib/core/base/ConfigStore.lua", sizeBytes = 1880, hash = "bb9c5ddfb4bcba10420cb0d278f3607c110bd96b1e510794a007de60c9128bec" },
            },
        },
        ["core.peripherals"] = {
            name = "Core Peripherals",
            description = "Peripheral discovery and wrapping.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/peripherals/PeripheralScanner.lua", target = "lib/core/peripherals/PeripheralScanner.lua", sizeBytes = 1374, hash = "679dc1a8494cbcafcc9d4187fdb8465e385f6076c62ef83067148323dc39e9dd" },
            },
        },
        ["core.network"] = {
            name = "Core Network",
            description = "Rednet and modem communication protocols.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/network/RednetProtocol.lua", target = "lib/core/network/RednetProtocol.lua", sizeBytes = 2300, hash = "749b3a58bc8e79c33ea15587e144c19c9343745a44a155db01ad95775c76cff7" },
            },
        },
        ["core.redstone"] = {
            name = "Core Redstone",
            description = "Redstone interaction helpers.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/redstone/RedstoneController.lua", target = "lib/core/redstone/RedstoneController.lua", sizeBytes = 1874, hash = "7c306a727adda93120b62bab1e6dde1ad3a0ceadb426c29287e8e51407875367" },
            },
        },
        ["core.ui"] = {
            name = "Core UI",
            description = "Generic monitor and button handling.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/ui/ButtonGrid.lua", target = "lib/core/ui/ButtonGrid.lua", sizeBytes = 7724, hash = "eb32ec93513ce6b4396f9b8e9b8b297387bab2003e8461e10b16e41ce351f016" },
            },
        },
        ["core.inventory"] = {
            name = "Core Inventory",
            description = "Standardized inventory handling and item matching.",
            hidden = true,
            dependencies = { "core.peripherals" },
            files = {
                { source = "lib/core/inventory/InventoryAdapter.lua", target = "lib/core/inventory/InventoryAdapter.lua", sizeBytes = 2850, hash = "2753bda4a3c24e2a57a9f27fa5ae8a736c35f2aaff36a05dc3d2f9b4180540ff" },
                { source = "lib/core/inventory/ItemMatcher.lua", target = "lib/core/inventory/ItemMatcher.lua", sizeBytes = 1977, hash = "d9910aeb984cd7a59d61b4c09df94c8e37f261c2d4d02d7eef568b476ea86bf6" },
            },
        },
        ["core.recipes"] = {
            name = "Core Recipes",
            description = "JSON-backed recipe storage and management.",
            hidden = true,
            dependencies = {},
            files = {
                { source = "lib/core/recipes/RecipeStore.lua", target = "lib/core/recipes/RecipeStore.lua", sizeBytes = 2134, hash = "766064a65aae6d89e7765f150b6588d8f63c7f42b8c30f8cbef90c185db59382" },
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
                { source = "Create%20Mechanical%20Crafter%20Automation/startup.lua", target = "startup.lua", sizeBytes = 2640, hash = "f0f808dc2ea706212042c39859d31ec693766051f45b4d84765b0812d82c7f7d" },
                { source = "Create%20Mechanical%20Crafter%20Automation/CrafterSystem.lua", target = "CrafterSystem.lua", sizeBytes = 7207, hash = "6022225c7ddf67e8b5cb12b0a4969e0f55c2ab262a9b58fbfda4841872b10e6d" },
                { source = "Create%20Mechanical%20Crafter%20Automation/RecipeManager.lua", target = "RecipeManager.lua", sizeBytes = 9381, hash = "f42c613d8c9b6b7a178d89a034b50763eb36fbba7648ecc539c155e7d5f9a379" },
                { source = "Create%20Mechanical%20Crafter%20Automation/Dashboard.lua", target = "Dashboard.lua", sizeBytes = 4098, hash = "3ba1d8bfbafbb9980192a34872e81f5c4545c304f438359110dab2e9864133f6" },
                { source = "Create%20Mechanical%20Crafter%20Automation/Chest.lua", target = "Chest.lua", sizeBytes = 3185, hash = "1182e469be949e81f02b8fd65c54eba0d81be5a6e2b5eae2cfbe6b18e7c1706c" },
                { source = "Create%20Mechanical%20Crafter%20Automation/CrafterGrid.lua", target = "CrafterGrid.lua", sizeBytes = 4057, hash = "e167f7350742a82b6a56e5cc7d4f817d5617f1e41f46d0cc24b3ef2d0c6e71bb" },
                { source = "Create%20Mechanical%20Crafter%20Automation/ManageRecipes.lua", target = "ManageRecipes.lua", sizeBytes = 7263, hash = "c721b3f18826f249b574c012f2f473cfb903933b9646f90d603b20143c469fec" },
            },
        },
        ["powah_orb"] = {
            name = "Powah Energizing Orb Automation",
            description = "Multi-orb parallel processing with AE2 pattern import support.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.inventory", "core.recipes" },
            files = {
                { source = "Powah%20Energizing%20Orb%20Automation/startup.lua", target = "startup.lua", sizeBytes = 2800, hash = "2d07120b20912975081af54d88339ece82a1f49b49fba718073118e624d42b3b" },
                { source = "Powah%20Energizing%20Orb%20Automation/PowahSystem.lua", target = "PowahSystem.lua", sizeBytes = 5907, hash = "c96e5482a950cb73b54e897a8ee0cb7988a36d11e2594300c1b40f22c5fbebcd" },
                { source = "Powah%20Energizing%20Orb%20Automation/RecipeManager.lua", target = "RecipeManager.lua", sizeBytes = 4018, hash = "8ea71b70d9c254aae259beb4a1bc7541f66f91a91c3af53f4553e6829e7580a6" },
                { source = "Powah%20Energizing%20Orb%20Automation/Dashboard.lua", target = "Dashboard.lua", sizeBytes = 3597, hash = "0f507a9705367ba04a670104afad2c95c264073291d857f25f1baca500e600e9" },
                { source = "Powah%20Energizing%20Orb%20Automation/Orb.lua", target = "Orb.lua", sizeBytes = 1409, hash = "c4614a94ab4751576b11c3ce32a3487b38360c50c499dcead1e0c994147ebe27" },
                { source = "Powah%20Energizing%20Orb%20Automation/Chest.lua", target = "Chest.lua", sizeBytes = 1767, hash = "b08588db81edd2ae0e8b2adf84899cde9a502cf4c0678d46a4996f766b8b4c05" },
                { source = "Powah%20Energizing%20Orb%20Automation/ImportMenu.lua", target = "ImportMenu.lua", sizeBytes = 12911, hash = "80e3fe2be3ed8c09c152b71d8128255481b41617227907a7cbe512ef5852bce2" },
            },
        },
        ["mekanism_portal_hub"] = {
            name = "Mekanism Portal Dialer Hub",
            description = "Premium touch-screen frequency manager for Mekanism Teleporters.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.base", "core.peripherals", "core.network", "core.ui" },
            files = {
                { source = "Mekanism%20Portal%20Dialer%20Hub/startup.lua", target = "startup.lua", sizeBytes = 2190, hash = "9521cab6fb7f8e59ffdb46897ad2875de055bcef1594d6b2c3c1af61d4991018" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/HubSystem.lua", target = "HubSystem.lua", sizeBytes = 23534, hash = "68a111a1f0c6f785d8ed61f406c70498feb4b5ceee198f418e90512534f05d84" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/UUIDService.lua", target = "UUIDService.lua", sizeBytes = 2358, hash = "d2af8b45d9d0257f2e20468a150795256fbbe17d0f2842951b531dd0d82a5c1d" },
                { source = "Mekanism%20Portal%20Dialer%20Hub/Dashboard.lua", target = "Dashboard.lua", sizeBytes = 4429, hash = "4dc6c56bbc3bc8d16ac946fc2adadb20fe6043deaacb4733f939f61bfaa65c12" },
            },
        },
        ["mekanism_recall_sender"] = {
            name = "Mekanism Portal Recaller",
            description = "Remote trigger for the Portal Hub system.",
            hidden = false,
            entry = "startup.lua",
            dependencies = { "core.base", "core.peripherals", "core.network", "core.redstone" },
            files = {
                { source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua", target = "startup.lua", sizeBytes = 7253, hash = "97392491ff7651b7f255b2a2193bf7ce9eecc54a98b9b66433cc11473b658171" },
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
                { source = "CC%20Developer%20Suite/startup.lua", target = "startup.lua", sizeBytes = 13257, hash = "1b2078cf19bd185d051934e61ece813b14da8aafec4d9be6451031ebe0c66590" },
            },
        },
    },
}
