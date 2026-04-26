extends ColorRect
class_name ProfileCard

var highest_enemies: int
var highest_level: int
var highest_phases: int
var highest_score: int

@onready var highest_enemies_text: Label = $StatsList/HighestEnemies/Value
@onready var highest_level_text: Label = $StatsList/HighestLevel/Value
@onready var highest_phases_text: Label = $StatsList/HighestPhases/Value
@onready var highest_score_text: Label = $StatsList/HighestScore/Value

func insert_data(enemies: int, level: int, \
	phases: int, score: int) -> void:
	highest_enemies_text.text = str(enemies)
	highest_level_text.text = str(level)
	highest_phases_text.text = str(phases)
	highest_score_text.text = str(score)
