local function get_setting(name)
	if settings.global[name] == nil then return nil end
	return settings.global[name].value
end

local function check_blacklists()
	local length_blacklist = get_setting("inserter-config-length-blacklist") 
	local direction_blacklist = get_setting("inserter-config-direction-blacklist")
	if length_blacklist then 
		for inserter in string.gmatch(length_blacklist, '[^",%s]+') do
			storage.inserter_config_blacklist_length[inserter] = true
		end
	end
	if direction_blacklist then 
		for inserter in string.gmatch(direction_blacklist, '[^",%s]+') do
			storage.inserter_config_blacklist_direction[inserter] = true
		end
	end
end

--setup blacklists
storage.inserter_config_blacklist_length = {}
storage.inserter_config_blacklist_direction = {}
check_blacklists()

--destroy previous guis
for _, player in pairs(game.players) do
	if player.gui.relative.inserter_config then
		player.gui.relative.inserter_config.destroy()
	end
end

if mods["Kux-SlimInserters"] then
	local slim_inserters = {
		"basic-slim-inserter",
		"long-slim-inserter",
		"fast-slim-inserter",
		"stack-slim-inserter",
		"basic-double-slim-inserter",
		"long-double-slim-inserter",
		"fast-double-slim-inserter",
		"stack-double-slim-inserter",
	}
	for _, inserter in pairs(slim_inserters)  do
		storage.inserter_config_blacklist_direction[inserter] = true
	end
end