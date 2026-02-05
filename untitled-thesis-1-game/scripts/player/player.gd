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

enum CharacterType
{
	TRIANGLE,
	SQUARE,
	DIAMOND,
	CIRCLE,
}

@export var _character_type: CharacterType

@onready var _dash_timer: Timer = $DashTimer

@onready var _triangle_hurt_collision: CollisionPolygon2D = $HurtAreas/TriangleHurtArea2D/CollisionPolygon2D
@onready var _square_hurt_collision: CollisionShape2D = $HurtAreas/SquareHurtArea2D/CollisionShape2D
@onready var _diamond_hurt_collision: CollisionPolygon2D = $HurtAreas/DiamondHurtArea2D/CollisionPolygon2D
@onready var _circle_hurt_collision: CollisionShape2D = $HurtAreas/CircleHurtArea2D/CollisionShape2D

var state: PlayerState
var _is_dash: bool = false
var _move_rate: float = 1.0

func _ready() -> void:
	set_up_player()
	pass

func _process(_delta: float) -> void:
	state_check()
	
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	
func _physics_process(_delta: float) -> void:
	manage_dash()
	manage_move()
	pass

func manage_move() -> void:
	var input_vector = Vector2(
		Input.get_action_strength(ValueStorer.key_right) - Input.get_action_strength(ValueStorer.key_left),
		Input.get_action_strength(ValueStorer.key_down) - Input.get_action_strength(ValueStorer.key_up)
	)
	
	direction_vector = input_vector.normalized()
	velocity = ValueStorer.velocity * _move_rate * direction_vector
	move_and_slide()

func manage_dash() -> void:
	if Input.is_action_just_pressed(ValueStorer.key_dash):
		toggle_dash(true)
		_dash_timer.start()
	
	if Input.is_action_pressed(ValueStorer.key_dash):
		if _dash_timer.is_stopped():
			toggle_dash(false)
			_move_rate = ValueStorer.player_default_rate
		else:
			toggle_dash(true)
			_move_rate = ValueStorer.player_dash_rate
			
	if Input.is_action_just_released(ValueStorer.key_dash):
		toggle_dash(false)
		_dash_timer.stop()
		_move_rate = ValueStorer.player_default_rate
	pass

func state_check() -> void:
	if direction_vector == Vector2.ZERO:
		state = PlayerState.IDLE
	else:
		if _is_dash:
			state = PlayerState.DASH
		else:
			state = PlayerState.MOVE
	pass

func set_up_player() -> void:
	hit_collision = $HitAreas/HitArea2D/CollisionShape2D
	hit_collision.disabled = true
	
	_triangle_hurt_collision.disabled = true
	_square_hurt_collision.disabled = true
	_diamond_hurt_collision.disabled = true
	_circle_hurt_collision.disabled = true
	
	if _character_type == CharacterType.TRIANGLE:
		_triangle_hurt_collision.disabled = false
		hurt_collision = _triangle_hurt_collision
	elif _character_type == CharacterType.SQUARE:
		_square_hurt_collision.disabled = false
		hurt_collision = _square_hurt_collision
	elif _character_type == CharacterType.DIAMOND:
		_diamond_hurt_collision.disabled = false
		hurt_collision = _diamond_hurt_collision
	elif _character_type == CharacterType.CIRCLE:
		_circle_hurt_collision.disabled = false
		hurt_collision = _circle_hurt_collision
	
	health = ValueStorer.player_health
	
func toggle_dash(is_toggled: bool) -> void:
	_is_dash = is_toggled
	hurt_collision.disabled = is_toggled
	hit_collision.disabled = !is_toggled
