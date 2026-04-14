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
