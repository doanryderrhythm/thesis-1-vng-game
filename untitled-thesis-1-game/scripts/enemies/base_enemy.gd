extends BaseCharacter
class_name BaseEnemy

@onready var shoot_markers_storer = $ShootingMarkers
var shoot_markers: Array[Marker2D]

@export var bullet_stats: BulletStats
@export var bullet_scene: PackedScene
@export var shoot_delay: float

@onready var shoot_delay_timer: Timer = $ShootingDelayTimer

func _ready() -> void:
	dead.connect(GameManager.deduct_enemies)
	
	for marker in shoot_markers_storer.get_children():
		shoot_markers.push_back(marker)
		
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
		bullet.angle = atan2(
			(shoot_markers[i].global_position.y - global_position.y),
			(shoot_markers[i].global_position.x - global_position.x)
			)
		bullet.damage = bullet_stats.damage
		get_tree().current_scene.add_child(bullet)

func _on_shooting_delay_timer_timeout() -> void:
	shoot_bullets()
	pass # Replace with function body.
