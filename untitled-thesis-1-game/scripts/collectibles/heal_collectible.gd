extends BaseCollectible
class_name HealCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.heal(15)
	queue_free()
	pass
