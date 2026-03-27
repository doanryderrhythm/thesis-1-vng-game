extends RigidBody2D
class_name Bomb

@onready var warning_sprite: Sprite2D = $WarningSprite
@onready var harmful_sprite: Sprite2D = $HarmfulSprite
@onready var bomb_glow: Sprite2D = $BombGlow

@onready var bomb_collision: CollisionShape2D = $HitArea2D/CollisionShape2D

@onready var warning_timer: Timer = $WarningTimer
@onready var harmful_timer: Timer = $HarmfulTimer

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_ready: bool = false

var damage: float = 10

func _ready() -> void:
	warning_sprite.visible = true
	harmful_sprite.visible = false
	bomb_glow.visible = false
	bomb_collision.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_ready:
		warning_sprite.rotate(deg_to_rad(60) * delta)
	pass

func _on_warning_timer_timeout() -> void:
	is_ready = true
	warning_sprite.visible = false
	harmful_sprite.visible = true
	bomb_glow.visible = true
	bomb_collision.disabled = false
	anim_player.play("default")
	harmful_timer.start()
	pass # Replace with function body.

func _on_harmful_timer_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
	pass # Replace with function body.
