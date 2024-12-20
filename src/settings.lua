data:extend({
	--Startup settings
	{
		type = "bool-setting",
		name = "inserter-config-remove-long-inserters",
		order = "a-a",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "inserter-config-allow-all-long-inserters",
		order = "a-b",
		setting_type = "startup",
		default_value = true,
	},

	--Map settings
	{
		type = "string-setting",
		name = "inserter-config-length-blacklist",
		order = "a-a",
		setting_type = "runtime-global",
		default_value = (mods["delta"] and "") or "burner-inserter",
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "inserter-config-direction-blacklist",
		order = "a-b",
		setting_type = "runtime-global",
		default_value = (mods["delta"] and "") or "burner-inserter",
		allow_blank = true,
	},

	--Per player settings
	{
		type = "bool-setting",
		name = "inserter-config-smart-pipette-enabled",
		order = "a-a",
		setting_type = "runtime-per-user",
		default_value = false,
	},
	{
		type = "bool-setting",
		name = "inserter-config-gui-enabled",
		order = "b-a",
		setting_type = "runtime-per-user",
		default_value = true,
	},
})