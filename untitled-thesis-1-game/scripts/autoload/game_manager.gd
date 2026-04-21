extends Node

enum LevelType
{
	LEVEL_NORMAL,
	LEVEL_TERRAIN,
	LEVEL_ICY,
}

var level_type: LevelType

var current_id_x: int = 0
var current_id_y: int = 0

var player: Player

var total_score: int = 0
var survival_time: float = 0.0
var total_destroyed_enemies: int = 0
var total_successful_phases: int = 0

var current_level: int = 0
var current_actual_level: int = 0
var current_phase: int = 0
var max_phase: int = 0

var enemies_num: int
var current_enemies_num: int

var is_lazer: bool
var is_spike: bool
var is_bomb: bool
var is_bomb_four: bool
var is_bomb_pellet: bool
var is_bomb_move: bool

var is_icy: bool

var enemy_particles: PackedScene = preload("res://effects/base_enemy_spawn.tscn")
var enemy_scenes: Array[PackedScene] = []
var room_scenes: Array[PackedScene] = []

var base_room: PackedScene
var rooms: Array[Room] = []
var used_rooms: Array[Dictionary] = []

# STATS
var is_going: bool = false
var stage_stats: Array[StageStats]
var in_level_coins: int = 0

var is_gameplay: bool = false
var is_locked: bool = false

signal health_change
signal dash_change
signal state_lose_change
signal score_change
signal phase_change(is_ongoing: bool)
signal start_level
signal end_level
signal room_start
signal delete_bullets
signal coin_change
signal stats_change

func _ready() -> void:
	pass

func reset() -> void:
	is_gameplay = true
	is_locked = false
	in_level_coins = 0
	
	current_id_x = 0
	current_id_y = 0
	
	total_score = 0
	survival_time = 0.0
	total_destroyed_enemies = 0
	total_successful_phases = 0

	current_level = 0
	current_actual_level = 0
	current_phase = 0
	max_phase = 0

	enemy_particles = preload("res://effects/base_enemy_spawn.tscn")
	enemy_scenes = []
	room_scenes = []

	if level_type == LevelType.LEVEL_NORMAL:
		base_room = preload("res://scenes/rooms/base_room.tscn")
	elif level_type == LevelType.LEVEL_TERRAIN:
		base_room = preload("res://scenes/rooms/base_terrain_room.tscn")
	elif level_type == LevelType.LEVEL_ICY:
		base_room = preload("res://scenes/rooms/base_icy_room.tscn")
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
	if is_going:
		survival_time += delta
		AchievementManager.total_survival_time += delta
		AchievementManager.check_achievement("survival_0")

func set_up_rooms() -> void:
	var listener: RoomsListener
	if level_type == LevelType.LEVEL_NORMAL:
		listener = load("res://resources/rooms/room_normal_listener.tres")
	elif level_type == LevelType.LEVEL_TERRAIN:
		listener = load("res://resources/rooms/room_terrain_listener.tres")
	elif level_type == LevelType.LEVEL_ICY:
		listener = load("res://resources/rooms/room_icy_listener.tres")
	room_scenes = listener.rooms
	
func set_up_stage_stats() -> void:
	var listener: StageStatsListener
	if level_type == LevelType.LEVEL_NORMAL:
		listener = load("res://resources/stages/normal_stage_stats_listener.tres")
	elif level_type == LevelType.LEVEL_TERRAIN:
		listener = load("res://resources/stages/terrain_stage_stats_listener.tres")
	elif level_type == LevelType.LEVEL_ICY:
		listener = load("res://resources/stages/icy_stage_stats_listener.tres")
	stage_stats = listener.stages

func set_up_enemies() -> void:
	var listener: EnemiesListener = load("res://resources/enemies/enemies_listener.tres")
	enemy_scenes = listener.enemies

func add_score(num: int) -> void:
	total_score += num
	score_change.emit()
	
func add_coin(num: int) -> void:
	in_level_coins += num
	coin_change.emit()

func start_stage() -> void:
	current_phase = stage_stats[current_level].phase_count
	max_phase = stage_stats[current_level].phase_count
	is_lazer = stage_stats[current_level].is_lazer
	is_spike = stage_stats[current_level].is_spike
	is_bomb = stage_stats[current_level].is_bomb
	is_bomb_four = stage_stats[current_level].is_bomb_four
	is_bomb_pellet = stage_stats[current_level].is_bomb_pellet
	is_bomb_move = stage_stats[current_level].is_bomb_move
	
	is_icy = stage_stats[current_level].is_icy
	
	is_going = true
	start_level.emit()
	phase_change.emit(true)
	
	MusicManager.toggle_filter_effect(false)
	pass

func spawn_enemies(first_point: Vector2, last_point: Vector2) -> void:
	var parent = get_tree().current_scene.find_child(ValueStorer.enemy_particles_node)
	if parent == null:
		push_error("Enemy particles node not found!")
		return
	
	enemies_num = randi_range(
		stage_stats[current_level].min_enemy, 
		stage_stats[current_level].max_enemy
		)
	current_enemies_num = 0
	
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
	total_destroyed_enemies += 1
	if current_enemies_num <= 0:
		current_phase -= 1
		total_successful_phases += 1
		AchievementManager.total_phases_finished += 1
		AchievementManager.check_achievement("phase_15")
		AchievementManager.check_achievement("phase_30")
		if current_phase > 0:
			phase_change.emit(true)
			var current_room = find_room(current_id_x, current_id_y)
			spawn_enemies(
				current_room.first_point.global_position,
				current_room.last_point.global_position
				)
			return
		
		var _room: Room = find_room(current_id_x, current_id_y)
		if _room == null:
			return
		_room.is_executed = true
		_room.call_deferred("start_stage", false)
		is_going = false
		end_level.emit()
		if current_level < stage_stats.size() - 1:
			current_level += 1
		current_actual_level += 1
		if !AchievementManager.is_dash:
			AchievementManager.total_rooms_no_dash += 1
			AchievementManager.check_achievement("no_dash_10")
		if !AchievementManager.is_shoot:
			AchievementManager.total_rooms_no_shoot += 1
			AchievementManager.check_achievement("no_bullet_10")
		
		if player.health >= 0 and player.health <= 10:
			AchievementManager.check_achievement("clutch")
		phase_change.emit(false)
		delete_bullets.emit()
		if is_all_surroundings_locked(current_id_x, current_id_y):
			if is_instance_valid(GameManager.player):
				AchievementManager.check_achievement("lock_yourself")
				GameManager.player.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
				GameManager.player.call_deferred("set_physics_process", false)
				is_locked = true
				state_lose_change.emit()
		create_available_rooms(current_id_x, current_id_y)
		
		MusicManager.toggle_filter_effect(true)

func confirm_stage(room: Room) -> void:
	if is_lazer:
		room.lazer_timer.wait_time = stage_stats[current_level].lazer_spawn_rate
		room.lazer_warn_time = stage_stats[current_level].lazer_warn_time
		room.lazer_harm_time = stage_stats[current_level].lazer_stay_time
	if is_spike:
		room.spike_timer.wait_time = stage_stats[current_level].spike_spawn_rate
		room.spike_warn_time = stage_stats[current_level].spike_warn_time
		room.spike_harm_time = stage_stats[current_level].spike_stay_time
	if is_bomb:
		room.bomb_timer.wait_time = stage_stats[current_level].bomb_spawn_rate
		room.bomb_warn_time = stage_stats[current_level].bomb_warn_time
		room.bomb_harm_time = stage_stats[current_level].bomb_stay_time
	if is_bomb_four:
		room.bomb_four_timer.wait_time = stage_stats[current_level].bomb_four_spawn_rate
		room.bomb_four_warn_time = stage_stats[current_level].bomb_four_warn_time
		room.bomb_four_harm_time = stage_stats[current_level].bomb_four_stay_time
	if is_bomb_pellet:
		room.bomb_pellet_timer.wait_time = stage_stats[current_level].bomb_pellet_spawn_rate
		room.bomb_pellet_warn_time = stage_stats[current_level].bomb_pellet_warn_time
		room.bomb_pellet_harm_time = stage_stats[current_level].bomb_pellet_stay_time
		room.bomb_pellet_shoot_attempts = stage_stats[current_level].bomb_pellet_shoot_attempts
	if is_bomb_move:
		room.bomb_move_timer.wait_time = stage_stats[current_level].bomb_move_spawn_rate
		room.bomb_move_warn_time = stage_stats[current_level].bomb_move_warn_time
	if is_icy:
		room.snow_count = stage_stats[current_level].number_of_snowball
	
func is_all_surroundings_locked(_id_x: int, _id_y: int) -> bool:
	if find_used_room(_id_x - 1, _id_y) and \
		find_used_room(_id_x + 1, _id_y) and \
		find_used_room(_id_x, _id_y - 1) and \
		find_used_room(_id_x, _id_y + 1):
		return true
	return false

func find_room(_id_x: int, _id_y: int) -> Room:
	rooms = rooms.filter(func(room):
		return is_instance_valid(room)
	)
	
	for room in rooms:
		if room.id_x == _id_x and room.id_y == _id_y:
			return room
	return null

func find_used_room(_id_x: int, _id_y: int) -> bool:
	for room in used_rooms:
		if room[ValueStorer.used_room_x] == _id_x and \
		room[ValueStorer.used_room_y] == _id_y:
			return true
	return false

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

func destroy_everything() -> void:
	var play_scene = get_tree().current_scene
	
	var enemies_node = play_scene.find_child(ValueStorer.enemies_node)
	var rewards_node = play_scene.find_child(ValueStorer.rewards_node)
	var bullet_node = play_scene.find_child(ValueStorer.bullets_node)
	
	for obj in enemies_node.get_children():
		if is_instance_valid(obj): obj.queue_free()
	for obj in rewards_node.get_children():
		if is_instance_valid(obj): obj.queue_free()
	for obj in bullet_node.get_children():
		if is_instance_valid(obj): obj.queue_free()
	
	var room: Room = find_room(current_id_x, current_id_y)
	if room != null and is_instance_valid(room):
		for obj in room.all_bombs.get_children():
			if is_instance_valid(obj): obj.queue_free()
		for obj in room.all_spikes.get_children():
			if is_instance_valid(obj): obj.queue_free()
		for obj in room.all_lazers.get_children():
			if is_instance_valid(obj): obj.queue_free()
		for obj in room.all_snows.get_children():
			if is_instance_valid(obj): obj.queue_free()
		room.spike_timer.stop()
		room.lazer_timer.stop()
		room.bomb_timer.stop()
		room.bomb_four_timer.stop()
		room.bomb_pellet_timer.stop()
		room.bomb_move_timer.stop()

func update_profile() -> void:
	ProfileManager.total_coins += in_level_coins
	var total_coins: int = ProfileManager.total_coins
	if total_coins >= 100:
		AchievementManager.check_achievement("coins_100")
	if total_coins >= 500:
		AchievementManager.check_achievement("coins_500")
	if total_coins >= 2000:
		AchievementManager.check_achievement("coins_2000")
