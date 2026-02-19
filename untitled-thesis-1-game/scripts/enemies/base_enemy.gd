extends BaseCharacter
class_name BaseEnemy

@onready var shoot_markers_storer = $ShootingMarkers
var shoot_markers: Array[Marker2D]

@export var enemy_stats: EnemyStats
@export var bullet_scene: PackedScene

@onready var shoot_delay_timer: Timer = $ShootingDelayTimer
@onready var navigation_timer: Timer = $NavigationTimer

var is_moving: bool = false
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var goal: Node

func _ready() -> void:
	health = enemy_stats.health
	
	dead.connect(GameManager.deduct_enemies)
	goal = GameManager.player
	navigation_agent.target_position = goal.global_transform.origin
	
	for marker in shoot_markers_storer.get_children():
		shoot_markers.push_back(marker)

	shoot_delay_timer.wait_time = enemy_stats.shoot_delay
	check_move()
	pass

func check_move() -> void:
	if not is_moving:
		modulate = enemy_stats.enemy_color
		navigation_agent.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		modulate = enemy_stats.enemy_color_moving
		navigation_agent.process_mode = Node.PROCESS_MODE_INHERIT

func _process(_delta: float) -> void:
	if GameManager.player:
		look_at(GameManager.player.position)

func _physics_process(_delta: float) -> void:
	var current_position: Vector2 = self.global_transform.origin
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = current_position.direction_to(next_path_position)
	navigation_agent.set_velocity(new_velocity)

func shoot_bullets() -> void:
	for i in range(shoot_markers.size()):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shoot_markers[i].global_position
		bullet.texture = enemy_stats.bullet_stats.texture
		bullet.speed = randf_range(
			enemy_stats.bullet_stats.min_speed,
			enemy_stats.bullet_stats.max_speed
			)
		bullet.angle = atan2(
			(shoot_markers[i].global_position.y - global_position.y),
			(shoot_markers[i].global_position.x - global_position.x)
			)
		bullet.damage = enemy_stats.bullet_stats.damage
		if is_moving:
			bullet.modulate = enemy_stats.bullet_stats.bullet_color_moving
		else:
			bullet.modulate = enemy_stats.bullet_stats.bullet_color
		get_tree().current_scene.add_child(bullet)

func _on_shooting_delay_timer_timeout() -> void:
	shoot_bullets()
	pass # Replace with function body.

func _on_navigation_timer_timeout() -> void:
	if goal != null:
		navigation_agent.target_position = goal.global_transform.origin
		navigation_timer.start()
	pass # Replace with function body.

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = velocity.move_toward(safe_velocity * enemy_stats.movement_speed, 10.0)
	move_and_slide()
	pass # Replace with function body.
