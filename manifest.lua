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
					sizeBytes = 7356,
					hash = "5e5cdb18e77b264f1b1ea3acbc07a9e488d4b4b8466ef20ebf319db1c5f84bc5",
				},
				{
					source = "lib/core/ui/FrameRenderer.lua",
					target = "lib/core/ui/FrameRenderer.lua",
					sizeBytes = 13897,
					hash = "6eec3dbf9b4690931384395a2599806472b9b4a59f9fc98119d621f919aa237d",
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
					sizeBytes = 12054,
					hash = "694a82c6cd46d2b2fc76c7ecbb985b1f378e86b174c97af05deb941252038c90",
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
				{
					source = "lib/core/runtime/HotReloader.lua",
					target = "lib/core/runtime/HotReloader.lua",
					sizeBytes = 2735,
					hash = "e7ce98305ca2bf1146f1264cdeb8422bcfd2c0bb975a919f11e7320dbddd3471",
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
					hash = "944966c531943c316d98b60eb5ff07f58ba1248397f20d283b3332d40328b581",
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
					hash = "a3025577f3380acad0a9559602056e29228ec96c5dcce0b144611ac879a09550",
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
					hash = "db176601d2bfa3cb384fa0583f700358dd067c07a95bee57fa075ba0fc2fbd90",
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
					sizeBytes = 1715,
					hash = "0da4ec2315079828e5f804ab86e03c7aa7e82e86cc2772f5d96f08a6908ac264",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubSystem.lua",
					target = "system/HubSystem.lua",
					sizeBytes = 24834,
					hash = "904a95084dc31a491ecdd04f74a0304b7a72bce981d111274cc6f03bc9522a37",
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
					sizeBytes = 6996,
					hash = "20b9467ebe2e4508e5488b3d0f8957746436eff5bd0cdc12f310fd9fdf558699",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Hub/system/HubApp.lua",
					target = "system/HubApp.lua",
					sizeBytes = 9592,
					hash = "72a9f530042f3f880822ddbde6d3ea607e34bd13c55af3b6d278706dac9e554f",
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
					hash = "5c6fb9f14eeacafcf7258f0f4fd707c9967deb4f6e8e2b56a97f7d90576e8d6d",
				},
				{
					source = "Mekanism%20Portal%20Dialer%20Recall%20Sender/system/RecallSenderApp.lua",
					target = "system/RecallSenderApp.lua",
					sizeBytes = 4463,
					hash = "0770e03b43a709836f8fcbd905855a1f0ac716ea32f5b3cce813bd49c4eeec49",
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
					hash = "ca52a6070b2798189e625884545655a517900892eb30261e198fbca720f85b87",
				},
				{
					source = "CC%20Developer%20Suite/system/DevSuiteApp.lua",
					target = "system/DevSuiteApp.lua",
					sizeBytes = 11388,
					hash = "138e3f29a0f73e74c1cf97f797b9998fea0aaedfd6dd57bd4086545e36222eb0",
				},
			},
		},
	},
}
