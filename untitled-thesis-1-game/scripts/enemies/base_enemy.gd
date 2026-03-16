extends BaseCharacter
class_name BaseEnemy

@export var damage: float

@onready var sprite: Sprite2D = $Sprite2D

@onready var shoot_markers_storer = $ShootingMarkers
var shoot_markers: Array[Marker2D]

@export var enemy_stats: EnemyStats
@export var bullet_scene: PackedScene

@onready var shoot_delay_timer: Timer = $ShootingDelayTimer
@onready var navigation_timer: Timer = $NavigationTimer

var is_moving: bool = false
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var goal: Node

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio
@onready var hurt_audio: AudioStreamPlayer2D = $HurtAudio
@onready var dead_audio: AudioStreamPlayer2D = $DeadAudio

@onready var enemy_killed_particles: PackedScene = preload("res://effects/killed_particles.tscn")

@onready var reward_listener: RewardListener = load("res://resources/rewards/reward_listener.tres")

@onready var health_bar_sub_viewport: EnemyHealthBar = $HealthBarSubViewport/EnemyHealthBar
@onready var health_bar_sprite: Sprite2D = $HealthBarViewport

func _ready() -> void:
	anim.play("default")
	health = enemy_stats.health
	health_bar_sub_viewport.set_up_health(enemy_stats.health, health)
	
	dead.connect(GameManager.deduct_enemies)
	goal = GameManager.player
	
	if !is_instance_valid(goal):
		if is_instance_valid(self):
			queue_free()
		return

	navigation_agent.target_position = goal.global_transform.origin
	
	for marker in shoot_markers_storer.get_children():
		shoot_markers.push_back(marker)

	shoot_delay_timer.wait_time = enemy_stats.shoot_delay
	check_move()
	pass

func check_move() -> void:
	if not is_moving:
		sprite.modulate = enemy_stats.enemy_color
		navigation_agent.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		sprite.modulate = enemy_stats.enemy_color_moving
		navigation_agent.process_mode = Node.PROCESS_MODE_INHERIT

func take_damage(_damage: float) -> void:
	if is_dead:
		return
	
	health -= _damage
	health_bar_sub_viewport.change_health(health)
	GameManager.add_score(1)
	anim.play("hurt")
	hurt_audio.play()
	if health <= 0:
		is_dead = true
		GameManager.add_score(20)
		dead_audio.play()
		spawn_killed_particles()
		throw_reward()
		var parent = get_tree().current_scene
		dead_audio.reparent(parent)
		queue_free()
		call_deferred("emit_dead_signal")

func _process(_delta: float) -> void:
	if GameManager.player:
		look_at(GameManager.player.position)
	
	health_bar_sprite.rotation = -rotation

func _physics_process(_delta: float) -> void:
	var current_position: Vector2 = self.global_transform.origin
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = current_position.direction_to(next_path_position)
	navigation_agent.set_velocity(new_velocity)

func shoot_bullets() -> void:
	shoot_audio.play()
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
		
		var parent = get_tree().current_scene.find_child(ValueStorer.bullets_node)
		parent.add_child(bullet)

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

func spawn_killed_particles() -> void:
	var killed_particles = enemy_killed_particles.instantiate()
	killed_particles.color = sprite.modulate
	killed_particles.global_position = global_position
	
	var parent = get_tree().current_scene.find_child(ValueStorer.enemy_particles_node)
	if parent:
		parent.add_child(killed_particles)

func hurt(area: Area2D) -> void:
	if is_dead:
		return
		
	var temp = area
	while temp.get_parent() != null:
		temp = temp.get_parent()
		if temp is BaseCharacter:
			break
	if temp is Player:
		is_dead = true
		GameManager.add_score(100)
		dead_audio.play()
		var parent = get_tree().current_scene
		dead_audio.reparent(parent)
		spawn_killed_particles()
		throw_reward()
		queue_free()
		call_deferred("emit_dead_signal")
	else:
		take_damage(5.0)

func throw_reward() -> void:
	var total_value: int = 0
	for reward in reward_listener.rewards:
		total_value += reward.rate
	
	var random_value: int = randi_range(1, total_value + ValueStorer.reward_random_extra)
	var compare_value: int = 0
	for reward in reward_listener.rewards:
		compare_value += reward.rate
		if random_value <= compare_value:
			instantiate_reward(reward.collectible_id, reward.collectible)
			return
	pass

func instantiate_reward(id: String, reward: PackedScene) -> void:
	if id == "":
		return
	
	var num: int = 1
	if id == "coin":
		num = randi_range(1, 10)
	
	for i in range(num):
		var reward_scene = reward.instantiate()
		var parent = get_tree().current_scene.find_child(ValueStorer.rewards_node)
		if parent:
			parent.call_deferred("add_child", reward_scene)
			reward_scene.position = self.position
	pass

func emit_dead_signal() -> void:
	dead.emit()
