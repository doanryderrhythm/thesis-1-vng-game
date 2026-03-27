extends Bomb
class_name BombMove

var rotate_value: float
var force_value: float

@onready var shoot_markers: Node2D = $Markers

@export var bullet_scene: PackedScene
@export var glow_scene: PackedScene
@export var bullet_stats: BulletStats

@onready var raycast: RayCast2D = $RayCast
@onready var warning_line: Line2D = $WarningLine

var is_exploded: bool = false

func _ready() -> void:
	warning_sprite.visible = true
	harmful_sprite.visible = false
	bomb_glow.visible = false
	bomb_collision.disabled = true
	
	rotate_value = randf_range(0.0, 360.0)
	force_value = randf_range(1000.0, 2000.0)
	
	rotation_degrees = rotate_value
	
func _physics_process(_delta: float) -> void:
	if is_ready:
		apply_central_force(Vector2(force_value * cos(rotation), force_value * sin(rotation)))
		var collision = move_and_collide(linear_velocity * _delta)
		if collision != null:
			show_glow()
			shoot_bullets()
			execute_collision()

	if raycast.is_colliding():
		var collide_pos = raycast.get_collision_point()
		warning_line.clear_points()
		warning_line.add_point(Vector2.ZERO)
		warning_line.add_point(to_local(collide_pos))
		anim_player.play("default")

func execute_collision() -> void:
	if is_instance_valid(self):
		queue_free()
	pass

func shoot_bullets() -> void:
	for marker in shoot_markers.get_children():
		var bullet = bullet_scene.instantiate()
		bullet.global_position = marker.global_position
		bullet.texture = bullet_stats.texture
		bullet.speed = randf_range(
			bullet_stats.min_speed,
			bullet_stats.max_speed
			) * 2.0
		bullet.angle = atan2(
			(marker.global_position.y - global_position.y),
			(marker.global_position.x - global_position.x)
			)
		bullet.damage = bullet_stats.damage
		
		var parent = get_tree().current_scene.find_child(ValueStorer.bullets_node)
		parent.call_deferred("add_child", bullet)
		bullet.modulate = Color("c4ffe6ff")

func show_glow() -> void:
	var glow = glow_scene.instantiate()
	var parent = get_tree().current_scene.find_child(ValueStorer.enemy_particles_node)
	parent.add_child(glow)
	glow.global_position = global_position
	glow.set_color(bomb_glow.self_modulate)

func _on_warning_timer_timeout() -> void:
	is_ready = true
	warning_sprite.visible = false
	harmful_sprite.visible = true
	bomb_glow.visible = true
	bomb_collision.disabled = false
	anim_player.play("default")
	pass
