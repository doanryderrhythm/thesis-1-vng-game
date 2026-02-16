extends Node

var current_id_x: int = 0
var current_id_y: int = 0

var player: Player

var current_level: int = 0

var current_phase: int = 0
var max_phase: int = 0

var min_enemies_num: int
var max_enemies_num: int
var enemies_num: int
var current_enemies_num: int

var enemy_scenes: Array[PackedScene] = []

var base_room: PackedScene = preload("res://scenes/rooms/base_room.tscn")
var rooms: Array[Room] = []

func _ready() -> void:
	set_up_enemies()
	create_room(0, 0)
	create_available_rooms(current_id_x, current_id_y)
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
		
		min_enemies_num = 1
		max_enemies_num = enemy_scenes.size()

func spawn_enemies(first_point: Vector2, last_point: Vector2) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.enemies_node)
	if parent == null:
		push_error("Enemies node not found!")
		return
	
	enemies_num = randi_range(min_enemies_num, max_enemies_num);
	current_enemies_num = enemies_num
	
	for i in range(enemies_num):
		var rand_enemy = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)]
		var inst_enemy = rand_enemy.instantiate()
		inst_enemy.position = Vector2(
			randf_range(first_point.x, last_point.x),
			randf_range(first_point.y, last_point.y))
		parent.call_deferred("add_child", inst_enemy)

func create_room(id_x: int, id_y: int) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.rooms_node)
	if parent == null:
		push_error("Rooms node not found!")
		return
	
	var new_room = base_room.instantiate()
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
	if current_enemies_num <= 0:
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
