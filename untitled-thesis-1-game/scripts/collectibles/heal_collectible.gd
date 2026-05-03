extends BaseCollectible
class_name HealCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.heal(15)
		GameManager.stats_change.emit(GameManager.CollectibleType.HEALTH)
	queue_free()
	pass

func _on_interact_area_2d_interact(_area: Area2D) -> void:
	take_effect()
	play_audio(AudioStorer.collectible_collect, _area)
	pass # Replace with function body.
