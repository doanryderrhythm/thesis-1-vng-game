extends CPUParticles2D
class_name EnemySpawnEffects

var enemy_scene: PackedScene

var first_point: Vector2
var last_point: Vector2

var is_moving: bool = false

var inst_enemy: BaseEnemy = null

func _ready() -> void:
	var move_ability: float = randf_range(0.0, 1.0)
	if move_ability > 0.5:
		is_moving = true
	
	inst_enemy = enemy_scene.instantiate()
	if is_moving:
		color = inst_enemy.enemy_stats.enemy_color_moving
	else:
		color = inst_enemy.enemy_stats.enemy_color
	
	emitting = true
	pass

func spawn_enemy() -> void:
	GameManager.current_enemies_num += 1
	var parent = get_tree().current_scene.find_child(ValueStorer.enemies_node)
	if parent == null:
		push_error("Enemies node not found!")
		return

	inst_enemy.position = self.position
	inst_enemy.is_moving = is_moving
	
	parent.call_deferred("add_child", inst_enemy)

func _on_wait_timer_timeout() -> void:
	spawn_enemy()
	pass # Replace with function body.

func _on_finished() -> void:
	call_deferred("queue_free")
	pass # Replace with function body.
