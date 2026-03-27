extends Resource
class_name StageStats

@export var phase_count: int

@export var min_enemy: int
@export var max_enemy: int

@export_group("Lazer")
@export var is_lazer: bool
@export var lazer_spawn_rate: float
@export var lazer_warn_time: float
@export var lazer_stay_time: float

@export_group("Spike")
@export var is_spike: bool
@export var spike_spawn_rate: float
@export var spike_warn_time: float
@export var spike_stay_time: float

@export_group("Bomb")
@export var is_bomb: bool
@export var bomb_spawn_rate: float
@export var bomb_warn_time: float
@export var bomb_stay_time: float

@export_group("Bomb-Four")
@export var is_bomb_four: bool
@export var bomb_four_spawn_rate: float
@export var bomb_four_warn_time: float
@export var bomb_four_stay_time: float

@export_group("Bomb-Pellet")
@export var is_bomb_pellet: bool
@export var bomb_pellet_spawn_rate: float
@export var bomb_pellet_warn_time: float
@export var bomb_pellet_stay_time: float
@export var bomb_pellet_shoot_attempts: int

@export_group("Bomb-Move")
@export var is_bomb_move: bool
@export var bomb_move_spawn_rate: float
@export var bomb_move_warn_time: float
