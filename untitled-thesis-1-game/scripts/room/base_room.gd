extends Node2D
class_name Room

var id_x: int
var id_y: int

var is_executed: bool

var lazer_warn_time: float
var lazer_harm_time: float

var spike_warn_time: float
var spike_harm_time: float

var bomb_warn_time: float
var bomb_harm_time: float

var bomb_four_warn_time: float
var bomb_four_harm_time: float

@onready var first_point: Marker2D = $WayPoints/FirstPoint
@onready var last_point: Marker2D = $WayPoints/LastPoint

@onready var doors: Node2D = $Doors
@onready var corridors: Node2D = $Corridors

@onready var start_area_collision: CollisionShape2D = $StartArea2D/CollisionShape2D

@onready var room_particles: Node2D = $RoomParticles

@onready var lazer_scene: PackedScene = preload("res://scenes/lazers/lazer_test.tscn")
@onready var lazer_timer: Timer = $LazerTimer

@onready var spike_scene: PackedScene = preload("res://scenes/spikes/big_spike.tscn")
@onready var spike_timer: Timer = $SpikeTimer
@onready var spike_way_points: Node2D = $SpikeWayPoints

@onready var bomb_scene: PackedScene = preload("res://scenes/bombs/bomb.tscn")
@onready var bomb_timer: Timer = $BombTimer
@onready var bomb_four_scene: PackedScene = preload("res://scenes/bombs/bomb_four.tscn")
@onready var bomb_four_timer: Timer = $BombFourTimer
@onready var bomb_way_points: Node2D = $BombWayPoints

@onready var all_spikes: Node2D = $Spikes
@onready var all_bombs: Node2D = $Bombs
@onready var all_lazers: Node2D = $Lazers

@onready var anim_player: AnimationPlayer = $RoomAnimationPlayer

@onready var door_close_audio: AudioStreamPlayer = $DoorCloseAudio

func _ready() -> void:
	start_stage(false, true)
	pass

func init_detail(_id_x: int, _id_y: int, _is_executed: bool = false) -> void:
	id_x = _id_x
	id_y = _id_y
	position = ValueStorer.room_distance * Vector2(float(id_x), float(id_y))
	is_executed = _is_executed

func start_stage(is_toggled: bool, is_game_start: bool = false) -> void:
	doors.visible = is_toggled
	corridors.visible = !is_toggled
	if is_toggled:
		door_close_audio.play()
		GameManager.room_start.emit()
		if GameManager.is_lazer: lazer_timer.start()
		if GameManager.is_spike: spike_timer.start()
		if GameManager.is_bomb: bomb_timer.start()
		if GameManager.is_bomb_four: bomb_four_timer.start()
		doors.process_mode = Node.PROCESS_MODE_INHERIT
		RenderingServer.set_default_clear_color(Color(0.1, 0.1, 0.1, 1.0))
	else:
		lazer_timer.stop()
		spike_timer.stop()
		bomb_timer.stop()
		bomb_four_timer.stop()
		
		for obj in all_bombs.get_children():
			if is_instance_valid(obj): obj.queue_free()
		for obj in all_spikes.get_children():
			if is_instance_valid(obj): obj.queue_free()
		for obj in all_lazers.get_children():
			if is_instance_valid(obj): obj.queue_free()
			
		doors.process_mode = Node.PROCESS_MODE_DISABLED
		RenderingServer.set_default_clear_color(Color(0.3, 0.3, 0.3, 1.0))
		
		if not is_game_start:
			anim_player.play("finished")
			for particle in room_particles.get_children():
				particle.emitting = true
			
			var used_room: Dictionary = {
				ValueStorer.used_room_x: id_x,
				ValueStorer.used_room_y: id_y
			}
			GameManager.used_rooms.append(used_room)
	start_area_collision.disabled = is_toggled
	
func _on_start_area_2d_area_entered(_area: Area2D) -> void:
	if is_executed or (id_x == 0 and id_y == 0):
		return
		
	GameManager.delete_room(id_x, id_y)
	GameManager.current_id_x = id_x
	GameManager.current_id_y = id_y
	GameManager.start_stage()
	GameManager.confirm_stage(self)
	call_deferred("start_stage", true)
	GameManager.spawn_enemies(first_point.global_position, last_point.global_position)
	pass # Replace with function body.

func is_valid_position(pos: Vector2, radius: float) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0, pos)
	query.shape = CircleShape2D.new()
	query.shape.radius = radius
	query.collide_with_bodies = true
	
	var result = space_state.intersect_shape(query)
	if result.is_empty():
		return true
		
	return false

func _on_lazer_timer_timeout() -> void:
	if is_executed:
		return
	
	if not is_instance_valid(GameManager.player):
		return
	
	var new_lazer: BaseLazer = lazer_scene.instantiate()
	var parent = self.find_child(ValueStorer.lazers_node)
	parent.add_child(new_lazer)
	new_lazer.warning_timer_value = lazer_warn_time
	new_lazer.finish_timer_value = lazer_harm_time
	new_lazer.global_position = GameManager.player.global_position
	new_lazer.rotation = randf_range(0, 360)
	pass # Replace with function body.

func _on_spike_timer_timeout() -> void:
	if is_executed:
		return
	
	if not is_instance_valid(GameManager.player):
		return
	
	var random_side: int = randi_range(0, 3)
	var node_side = spike_way_points.get_child(random_side)
	
	var side_first_point: Vector2 = node_side.get_child(0).position
	var side_last_point: Vector2 = node_side.get_child(1).position
	var confirmed_position: Vector2 = Vector2(
		randf_range(side_first_point.x, side_last_point.x),
		randf_range(side_first_point.y, side_last_point.y)
	)
	var confirmed_rotation: float = 90 * float(random_side)
	
	var new_spike: BigSpike = spike_scene.instantiate()
	var parent = find_child(ValueStorer.spikes_node)
	parent.add_child(new_spike)
	new_spike.ready_timer = spike_warn_time
	new_spike.spawn_timer = spike_harm_time
	new_spike.position = confirmed_position
	new_spike.rotation = deg_to_rad(confirmed_rotation)
	pass # Replace with function body.

func _on_bomb_timer_timeout() -> void:
	respawn_bomb(bomb_scene)
	pass # Replace with function body.

func _on_bomb_four_timer_timeout() -> void:
	respawn_bomb(bomb_four_scene)
	pass # Replace with function body.

func respawn_bomb(scene: PackedScene) -> void:
	if is_executed:
		return
	
	if not is_instance_valid(GameManager.player):
		return
	
	var begin_point: Vector2 = bomb_way_points.get_child(0).position
	var end_point: Vector2 = bomb_way_points.get_child(1).position
	var confirmed_position: Vector2 = Vector2(
		randf_range(begin_point.x, end_point.x),
		randf_range(begin_point.y, end_point.y)
	)
	while not is_valid_position(confirmed_position, ValueStorer.bomb_radius):
		confirmed_position = Vector2(
			randf_range(begin_point.x, end_point.x),
			randf_range(begin_point.y, end_point.y)
		)
	
	var new_bomb = scene.instantiate()
	var parent = find_child(ValueStorer.bombs_node)
	parent.add_child(new_bomb)
	if new_bomb is BombFour:
		new_bomb.warning_timer.wait_time = bomb_four_warn_time
		new_bomb.harmful_timer.wait_time = bomb_four_harm_time
	else:
		new_bomb.warning_timer.wait_time = bomb_warn_time
		new_bomb.harmful_timer.wait_time = bomb_harm_time
	new_bomb.position = confirmed_position
	pass
