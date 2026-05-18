extends RigidBody2D
class_name BaseBullet

@onready var sprite: Sprite2D = $Sprite2D

var texture: Texture2D

var speed: float
var angle: float
var damage: float

var time: float = 0.0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	time += _delta
	if time > 30.0:
		reset_bullet()

func _on_body_entered(_body: Node) -> void:
	reset_bullet()
	pass

func reset_bullet() -> void:
	time = 0.0
	visible = false
	call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	set_physics_process(false)
	self.call_deferred("reparent", ObjectPoolManager)

func reenable_bullet() -> void:
	visible = true
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	set_physics_process(true)
	print(damage)
	
	angular_velocity = randf_range(ValueStorer.bullet_min_angular_velocity, ValueStorer.bullet_max_angular_velocity)
	
	sprite.texture = texture
	sprite.global_rotation = angle
	
	linear_velocity = speed * Vector2(cos(angle), sin(angle))
