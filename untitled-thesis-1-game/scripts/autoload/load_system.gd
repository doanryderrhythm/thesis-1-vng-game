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

		ProfileManager.total_coins = node_data["total_coins"]
		ProfileManager.unlocked_codes.assign(node_data.get("unlocked_players", []))
		ProfileManager.best_score = node_data["best_score"]
		ProfileManager.best_successful_phases = node_data["best_phase"]
		ProfileManager.best_level_reached = node_data["best_level"]
