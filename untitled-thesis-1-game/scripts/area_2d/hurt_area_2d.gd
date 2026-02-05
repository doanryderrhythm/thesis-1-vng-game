extends Area2D
class_name HurtArea2D

signal hurt(area: Area2D)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	hurt.connect(on_hurt)

func _on_area_entered(area: Area2D) -> void:
	emit_signal("hurt", area)

func on_hurt(area: Area2D) -> void:
	var temp = self
	while temp.get_parent() != null:
		temp = temp.get_parent()
		if temp is BaseCharacter:
			break
	temp.hurt(area)
	pass
