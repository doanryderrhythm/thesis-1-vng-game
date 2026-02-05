extends CharacterBody2D
class_name BaseCharacter

var health: float
var direction_vector: Vector2 = Vector2.ZERO

var hit_collision
var hurt_collision

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass

func hurt(area: Area2D) -> void:
	var temp = area
	while temp.get_parent() != null:
		temp = temp.get_parent()
		if temp is BaseCharacter:
			break
	if temp is Player:
		queue_free()
	else:
		print("Enemies hurt player")
	pass
