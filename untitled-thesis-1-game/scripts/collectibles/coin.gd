extends BaseCollectible
class_name Coin

func _ready() -> void:
	interact_collision.disabled = true
	linear_velocity = Vector2(
		randf_range(-700, 700),
		randf_range(-700, 700)
	)
	pass

func take_effect() -> void:
	GameManager.add_coin(1)
	if is_instance_valid(self):
		queue_free()
	pass

func _on_interact_area_2d_interact(_area: Area2D) -> void:
	take_effect()
	play_audio(AudioStorer.coin_collect, _area)
	pass # Replace with function body.
