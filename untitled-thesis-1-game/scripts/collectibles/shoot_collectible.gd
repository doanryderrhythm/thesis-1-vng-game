extends BaseCollectible
class_name ShootCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_bullet_speed(1)
	queue_free()
	pass
