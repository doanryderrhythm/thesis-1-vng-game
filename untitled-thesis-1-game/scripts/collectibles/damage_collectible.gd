extends BaseCollectible
class_name DamageCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.take_damage(30)
	queue_free()
	pass
