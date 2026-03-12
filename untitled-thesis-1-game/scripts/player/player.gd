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
@export var _bullet_stats: BulletStats
@export var _bullet_scene: PackedScene

@onready var _shoot_markers_storer = $ShootingMarkers
var _markers_pos: Array[Vector2]
var _shoot_markers: Array[Marker2D]
@onready var _shooting_delay_timer: Timer = $ShootingDelayTimer

@onready var _dash_timer: Timer = $DashTimer
@onready var _dash_wait_timer: Timer = $DashWaitTimer
var _dash_direction_vector: Vector2 = Vector2(0, 0)
var _dash_count: int = ValueStorer.max_dash_count

@onready var _statue_timer: Timer = $StatueTimer
@onready var _invulnerable_timer: Timer = $InvulnerableTimer
var _is_statue: bool = false
var _is_invulnerable: bool = false

@onready var _triangle_hurt_collision: CollisionPolygon2D = $HurtAreas/TriangleHurtArea2D/CollisionPolygon2D
@onready var _square_hurt_collision: CollisionShape2D = $HurtAreas/SquareHurtArea2D/CollisionShape2D
@onready var _diamond_hurt_collision: CollisionPolygon2D = $HurtAreas/DiamondHurtArea2D/CollisionPolygon2D
@onready var _circle_hurt_collision: CollisionShape2D = $HurtAreas/CircleHurtArea2D/CollisionShape2D

@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _shoot_audio: AudioStreamPlayer = $ShootAudio
@onready var _dash_audio: AudioStreamPlayer = $DashAudio
@onready var _hurt_audio: AudioStreamPlayer = $HurtAudio

@onready var _player_sprite: Sprite2D = $Sprite2D

var state: PlayerState
var _is_dash: bool = false
var _move_rate: float = 1.0

var _total_dash: float
var _offset_bullet_speed: float
var _offset_move_speed: float

func _init() -> void:
	GameManager.player = self

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

func increase_move_speed(_amount: float) -> void:
	_offset_move_speed += _amount

func manage_move() -> void:
	if _is_statue:
		return
	
	var input_vector = Vector2(
		Input.get_action_strength(ValueStorer.key_right) - Input.get_action_strength(ValueStorer.key_left),
		Input.get_action_strength(ValueStorer.key_down) - Input.get_action_strength(ValueStorer.key_up)
	)
	
	if state != PlayerState.DASH:
		direction_vector = input_vector.normalized() * _offset_move_speed
	else:
		direction_vector = _dash_direction_vector
		
	velocity = ProfileManager.move_speed * _move_rate * direction_vector
	move_and_slide()

func manage_dash() -> void:
	if Input.is_action_just_pressed(ValueStorer.key_dash):
		if _dash_count <= 0:
			return
		
		_dash_count -= 1
		GameManager.dash_change.emit()
		_dash_direction_vector = Vector2(cos(rotation), sin(rotation))
		_dash_audio.play()
		toggle_dash(true)
		_dash_timer.start()
		
		if _dash_count <= 0:
			_dash_wait_timer.start()
	
	if Input.is_action_pressed(ValueStorer.key_dash):
		if _dash_timer.is_stopped():
			toggle_dash(false)
			_move_rate = ValueStorer.player_default_rate
		else:
			toggle_dash(true)
			_move_rate = _total_dash
			
	if Input.is_action_just_released(ValueStorer.key_dash):
		toggle_dash(false)
		_dash_timer.stop()
		_move_rate = ValueStorer.player_default_rate
	pass

func increase_bullet_speed(_amount: float) -> void:
	_offset_bullet_speed += _amount

func shoot_bullet() -> void:
	_shoot_audio.play()
	for i in range(_shoot_markers.size()):
		var bullet = _bullet_scene.instantiate()
		bullet.global_position = _shoot_markers[i].global_position
		bullet.texture = _bullet_stats.texture
		bullet.speed = randf_range(_bullet_stats.min_speed, _bullet_stats.max_speed) * (ValueStorer.player_bullet_speed_mult + _offset_bullet_speed)
		var cal_angle: float = rad_to_deg(atan2(
			(_shoot_markers[i].global_position.y - global_position.y),
			(_shoot_markers[i].global_position.x - global_position.x)
			))
		bullet.angle = deg_to_rad(randf_range(cal_angle - 2, cal_angle + 2))
		bullet.damage = _bullet_stats.damage
		
		var parent = get_tree().current_scene.find_child(ValueStorer.bullets_node)
		parent.add_child(bullet)

func increase_dash(_amount: float) -> void:
	_total_dash += _amount;

func heal(_amount: float) -> void:
	health += _amount
	if health > ValueStorer.player_health:
		health = ValueStorer.player_health
	GameManager.health_change.emit()

func take_damage(_damage: float) -> void:
	if is_dead:
		return
		
	if _is_invulnerable:
		return
	
	health -= _damage
	GameManager.health_change.emit()
	GameManager.add_score(-25)
	_anim.play("hurt")
	_hurt_audio.play()
	_invulnerable_timer.start()
	_statue_timer.start()
	_is_statue = true
	call_deferred("set_invulnerable", true)
	
	if health <= 0:
		is_dead = true
		GameManager.state_lose_change.emit()
		self.visible = false
		self.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)

func set_invulnerable(is_toggled: bool) -> void:
	_is_invulnerable = is_toggled
	hurt_collision.disabled = _is_invulnerable

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			shoot_bullet()
			_shooting_delay_timer.start()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			_shooting_delay_timer.stop()

func state_check() -> void:
	if direction_vector == Vector2.ZERO:
		state = PlayerState.IDLE
		
	if _is_dash:
		state = PlayerState.DASH
	else:
		state = PlayerState.MOVE
	pass

func set_up_player() -> void:
	_player_sprite.texture = ProfileManager.sprite
	_character_type = ProfileManager.character_type
	_bullet_stats = ProfileManager.bullet_res
	health = ProfileManager.health
	_total_dash = ProfileManager.dash_speed
	_markers_pos = ProfileManager.markers_pos
	
	_offset_bullet_speed = 0
	_offset_move_speed = 1
	_dash_wait_timer.wait_time = ValueStorer.dash_wait_time
	
	for pos in _markers_pos:
		var marker: Marker2D = Marker2D.new()
		marker.position = pos
		_shoot_markers_storer.add_child(marker)
	
	for marker in _shoot_markers_storer.get_children():
		_shoot_markers.push_back(marker)
	
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
	
func toggle_dash(is_toggled: bool) -> void:
	_is_dash = is_toggled
	if _is_invulnerable and !_is_dash:
		hurt_collision.disabled = true
	else:
		hurt_collision.disabled = is_toggled
	hit_collision.disabled = !is_toggled

func _on_shooting_delay_timer_timeout() -> void:
	_shooting_delay_timer.start()
	shoot_bullet()
	pass

func _on_dash_wait_timer_timeout() -> void:
	_dash_count = ValueStorer.max_dash_count
	GameManager.dash_change.emit()
	pass # Replace with function body.

func _on_invulnerable_timer_timeout() -> void:
	_anim.play("default")
	call_deferred("set_invulnerable", false)
	pass # Replace with function body.

func _on_statue_timer_timeout() -> void:
	_is_statue = false;
	pass # Replace with function body.

func hurt(_area: Area2D) -> void:
	print(_area)
	if is_dead:
		return
	
	var temp = _area
	while temp.get_parent() != null:
		temp = temp.get_parent()
		if temp is BaseEnemy:
			take_damage(15.0)
			break
		elif temp is BaseBullet:
			take_damage(temp.damage)
			break
		elif temp is BaseLazer:
			take_damage(temp.damage)
			break
		elif temp is BigSpike:
			take_damage(temp.damage)
			break
		elif temp is Bomb:
			take_damage(temp.damage)
			break
