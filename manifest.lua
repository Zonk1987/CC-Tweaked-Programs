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
					sizeBytes = 4627,
					hash = "1ffd1fafc02c6c665aeedf4f8e660538dee77433ac52af1180259561032898c7",
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
					sizeBytes = 15287,
					hash = "f4fcad9277d6267aa316b7b01771a9650fc70b13a6ebb09ed929d60f9bb7a82f",
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
					sizeBytes = 21733,
					hash = "6c5570813349e3580e638d2ccd33f09d2ba86093ee99eae7f4c3c646d9790879",
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
					sizeBytes = 11336,
					hash = "153f75b6fd2abe62293010f4fb9593f974172d2adbdbdb55cf18d8e889e645db",
				},
				{
					source = "lib/core/runtime/Scheduler.lua",
					target = "lib/core/runtime/Scheduler.lua",
					sizeBytes = 5698,
					hash = "1c71feab3d023525676debf663dc9926e24feab58d1d223894d3fcebb27d570f",
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
					sizeBytes = 1910,
					hash = "3872f8795cb143b47e2764a34312199e4f423ca5f80bcd6cfc7642424a7c454d",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterSystem.lua",
					target = "system/CrafterSystem.lua",
					sizeBytes = 8051,
					hash = "645f69ff95b1d07d03658a29bef48a4128b8b06f03fe0e1fb0be7a1ca1126379",
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
					hash = "768a374a8c481b6030c38b644f516849e3adfa420af3790a75f44931fba545b2",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/Chest.lua",
					target = "system/Chest.lua",
					sizeBytes = 5982,
					hash = "d5423ea655e36093031067a03cb61c58f40930d362b6a2079e97f63e39fc6107",
				},
				{
					source = "Create%20Mechanical%20Crafter%20Automation/system/CrafterGrid.lua",
					target = "system/CrafterGrid.lua",
					sizeBytes = 4343,
					hash = "ae712b0a874d477d1324a4374b34129b5be04aebee8b7c163efadcf549df5606",
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
					hash = "8887443b0598f478fb542016c25f75fcd36805ace5e484d474c2b16fd480663d",
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
					hash = "c40ed67481517107e09b95bfdb9b2b2daa55070be8f4e5a3f7f42b168073756c",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubSystem.lua",
					target = "system/HubSystem.lua",
					sizeBytes = 23778,
					hash = "7579d2f9ecf1137d9319b5db367d60adaaf430a93c03b0ca136dd3604f0feedb",
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
					hash = "a8d4d00ed0c9b9aedda7b89abc8a49c7cb2a489550b565ea0e89c7736a8ed0be",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/system/RecallSenderApp.lua",
					target = "system/RecallSenderApp.lua",
					sizeBytes = 4463,
					hash = "9e3263d121440967d12de5afaf44941ae34cb61aa02c21ad4b8b072a52efdde2",
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
					hash = "a11a8207e7dfdf10aed48a8712f8e57eb6aa28fbeab016b49a164538a21e10d0",
				},
				{
					source = "CC%20Developer%20Suite/system/DevSuiteApp.lua",
					target = "system/DevSuiteApp.lua",
					sizeBytes = 11388,
					hash = "b302d6161a48a772ac43499da52304ccfe30d152f002b47778c90efe8c1a294a",
				},
			},
		},
	},
}
