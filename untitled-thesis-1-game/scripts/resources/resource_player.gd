extends Resource
class_name PlayerStats

@export var requirement: int

@export var character_type: Player.CharacterType
@export var markers_pos: Array[Vector2]

@export var code: String

@export var sprite: Texture2D
@export var health: float
@export var move_speed: float
@export var dash_speed: float
@export var bullet_res: BulletStats
