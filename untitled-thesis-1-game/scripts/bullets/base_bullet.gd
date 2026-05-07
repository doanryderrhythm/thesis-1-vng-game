extends RigidBody2D
class_name BaseBullet

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D

var texture: Texture2D

var speed: float
var angle: float
var damage: float

func _ready() -> void:
	pass

func _on_body_entered(_body: Node) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.bullet_particles_node)
	if parent == null:
		return
	particles.color = modulate
	particles.one_shot = true
	particles.explosiveness = 1
	particles.reparent(parent)
	reset_bullet()
	pass

func reset_bullet() -> void:
	visible = false
	call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	set_physics_process(false)

func reenable_bullet() -> void:
	visible = true
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	set_physics_process(true)
	
	angular_velocity = randf_range(ValueStorer.bullet_min_angular_velocity, ValueStorer.bullet_max_angular_velocity)
	
	sprite.texture = texture
	sprite.global_rotation = angle
	
	linear_velocity = speed * Vector2(cos(angle), sin(angle))
