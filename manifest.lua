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
			description = "Fundamental utilities (Config Store, Event Bus, Result wrapping).",
			hidden = true,
			dependencies = {},
			files = {
				{
					source = "lib/core/base/ConfigStore.lua",
					target = "lib/core/base/ConfigStore.lua",
					sizeBytes = 2016,
					hash = "7c78abb91cf6f8d57e0deaa11e0db1077304883ba66225d2617e956b30d743d5",
				},
				{
					source = "lib/core/base/EventBus.lua",
					target = "lib/core/base/EventBus.lua",
					sizeBytes = 3109,
					hash = "b6b88cb42f4368293055eeed6b39a83f5e9ab8dfe75c2bb49db576093153dd13",
				},
				{
					source = "lib/core/base/Result.lua",
					target = "lib/core/base/Result.lua",
					sizeBytes = 2341,
					hash = "24e1b237f94765562e96d6c43aaa141e434d6275903c5f868278ea8017017fe3",
				},
			},
		},
		["core.logger"] = {
			name = "Core Logger",
			description = "File-based structured logging (Logger).",
			hidden = true,
			dependencies = {},
			files = {
				{
					source = "lib/core/logger/Logger.lua",
					target = "lib/core/logger/Logger.lua",
					sizeBytes = 4184,
					hash = "3e21cdfaeced7f52b571ef5152641342546f97a133e59de6e251e35e594bce84",
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
			description = "Generic monitor, button, layout, and canvas drawing handling.",
			hidden = true,
			dependencies = { "core.peripherals" },
			files = {
				{
					source = "lib/core/ui/ButtonGrid.lua",
					target = "lib/core/ui/ButtonGrid.lua",
					sizeBytes = 7225,
					hash = "4db07bde8e4da2b2ed86dcd00d0154755d3a974f0829391b2ee342cd91c0a788",
				},
				{
					source = "lib/core/ui/ConfigGUI.lua",
					target = "lib/core/ui/ConfigGUI.lua",
					sizeBytes = 10619,
					hash = "a593aa70778afd9e15ec4e06f989d41996ec6b9ca78a73fd984d29dc3869b63f",
				},
				{
					source = "lib/core/ui/FlexLayout.lua",
					target = "lib/core/ui/FlexLayout.lua",
					sizeBytes = 4514,
					hash = "e6f62d1acfb782ff390bfc01d85776c3fc0f790ad8e4a199b8a8542d82ca180b",
				},
				{
					source = "lib/core/ui/VirtualCanvas.lua",
					target = "lib/core/ui/VirtualCanvas.lua",
					sizeBytes = 5296,
					hash = "32d670a7f29748cb34ff98f943036c11f5cb8862bc4bcab13987c39b4a0d2de7",
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
					sizeBytes = 20287,
					hash = "8a9b3388704f8b012d45689017cea1a1a2dd9204045ad9c4156889919ab0fe99",
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
		["core.runtime"] = {
			name = "Core Runtime",
			description = "Enterprise app runtime, cooperative multitasking scheduler, and fiber engine.",
			hidden = true,
			dependencies = { "core.base", "core.logger", "core.peripherals", "core.ui" },
			files = {
				{
					source = "lib/core/runtime/AppRuntime.lua",
					target = "lib/core/runtime/AppRuntime.lua",
					sizeBytes = 9509,
					hash = "f97b140a74e0ec1cb345fab62fdc8608a8799dde3c97a8175f0bdd5326dc5993",
				},
				{
					source = "lib/core/runtime/Scheduler.lua",
					target = "lib/core/runtime/Scheduler.lua",
					sizeBytes = 4346,
					hash = "7f38411fb3fa656fba6bc5e1c18863ff9039647d915a03ae213b3261810b700b",
				},
				{
					source = "lib/core/runtime/Fiber.lua",
					target = "lib/core/runtime/Fiber.lua",
					sizeBytes = 1913,
					hash = "abb75a1059c25f4ae9a81cdf53cebee9a52c2a0b41a663dcb31859e8a2f54119",
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
			dependencies = {
				"core.base",
				"core.logger",
				"core.ui",
				"core.redstone",
				"core.inventory",
				"core.recipes",
				"core.ui.boot_assistant",
				"core.runtime",
			},
			files = {
				{
					source = "Create%20Mechanical%20Crafter%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 1517,
					hash = "774977ae9f99183ee5840409867c8910dfd0fc2b3e5fa247e8ba401e6442dc6e",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterSystem.lua",
					target = "system/CrafterSystem.lua",
					sizeBytes = 7718,
					hash = "6c97f8f9832b3170a20fc6a04b7e68d63b2e6bd2929f8e3e00e1a71375f0b93f",
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
					sizeBytes = 3944,
					hash = "7af088418975504c14e5aaa0e2c9ab3608eb3d36fa25135d34a49646c26be4eb",
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
					sizeBytes = 6301,
					hash = "c62383d7e149893a732f01df8651c5288f713ed934051fe5384ae06cca19d5a8",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterApp.lua",
					target = "system/CrafterApp.lua",
					sizeBytes = 2432,
					hash = "2e05485db524a773b6727ea88d2efda08868d03e897004edd6af748eacbec4dd",
				},
			},
		},
		["powah_orb"] = {
			name = "Powah Energizing Orb Automation",
			description = "Multi-orb parallel processing with AE2 pattern import support.",
			hidden = false,
			entry = "startup.lua",
			dependencies = {
				"core.base",
				"core.logger",
				"core.ui",
				"core.inventory",
				"core.recipes",
				"core.ui.boot_assistant",
				"core.runtime",
			},
			files = {
				{
					source = "Powah%20Energizing%20Orb%20Automation/startup.lua",
					target = "startup.lua",
					sizeBytes = 1598,
					hash = "974fa17b3c6a5e4a9f887966442036f09f8713df9b2ddad8ebcd28e0319b970b",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/PowahSystem.lua",
					target = "system/PowahSystem.lua",
					sizeBytes = 6510,
					hash = "85b10dd8a6856a056f45e029011e3d59b8b9cfd5e7d94b945def233721e8fc6d",
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
					sizeBytes = 3451,
					hash = "b0ba33f78119126d884661250f0dd4eea30b166224f5db654bd2a15c5b4421ed",
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
					sizeBytes = 10994,
					hash = "a844228b6e4e3bfbb48bfdb49b31c6ef8c2777f9e40c02b1e1a338ceaac7d8d3",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/PowahApp.lua",
					target = "system/PowahApp.lua",
					sizeBytes = 3189,
					hash = "a45f0f44c531a997c9e18b5e70dae45cf025496d92a29e5044bb88c6e3a1a044",
				},
			},
		},
		["mekanism_portal_hub"] = {
			name = "Mekanism Portal Dialer Hub",
			description = "Premium touch-screen frequency manager for Mekanism Teleporters.",
			hidden = false,
			entry = "startup.lua",
			dependencies = {
				"core.base",
				"core.logger",
				"core.peripherals",
				"core.network",
				"core.ui",
				"core.ui.boot_assistant",
				"core.runtime",
			},
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/startup.lua",
					target = "startup.lua",
					sizeBytes = 1541,
					hash = "26ece27e4226a56685952772f978ef41d5201c72e347fb5660bc95cdb6b32f9d",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubSystem.lua",
					target = "system/HubSystem.lua",
					sizeBytes = 23778,
					hash = "f471f3c16783613e8cb0f365dea9d7a70da253bdb57b10e0c3e0b3a1b687fdb4",
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
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubApp.lua",
					target = "system/HubApp.lua",
					sizeBytes = 8662,
					hash = "da7bb6ceb70b3de1460c61418b3df5f368e02df71c6f3004827127686b757528",
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
				"core.logger",
				"core.peripherals",
				"core.network",
				"core.redstone",
				"core.ui.boot_assistant",
				"core.runtime",
			},
			files = {
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/startup.lua",
					target = "startup.lua",
					sizeBytes = 1368,
					hash = "3ea756edc7278700cbfe362f13f0a427cc8dda7864923d31e5c6d7595158f019",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/system/RecallSenderApp.lua",
					target = "system/RecallSenderApp.lua",
					sizeBytes = 4463,
					hash = "90b465fe2d21e02c0f9dc4ce246f503453c52731477998479c435f2a6b671780",
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
			dependencies = { "core.network", "core.ui.boot_assistant", "core.runtime" },
			files = {
				{
					source = "CC%20Developer%20Suite/startup.lua",
					target = "startup.lua",
					sizeBytes = 1395,
					hash = "0f0dcdfc6541be3887c4589f47eddfc40236565e47b42c3c864601c5bd2b4d3d",
				},
				{
					source = "CC%20Developer%20Suite/system/DevSuiteApp.lua",
					target = "system/DevSuiteApp.lua",
					sizeBytes = 11388,
					hash = "9c641600a994fa469efd423e8b174ee206b215ef185049b1707696ac2d5b62dc",
				},
			},
		},
	},
}
