local vector = require("math2d").position

local function create_gui(player)
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
		right_label_caption = { "inserter-config.right" },
		actions = {
			on_switch_state_changed = { gui = "inserter", action = "change_inserter_setting" },
		}
	}
	gui.inserter_switches.add {
		type = "switch",
		name = "inserter_lenght",
		tooltip = { "inserter-config.inserter-lenght" },
		switch_state = "left",
		left_label_caption = { "inserter-config.short" },
		right_label_caption = { "inserter-config.long" },
		actions = {
			on_switch_state_changed = { gui = "inserter", action = "change_inserter_setting" },
		}
	}
	gui.inserter_switches.add {
		type = "switch",
		name = "inserter_lane",
		tooltip = { "inserter-config.inserter-lane" },
		switch_state = "left",
		left_label_caption = { "inserter-config.far" },
		right_label_caption = { "inserter-config.close" },
		actions = {
			on_switch_state_changed = { gui = "inserter", action = "change_inserter_setting" },
		}
	}

	return gui
end
local function change_inserter_settings(inserter, values)
	local pickup = { x = 0, y = -1 }
	local dropoff = { x = 0, y = 1.20 }

	values.direction = values.direction or "none"
	values.lenght = values.lenght or "left"
	values.lane = values.lane or "left"

	if values.lenght == "right" or values.lenght == "long" then
		pickup = vector.add(pickup, { x = 0, y = -1 })
	end
	inserter.pickup_position = vector.add(inserter.position, vector.rotate_vector(pickup, (inserter.direction / 4 * 90)))

	if values.lenght == "right" or values.lenght == "long" then
		dropoff = vector.add(dropoff, { x = 0, y = 1 })
	end

	if values.lane == "right" or values.lane == "close" then
		dropoff = vector.add(dropoff, { x = 0, y = -0.30 })
	end

	if values.direction ~= "none" then
		rotation = (values.direction == "right" and 90) or -90
		dropoff = vector.rotate_vector(dropoff, rotation)
	end

	inserter.drop_position = vector.add(inserter.position, vector.rotate_vector(dropoff, (inserter.direction / 4 * 90)))

	inserter.surface.play_sound{ path = "utility/wire_connect_pole" }
end

local function get_vector_direction(vector)
	local x = vector.x
	local y = vector.y

	if y < 0 then
		return 0
	elseif y > 0 then
		return 2
	elseif x > 0 then
		return 1
	elseif x < 0 then
		return 3
	end
end

local function get_inserter_state(inserter)
	local current = {}

	local inserter_direction = inserter.direction / 4

	local drop_vector = vector.subtract(inserter.position, inserter.drop_position)
	local drop_vector_direction = get_vector_direction(drop_vector)

	if drop_vector_direction == inserter_direction then
		current.direction = "none"
	elseif (drop_vector_direction - inserter_direction == 1) or (drop_vector_direction - inserter_direction == -3) then
		current.direction = "right"
	else
		current.direction = "left"
	end

	local lenght = vector.distance(inserter.position, inserter.drop_position)
	if lenght > 1.8 then
		current.lenght = "right"
		lenght = lenght - 2
	else
		current.lenght = "left"
		lenght = lenght - 1
	end

	if lenght > 0 then
		current.lane = "left"
	else
		current.lane = "right"
	end

	return current
end

local function update_gui(player, inserter)
	gui = player.gui.relative.inserter_config or create_gui(player)
	if gui and gui.valid then
		local current = get_inserter_state(inserter)
		gui.inserter_switches.inserter_direction.switch_state = current.direction
		gui.inserter_switches.inserter_lenght.switch_state = current.lenght
		gui.inserter_switches.inserter_lane.switch_state = current.lane
	end
end

local function update_all_guis(inserter)
	for player_index in pairs(game.players) do
		local player = game.get_player(player_index)
		if player.opened_gui_type == defines.gui_type.entity then
			local opened = player.opened
			if opened and opened == inserter then
				update_gui(player, inserter)
			end
		end
	end
end

local function change_settings(player_index)
	local player = game.get_player(player_index)
	if player.opened_gui_type == defines.gui_type.entity then
		local entity = player.opened
		if entity and entity.valid and entity.type == "inserter" then
			local gui = player.gui.relative.inserter_config
			if gui and gui.valid then
				local values = {}
				values.direction = gui.inserter_switches.inserter_direction.switch_state
				values.lenght = gui.inserter_switches.inserter_lenght.switch_state
				values.lane = gui.inserter_switches.inserter_lane.switch_state

				change_inserter_settings(entity, values)

				update_all_guis(entity)
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
		update_gui(player, entity)
	end
end)

script.on_event(defines.events.on_gui_switch_state_changed, function(event)
	if event.element.parent.name == "inserter_switches" then
		change_settings(event.player_index)
	end
end)

local function notification(player, text)
	player.create_local_flying_text{
		text = { "inserter-config."..text },
		create_at_cursor = true
	}
end

local function quick_change_settings(player, inserter, operation)
	local values = get_inserter_state(inserter)

	if operation == 0 then
		values.direction = (values.direction == "none") and "right" or (values.direction == "right") and "left" or "none"
		notification(player, "changed-direction")
	elseif operation == 1 then
		values.lane = (values.lane == "right") and "left" or "right"
		notification(player, "changed-lane")
	else
		values.lenght = (values.lenght == "right") and "left" or "right"
		notification(player, "changed-lenght")
	end

	change_inserter_settings(inserter, values)

	update_all_guis(inserter)
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
	keybind_detected(event, 0)
end)

script.on_event("inserter-config-lane", function(event)
	keybind_detected(event, 1)
end)

script.on_event("inserter-config-lenght", function(event)
	keybind_detected(event, 2)
end)