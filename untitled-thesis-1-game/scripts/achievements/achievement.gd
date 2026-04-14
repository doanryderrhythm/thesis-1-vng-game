extends Resource
class_name Achievement

@export_group("Information")
@export var ach_code: String
@export var name: String
@export var description: String

@export_group("Is applicable?")
@export var is_applicable: bool

@export_group("Properties")
@export var total_survival_time_enable: bool
@export var total_survival_time: float

@export var total_stay_still_enable: bool
@export var total_stay_still: float

@export var enemies_destroyed_enable: bool
@export var enemies_destroyed: int

@export var enemies_destroyed_dash_enable: bool
@export var enemies_destroyed_dash: int

@export var enemies_destroyed_dash_same_enable: bool
@export var enemies_destroyed_dash_same: int

@export var enemies_destroyed_shoot_enable: bool
@export var enemies_destroyed_shoot: int

@export var total_rooms_no_dash_enable: bool
@export var total_rooms_no_dash: int

@export var total_rooms_no_shoot_enable: bool
@export var total_rooms_no_shoot: int

@export var total_phases_finished_enable: bool
@export var total_phases_finished: int
