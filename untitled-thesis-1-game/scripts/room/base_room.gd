extends Node2D
class_name Room

var id_x: int
var id_y: int

var is_executed: bool

@onready var first_point: Marker2D = $WayPoints/FirstPoint
@onready var last_point: Marker2D = $WayPoints/LastPoint

@onready var doors: Node2D = $Doors

@onready var start_area_collision: CollisionShape2D = $StartArea2D/CollisionShape2D

@onready var lazer_scene: PackedScene = preload("res://scenes/lazers/lazer_test.tscn")
@onready var lazer_timer: Timer = $LazerTimer

@onready var spike_scene: PackedScene = preload("res://scenes/spikes/big_spike.tscn")
@onready var spike_timer: Timer = $SpikeTimer
@onready var spike_way_points: Node2D = $SpikeWayPoints

func _ready() -> void:
	toggle_doors(false)
	pass

func init_detail(_id_x: int, _id_y: int) -> void:
	id_x = _id_x
	id_y = _id_y
	position = ValueStorer.room_distance * Vector2(float(id_x), float(id_y))
	is_executed = false
	print(str(id_x) + ", " + str(id_y))

func toggle_doors(is_toggled: bool) -> void:
	doors.visible = is_toggled
	if is_toggled:
		lazer_timer.start()
		spike_timer.start()
		doors.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		lazer_timer.stop()
		spike_timer.stop()
		doors.process_mode = Node.PROCESS_MODE_DISABLED
	start_area_collision.disabled = is_toggled
	
func _on_start_area_2d_area_entered(_area: Area2D) -> void:
	if is_executed or (id_x == 0 and id_y == 0):
		return
		
	call_deferred("toggle_doors", true)
	GameManager.delete_room(id_x, id_y)
	GameManager.current_id_x = id_x
	GameManager.current_id_y = id_y
	GameManager.start_stage()
	GameManager.spawn_enemies(first_point.global_position, last_point.global_position)
	pass # Replace with function body.

	
func is_valid_position(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0, pos)
	query.shape = CircleShape2D.new()
	query.shape.radius = ValueStorer.enemy_radius
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
	
	var new_lazer = lazer_scene.instantiate()
	var parent = self.find_child(ValueStorer.lazers_node)
	parent.add_child(new_lazer)
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
	
	var new_spike = spike_scene.instantiate()
	var parent = find_child(ValueStorer.spikes_node)
	parent.add_child(new_spike)
	new_spike.position = confirmed_position
	new_spike.rotation = deg_to_rad(confirmed_rotation)
	pass # Replace with function body.
