extends Panel
class_name AchievementShownItem

@onready var status_pic: TextureRect = $StatusPic
@onready var title_label: Label = $Title
@onready var description_label: Label = $Description

var achievement: Achievement

@onready var unlocked_style: StyleBoxFlat = preload("res://styles/style_achievement_unlocked.tres")
@onready var locked_style: StyleBoxFlat = preload("res://styles/style_achievement_locked.tres")

func _ready() -> void:
	title_label.text = achievement.name
	description_label.text = achievement.description
	
	var is_unlocked: bool = ProfileManager.is_achievement_unlocked(achievement.ach_code)
	if !is_unlocked:
		status_pic.visible = false
		add_theme_stylebox_override("panel", locked_style)
	else:
		status_pic.visible = true
		add_theme_stylebox_override("panel", unlocked_style)
