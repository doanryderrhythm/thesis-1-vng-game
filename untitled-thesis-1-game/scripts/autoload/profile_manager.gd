extends Node

var total_coins: int = 0
var best_score: int
var best_enemies_destroyed: int
var best_survival_time: int
var best_level_reached: int
var best_successful_phases: int

var player_code: String

var unlocked_codes: Array[String]

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

func update_data(coins: int, survival_time: int, enemies: int, level_reached: int, phases: int, score: int) -> void:
	total_coins += coins
	if score >= best_score: best_score = score
	if enemies >= best_enemies_destroyed: best_enemies_destroyed = enemies
	if survival_time >= best_survival_time: best_survival_time = survival_time
	if level_reached >= best_level_reached: best_level_reached = level_reached
	if phases >= best_successful_phases: best_successful_phases = phases
