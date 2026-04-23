extends BaseCollectible
class_name Coin

func _ready() -> void:
	anim_player.play("default")
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
