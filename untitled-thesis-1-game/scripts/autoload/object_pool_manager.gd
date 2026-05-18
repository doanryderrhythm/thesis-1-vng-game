extends Node

var max_bullet_count: int = 500

var enemy_bullets_pool: Array[BaseBullet] = []
var player_bullets_pool: Array[PlayerBullet] = []

var enemy_bullet_scene: PackedScene = preload("res://scenes/bullets/base_bullet.tscn")
var player_bullet_scene: PackedScene = preload("res://scenes/bullets/player_bullet.tscn")

var enemy_bullet_index: int = 0
var player_bullet_index: int = 0

func _ready() -> void:
	for i in max_bullet_count:
		var enemy_bullet: BaseBullet = enemy_bullet_scene.instantiate()
		add_child(enemy_bullet)
		enemy_bullets_pool.append(enemy_bullet)
		enemy_bullet.reset_bullet()
		
		var player_bullet: PlayerBullet = player_bullet_scene.instantiate()
		add_child(player_bullet)
		player_bullets_pool.append(player_bullet)
		player_bullet.reset_bullet()

func get_bullet_from_enemy_pool() -> BaseBullet:
	var bullet: BaseBullet = enemy_bullets_pool[enemy_bullet_index]
	enemy_bullet_index = wrapi(enemy_bullet_index + 1, 0, max_bullet_count)
	return bullet

func get_bullet_from_player_pool() -> PlayerBullet:
	var bullet: PlayerBullet = player_bullets_pool[player_bullet_index]
	player_bullet_index = wrapi(player_bullet_index + 1, 0, max_bullet_count)
	return bullet
