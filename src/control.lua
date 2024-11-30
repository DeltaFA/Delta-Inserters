local inserter_scripts = require("scripts.inserters")
local gui_scripts = require("scripts.gui")

local function get_setting(name)
	if settings.global[name] == nil then return nil end
	return settings.global[name].value
end

local function check_blacklists()
	--clear previous blacklist
	storage.inserter_config_blacklist_length = {}
	storage.inserter_config_blacklist_direction = {}

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

	if script.active_mods["Kux-SlimInserters"] then
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
end

script.on_init(function ()
	storage.inserter_config_blacklist_length = {}
	storage.inserter_config_blacklist_direction = {}
	check_blacklists()
end)

script.on_event("on_runtime_mod_setting_changed", function()
	check_blacklists()
end)

local function change_settings(player_index, switch_name)
	local player = game.get_player(player_index)
	if player.opened_gui_type == defines.gui_type.entity then
		local entity = player.opened
		if entity and entity.valid and entity.type == "inserter" then
			local gui = player.gui.relative.inserter_config
			if gui and gui.valid then
				local values = {}

				local state = gui.inserter_switches[switch_name].switch_state
				if switch_name == "inserter_length" then
					values.length = (state == "right" and "long") or "short"
				elseif switch_name == "inserter_lane" then
					values.lane = (state == "right" and "close") or "far"
				elseif switch_name == "inserter_direction" then
					values.direction = (state == "none" and "straight") or (state == "right" and "right") or "left"
				end

				inserter_scripts.set_state(entity, values, player)
				gui_scripts.update_all_guis(entity)
			end
		end
	end
end

script.on_event(defines.events.on_gui_opened, function(event)
	local player = game.get_player(event.player_index)
	if not player or not event.entity then return end
	local entity = event.entity
	if not entity.valid then return end
	if entity.type == "inserter" then
		gui_scripts.update_gui(player, entity)
	end
end)

script.on_event(defines.events.on_gui_switch_state_changed, function(event)
	if event.element.parent.name == "inserter_switches" then
		change_settings(event.player_index, event.element.name)
	end
end)

local function quick_change_settings(player, inserter, operation)
	local values = inserter_scripts.get_state(inserter)

	if operation == "direction" then
		values.direction = (values.direction == "straight") and "right" or (values.direction == "right") and "left" or "straight"
	elseif operation == "lane" then
		values.lane = (values.lane == "far") and "close" or "far"
	elseif operation == "length" then
		values.length = (values.length == "short") and "long" or "short"
	end

	inserter_scripts.set_state(inserter, values, player)
	gui_scripts.update_all_guis(inserter)
end

local function keybind_detected(event, operation)
	local player = game.get_player(event.player_index)
	if not player then return end
	local inserter = player.selected
	if not inserter then return end
	if inserter.type ~= "inserter" then return end

	quick_change_settings(player, inserter, operation)
end

script.on_event("inserter-config-direction", function(event)
	keybind_detected(event, "direction")
end)

script.on_event("inserter-config-lane", function(event)
	keybind_detected(event, "lane")
end)

script.on_event("inserter-config-length", function(event)
	keybind_detected(event, "length")
end)