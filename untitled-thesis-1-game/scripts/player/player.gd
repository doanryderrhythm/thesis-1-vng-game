extends CharacterBody2D
class_name Player

var direction_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	
func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength(ValueStorer.key_right) - Input.get_action_strength(ValueStorer.key_left),
		Input.get_action_strength(ValueStorer.key_down) - Input.get_action_strength(ValueStorer.key_up)
	)
	
	direction_vector = input_vector.normalized()
	velocity = ValueStorer.velocity * direction_vector
	move_and_slide()
	pass
