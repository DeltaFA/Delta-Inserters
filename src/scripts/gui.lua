local inserters = require("scripts.inserters")

local gui_scripts = {}

function gui_scripts.create_gui(player_index)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if not player.mod_settings["inserter-config-gui-enabled"].value then return end
	local gui = player.gui.relative.add {
		type = "frame",
		name = "inserter_config",
		caption = { "inserter-config.title" },
		anchor = {
			gui = defines.relative_gui_type.inserter_gui,
			position = defines.relative_gui_position.right
		}
	}
	gui.add {
		type = "frame",
		name = "inserter_switches",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}
	gui.inserter_switches.add {
		type = "switch",
		name = "inserter_direction",
		tooltip = { "inserter-config.inserter-direction" },
		allow_none_state = true,
		switch_state = "none",
		left_label_caption = { "inserter-config.left" },
		right_label_caption = { "inserter-config.right" }
	}
	gui.inserter_switches.add {
		type = "switch",
		name = "inserter_length",
		tooltip = { "inserter-config.inserter-length" },
		switch_state = "left",
		left_label_caption = { "inserter-config.short" },
		right_label_caption = { "inserter-config.long" }
	}
	gui.inserter_switches.add {
		type = "switch",
		name = "inserter_lane",
		tooltip = { "inserter-config.inserter-lane" },
		switch_state = "left",
		left_label_caption = { "inserter-config.far" },
		right_label_caption = { "inserter-config.close" }
	}

	return gui
end

local function translate_state_to_gui(current)
	current.direction = (current.direction == "straight" and "none") or (current.direction == "right" and "right") or "left"
	current.length = (current.length == "long" and "right") or "left"
	current.lane = (current.lane == "close" and "right") or "left"

	return current
end

function gui_scripts.update_gui(player_index, inserter)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if not player.mod_settings["inserter-config-gui-enabled"].value then
		if player.gui.relative.inserter_config then player.gui.relative.inserter_config.destroy() end
	end

	gui = player.gui.relative.inserter_config or gui_scripts.create_gui(player_index)
	if gui and gui.valid then
		local current = translate_state_to_gui(inserters.get_state(inserter))
		gui.inserter_switches.inserter_direction.switch_state = current.direction
		gui.inserter_switches.inserter_length.switch_state = current.length
		gui.inserter_switches.inserter_lane.switch_state = current.lane
	end
end

function gui_scripts.update_all_guis(inserter)
	for _, player in pairs(game.players) do
		if player.opened_gui_type == defines.gui_type.entity then
			local opened = player.opened
			if opened and opened == inserter then
				gui_scripts.update_gui(player.index, inserter)
			end
		end
	end
end

return gui_scripts