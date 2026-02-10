extends Node2D
class_name Room

var id_x: int
var id_y: int

var is_executed: bool

func _ready() -> void:
	pass

func init_detail(_id_x: int, _id_y: int) -> void:
	id_x = _id_x
	id_y = _id_y
	position = ValueStorer.room_distance * Vector2(float(id_x), float(id_y))
	is_executed = false

func _on_start_area_2d_area_entered(_area: Area2D) -> void:
	GameManager.create_available_rooms(id_x, id_y)
	pass # Replace with function body.
