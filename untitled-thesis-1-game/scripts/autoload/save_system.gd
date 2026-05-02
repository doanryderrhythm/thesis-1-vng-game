extends Node

func get_save_profile() -> Dictionary:
	var save_dict = {
		"font_index": GameManager.font_index,
		"is_tutorial_finished": ProfileManager.is_tutorial_finished,
		"total_coins": ProfileManager.total_coins,
		"unlocked_players": ProfileManager.unlocked_codes,
		"unlocked_achs": ProfileManager.unlocked_achs,
		"equipped_player": ProfileManager.player_code,
		"normal_result": {
			"best_score": ProfileManager.normal_result_data.best_score,
			"best_phase": ProfileManager.normal_result_data.best_successful_phases,
			"best_level": ProfileManager.normal_result_data.best_level_reached,
			"best_enemies_destroyed": ProfileManager.normal_result_data.best_enemies_destroyed,
		},
		"terrain_result": {
			"best_score": ProfileManager.terrain_result_data.best_score,
			"best_phase": ProfileManager.terrain_result_data.best_successful_phases,
			"best_level": ProfileManager.terrain_result_data.best_level_reached,
			"best_enemies_destroyed": ProfileManager.terrain_result_data.best_enemies_destroyed,
		},
		"icy_result": {
			"best_score": ProfileManager.icy_result_data.best_score,
			"best_phase": ProfileManager.icy_result_data.best_successful_phases,
			"best_level": ProfileManager.icy_result_data.best_level_reached,
			"best_enemies_destroyed": ProfileManager.icy_result_data.best_enemies_destroyed,
		},
	}
	return save_dict

func save_game():
	var save_file = FileAccess.open("user://save_profile.tsis", FileAccess.WRITE)

	var node_data = get_save_profile()
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
