extends Node

func load_game():
	if not FileAccess.file_exists("user://save_profile.tsis"):
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open("user://save_profile.tsis", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.data

		GameManager.font_index = node_data["font_index"]
		ProfileManager.is_tutorial_finished = node_data["is_tutorial_finished"]

		ProfileManager.total_coins = node_data["total_coins"]
		ProfileManager.unlocked_codes.assign(node_data.get("unlocked_players", []))
		ProfileManager.unlocked_achs.assign(node_data.get("unlocked_achs", []))
		
		ProfileManager.player_code = node_data["equipped_player"]
		
		ProfileManager.normal_result_data.best_score = node_data["normal_result"]["best_score"]
		ProfileManager.normal_result_data.best_successful_phases = node_data["normal_result"]["best_phase"]
		ProfileManager.normal_result_data.best_level_reached = node_data["normal_result"]["best_level"]
		ProfileManager.normal_result_data.best_enemies_destroyed = node_data["normal_result"]["best_enemies_destroyed"]

		ProfileManager.terrain_result_data.best_score = node_data["terrain_result"]["best_score"]
		ProfileManager.terrain_result_data.best_successful_phases = node_data["terrain_result"]["best_phase"]
		ProfileManager.terrain_result_data.best_level_reached = node_data["terrain_result"]["best_level"]
		ProfileManager.terrain_result_data.best_enemies_destroyed = node_data["terrain_result"]["best_enemies_destroyed"]
		
		ProfileManager.icy_result_data.best_score = node_data["icy_result"]["best_score"]
		ProfileManager.icy_result_data.best_successful_phases = node_data["icy_result"]["best_phase"]
		ProfileManager.icy_result_data.best_level_reached = node_data["icy_result"]["best_level"]
		ProfileManager.icy_result_data.best_enemies_destroyed = node_data["icy_result"]["best_enemies_destroyed"]
