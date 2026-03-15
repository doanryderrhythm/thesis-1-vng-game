extends CharacterBody2D
class_name BaseCharacter

@export var health: float
var direction_vector: Vector2 = Vector2.ZERO

var hit_collision
var hurt_collision

var is_dead: bool = false

signal dead

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass

func take_damage(_damage: float) -> void:
	pass

func hurt(_area: Area2D) -> void:
	pass
