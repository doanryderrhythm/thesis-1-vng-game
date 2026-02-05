extends BaseCharacter
class_name BaseEnemy

@export var shoot_markers: Array[Marker2D]
@export var bullet_stats: BulletStats
@export var bullet_scene: PackedScene
@export var shoot_delay: float

@onready var shoot_delay_timer: Timer = $ShootingDelayTimer

func _ready() -> void:
	shoot_delay_timer.wait_time = shoot_delay
	pass

func _process(_delta: float) -> void:
	if GameManager.player:
		look_at(GameManager.player.position)

func shoot_bullets() -> void:
	for i in range(shoot_markers.size()):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shoot_markers[i].global_position
		bullet.texture = bullet_stats.texture
		bullet.speed = randf_range(bullet_stats.min_speed, bullet_stats.max_speed)
		bullet.angle = rotation
		bullet.damage = bullet_stats.damage
		get_tree().current_scene.add_child(bullet)

func _on_shooting_delay_timer_timeout() -> void:
	shoot_bullets()
	pass # Replace with function body.
