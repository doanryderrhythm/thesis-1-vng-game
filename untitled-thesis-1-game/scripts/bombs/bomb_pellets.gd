extends Bomb
class_name BombPellets

@onready var cannons: Node2D = $Cannons
@onready var shoot_markers: Node2D = $Markers

@export var bullet_scene: PackedScene
@export var bullet_stats: BulletStats

func _ready() -> void:
	warning_sprite.visible = true
	harmful_sprite.visible = false
	bomb_glow.visible = false
	cannons.visible = false
	bomb_collision.disabled = true

func _on_warning_timer_timeout() -> void:
	is_ready = true
	warning_sprite.visible = false
	harmful_sprite.visible = true
	bomb_glow.visible = true
	bomb_collision.disabled = false
	anim_player.play("default")
	harmful_timer.start()
	shoot_bullets()
	pass # Replace with function body.

func shoot_bullets() -> void:
	for marker in shoot_markers.get_children():
		var bullet = bullet_scene.instantiate()
		bullet.global_position = marker.global_position
		bullet.texture = bullet_stats.texture
		bullet.speed = randf_range(
			bullet_stats.min_speed,
			bullet_stats.max_speed
			) * 2.5
		bullet.angle = atan2(
			(marker.global_position.y - global_position.y),
			(marker.global_position.x - global_position.x)
			)
		bullet.damage = bullet_stats.damage
		
		var parent = get_tree().current_scene.find_child(ValueStorer.bullets_node)
		parent.add_child(bullet)
		bullet.modulate = Color("ffc4ffff")
