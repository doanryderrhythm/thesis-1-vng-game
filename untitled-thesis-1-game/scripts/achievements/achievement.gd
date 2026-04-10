extends Resource
class_name Achievement

@export_group("Information")
@export var ach_code: String
@export var name: String
@export var description: String

@export_group("Properties")
@export var total_survival_time: float
@export var total_stay_still: float
@export var enemies_destroyed: int
@export var enemies_destroyed_dash: int
@export var enemies_destroyed_dash_same: int
@export var enemies_destroyed_shoot: int
@export var total_rooms_no_dash: int
@export var total_rooms_no_shoot: int
@export var total_phases_finished: int
@export var difficulties_played: int
