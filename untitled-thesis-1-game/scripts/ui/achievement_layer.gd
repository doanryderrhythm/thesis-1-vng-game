extends CanvasLayer

@onready var achievement_list: VBoxContainer = $AchievementList

@onready var achievement_scene: PackedScene = preload("res://scenes/ui/achievement_item.tscn")

func receive_achievement(ach_code: String = "") -> void:
	if ach_code == "":
		return
	
	var ach_item: AchievementItem = achievement_scene.instantiate()
	achievement_list.add_child(ach_item)
	
	var all_achs: Array[Achievement] = AchievementManager.achievement_listener.achievements
	var found_achievement: Achievement = null
	for ach in all_achs:
		if ach.ach_code == ach_code:
			found_achievement = ach
			break
	if found_achievement == null:
		return
	
	ach_item.title_label.text = found_achievement.name
	ach_item.description_label.text = found_achievement.description
	
	SaveSystem.save_game()
	pass
