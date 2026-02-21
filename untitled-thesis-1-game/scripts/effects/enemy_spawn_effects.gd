extends CPUParticles2D
class_name EnemySpawnEffects

var enemy_scene: PackedScene

var first_point: Vector2
var last_point: Vector2

func _ready() -> void:
	emitting = true
	pass

func spawn_enemy() -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.enemies_node)
	if parent == null:
		push_error("Enemies node not found!")
		return

	var inst_enemy = enemy_scene.instantiate()
	var move_ability: float = randf_range(0.0, 1.0)
	var is_moving: bool = false
	if move_ability > 0.5:
		is_moving = true

	inst_enemy.position = self.position
	inst_enemy.is_moving = is_moving
	
	parent.call_deferred("add_child", inst_enemy)

func _on_wait_timer_timeout() -> void:
	spawn_enemy()
	pass # Replace with function body.

func _on_finished() -> void:
	call_deferred("queue_free")
	pass # Replace with function body.
