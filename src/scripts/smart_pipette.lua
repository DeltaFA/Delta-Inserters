local inserter_scripts = require("scripts.inserters")

local pipette = {}

local function check_if_pipette_enabled(player_index)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return false end
	if game.simulation then return true end --changing settings in simulations doesn't work.
	return player.mod_settings["inserter-config-smart-pipette-enabled"].value
end

function pipette.save_pipette(player_index, inserter)
	if check_if_pipette_enabled(player_index) then
		storage.inserter_player_pipette_config[player_index] = {
			settings = inserter_scripts.get_state(inserter),
			expected_inserter = ((inserter.type == "entity-ghost" and inserter.ghost_name) or inserter.name) }
	end
end

function pipette.check_cursor_change(player_index)
	if not check_if_pipette_enabled(player_index) then return end

	local player = game.get_player(player_index)
	if not (player and player.valid) then return false end

	local data = storage.inserter_player_pipette_config[player_index]
	if not data then return end
	if not (player.cursor_stack and
		player.cursor_stack.count ~= 0 and
		player.cursor_stack.prototype and
		player.cursor_stack.prototype.place_result and
		player.cursor_stack.prototype.place_result.name == data.expected_inserter)
	then
		storage.inserter_player_pipette_config[player_index] = nil
	end
end

function pipette.apply_pipette(player_index, inserter)
	local player = check_if_pipette_enabled(player_index)
	if (player) then
		local data = storage.inserter_player_pipette_config[player_index]
		if not data then return end
		if not (((inserter.type == "entity-ghost" and inserter.ghost_name) or inserter.name) == data.expected_inserter) then
			storage.inserter_player_pipette_config[player_index] = nil
			return
		end
		inserter_scripts.set_state(inserter, storage.inserter_player_pipette_config[player_index].settings, player_index, true)
	end
end

return pipette