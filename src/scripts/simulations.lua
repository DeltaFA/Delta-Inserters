local simulations = {}

simulations.config = {
	mods = { "delta-inserters" },
	init = [[
		require("__core__/lualib/story")
		local sim = game.simulation
		local player = game.simulation.create_test_player{name = "big k"}
		player.teleport({0.5, 2.5})
		player.character.direction = defines.direction.north
		sim.camera_player = player
		sim.camera_position = {0.5, 0}
		sim.camera_zoom = 3
		sim.camera_alt_info = true
		sim.camera_player_cursor_position = player.position

		game.surfaces[1].create_entities_from_blueprint_string
		{
			string = "0eNqV0uFqhDAMB/B3yed6aL2O6auMcVQvHgGtR1PHnPTdl+vAja1sNz/VNvn9A+0G3bjg1ZML0G5A/ewY2qcNmC7Ojrc9ZyeEFnDEPnjqC3ToL2shHegH2yNEBeTO+AptFVWmk5eOgw00uy+lOj4rQBcoEH4kpp/15JapQy+WyvQruM5MaSm+MIWUraI18Rb9jdDq7+F/iDuooFuGAf2J6U2Mqty/TFS9Rw2Wg/iMXiJyAx9MSqjrg5GMM3kZLZ0/ZtzjvW75L9bcy+pfWLlACjgJ8vmGFLyg51RgHnRzbBpjKm20KWN8BxKVzKQ=",
			position = {0.5, -3.5}
		}
			
		local inserter_1 = game.surfaces[1].find_entity("fast-inserter", {-1.5, -0.5})
		local inserter_2 = game.surfaces[1].find_entity("fast-inserter", {0.5, -0.5})
		local inserter_3 = game.surfaces[1].find_entity("fast-inserter", {2.5, -0.5})

		local story_table = {{
			{
				name = "start",
				condition = function() return game.simulation.move_cursor({position = inserter_1.position}) end
			},
			{
				condition = story_elapsed_check(0.75),
				action = function() sim.control_press{control="inserter-config-direction", notify = false } end
			},
			{
				condition = story_elapsed_check(1),
				action = function() sim.control_press{control="inserter-config-direction", notify = false } end
			},
			{
				condition = story_elapsed_check(1),
				action = function() sim.control_press{control="inserter-config-direction", notify = false } end
			},
			{ condition = story_elapsed_check(1) },
			{ condition = function() return game.simulation.move_cursor({position = inserter_2.position}) end },
			{
				condition = story_elapsed_check(0.75),
				action = function() sim.control_press{control="inserter-config-lane", notify = false } end
			},
			{ 
				condition = story_elapsed_check(1),
				action = function() sim.control_press{control="inserter-config-lane", notify = false } end
			},
			{ condition = story_elapsed_check(1) },
			{ condition = function() return game.simulation.move_cursor({position = inserter_3.position}) end },
			{
				condition = story_elapsed_check(0.75),
				action = function() sim.control_press{control="inserter-config-length", notify = false } end
			},
			{
				condition = story_elapsed_check(1),
				action = function() sim.control_press{control="inserter-config-length", notify = false } end
			},
			{
				condition = story_elapsed_check(1),
				action = function() story_jump_to(storage.story, "start") end
			}
		}}

		tip_story_init(story_table)
	]]
}

simulations.direction = {
	mods = { "delta-inserters" },
	init = [[
		require("__core__/lualib/story")
		local sim = game.simulation
		local player = game.simulation.create_test_player{name = "big k"}
		player.teleport({2.5, 0.5})
		player.character.direction = defines.direction.west
		sim.camera_player = player
		sim.camera_position = {0.5, 0}
		sim.camera_zoom = 3
		sim.camera_alt_info = false
		sim.camera_player_cursor_position = player.position
		
		game.surfaces[1].create_entities_from_blueprint_string
		{
			string = "0eNqVldtugzAMht/F12FqAqGFV5kmBNR0kWhAiZnWVX33Gaq100q2hbvg+PPvg+IzNP2EozOWoDyDaQfroXw+gzcHW/fzP1sfEUogV1s/Do6SBnuCiwBj9/gOpby8CEBLhgxefZfDqbLTsUHHF8QXw9jOWDYl7St6AgHj4NltsHMcRuknLeAEpSqe9BLger3ySGTswc/XHB6HN6wmtvWEDveVITyyidyEl4t4CK9u4bHHlpxpE7ToDqeEk0bX1S0+KskWHemGVTRT16GrvPlghtzcvpVQ6T3U++jQ+6Qf6j1bgpmmkiPQabxWZ5zmwj5gsxvWT42neuE8ILdfklcIWgTaGBamuAUrpPzfpOw7ScDeOK7+Ys5WuNt4brqucBefa4BU/JuUB3OVagUsN/HkgEYp49PNAigVj9IBVBrfzpCqLB4VUqXjyx5SlcejQqruo9/VnvhV8ujo10dj+3PKdmvcXXzhtgGJRfxk5OsotYlXFULJ+B4EElQqHhVSdR99T4j9X7su3c0cXqHzGmOn+z4W8IbOLx46V0VWFFpLpZXmJ/4TcnCJdQ==",
			position = {-1.5, -3.5}
		}

		local inserter = game.surfaces[1].find_entity("fast-inserter", {-1.5, 0.5})
		local chest = game.surfaces[1].find_entity("steel-chest", {-1.5, 1.5})
		local chest_inv = chest.get_inventory(defines.inventory.chest)
		chest_inv.insert({name="iron-gear-wheel", count=200})

		local story_table = {{
			{
				name = "start",
				condition = function() return game.simulation.move_cursor({position = {-1.5, 0.5}}) end
			},
			{
				name = "click",
				condition = story_elapsed_check(0.75),
				action = function() 
					sim.control_press{control="inserter-config-direction", notify = false }
					chest_inv.clear()
					chest_inv.insert({name="iron-gear-wheel", count=200})
				end
			},
			{
				condition = story_elapsed_check(3),
				action = function() sim.control_press{control="inserter-config-direction", notify = false } end
			},
			{
				condition = story_elapsed_check(3),
				action = function() sim.control_press{control="inserter-config-direction", notify = false } end
			},
			{
				condition = story_elapsed_check(3),
				action = function() sim.control_press{control="inserter-config-direction-reverse", notify = false } end
			},
			{
				condition = story_elapsed_check(3),
				action = function() sim.control_press{control="inserter-config-direction-reverse", notify = false } end
			},
			{
				condition = story_elapsed_check(3),
				action = function() sim.control_press{control="inserter-config-direction-reverse", notify = false } end
			},
			{
				condition = story_elapsed_check(3),
				action = function() story_jump_to(storage.story, "click") end
			}
		}}

		tip_story_init(story_table)
	]]
}

simulations.lane = {
	mods = { "delta-inserters" },
	init = [[
		require("__core__/lualib/story")
		local sim = game.simulation
		local player = game.simulation.create_test_player{name = "big k"}
		player.teleport({2.5, 0.5})
		player.character.direction = defines.direction.west
		sim.camera_player = player
		sim.camera_position = {0.5, 0}
		sim.camera_zoom = 3
		sim.camera_alt_info = false
		sim.camera_player_cursor_position = player.position
		
		game.surfaces[1].create_entities_from_blueprint_string
		{
			string = "0eNqVlNtugzAMht/F16Eqh9DBq0wT4mC6SBBQYqqyinefoepBa9gGd8Hx9/92nFygaAbsjdIE6QVU2WkL6fsFrDrqvJn/6bxFSIFMrm3fGfIKbAgmAUpXeIbUn4RjOzZYklGlhxrNcfRYAE2dl/iUGUwfAlCTIoVX1WUxZnpoCzSMFjec0rXSHPLKT7QEAvrOclqnZ0lGyZ0UMDIy2clF4Lo9s0ik9NHO2wy23QmzgWMNm8EqU4Qth8gMOM1V/JAPxN/VvDiJFh/hnl0UQ12jyaz6Yoa/v38OqfAhde4NWus1XV5xZLXSkPsONPbX7vTDfCQv2OiOtUNhKV84L8jDzbKDIMXKAKwbC/gIHKT436T4mSSgUoa7v4T9wAE+bAeHbotv20mRm5RsJ0k3yd/fUXVuiUfPoqFfJ+Pwr7b5j9tlCbFZu1rRM9bFCbbXuoYKt6PiGcXvyHyXOe/xnAk4obFLhoyDJEoSKf1ABpLn/Bt/nqTr",
			position = {-1.5, -3.5}
		}

		local inserter = game.surfaces[1].find_entity("fast-inserter", {-1.5, 0.5})
		local chest = game.surfaces[1].find_entity("steel-chest", {-2.5, 0.5})
		local chest_inv = chest.get_inventory(defines.inventory.chest)
		chest_inv.insert({name="iron-gear-wheel", count=100})

		local story_table = {{
			{
				name = "start",
				condition = function() return game.simulation.move_cursor({position = {-1.5, 0.5}}) end
			},
			{
				name = "click",
				condition = story_elapsed_check(0.75),
				action = function() 
					sim.control_press{control="inserter-config-lane", notify = false }
					chest_inv.clear()
					chest_inv.insert({name="iron-gear-wheel", count=100})
				end
			},
			{
				condition = story_elapsed_check(3),
				action = function() story_jump_to(storage.story, "click") end
			}
		}}

		tip_story_init(story_table)
	]]
}

simulations.length = {
	mods = { "delta-inserters" },
	init = [[
		require("__core__/lualib/story")
		local sim = game.simulation
		local player = game.simulation.create_test_player{name = "big k"}
		player.teleport({2.5, 0.5})
		player.character.direction = defines.direction.west
		sim.camera_player = player
		sim.camera_position = {0.5, 0}
		sim.camera_zoom = 3
		sim.camera_alt_info = true
		sim.camera_player_cursor_position = player.position
		
		game.surfaces[1].create_entities_from_blueprint_string
		{
			string = "0eNqdldFugzAMRf/Fz6EqgcDgV6YJATVdJBpQYqZ1Vf99hqrtpJKtGW/B8bnXSZycoOknHK02BOUJdDsYB+XrCZzem7qf/5n6gFAC2dq4cbAUNdgTnAVos8NPKOPzmwA0pEnjJXcZHCszHRq0PEFcGdp02nAoat/REQgYB8dpg5l1GKU2SsARSlls1CJwmV45JNJm7+ZpFg/DB1YTx3pCi7tKEx44RHbC81k8yMubPPbYktVthAbt/hhx0Wi7usVHJ+niI9myi2bqOrSV01/MiLe3b0UquUt9jhadi/qh3nHEW2kSswIdx8vqjNO8sA/Y9IZ1U+OoXjgPyPxqeYWghGcb/cYkb8EKKXualP8kCdhpy6u/hGO5As7Dwcm6xZenSVmYxSIc7LEYb8OrTT2oOBylPCgZXqDPVRKO8rn6cfwJsfddHsmVk3s49yboakfc/Q4t/dqc+VPHIs6eM5j+ZfAfLZB5UC/hKJ+rf5x6D0puw1FLgfzAzJc8591fKwEfaN2SoTJZpEWhVCyVVHwBfgOLDD83",
			position = {-1.5, -3.5}
		}

		local inserter = game.surfaces[1].find_entity("fast-inserter", {-1.5, 0.5})
		local chest_1 = game.surfaces[1].find_entity("steel-chest", {-2.5, 0.5})
		local chest_2 = game.surfaces[1].find_entity("steel-chest", {-3.5, 0.5})
		local chest_1_inv = chest_1.get_inventory(defines.inventory.chest)
		local chest_2_inv = chest_2.get_inventory(defines.inventory.chest)
		chest_1_inv.insert({name="iron-gear-wheel", count=100})
		chest_2_inv.insert({name="electronic-circuit", count=100})

		local story_table = {{
			{
				name = "start",
				condition = function() return game.simulation.move_cursor({position = {-1.5, 0.5}}) end
			},
			{
				name = "click",
				condition = story_elapsed_check(0.75),
				action = function() 
					sim.control_press{control="inserter-config-length", notify = false }
					chest_1_inv.clear()
					chest_2_inv.clear()
					chest_1_inv.insert({name="iron-gear-wheel", count=100})
					chest_2_inv.insert({name="electronic-circuit", count=100})
				end
			},
			{
				condition = story_elapsed_check(3),
				action = function() story_jump_to(storage.story, "click") end
			}
		}}

		tip_story_init(story_table)
	]]
}

simulations.gui = {
	mods = { "delta-inserters" },
	init = [[
		require("__core__/lualib/story")
		local sim = game.simulation
		local player = game.simulation.create_test_player{name = "big k"}
		player.teleport({0.5, 3.5})
		player.character.direction = defines.direction.east
		sim.camera_player = player
		sim.camera_position = {0.5, 0}
		sim.camera_zoom = 2.5
		sim.camera_alt_info = true
		sim.camera_player_cursor_position = player.position
		
		game.surfaces[1].create_entities_from_blueprint_string
		{
			string = "0eNqFkdGKgzAQRf9lnmPRtCmrv7KUEu1YBjSWSSy1kn/vmIK7bIXNUzK5c86QzFB3I96YXIBqBmoG56H6nsHT1dluqTnbI1SAHTaBqcnQIV+nTDqQW9sgRAXkLviAqohqo9OPtQ820OB+RXU8KUAXKBC+jekwnd3Y18jCUhv9Cm6Dp7QVvmAyiU1CK+Oi/oPQ6v/hP4grUEE9ti3y2dNTGEW+rg3VflW11gfhe2RRfOLznUmC/XFnRHEhlsnS9dfyIhSwF8jPpyi4I/sUMEddHsrSmEIbbfIYX4Vbk7Y=",
			position = {5.5, -3.5}
		}

		local inserter = game.surfaces[1].find_entity("fast-inserter", {6.5, 0.5})

		local story_table = {{
			{
				name = "start",
				condition = function() return game.simulation.move_cursor({position = inserter.position}) end
			},
			{
				condition = story_elapsed_check(0.5),
				action = function() if not (player.opened == inserter) then player.opened = inserter end end
			},
			{
				name = "change",
				condition = story_elapsed_check(1),
				action = function() sim.control_press{control="inserter-config-direction", notify = true } end
			},
			{
				condition = story_elapsed_check(2),
				action = function() sim.control_press{control="inserter-config-length", notify = true } end
			},
			{
				condition = story_elapsed_check(2),
				action = function() sim.control_press{control="inserter-config-lane", notify = true } end
			},
			{
				condition = story_elapsed_check(2),
				action = function() story_jump_to(storage.story, "change") end
			}
		}}

		tip_story_init(story_table)

	]]
}


return simulations