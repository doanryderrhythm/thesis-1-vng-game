extends Bomb
class_name Snow

@onready var snow_particles: CPUParticles2D = $SnowParticles

var move_speed: float = 750.0

func _ready() -> void:
	warning_sprite.visible = true
	harmful_sprite.visible = false
	bomb_glow.visible = false
	bomb_collision.disabled = true
	snow_particles.visible = false
	snow_particles.emitting = false
	
	linear_velocity = Vector2.ZERO;

func _on_warning_timer_timeout() -> void:
	is_ready = true
	warning_sprite.visible = false
	harmful_sprite.visible = true
	bomb_glow.visible = true
	bomb_collision.disabled = false
	snow_particles.visible = true
	snow_particles.emitting = true
	anim_player.play("default")
	linear_velocity = Vector2(
		randf_range(-move_speed, move_speed),
		randf_range(-move_speed, move_speed))
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if is_ready:
		var collision = move_and_collide(linear_velocity * delta)
		if collision:
			var new_direction = linear_velocity.bounce(collision.get_normal()).normalized()
			linear_velocity = new_direction * move_speed
