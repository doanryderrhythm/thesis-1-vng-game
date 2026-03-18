extends Node

var total_coins: int = 0

var player_code: String

var character_type: Player.CharacterType
var markers_pos: Array[Vector2]

var sprite: Texture2D
var health: float
var move_speed: float
var dash_speed: float
var bullet_res: BulletStats

func update_profile(player: PlayerStats) -> void:
	player_code = player.code
	character_type = player.character_type
	markers_pos = player.markers_pos
	sprite = player.sprite
	health = player.health
	move_speed = player.move_speed
	dash_speed = player.dash_speed
	bullet_res = player.bullet_res
