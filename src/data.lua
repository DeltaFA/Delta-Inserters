local simulations = require("scripts.simulations")

data:extend({
	--Keybinds
	{
		type = "custom-input",
		name = "inserter-config-direction",
		key_sequence = "CONTROL + R",
		action = "lua"
	},
	{
		type = "custom-input",
		name = "inserter-config-direction-reverse",
		key_sequence = "CONTROL + SHIFT + R",
		action = "lua"
	},
	{
		type = "custom-input",
		name = "inserter-config-length",
		key_sequence = "L",
		action = "lua"
	},
	{
		type = "custom-input",
		name = "inserter-config-lane",
		key_sequence = "SHIFT + L",
		action = "lua"
	},

	--Tips and Tricks
	{
		type = "tips-and-tricks-item-category",
		name = "delta-inserter-config",
		order = "--d[delta]-b[inserters]"
	},
	{
		type = "tips-and-tricks-item",
		name = "delta-inserter-config",
		category = "delta-inserter-config",
		order = "a",
		tag = "[entity=fast-inserter]",
		is_title = true,
		trigger =
		{
			type = "build-entity",
			entity = "inserter",
			match_type_only = true
		},
		simulation = simulations.config
	},
	{
		type = "tips-and-tricks-item",
		name = "delta-inserter-direction",
		category = "delta-inserter-config",
		order = "b-a",
		indent = 1,
		dependencies = { "delta-inserter-config" },
		simulation = simulations.direction
	},
	{
		type = "tips-and-tricks-item",
		name = "delta-inserter-length",
		category = "delta-inserter-config",
		order = "b-b",
		indent = 1,
		dependencies = { "delta-inserter-config" },
		simulation = simulations.length
	},
	{
		type = "tips-and-tricks-item",
		name = "delta-inserter-lane",
		category = "delta-inserter-config",
		order = "b-c",
		indent = 1,
		dependencies = { "delta-inserter-config" },
		simulation = simulations.lane
	},
	{
		type = "tips-and-tricks-item",
		name = "delta-inserter-gui",
		category = "delta-inserter-config",
		order = "c",
		indent = 1,
		dependencies = { "delta-inserter-config" },
		simulation = simulations.gui
	}
})