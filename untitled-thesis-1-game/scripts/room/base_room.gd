extends Node2D
class_name Room

var id_x: int
var id_y: int

var is_executed: bool

@onready var first_point: Marker2D = $WayPoints/FirstPoint
@onready var last_point: Marker2D = $WayPoints/LastPoint

@onready var doors: Node2D = $Doors

@onready var start_area_collision: CollisionShape2D = $StartArea2D/CollisionShape2D

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
	doors.process_mode = (
		Node.PROCESS_MODE_INHERIT if is_toggled
		else Node.PROCESS_MODE_DISABLED
	)
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
