extends Node

var is_surviving: bool = false

var total_survival_time: float = 0.0
var total_stay_still: float = 0.0
var enemies_destroyed: int = 0
var enemies_destroyed_dash: int = 0
var enemies_destroyed_dash_same: int = 0
var enemies_destroyed_shoot: int = 0
var total_rooms_no_dash: int = 0
var total_rooms_no_shoot: int = 0
var total_phases_finished: int = 0

func reset_achievements() -> void:
	total_survival_time = 0.0
	total_stay_still = 0.0
	enemies_destroyed = 0
	enemies_destroyed_dash = 0
	enemies_destroyed_dash_same = 0
	enemies_destroyed_shoot = 0
	total_rooms_no_dash = 0
	total_rooms_no_shoot = 0
	total_phases_finished = 0
