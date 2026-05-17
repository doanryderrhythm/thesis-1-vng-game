extends Node

signal survival_time_added(time_span: float)
signal stay_still_time_added(time_span: float)
signal enemy_destroyed(amount: int)
signal enemy_destroyed_dash(amount: int)
signal enemy_destroyed_dash_same()
signal enemy_destroyed_shoot(amount: int)
signal room_no_dash_added(amount: int)
signal room_no_shoot_added(amount: int)
signal phase_finished_added(amount: int)

signal clutch
signal lock_yourself
signal destroy_yourself
signal fully_heal
signal coin_check(amount: int)
