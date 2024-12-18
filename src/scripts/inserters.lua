local vector = require("math2d").position

local inserters = {}

local function get_vector_direction(vector)
	local x = vector.x
	local y = vector.y

	if y < -0.2 then
		return 0
	elseif y > 0.2 then
		return 2
	elseif x > 0.2 then
		return 1
	elseif x < -0.2 then
		return 3
	end
	return 0
end

function inserters.get_state(inserter)
	local current = {}

	--get default length
	local dropoff = vector.ensure_xy(inserter.prototype.inserter_drop_position)
	dropoff.y = math.abs(((math.abs(dropoff.y) > math.abs(dropoff.x)) and dropoff.y) or dropoff.x)
	local inserter_default_length = dropoff.y or 1.2

	--get direction
	local inserter_direction = inserter.direction / 4

	--get dropoff vector and its direction
	local drop_vector = vector.subtract(inserter.position, inserter.drop_position)
	local drop_vector_direction = get_vector_direction(drop_vector)

	--check dropoff direction
	if drop_vector_direction == inserter_direction then
		current.direction = "straight"
	elseif (drop_vector_direction - inserter_direction == 1) or (drop_vector_direction - inserter_direction == -3) then
		current.direction = "right"
	else
		current.direction = "left"
	end

	local length = vector.distance(inserter.position, inserter.drop_position)

	--round to 2 points
	length = (math.floor(length * 100 + 0.5) / 100)


	--handle long inserters
	if inserter_default_length > 2 then
		inserter_default_length = inserter_default_length - 1
	end

	--handle special... case.
	local slim = false
	if inserter_default_length < 0.7 or (inserter_default_length > 1.3 and inserter_default_length < 1.4) then
		slim = true
	end

	--check length and substract it for checking target lane
	inserter_reach = math.floor(inserter_default_length)
	if length > inserter_default_length + 0.6 then
		current.length = "long"
		length = length - inserter_reach - 1
	else
		current.length = "short"
		length = length - inserter_reach
	end

	if length > ((slim and 0.45) or 0) then
		current.lane = "far"
	else
		current.lane = "close"
	end

	return current
end

local function changed_settings_notification(inserter, configuring_player_index, text)
	for _, player in pairs(inserter.force.players) do
		if player.index == configuring_player_index then
			if player.opened ~= inserter then
				player.create_local_flying_text{
					text = { "inserter-config."..text },
					create_at_cursor = true
				}
			end
			player.play_sound{
				path = "utility/wire_connect_pole",
				position = inserter.position
			}
		elseif player.surface == inserter.surface then
			player.create_local_flying_text{
				text = { "inserter-config."..text },
				position = inserter.position
			}
			player.play_sound{
				path = "utility/wire_connect_pole",
				position = inserter.position
			}
		end
	end
end

local function blacklist_notification(inserter, player_index, text)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	player.create_local_flying_text{
		text = { "inserter-config."..text },
		create_at_cursor = true
	}
	player.play_sound{
		path = "utility/cannot_build",
		position = inserter.position
	}
end

function inserters.set_state(inserter, values, player_index)
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end
	if not (player.force == inserter.force) then return end

	--default vectors
	local pickup = vector.ensure_xy(inserter.prototype.inserter_pickup_position)
	local dropoff = vector.ensure_xy(inserter.prototype.inserter_drop_position)

	--normalize pickup/dropoff vectors 
	pickup.y = ((math.abs(pickup.y) > math.abs(pickup.x)) and pickup.y) or pickup.x
	dropoff.y = math.abs(((math.abs(dropoff.y) > math.abs(dropoff.x)) and dropoff.y) or dropoff.x)
	pickup.x = 0 
	dropoff.x = 0

	--check current state
	local current_state = inserters.get_state(inserter)
	local changed = {}

	--handle long inserters
	if dropoff.y > 1.8 then
		dropoff = vector.subtract(dropoff, { x = 0, y = 1 })
		pickup = vector.subtract(pickup, { x = 0, y = -1 })
	end

	--fill all values
	values.lane = values.lane or current_state.lane
	values.length = values.length or current_state.length
	values.direction = values.direction or current_state.direction

	--check what's changed
	changed.length = (values.length ~= current_state.length)
	changed.lane = (values.lane ~= current_state.lane)
	changed.direction = (values.direction ~= current_state.direction)

	--check if changing's allowed for the inserter
	if changed.length then
		if storage.inserter_config_blacklist_length[inserter.name] then
			blacklist_notification(inserter, player_index, "blacklist-length")
			values.length = current_state.length
			changed.length = false
		end
	end
	if changed.direction then
		if storage.inserter_config_blacklist_direction[inserter.name] then
			blacklist_notification(inserter, player_index, "blacklist-direction")
			values.direction = current_state.direction
			changed.direction = false
		end
	end

	--checking if a value is changed and applying it 
	if changed.length then
		changed_settings_notification(inserter, player_index, "changed-length")
	end
	if values.length == "long" then
		pickup = vector.add(pickup, { x = 0, y = -1 })
		dropoff = vector.add(dropoff, { x = 0, y = 1 })
	end

	if changed.lane then
	changed_settings_notification(inserter, player_index, "changed-lane")
	end
	if values.lane == "close" then
		dropoff = vector.add(dropoff, { x = 0, y = -0.30 })
	end

	if changed.direction then
		changed_settings_notification(inserter, player_index, "changed-direction")
	end
	if values.direction ~= "straight" then
		rotation = (values.direction == "right" and 90) or -90
		dropoff = vector.rotate_vector(dropoff, rotation)
	end

	--rotate vecors to match inserter's direction before applying them
	inserter.pickup_position = vector.add(inserter.position, vector.rotate_vector(pickup, (inserter.direction / 4 * 90)))
	inserter.drop_position = vector.add(inserter.position, vector.rotate_vector(dropoff, (inserter.direction / 4 * 90)))
end

return inserters