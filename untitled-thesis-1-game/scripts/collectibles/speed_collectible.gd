extends BaseCollectible
class_name SpeedCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_move_speed(0.25)
		GameManager.stats_change.emit()
	queue_free()
	pass
