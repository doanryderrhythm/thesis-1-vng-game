extends RigidBody2D
class_name BaseCollectible

@onready var interact_collision: CollisionShape2D = $InteractArea2D/CollisionShape2D
var current_time: float = 0

func _ready() -> void:
	interact_collision.disabled = true

func _process(delta: float) -> void:
	current_time += delta
	if current_time >= ValueStorer.reward_enable_time and interact_collision.disabled:
		interact_collision.disabled = false

func take_effect() -> void:
	pass

func _on_interact_area_2d_interact(_area: Area2D) -> void:
	take_effect()
	pass # Replace with function body.
