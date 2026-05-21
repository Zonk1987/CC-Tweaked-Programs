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
					sizeBytes = 11425,
					hash = "e908dd273c0be870c427d08d1f737414573230387bc1ccd3c8422a07dd667fc7",
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
					sizeBytes = 21487,
					hash = "0ef808d52ba53b5a74ec7d35a73bf0b41adbe602cc28c782b82964bee714efc5",
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
					sizeBytes = 2274,
					hash = "6773ab1aa80556d76a94f55fd3fa8637dc2115fe4f68612e115339c834614e58",
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
					sizeBytes = 9668,
					hash = "3f34ab7374d58781455db277e390a6435e19c0544f26228874cc9bdeec7edf61",
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
					hash = "ee591c3c1d5f04573850962c5b59490238461dd2e7acb261de152ba89df14dc6",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterSystem.lua",
					target = "system/CrafterSystem.lua",
					sizeBytes = 7863,
					hash = "226a69dec19eeb1710f4d915ade2cda022566434acf7a1115f957e3643b8d06f",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/RecipeManager.lua",
					target = "system/RecipeManager.lua",
					sizeBytes = 9322,
					hash = "9486fced1deb0b0ee7d95e017510584d5658e96d6730c6b0159d33446c6996fa",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/ui/Dashboard.lua",
					target = "ui/Dashboard.lua",
					sizeBytes = 3944,
					hash = "e8121af14c8689eeeff2339fe7e30de305818c2ab9e3c003e519e6b37b067135",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/Chest.lua",
					target = "system/Chest.lua",
					sizeBytes = 4113,
					hash = "b935f88c04cffbd589dea2cdcbb3eab31ff4baf24d2a9003e4e81e640813e65f",
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
					hash = "8bb2c52d739b05cfc9e6613e5e38da36e100005965c19dce290d64e511e55bf9",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/PowahSystem.lua",
					target = "system/PowahSystem.lua",
					sizeBytes = 7053,
					hash = "3406b6d6e872830321ef550788af7957f61bdfb822bec0cb655f553296748b61",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/RecipeManager.lua",
					target = "system/RecipeManager.lua",
					sizeBytes = 4064,
					hash = "5692a784ddf467e482be9dd8d173ab071ed79f502ed2190aa5fbcc4618b965d8",
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
					sizeBytes = 2428,
					hash = "a664ea7ca92add0fc5c9f21d9c347562ca4124ae916e395ac231471c91d12558",
				},
				{
					source = "Powah%20Energizing%20Orb%20Automation/system/Chest.lua",
					target = "system/Chest.lua",
					sizeBytes = 2785,
					hash = "63b93fd710561a54226aca5645076421bcf207a8169089b20983fb231b6484bf",
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
					hash = "82cc497d90e0b1ce4b8f02df9e26fbee51e11187d40fa6ec0f6d4fb122898e65",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubSystem.lua",
					target = "system/HubSystem.lua",
					sizeBytes = 23778,
					hash = "b43871f98fd74654eac9de2b68e90bf461eb11dfa5217a6eaf9e37ed8f965425",
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
					hash = "149f1d014117123a8feed2e3cc439c344b600dc40568c5e4cc7f17f940e7cd36",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/system/RecallSenderApp.lua",
					target = "system/RecallSenderApp.lua",
					sizeBytes = 4463,
					hash = "de78ba74983f8e9d8317869c4e45f8a586d92ac2bb5ae1ae880c982b48cdf4a0",
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
					hash = "5cee98836c49145c66bd0ec090976b7b01637519cb3660cc5ee619f5b6cb525a",
				},
				{
					source = "CC%20Developer%20Suite/system/DevSuiteApp.lua",
					target = "system/DevSuiteApp.lua",
					sizeBytes = 11388,
					hash = "1f16e62a8621444b7db9538652013a81a303dacd517f130ab6807dbe89dab595",
				},
			},
		},
	},
}
