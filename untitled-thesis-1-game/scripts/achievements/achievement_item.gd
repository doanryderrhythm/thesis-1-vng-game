extends PanelContainer
class_name AchievementItem

var achievement: Achievement

@onready var title_label: Label = $Detail/Title
@onready var description_label: Label = $Detail/Description

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("default")

func import_achievement(ach: Achievement) -> void:
	achievement = ach
	load_achievement()

func load_achievement() -> void:
	title_label.text = achievement.name
	description_label.text = achievement.description

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "default":
		queue_free()
	pass # Replace with function body.
