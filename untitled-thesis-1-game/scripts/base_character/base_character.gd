extends CharacterBody2D
class_name BaseCharacter

@export var health: float
var direction_vector: Vector2 = Vector2.ZERO

var hit_collision
var hurt_collision

signal dead

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass

func take_damage(_damage: float) -> void:
	health -= _damage
	if health <= 0:
		if self is BaseEnemy:
			dead.emit()
		queue_free()

func hurt(area: Area2D) -> void:
	var temp = area
	while temp.get_parent() != null:
		temp = temp.get_parent()
		if temp is BaseCharacter:
			break
	if temp is Player:
		queue_free()
		dead.emit()
	else:
		take_damage(5.0)
	pass
