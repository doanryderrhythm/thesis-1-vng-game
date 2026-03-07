extends Area2D
class_name InteractArea2D

signal interact(area: Area2D)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	emit_signal("interact", area)
