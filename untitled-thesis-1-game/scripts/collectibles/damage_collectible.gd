extends BaseCollectible
class_name DamageCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.take_damage(30)
		if GameManager.player.health <= 0:
			EventBus.destroy_yourself.emit()
	queue_free()
	pass
