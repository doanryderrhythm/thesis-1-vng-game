extends CanvasLayer

@onready var achievement_list: VBoxContainer = $AchievementList

@onready var achievement_listener: AchievementListener = load("res://resources/achievements/achievement_listener.tres")
@onready var achievement_scene: PackedScene = preload("res://scenes/ui/achievement_item.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		receive_achievement("bruh")

func receive_achievement(ach_code: String = "") -> void:
	var ach_item: AchievementItem = achievement_scene.instantiate()
	achievement_list.add_child(ach_item)
	
	if ach_code == "":
		return
	
	var all_achs: Array[Achievement] = achievement_listener.achievements
	var found_achievement: Achievement = null
	for ach in all_achs:
		if ach.ach_code == ach_code:
			found_achievement = ach
			break
	if found_achievement == null:
		return
	
	ach_item.title_label.text = found_achievement.name
	ach_item.description_label.text = found_achievement.description
	pass
