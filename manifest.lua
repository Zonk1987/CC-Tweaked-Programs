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
				{
					source = "lib/core/base/ConfigStore.lua",
					target = "lib/core/base/ConfigStore.lua",
					sizeBytes = 1880,
					hash = "bb9c5ddfb4bcba10420cb0d278f3607c110bd96b1e510794a007de60c9128bec",
				},
			},
		},
		["core.peripherals"] = {
			name = "Core Peripherals",
			description = "Peripheral discovery and wrapping.",
			hidden = true,
			dependencies = {},
			files = {
				{
					source = "lib/core/peripherals/PeripheralScanner.lua",
					target = "lib/core/peripherals/PeripheralScanner.lua",
					sizeBytes = 1374,
					hash = "679dc1a8494cbcafcc9d4187fdb8465e385f6076c62ef83067148323dc39e9dd",
				},
			},
		},
		["core.network"] = {
			name = "Core Network",
			description = "Rednet and modem communication protocols.",
			hidden = true,
			dependencies = { "core.peripherals" },
			files = {
				{
					source = "lib/core/network/RednetProtocol.lua",
					target = "lib/core/network/RednetProtocol.lua",
					sizeBytes = 2323,
					hash = "19857afe3c515565ff1d5c9df379c2bf160778e7769fd8de0a21827ee17ba411",
				},
			},
		},
		["core.redstone"] = {
			name = "Core Redstone",
			description = "Redstone interaction helpers.",
			hidden = true,
			dependencies = {},
			files = {
				{
					source = "lib/core/redstone/RedstoneController.lua",
					target = "lib/core/redstone/RedstoneController.lua",
					sizeBytes = 2017,
					hash = "253ff8973c3efab952ca692c2ed41dbe111b22d76b6d741693b3a7e784e93090",
				},
			},
		},
		["core.ui"] = {
			name = "Core UI",
			description = "Generic monitor and button handling.",
			hidden = true,
			dependencies = { "core.peripherals" },
			files = {
				{
					source = "lib/core/ui/ButtonGrid.lua",
					target = "lib/core/ui/ButtonGrid.lua",
					sizeBytes = 7724,
					hash = "eb32ec93513ce6b4396f9b8e9b8b297387bab2003e8461e10b16e41ce351f016",
				},
			},
		},
		["core.inventory"] = {
			name = "Core Inventory",
			description = "Standardized inventory handling and item matching.",
			hidden = true,
			dependencies = { "core.peripherals" },
			files = {
				{
					source = "lib/core/inventory/InventoryAdapter.lua",
					target = "lib/core/inventory/InventoryAdapter.lua",
					sizeBytes = 2850,
					hash = "2753bda4a3c24e2a57a9f27fa5ae8a736c35f2aaff36a05dc3d2f9b4180540ff",
				},
				{
					source = "lib/core/inventory/ItemMatcher.lua",
					target = "lib/core/inventory/ItemMatcher.lua",
					sizeBytes = 1977,
					hash = "d9910aeb984cd7a59d61b4c09df94c8e37f261c2d4d02d7eef568b476ea86bf6",
				},
			},
		},
		["core.recipes"] = {
			name = "Core Recipes",
			description = "JSON-backed recipe storage and management.",
			hidden = true,
			dependencies = {},
			files = {
				{
					source = "lib/core/recipes/RecipeStore.lua",
					target = "lib/core/recipes/RecipeStore.lua",
					sizeBytes = 2199,
					hash = "c92f9ce3737a1a515e2ea424cff2f1c144659023ce5ff46c5955e699b0ddad11",
				},
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
				{
					source = "Create%20Mechanical%20Crafter%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 2640,
					hash = "a5d841e27df7debbd0e7cd7630559216dd7613e8f66a3f9252626057655b7489",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/CrafterSystem.lua",
					target = "CrafterSystem.lua",
					sizeBytes = 7223,
					hash = "2cc407bc984afcb914f8466940c39394d860dec62b6acc99b5e09d72249dc066",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/RecipeManager.lua",
					target = "RecipeManager.lua",
					sizeBytes = 9705,
					hash = "88bff91f325620a323554601589e127a34e114a99163264a0e327a28ead6493c",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/Dashboard.lua",
					target = "Dashboard.lua",
					sizeBytes = 4098,
					hash = "0eb8fe7c958fc0fefcd0493e0094453f7eea47a67e03430c33a6f3aa5c183f45",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/Chest.lua",
					target = "Chest.lua",
					sizeBytes = 4060,
					hash = "5c98056c8bf98a2629ee954e2e7b40707aa24042a08c4a1ec09a2f31c2e819d3",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/CrafterGrid.lua",
					target = "CrafterGrid.lua",
					sizeBytes = 4165,
					hash = "11c4d6d60fa66da8df7396a31d913b4e037dd963386401fe1ae58b09a22a44ab",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/ManageRecipes.lua",
					target = "ManageRecipes.lua",
					sizeBytes = 7263,
					hash = "c721b3f18826f249b574c012f2f473cfb903933b9646f90d603b20143c469fec",
				},
			},
		},
		["powah_orb"] = {
			name = "Powah Energizing Orb Automation",
			description = "Multi-orb parallel processing with AE2 pattern import support.",
			hidden = false,
			entry = "startup.lua",
			dependencies = { "core.inventory", "core.recipes" },
			files = {
				{
					source = "Powah%20Energizing%20Orb%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 2800,
					hash = "6c78e48108070efb1695895bf23369d8270a9e888402b3535731dbe75692a6b2",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/PowahSystem.lua",
					target = "PowahSystem.lua",
					sizeBytes = 5923,
					hash = "8a393036df8f05d3817bb98387796916b5fac3a7d6c6a682a3359cc6b257bf1b",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/RecipeManager.lua",
					target = "RecipeManager.lua",
					sizeBytes = 4274,
					hash = "43a86b4ede8a7cf403f52bfa175b48cef6beb8890a50b95e6ddd0aa19270fead",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Dashboard.lua",
					target = "Dashboard.lua",
					sizeBytes = 3597,
					hash = "0f507a9705367ba04a670104afad2c95c264073291d857f25f1baca500e600e9",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Orb.lua",
					target = "Orb.lua",
					sizeBytes = 2270,
					hash = "f297c6ac81a4061c93e86682cc5bb945ab5e41b7b00dcc2c30352f5846748180",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Chest.lua",
					target = "Chest.lua",
					sizeBytes = 2636,
					hash = "361d7c3994157574dbc7069b687328cd0a7ddaa021dc60b176b17347e25ea88e",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/ImportMenu.lua",
					target = "ImportMenu.lua",
					sizeBytes = 12911,
					hash = "80e3fe2be3ed8c09c152b71d8128255481b41617227907a7cbe512ef5852bce2",
				},
			},
		},
		["mekanism_portal_hub"] = {
			name = "Mekanism Portal Dialer Hub",
			description = "Premium touch-screen frequency manager for Mekanism Teleporters.",
			hidden = false,
			entry = "startup.lua",
			dependencies = { "core.base", "core.peripherals", "core.network", "core.ui" },
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/startup.lua",
					target = "startup.lua",
					sizeBytes = 2190,
					hash = "4dc745f0c7665c504e598db37fca6b7bb88ac44e57cf1204d808d300bb444922",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/HubSystem.lua",
					target = "HubSystem.lua",
					sizeBytes = 24809,
					hash = "b9d162f16cc58e5f9dad8da86b1693c38cbe13f0d1e463989c059b665f0492fd",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/UUIDService.lua",
					target = "UUIDService.lua",
					sizeBytes = 2415,
					hash = "62c700d3da1cfaf04ca1a2880dfa21c12ada76b6d9e9b350f10e25261f2fba69",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/Dashboard.lua",
					target = "Dashboard.lua",
					sizeBytes = 4429,
					hash = "4dc6c56bbc3bc8d16ac946fc2adadb20fe6043deaacb4733f939f61bfaa65c12",
				},
			},
		},
		["mekanism_recall_sender"] = {
			name = "Mekanism Portal Recaller",
			description = "Remote trigger for the Portal Hub system.",
			hidden = false,
			entry = "startup.lua",
			dependencies = { "core.base", "core.peripherals", "core.network", "core.redstone" },
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua",
					target = "startup.lua",
					sizeBytes = 7329,
					hash = "1903eded098cdfdca01c1c8bc1c8b2ef31283fee0922ce2cd24953e9cd0481c2",
				},
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
				{
					source = "CC%20Developer%20Suite/startup.lua",
					target = "startup.lua",
					sizeBytes = 13472,
					hash = "87029d23079e4da7905bb5f6eb0139f00c36fe0450329c7852fa7701bebb50f0",
				},
			},
		},
	},
}
