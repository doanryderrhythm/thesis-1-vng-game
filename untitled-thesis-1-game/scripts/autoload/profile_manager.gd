extends Node

var is_tutorial_finished: bool = false

var total_coins: int = 0

var normal_result_data: ResultData = ResultData.new()
var terrain_result_data: ResultData = ResultData.new()
var icy_result_data: ResultData = ResultData.new()

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

signal custom_index_selected

func update_profile(player: PlayerStats) -> void:
	player_code = player.code
	character_type = player.character_type
	markers_pos = player.markers_pos
	sprite = player.sprite
	health = player.health
	move_speed = player.move_speed
	dash_speed = player.dash_speed
	bullet_res = player.bullet_res

func update_data(level_type: GameManager.LevelType, coins: int, enemies: int, level_reached: int, phases: int, score: int) -> void:
	total_coins += coins
	var result_data: ResultData = null
	
	if level_type == GameManager.LevelType.LEVEL_NORMAL:
		result_data = normal_result_data
	elif level_type == GameManager.LevelType.LEVEL_TERRAIN:
		result_data = terrain_result_data
	elif level_type == GameManager.LevelType.LEVEL_ICY:
		result_data = icy_result_data
	
	if result_data == null:
		return
	
	if score >= result_data.best_score: result_data.best_score = score
	if enemies >= result_data.best_enemies_destroyed: result_data.best_enemies_destroyed = enemies
	if level_reached >= result_data.best_level_reached: result_data.best_level_reached = level_reached
	if phases >= result_data.best_successful_phases: result_data.best_successful_phases = phases

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
	
