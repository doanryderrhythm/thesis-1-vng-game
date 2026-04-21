extends Node2D

@onready var achievement_item: PackedScene = preload("res://scenes/ui/achievement_shown_item.tscn")
@onready var achievement_list: VBoxContainer = $AchievementUI/Panel/ScrollContainer/VBoxContainer
@onready var achievement_listener: AchievementListener = load("res://resources/achievements/achievement_listener.tres")

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.0, 0.092, 0.184, 1.0))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for ach in achievement_listener.achievements:
		var ach_item: AchievementShownItem = achievement_item.instantiate()
		ach_item.achievement = ach
		achievement_list.add_child(ach_item)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scenes/main_menu.tscn")
	pass # Replace with function body.
