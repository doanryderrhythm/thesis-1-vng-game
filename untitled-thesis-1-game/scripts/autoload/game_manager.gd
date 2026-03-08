extends Node

var current_id_x: int = 0
var current_id_y: int = 0

var player: Player

var total_score: int = 0

var current_level: int = 0
var ongoing_level: int = 0
var current_phase: int = 0
var max_phase: int = 0

var enemies_num: int
var current_enemies_num: int

var is_lazer: bool
var is_spike: bool
var is_bomb: bool
var is_bomb_four: bool

var enemy_particles: PackedScene = preload("res://effects/base_enemy_spawn.tscn")
var enemy_scenes: Array[PackedScene] = []
var room_scenes: Array[PackedScene] = []

var base_room: PackedScene = preload("res://scenes/rooms/base_room.tscn")
var rooms: Array[Room] = []
var used_rooms: Array[Dictionary] = []

# STATS
var play_time: float = 0.0
var play_time_int: int = 0
var stage_stats: Array[StageStats]

signal health_change
signal dash_change
signal state_lose_change
signal score_change
signal play_time_change
signal room_start

func _ready() -> void:
	pass

func reset() -> void:
	current_id_x = 0
	current_id_y = 0
	
	total_score = 0

	current_level = 0
	ongoing_level = 0
	current_phase = 0
	max_phase = 0
	
	play_time = 0
	play_time_int = 0

	enemy_particles = preload("res://effects/base_enemy_spawn.tscn")
	enemy_scenes = []
	room_scenes = []

	base_room = preload("res://scenes/rooms/base_room.tscn")
	rooms = []
	used_rooms.clear()
	
	set_up_stage_stats()
	set_up_rooms()
	set_up_enemies()
	
	create_room(0, 0)
	create_available_rooms(current_id_x, current_id_y)
	used_rooms.append({
		ValueStorer.used_room_x: 0,
		ValueStorer.used_room_y: 0
		})
	
	health_change.emit()
	dash_change.emit()
	score_change.emit()

func _process(delta: float) -> void:
	play_time += delta
	if play_time_int != int(play_time):
		play_time_int = int(play_time)
		play_time_change.emit()
		if play_time_int >= stage_stats[current_level].time_to_pass and current_level + 1 < stage_stats.size():
			current_level += 1

func set_up_rooms() -> void:
	var listener: RoomsListener = load("res://resources/rooms/rooms_listener.tres")
	room_scenes = listener.rooms
	
func set_up_stage_stats() -> void:
	var listener: StageStatsListener = load("res://resources/stages/stage_stats_listener.tres")
	stage_stats = listener.stages

func set_up_enemies() -> void:
	var listener: EnemiesListener = load("res://resources/enemies/enemies_listener.tres")
	enemy_scenes = listener.enemies

func add_score(num: int) -> void:
	total_score += num
	score_change.emit()

func start_stage() -> void:
	ongoing_level = current_level
	current_phase = stage_stats[ongoing_level].phase_count
	is_lazer = stage_stats[ongoing_level].is_lazer
	is_spike = stage_stats[ongoing_level].is_spike
	is_bomb = stage_stats[ongoing_level].is_bomb
	is_bomb_four = stage_stats[ongoing_level].is_bomb_four
	print(used_rooms)
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
		while !current_room.is_valid_position(confirmed_pos, ValueStorer.enemy_radius):
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
	
	var new_room: Room = null
	if id_x == 0 and id_y == 0:
		new_room = base_room.instantiate()
	else:
		var random_room: PackedScene = room_scenes[randi_range(0, room_scenes.size() - 1)]
		new_room = random_room.instantiate()
	
	var is_used: bool = false
	for room in used_rooms:
		if room[ValueStorer.used_room_x] == id_x and room[ValueStorer.used_room_y] == id_y:
			is_used = true
			break
			
	new_room.init_detail(id_x, id_y, is_used)
	parent.add_child(new_room)
	if is_used:
		new_room.doors.visible = true
		new_room.doors.process_mode = Node.PROCESS_MODE_INHERIT
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
		call_deferred("create_room", id_x - 1, id_y)
	if is_right_available:
		call_deferred("create_room", id_x + 1, id_y)
	if is_up_available:
		call_deferred("create_room", id_x, id_y + 1)
	if is_down_available:
		call_deferred("create_room", id_x, id_y - 1)

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
		
		print(used_rooms)
		var _room: Room = find_room(current_id_x, current_id_y)
		print(_room)
		if _room == null:
			return
		_room.is_executed = true
		_room.call_deferred("start_stage", false)
		create_available_rooms(current_id_x, current_id_y)

func confirm_stage(room: Room) -> void:
	if is_lazer:
		room.lazer_timer.wait_time = stage_stats[ongoing_level].lazer_spawn_rate
		room.lazer_warn_time = stage_stats[ongoing_level].lazer_warn_time
		room.lazer_harm_time = stage_stats[ongoing_level].lazer_stay_time
	if is_spike:
		room.spike_timer.wait_time = stage_stats[ongoing_level].spike_spawn_rate
		room.spike_warn_time = stage_stats[ongoing_level].spike_warn_time
		room.spike_harm_time = stage_stats[ongoing_level].spike_stay_time
	if is_bomb:
		room.bomb_timer.wait_time = stage_stats[ongoing_level].bomb_spawn_rate
		room.bomb_warn_time = stage_stats[ongoing_level].bomb_warn_time
		room.bomb_harm_time = stage_stats[ongoing_level].bomb_stay_time
	if is_bomb_four:
		room.bomb_four_timer.wait_time = stage_stats[ongoing_level].bomb_four_spawn_rate
		room.bomb_four_warn_time = stage_stats[ongoing_level].bomb_four_warn_time
		room.bomb_four_harm_time = stage_stats[ongoing_level].bomb_four_stay_time

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
