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
					sizeBytes = 1747,
					hash = "a00c219b5bff320199dcd48c0dd296c11e65f9e45dce46cd5c8c81ed9b43e866",
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
					sizeBytes = 1312,
					hash = "38852bdd6ad17798074528d3e0cf8a172fb3f011649e88856087bf1cc33de31c",
				},
				{
					source = "lib/core/peripherals/HAL.lua",
					target = "lib/core/peripherals/HAL.lua",
					sizeBytes = 4059,
					hash = "9377c4ae70c7b5b1d7008bfc40ca1029697ea695e4934d9ab69cb72f3a51b63b",
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
					sizeBytes = 2059,
					hash = "806ec93d37b5f0e6dee4b58e7f8b923adae1b46080cb492e2121a0fb65c8ae4d",
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
					sizeBytes = 1836,
					hash = "bee9b68e422cf7b5ac2f2c93a347016e7eb9f6aa993361c1252d11c4d2ce4e00",
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
					sizeBytes = 7225,
					hash = "4db07bde8e4da2b2ed86dcd00d0154755d3a974f0829391b2ee342cd91c0a788",
				},
			},
		},
		["core.ui.boot_assistant"] = {
			name = "Core UI Boot Assistant",
			description = "Interactive boot loader and hardware diagnostics.",
			hidden = true,
			dependencies = { "core.peripherals" },
			files = {
				{
					source = "lib/core/ui/boot_assistant.lua",
					target = "lib/core/ui/boot_assistant.lua",
					sizeBytes = 18687,
					hash = "f5944c42c00e74bf77df9e9724829bc6ae976361a269fb28a4ef84f5d432a7e5",
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
					sizeBytes = 2732,
					hash = "30da6483c9adddbff722f2cfa6eb9261e7a618273784696d2b5157db740c62de",
				},
				{
					source = "lib/core/inventory/ItemMatcher.lua",
					target = "lib/core/inventory/ItemMatcher.lua",
					sizeBytes = 1863,
					hash = "79f325f0896e757def03b6f1f0515ae5abf6a76501417f1e78d72b0761fb4939",
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
					sizeBytes = 2015,
					hash = "2d680a4763bf7a1391a5eeecea9bca39610114906c5be9a0aa87a38b0ab6e0fd",
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
			dependencies = { "core.redstone", "core.inventory", "core.recipes", "core.ui.boot_assistant" },
			files = {
				{
					source = "Create%20Mechanical%20Crafter%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 4007,
					hash = "9581c7685d48ee5c38f88ad4b3a00c3b00a02b528ba20e3b336b41c2bbc90138",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterSystem.lua",
					target = "system/CrafterSystem.lua",
					sizeBytes = 6693,
					hash = "c10be963354b37e42727c9952cb3553b90a96c14a830c7a12c5c09aa0a652c89",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/RecipeManager.lua",
					target = "system/RecipeManager.lua",
					sizeBytes = 8681,
					hash = "03fdcb8db250ce582c3bab7df91533d2616a8302fa024ef2f83726b59ce4cb60",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/ui/Dashboard.lua",
					target = "ui/Dashboard.lua",
					sizeBytes = 3952,
					hash = "07e874a8c73752c65bc778f3dab350a3486d76d4ec17bb12b2be606aef7f193d",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/Chest.lua",
					target = "system/Chest.lua",
					sizeBytes = 3551,
					hash = "dde15384dccce044a5a3fb44d4cb7b7c77a0758ce651f4032b010dd7fe60ebc5",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterGrid.lua",
					target = "system/CrafterGrid.lua",
					sizeBytes = 3853,
					hash = "f73d15acfc52be7de1b50e77ae48e149d50d50988484e648920af2b89702b20a",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/ui/ManageRecipes.lua",
					target = "ui/ManageRecipes.lua",
					sizeBytes = 6305,
					hash = "4fbaef9770f0d29f2a3371002ab267424576ff3ba3f8eff8f7b8c7290a480653",
				},
			},
		},
		["powah_orb"] = {
			name = "Powah Energizing Orb Automation",
			description = "Multi-orb parallel processing with AE2 pattern import support.",
			hidden = false,
			entry = "startup.lua",
			dependencies = { "core.inventory", "core.recipes", "core.ui.boot_assistant" },
			files = {
				{
					source = "Powah%20Energizing%20Orb%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 5390,
					hash = "f092e714a66b2318e1918ced8949dc4f4066143a3d150f577229bc348a830591",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/PowahSystem.lua",
					target = "system/PowahSystem.lua",
					sizeBytes = 5041,
					hash = "07a5ad13b34f78fc2b02ebff30445ead3816f08743f48490c5a9aa713fe31350",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/RecipeManager.lua",
					target = "system/RecipeManager.lua",
					sizeBytes = 3852,
					hash = "b640d9fa04135931534519a3e08092d068034ac7d0f87e4a52cff6cddec668e1",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/ui/Dashboard.lua",
					target = "ui/Dashboard.lua",
					sizeBytes = 3459,
					hash = "412e0402a084756ff0ae7211c985569b5ac30760b1eb18ab360fa40628138a50",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/Orb.lua",
					target = "system/Orb.lua",
					sizeBytes = 2167,
					hash = "3fc3269720b341d3315ca7cbcc52854a92d2e05e7e070d4d59425b96bd593435",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/Chest.lua",
					target = "system/Chest.lua",
					sizeBytes = 2452,
					hash = "697a306aa7132293be3164e68ad15260a384cac85ddb342ddc38e04194a0a0d3",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/ui/ImportMenu.lua",
					target = "ui/ImportMenu.lua",
					sizeBytes = 10734,
					hash = "e46416d52b4fa2c40df6ff4d195a9699bae552295b4d29d32ab2b3d999760e1d",
				},
			},
		},
		["mekanism_portal_hub"] = {
			name = "Mekanism Portal Dialer Hub",
			description = "Premium touch-screen frequency manager for Mekanism Teleporters.",
			hidden = false,
			entry = "startup.lua",
			dependencies = { "core.base", "core.peripherals", "core.network", "core.ui", "core.ui.boot_assistant" },
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/startup.lua",
					target = "startup.lua",
					sizeBytes = 3052,
					hash = "e127c904b68b02c5db52811e5a4a59c00227c5406118e9724e2e78769759f6ed",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubSystem.lua",
					target = "system/HubSystem.lua",
					sizeBytes = 22164,
					hash = "ec34c5d6c27b17b2a1792d84e4364b2d1a20d7da04c5859c19d091890dc54fbe",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/UUIDService.lua",
					target = "system/UUIDService.lua",
					sizeBytes = 2155,
					hash = "40e7b87d090b9344898c641d0d061840177036cf78468050e6926177c201bde4",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/ui/Dashboard.lua",
					target = "ui/Dashboard.lua",
					sizeBytes = 4088,
					hash = "e8eff4829d361c3932805a98259cdd457ac243619dced016305c6815016d667e",
				},
			},
		},
		["mekanism_recall_sender"] = {
			name = "Mekanism Portal Recaller",
			description = "Remote trigger for the Portal Hub system.",
			hidden = false,
			entry = "startup.lua",
			dependencies = {
				"core.base",
				"core.peripherals",
				"core.network",
				"core.redstone",
				"core.ui.boot_assistant",
			},
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua",
					target = "startup.lua",
					sizeBytes = 8180,
					hash = "fa3fde380bcfb44449c863e8f649fed19d803d764e8c2e65265fc5692bed3377",
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
			dependencies = { "core.network", "core.ui.boot_assistant" },
			files = {
				{
					source = "CC%20Developer%20Suite/startup.lua",
					target = "startup.lua",
					sizeBytes = 12193,
					hash = "fd145f242322ef92d6d963b5fb4cf4c633724ee22c4023df9ff07f51a27deb38",
				},
			},
		},
	},
}
