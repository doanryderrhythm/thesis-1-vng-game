extends BaseCollectible
class_name DashCollectible

func take_effect() -> void:
	if GameManager.player:
		GameManager.player.increase_dash(1)
		GameManager.stats_change.emit(GameManager.CollectibleType.DASH_LENGTH)
	queue_free()
	pass

func _on_interact_area_2d_interact(_area: Area2D) -> void:
	take_effect()
	play_audio(AudioStorer.collectible_collect, _area)
	pass # Replace with function body.
