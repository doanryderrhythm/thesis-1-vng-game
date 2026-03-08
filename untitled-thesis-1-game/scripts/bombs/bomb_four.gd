extends Bomb
class_name BombFour

@onready var wings: Node2D = $Wings

@onready var wing_sprite_0: Sprite2D = $Wings/Wing0
@onready var wing_sprite_1: Sprite2D = $Wings/Wing1

@onready var wing_collision_0: CollisionShape2D = $Wings/HitArea2D/CollisionShape2D
@onready var wing_collision_1: CollisionShape2D = $Wings/HitArea2D2/CollisionShape2D

var rotate_rate: float

func _ready() -> void:
	rotate_rate = randf_range(30, 150)
	
	warning_sprite.visible = true
	harmful_sprite.visible = false
	bomb_glow.visible = false
	bomb_collision.disabled = true
	
	wing_sprite_0.modulate.a = 0.2
	wing_sprite_1.modulate.a = 0.2
	
	wing_collision_0.disabled = true
	wing_collision_1.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_ready:
		warning_sprite.rotate(deg_to_rad(60) * delta)
	else:
		wings.rotate(deg_to_rad(rotate_rate) * delta)
	pass
	
func _on_warning_timer_timeout() -> void:
	is_ready = true
	warning_sprite.visible = false
	harmful_sprite.visible = true
	bomb_glow.visible = true
	bomb_collision.disabled = false
	anim_player.play("default")
	harmful_timer.start()
	
	wing_collision_0.disabled = false
	wing_collision_1.disabled = false
	wing_sprite_0.modulate.a = 1
	wing_sprite_1.modulate.a = 1
	
	pass # Replace with function body.
