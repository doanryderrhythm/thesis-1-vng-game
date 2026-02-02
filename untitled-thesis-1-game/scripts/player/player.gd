extends BaseCharacter
class_name Player

enum PlayerState
{
	IDLE,
	MOVE,
	DASH,
	HURT,
	DEAD,
}

@onready var dash_timer: Timer = $DashTimer

var state: PlayerState
var is_dash: bool = false
var move_rate: float = 1.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	state_check()
	
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	
func _physics_process(delta: float) -> void:
	manage_dash()
	manage_move()
	pass

func manage_move() -> void:
	var input_vector = Vector2(
		Input.get_action_strength(ValueStorer.key_right) - Input.get_action_strength(ValueStorer.key_left),
		Input.get_action_strength(ValueStorer.key_down) - Input.get_action_strength(ValueStorer.key_up)
	)
	
	direction_vector = input_vector.normalized()
	velocity = ValueStorer.velocity * move_rate * direction_vector
	move_and_slide()

func manage_dash() -> void:
	if Input.is_action_just_pressed(ValueStorer.key_dash):
		is_dash = true
		dash_timer.start()
	
	if Input.is_action_pressed(ValueStorer.key_dash):
		if dash_timer.is_stopped():
			is_dash = false
			move_rate = ValueStorer.player_default_rate
		else:
			is_dash = true
			move_rate = ValueStorer.player_dash_rate
			
	if Input.is_action_just_released(ValueStorer.key_dash):
		is_dash = false
		dash_timer.stop()
		move_rate = ValueStorer.player_default_rate
	pass

func state_check() -> void:
	if direction_vector == Vector2.ZERO:
		state = PlayerState.IDLE
	else:
		if is_dash:
			state = PlayerState.DASH
		else:
			state = PlayerState.MOVE
	print(state)
	pass
