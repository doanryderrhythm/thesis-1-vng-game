extends Node

var total_coins: int = 0
var best_score: int = 0
var best_enemies_destroyed: int = 0
var best_level_reached: int = 0
var best_successful_phases: int = 0

var player_code: String

var unlocked_codes: Array[String]
var unlocked_achs: Array[String]

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

func update_data(coins: int, enemies: int, level_reached: int, phases: int, score: int) -> void:
	total_coins += coins
	if score >= best_score: best_score = score
	if enemies >= best_enemies_destroyed: best_enemies_destroyed = enemies
	if level_reached >= best_level_reached: best_level_reached = level_reached
	if phases >= best_successful_phases: best_successful_phases = phases

func update_achievements(ach_code: String) -> void:
	var is_found: bool = is_achievement_unlocked(ach_code)
	if is_found:
		return
	
	unlocked_achs.append(ach_code)
	AchievementLayer.receive_achievement(ach_code)

func is_achievement_unlocked(ach_code: String) -> bool:
	for ach in unlocked_achs:
		if ach == ach_code:
			return true
	return false
	
