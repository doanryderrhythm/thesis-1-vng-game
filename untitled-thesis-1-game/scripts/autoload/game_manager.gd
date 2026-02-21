extends Node

var current_id_x: int = 0
var current_id_y: int = 0

var player: Player

var current_level: int = 0
var ongoing_level: int = 0
var current_phase: int = 0
var max_phase: int = 0

var min_enemies_num: int
var max_enemies_num: int
var enemies_num: int
var current_enemies_num: int

var enemy_particles: PackedScene = preload("res://effects/base_enemy_spawn.tscn")
var enemy_scenes: Array[PackedScene] = []
var room_scenes: Array[PackedScene] = []

var base_room: PackedScene = preload("res://scenes/rooms/base_room.tscn")
var rooms: Array[Room] = []

# STATS
var play_time: float = 0.0
var play_time_int: int = 0
var stage_stats: Array[StageStats]

signal play_time_change
signal max_min_enemy_change

func _ready() -> void:
	set_up_stage_stats()
	set_up_rooms()
	set_up_enemies()
	
	create_room(0, 0)
	create_available_rooms(current_id_x, current_id_y)
	pass

func _process(delta: float) -> void:
	play_time += delta
	if play_time_int != int(play_time):
		play_time_int = int(play_time)
		play_time_change.emit()
		if play_time_int >= stage_stats[current_level].time_to_pass and current_level + 1 < stage_stats.size():
			current_level += 1
			min_enemies_num = stage_stats[current_level].min_enemy
			max_enemies_num = stage_stats[current_level].max_enemy
			max_min_enemy_change.emit()

func set_up_rooms() -> void:
	var paths: Array[String] = [
		"res://scenes/rooms/rooms_design/"
	]
	
	execute_directories(paths, room_scenes)

func set_up_stage_stats() -> void:
	var paths: Array[String] = [
		"res://resources/stages/"
	]
	
	for path in paths:
		var dir := DirAccess.open(path)
		if dir == null:
			push_error("Failed to open dir: " + path)
			continue

		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = path + "/" + file_name
				var resource = load(resource_path)
				if resource:
					stage_stats.push_back(resource)
			file_name = dir.get_next()

		dir.list_dir_end()

func set_up_enemies() -> void:
	var paths: Array[String] = [
		"res://scenes/enemies/circle/",
		"res://scenes/enemies/diamond/",
		"res://scenes/enemies/square/",
		"res://scenes/enemies/triangle/",
	]
	
	execute_directories(paths, enemy_scenes)
	
	if enemy_scenes.size() == 0:
		return
	
	min_enemies_num = stage_stats[current_level].min_enemy
	max_enemies_num = stage_stats[current_level].max_enemy

func execute_directories(paths: Array[String], scenes: Array[PackedScene]) -> void:
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
					scenes.push_back(scene)
			file_name = dir.get_next()

		dir.list_dir_end()
		
func start_stage() -> void:
	ongoing_level = current_level
	current_phase = stage_stats[ongoing_level].phase_count
	pass

func spawn_enemies(first_point: Vector2, last_point: Vector2) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.enemy_particles_node)
	if parent == null:
		push_error("Enemy particles node not found!")
		return
	
	enemies_num = randi_range(
		stage_stats[ongoing_level].min_enemy, 
		stage_stats[ongoing_level].max_enemy
		)
	current_enemies_num = enemies_num
	
	for i in range(enemies_num):
		var rand_enemy = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)]
		var confirmed_pos = Vector2(
			randf_range(first_point.x, last_point.x),
			randf_range(first_point.y, last_point.y))
			
		var current_room: Room = find_room(current_id_x, current_id_y)
		while !current_room.is_valid_position(confirmed_pos):
			confirmed_pos = Vector2(
			randf_range(first_point.x, last_point.x),
			randf_range(first_point.y, last_point.y))
		
		var particles: EnemySpawnEffects = enemy_particles.instantiate()
		particles.enemy_scene = rand_enemy
		particles.first_point = first_point
		particles.last_point = last_point
		particles.position = confirmed_pos
		
		parent.call_deferred("add_child", particles)

func create_room(id_x: int, id_y: int) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.rooms_node)
	if parent == null:
		push_error("Rooms node not found!")
		return
	
	var new_room = null
	if id_x == 0 and id_y == 0:
		new_room = base_room.instantiate()
	else:
		var random_room: PackedScene = room_scenes[randi_range(0, room_scenes.size() - 1)]
		new_room = random_room.instantiate()
	
	new_room.init_detail(id_x, id_y)
	parent.call_deferred("add_child", new_room)
	rooms.append(new_room)

func create_available_rooms(id_x: int, id_y: int) -> void:
	var is_left_available: bool = true
	var is_right_available: bool = true
	var is_up_available: bool = true
	var is_down_available: bool = true
	
	rooms = rooms.filter(func(room):
		return is_instance_valid(room)
	)
	
	for room in rooms:
		if id_x == room.id_x and id_y == room.id_y:
			continue
		
		if id_x == room.id_x:
			if id_y - 1 == room.id_y:
				is_down_available = false
			elif id_y + 1 == room.id_y:
				is_up_available = false
		elif id_y == room.id_y:
			if id_x - 1 == room.id_x:
				is_left_available = false
			elif id_x + 1 == room.id_x:
				is_right_available = false
	
	if is_left_available:
		create_room(id_x - 1, id_y)
	if is_right_available:
		create_room(id_x + 1, id_y)
	if is_up_available:
		create_room(id_x, id_y + 1)
	if is_down_available:
		create_room(id_x, id_y - 1)

func deduct_enemies() -> void:
	current_enemies_num -= 1
	print(current_enemies_num)
	if current_enemies_num <= 0:
		current_phase -= 1
		if current_phase > 0:
			var current_room = find_room(current_id_x, current_id_y)
			spawn_enemies(
				current_room.first_point.global_position,
				current_room.last_point.global_position
				)
			return
		
		var _room: Room = find_room(current_id_x, current_id_y)
		print(_room)
		if _room == null:
			return
		_room.is_executed = true
		_room.call_deferred("toggle_doors", false)
		create_available_rooms(current_id_x, current_id_y)

func find_room(_id_x: int, _id_y: int) -> Room:
	rooms = rooms.filter(func(room):
		return is_instance_valid(room)
	)
	
	for room in rooms:
		if room.id_x == _id_x and room.id_y == _id_y:
			return room
	return null

func delete_room(_id_x: int, _id_y: int) -> void:	
	rooms = rooms.filter(func(room):
		return is_instance_valid(room)
	)
	
	for room in rooms:
		if _id_x == room.id_x and _id_y == room.id_y:
			continue
		room.queue_free()
	
	rooms = rooms.filter(func(room):
		return is_instance_valid(room)
	)
