extends BaseCollectible
class_name DashCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_dash(1)
		GameManager.stats_change.emit()
	queue_free()
	pass
