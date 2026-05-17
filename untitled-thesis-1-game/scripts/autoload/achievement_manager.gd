extends Node

@onready var achievement_listener: AchievementListener = load("res://resources/achievements/achievement_listener.tres")

var is_surviving: bool = false

var is_dash: bool = false
var is_shoot: bool = false

var total_survival_time: float = 0.0
var total_stay_still: float = 0.0
var enemies_destroyed: int = 0
var enemies_destroyed_dash: int = 0
var enemies_destroyed_dash_same: int = 0
var enemies_destroyed_shoot: int = 0
var total_rooms_no_dash: int = 0
var total_rooms_no_shoot: int = 0
var total_phases_finished: int = 0

func _ready() -> void:
	EventBus.survival_time_added.connect(_on_survival_time_added)
	EventBus.phase_finished_added.connect(_on_phase_finished_added)
	EventBus.room_no_dash_added.connect(_on_room_no_dash_added)
	EventBus.room_no_shoot_added.connect(_on_room_no_shoot_added)
	EventBus.clutch.connect(_on_clutch)
	EventBus.lock_yourself.connect(_on_lock_yourself)
	EventBus.coin_check.connect(_on_coin_checked)
	EventBus.destroy_yourself.connect(_on_destroy_yourself)
	EventBus.enemy_destroyed.connect(_on_enemy_destroyed)
	EventBus.enemy_destroyed_dash.connect(_on_enemy_destroyed_dash)
	EventBus.enemy_destroyed_shoot.connect(_on_enemy_destroyed_shoot)
	EventBus.enemy_destroyed_dash_same.connect(_on_enemy_destroyed_dash_same)
	EventBus.stay_still_time_added.connect(_on_stay_still_time_added)
	EventBus.fully_heal.connect(_on_fully_healed)

#region FUNCTIONS CONNECTED TO EVENTS

func _on_survival_time_added(time_span: float) -> void:
	total_survival_time += time_span
	check_achievement("survival_0")

func _on_stay_still_time_added(time_span: float) -> void:
	total_stay_still += time_span
	check_achievement("stay_still_0")

func _on_enemy_destroyed(amount: int) -> void:
	enemies_destroyed += amount
	check_achievement("destroy_enemies_50")

func _on_enemy_destroyed_dash(amount: int) -> void:
	enemies_destroyed_dash += amount
	check_achievement("destroy_enemies_dash_30")

func _on_enemy_destroyed_shoot(amount: int) -> void:
	enemies_destroyed_shoot += amount
	check_achievement("destroy_enemies_shoot_30")

func _on_enemy_destroyed_dash_same() -> void:
	check_achievement("double_kill")
	check_achievement("triple_kill")
	check_achievement("quadruple_kill")
	check_achievement("penta_kill")
	enemies_destroyed_dash_same = 0

func _on_room_no_dash_added(amount: int) -> void:
	if is_dash:
		return
		
	total_rooms_no_dash += amount
	check_achievement("no_dash_10")

func _on_room_no_shoot_added(amount: int) -> void:
	if is_shoot:
		return
	
	total_rooms_no_shoot += amount
	check_achievement("no_bullet_10")

func _on_phase_finished_added(amount: int) -> void:
	total_phases_finished += amount
	check_achievement("phase_15")
	check_achievement("phase_30")

func _on_coin_checked(total_amount: int) -> void:
	if total_amount >= 100:
		check_achievement("coins_100")
	if total_amount >= 500:
		check_achievement("coins_500")
	if total_amount >= 2000:
		check_achievement("coins_2000")

func _on_destroy_yourself() -> void:
	check_achievement("bruh")

func _on_clutch() -> void:
	check_achievement("clutch")

func _on_lock_yourself() -> void:
	check_achievement("lock_yourself")

func _on_fully_healed() -> void:
	check_achievement("fully_healed")

#endregion

func find_achievement(ach_code: String) -> Achievement:
	for ach in achievement_listener.achievements:
		if ach.ach_code == ach_code:
			return ach
	return null

func reset_achievements_progress() -> void:
	is_dash = false
	is_shoot = false
	
	total_survival_time = 0.0
	total_stay_still = 0.0
	enemies_destroyed = 0
	enemies_destroyed_dash = 0
	enemies_destroyed_dash_same = 0
	enemies_destroyed_shoot = 0
	total_rooms_no_dash = 0
	total_rooms_no_shoot = 0
	total_phases_finished = 0

func check_achievement(ach_code: String) -> void:
	var ach: Achievement = find_achievement(ach_code)
	if ach == null:
		return
	if ach.is_applicable:
		ProfileManager.update_achievements(ach_code)
		return
	
	if ach.total_survival_time_enable:
		if total_survival_time < ach.total_survival_time: return
	if ach.total_stay_still_enable:
		if total_stay_still < ach.total_stay_still: return
	if ach.enemies_destroyed_enable:
		if enemies_destroyed < ach.enemies_destroyed: return
	if ach.enemies_destroyed_dash_enable:
		if enemies_destroyed_dash < ach.enemies_destroyed_dash: return
	if ach.enemies_destroyed_dash_same_enable:
		if enemies_destroyed_dash_same < ach.enemies_destroyed_dash_same: return
	if ach.enemies_destroyed_shoot_enable:
		if enemies_destroyed_shoot < ach.enemies_destroyed_shoot: return
	if ach.total_rooms_no_dash_enable:
		if total_rooms_no_dash < ach.total_rooms_no_dash: return
	if ach.total_rooms_no_shoot_enable:
		if total_rooms_no_shoot < ach.total_rooms_no_shoot: return
	if ach.total_phases_finished_enable:
		if total_phases_finished < ach.total_phases_finished: return
	
	ProfileManager.update_achievements(ach_code)
