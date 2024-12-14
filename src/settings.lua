data:extend({
	{
		type = "bool-setting",
		name = "inserter-config-remove-long-inserters",
		order = "a-a",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "inserter-config-gui-enabled",
		order = "a-a",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "string-setting",
		name = "inserter-config-length-blacklist",
		order = "b-a",
		setting_type = "runtime-global",
		default_value = (mods["delta"] and "") or "burner-inserter",
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "inserter-config-direction-blacklist",
		order = "b-b",
		setting_type = "runtime-global",
		default_value = (mods["delta"] and "") or "burner-inserter",
		allow_blank = true,
	}
})