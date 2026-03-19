extends Node

func get_save_profile() -> Dictionary:
	var save_dict = {
		"total_coins": ProfileManager.total_coins,
		"unlocked_players": ProfileManager.unlocked_codes,
		"best_score": ProfileManager.best_score,
		"best_phase": ProfileManager.best_successful_phases,
		"best_level": ProfileManager.best_level_reached,
		"best_survival_time": ProfileManager.best_survival_time,
	}
	return save_dict

func save_game():
	var save_file = FileAccess.open("user://save_profile.tsis", FileAccess.WRITE)

	var node_data = get_save_profile()
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
