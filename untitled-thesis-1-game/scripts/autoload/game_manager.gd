extends Node

var player: Player

var current_level: int = 0

var current_phase: int = 0
var max_phase: int = 0

var min_enemies_num: int
var max_enemies_num: int
var enemies_num: int

var enemy_scenes: Array[PackedScene] = []

func _ready() -> void:
	set_up_enemies()
	
	enemies_num = randi_range(5, 20);
	for i in range(enemies_num):
		var rand_enemy = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)]
		var inst_enemy = rand_enemy.instantiate()
		inst_enemy.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		get_tree().current_scene.add_child(inst_enemy)
	pass

func set_up_enemies() -> void:
	var paths: Array[String] = [
		"res://scenes/enemies/circle/",
		"res://scenes/enemies/diamond/",
		"res://scenes/enemies/square/",
		"res://scenes/enemies/triangle/",
	]
	
	for path in paths:
		var dir := DirAccess.open(path)
		if dir == null:
			push_error("Failed to open dir: " + path)
			continue

		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var scene_path = path + "/" + file_name
				var scene = load(scene_path)
				if scene:
					enemy_scenes.push_back(scene)
			file_name = dir.get_next()

		dir.list_dir_end()
