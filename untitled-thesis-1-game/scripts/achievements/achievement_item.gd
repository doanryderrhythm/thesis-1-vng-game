extends PanelContainer
class_name AchievementItem

var achievement: Achievement

@onready var title_label: Label = $Detail/Title
@onready var description_label: Label = $Detail/Description

func import_achievement(ach: Achievement) -> void:
	achievement = ach
	load_achievement()

func load_achievement() -> void:
	title_label.text = achievement.name
	description_label.text = achievement.description
