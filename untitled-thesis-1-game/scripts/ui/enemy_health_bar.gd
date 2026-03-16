extends CanvasLayer
class_name EnemyHealthBar

@onready var health_bar: TextureProgressBar = $HealthBar

func set_up_health(max_value: float, current: float) -> void:
	health_bar.min_value = 0.0
	health_bar.max_value = max_value
	health_bar.value = current

func change_health(value: float) -> void:
	health_bar.value = value
