local inserter_scripts = require("scripts.inserters")
local gui_scripts = require("scripts.gui")
local pipette = require("scripts.smart_pipette")

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
			"basic-double-slim-inserter_part",
			"long-double-slim-inserter_part",
			"fast-double-slim-inserter_part",
			"stack-double-slim-inserter_part",
			"basic-loader-slim-inserter",
			"fast-loader-slim-inserter",
			"fast2-loader-slim-inserter",
		}
		local slim_loaders = {
			"basic-loader-slim-inserter",
			"fast-loader-slim-inserter",
			"fast2-loader-slim-inserter",
		}
		for _, inserter in pairs(slim_inserters)  do
			storage.inserter_config_blacklist_direction[inserter] = true
		end
		for _, inserter in pairs(slim_loaders)  do
			storage.inserter_config_blacklist_direction[inserter] = true
			storage.inserter_config_blacklist_length[inserter] = true
		end
	end

	if script.active_mods["delta"] then
		storage.inserter_config_blacklist_direction["burner-inserter"] = true
		storage.inserter_config_blacklist_length["burner-inserter"] = nil
	end
end

script.on_init(function ()
	storage.inserter_config_blacklist_length = {}
	storage.inserter_config_blacklist_direction = {}
	storage.inserter_player_pipette_config = {}
	check_blacklists()
end)

script.on_event("on_runtime_mod_setting_changed", function()
	check_blacklists()
end)

script.on_configuration_changed(function()
	check_blacklists()
end)

local function change_settings(player_index, switch_name)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if player.opened_gui_type == defines.gui_type.entity then
		local entity = player.opened
		if inserter_scripts.is_inserter(entity) then
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

				inserter_scripts.set_state(entity, values, player_index)
				gui_scripts.update_all_guis(entity)
			end
		end
	end
end

script.on_event(defines.events.on_gui_opened, function(event)
	if inserter_scripts.is_inserter(event.entity) then
		gui_scripts.update_gui(event.player_index, event.entity)
	end
end)

script.on_event(defines.events.on_gui_switch_state_changed, function(event)
	if event.element.parent.name == "inserter_switches" then
		change_settings(event.player_index, event.element.name)
	end
end)

local function quick_change_settings(player_index, inserter, operation)
	local values = inserter_scripts.get_state(inserter)

	if operation == "direction" then
		values.direction = (values.direction == "straight") and "right" or (values.direction == "right") and "left" or "straight"
	elseif operation == "direction-reverse" then
		values.direction = (values.direction == "straight") and "left" or (values.direction == "left") and "right" or "straight"
	elseif operation == "lane" then
		values.lane = (values.lane == "far") and "close" or "far"
	elseif operation == "length" then
		values.length = (values.length == "short") and "long" or "short"
	end

	inserter_scripts.set_state(inserter, values, player_index)
	gui_scripts.update_all_guis(inserter)
end

local function keybind_detected(event, operation)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	local inserter = player.selected
	if not inserter_scripts.is_inserter(inserter) then return end

	quick_change_settings(event.player_index, inserter, operation)
end

script.on_event("inserter-config-direction", function(event)
	keybind_detected(event, "direction")
end)

script.on_event("inserter-config-direction-reverse", function(event)
	keybind_detected(event, "direction-reverse")
end)

script.on_event("inserter-config-lane", function(event)
	keybind_detected(event, "lane")
end)

script.on_event("inserter-config-length", function(event)
	keybind_detected(event, "length")
end)

script.on_event(defines.events.on_player_pipette, function(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	if not player.selected then return end
	if inserter_scripts.is_inserter(player.selected) then
		pipette.save_pipette(event.player_index, player.selected)
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function (event)
	pipette.check_cursor_change(event.player_index)
end)

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	if inserter_scripts.is_inserter(event.entity) then
		pipette.apply_pipette(event.player_index, event.entity)
	end
end)