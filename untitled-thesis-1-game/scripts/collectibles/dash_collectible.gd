extends BaseCollectible
class_name DashCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_dash(1)
	queue_free()
	pass
