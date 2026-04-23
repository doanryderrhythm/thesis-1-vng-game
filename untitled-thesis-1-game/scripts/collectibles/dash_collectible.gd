extends BaseCollectible
class_name DashCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_dash(1)
		GameManager.stats_change.emit(GameManager.CollectibleType.DASH_LENGTH)
	queue_free()
	pass
