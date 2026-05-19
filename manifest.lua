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
					sizeBytes = 2130,
					hash = "b58925d748dbd1002bd6d628cb7293fa0cb47581e7549222305fd8ae978008db",
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
					sizeBytes = 7204,
					hash = "a65938527aeb6e1413620d96dceec2719d9081951a090112490b3f0ff5f20099",
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
					sizeBytes = 21827,
					hash = "f3392a106cc02db6efd927a08b3e8e19c0b1154ee8818fbe96041a941f1737e6",
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
					sizeBytes = 2720,
					hash = "c1034dca470afab49bd2f01e5a2823075139af493888f7affbb286cb90876ab6",
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
			dependencies = { "core.redstone", "core.inventory", "core.recipes" },
			files = {
				{
					source = "Create%20Mechanical%20Crafter%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 2428,
					hash = "4044ef39301856caacf01edb33f06c44d3d406abb9e5355419da7605ae022ffe",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/CrafterSystem.lua",
					target = "CrafterSystem.lua",
					sizeBytes = 6517,
					hash = "920ab3cfd9679658927baa29b5b93191f6d57983988fb81f964d881484530229",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/RecipeManager.lua",
					target = "RecipeManager.lua",
					sizeBytes = 8634,
					hash = "bfc985007dd3b7dbbc54e54941800ec72aff24db3504dc622e4be7f1feb02c7a",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/Dashboard.lua",
					target = "Dashboard.lua",
					sizeBytes = 3835,
					hash = "00e7d2937300e4fc8f7082e21aa0deb9d7f3a261eba3a3da373151783ce90c65",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/Chest.lua",
					target = "Chest.lua",
					sizeBytes = 3553,
					hash = "89ee59919bc29c1098c3728267a69eb77060505f9cfc1680eda0d5cfd7d45040",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/CrafterGrid.lua",
					target = "CrafterGrid.lua",
					sizeBytes = 3734,
					hash = "10acb7ce8d199d89480b2f0577c24a131b2f7457b4ce4e616b82cc6086e4ce70",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/ManageRecipes.lua",
					target = "ManageRecipes.lua",
					sizeBytes = 6165,
					hash = "99ea4e7047edcf2e75d97f6a802869d54d13dc1298bcc81cc3693c095130f434",
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
					sizeBytes = 2706,
					hash = "64adb110836afdc4172767c9a4070037171c442a44b340e8993a17025843bc81",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/PowahSystem.lua",
					target = "PowahSystem.lua",
					sizeBytes = 5041,
					hash = "59e7567726f4e1529b37cf7a14e0d1b61c8c66bbe75344012170d95f1c7a1cc4",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/RecipeManager.lua",
					target = "RecipeManager.lua",
					sizeBytes = 3852,
					hash = "b640d9fa04135931534519a3e08092d068034ac7d0f87e4a52cff6cddec668e1",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Dashboard.lua",
					target = "Dashboard.lua",
					sizeBytes = 3329,
					hash = "d5bc7ee57f3c11e35f35856657e7029e871891aeba02938f79878f14f0f09d92",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Orb.lua",
					target = "Orb.lua",
					sizeBytes = 2167,
					hash = "3fc3269720b341d3315ca7cbcc52854a92d2e05e7e070d4d59425b96bd593435",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/Chest.lua",
					target = "Chest.lua",
					sizeBytes = 2452,
					hash = "697a306aa7132293be3164e68ad15260a384cac85ddb342ddc38e04194a0a0d3",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/ImportMenu.lua",
					target = "ImportMenu.lua",
					sizeBytes = 10502,
					hash = "0636a34693b14d0a8aab1acbdb1b3d5c17be7f043772f2fac300f8734f0cb579",
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
					sizeBytes = 2056,
					hash = "16c5cdb173c1595e8c37f030cecb8e3b91485495e71dbae9dd9a9e117de728dc",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/HubSystem.lua",
					target = "HubSystem.lua",
					sizeBytes = 22203,
					hash = "b23327ccfcf9ca0cf28df53f3f5648a2c65994649adfd0ead81c9cc995f2e486",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/UUIDService.lua",
					target = "UUIDService.lua",
					sizeBytes = 2155,
					hash = "40e7b87d090b9344898c641d0d061840177036cf78468050e6926177c201bde4",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/Dashboard.lua",
					target = "Dashboard.lua",
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
			dependencies = { "core.base", "core.peripherals", "core.network", "core.redstone" },
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua",
					target = "startup.lua",
					sizeBytes = 6604,
					hash = "423783759bbd568f1553e2948107dad54bd5bfaaceae353c9c250ea9a8252453",
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
					sizeBytes = 11260,
					hash = "e24dd59dd5d38f979fab55e4f25616e0db9455daf1175c6a8ce68d46e0857482",
				},
			},
		},
	},
}
