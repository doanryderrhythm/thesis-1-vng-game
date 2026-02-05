extends RigidBody2D
class_name BaseBullet

@onready var sprite: Sprite2D = $Sprite2D

var texture: Texture2D

var speed: float
var angle: float
var damage: float

func _ready() -> void:
	sprite.texture = texture
	sprite.global_rotation = angle
	
	linear_velocity = speed * Vector2(cos(angle), sin(angle))

func _on_body_entered(body: Node) -> void:
	queue_free()
	pass
