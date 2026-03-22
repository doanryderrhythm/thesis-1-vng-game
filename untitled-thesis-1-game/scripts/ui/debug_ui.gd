extends CanvasLayer
class_name DebugUI

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var dash_bar: TextureProgressBar = $DashBar
@onready var fill_dash_bar: ProgressBar = $FillDashBar

@onready var coin_value_label: Label = $CoinBar/CoinValueLabel

@onready var result_screen: ColorRect = $ResultNode
@onready var score_label: Label = $ScoreLabel

@onready var level_label: Label = $LevelLabel

@onready var phase_title_label: Label = $PhaseTitleLabel
@onready var phase_label: Label = $PhaseLabel

@onready var danger_texture: TextureRect = $DangerTexture

@onready var gameplay_anim_player: AnimationPlayer = $GameplayAnimationPlayer
@onready var result_anim_player: AnimationPlayer = $ResultAnimationPlayer

#region RESULT
@onready var reason_to_lose_label: Label = $ResultNode/Background/ReasonLabel

@onready var survival_time_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/SurvivalTimeContainer/StatsValueLabel
@onready var destroyed_enemies_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/DestroyedEnemiesContainer/StatsValueLabel
@onready var level_reached_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/LevelReachedContainer/StatsValueLabel
@onready var phases_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/PhasesContainer/StatsValueLabel
@onready var total_score_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/ScoreContainer/StatsValueLabel

@onready var coins_label: Label = $ResultNode/Background/ContentContainer/RewardsContainer/CoinsContainer/RewardsValueLabel
@onready var achievements_label: Label = $ResultNode/Background/ContentContainer/RewardsContainer/AchievementsContainer/RewardsValueLabel
#endregion

@onready var pause_ui: ColorRect = $PauseNode
@export var retire_string: String

@onready var minimap: ColorRect = $Minimap

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_instance_valid(GameManager.player):
		fill_dash_bar.value = GameManager.player._dash_wait_timer.time_left
	pass
	
func set_up() -> void:
	health_bar.min_value = 0
	health_bar.max_value = ProfileManager.health
	print(health_bar.min_value)
	print(health_bar.max_value)
	
	dash_bar.min_value = 0
	dash_bar.max_value = ValueStorer.max_dash_count
	
	fill_dash_bar.min_value = 0
	fill_dash_bar.max_value = ValueStorer.dash_wait_time
	
	result_screen.visible = false
	
	change_health()
	change_dash()
	change_phase(false)
	change_score()
	change_coin()
	
	GameManager.health_change.connect(change_health)
	GameManager.dash_change.connect(change_dash)
	GameManager.state_lose_change.connect(show_restart)
	GameManager.start_level.connect(change_level)
	GameManager.end_level.connect(update_minimap)
	GameManager.phase_change.connect(change_phase)
	GameManager.score_change.connect(change_score)
	GameManager.coin_change.connect(change_coin)
	
	update_minimap()

func change_health() -> void:
	health_bar.value = GameManager.player.health
	print(GameManager.player.health)
	if GameManager.player.health <= 0:
		danger_texture.modulate = Color(1, 1, 1, 0)
	elif GameManager.player.health <= 0.3 * ProfileManager.health:
		danger_texture.modulate = Color(1, 1, 1, 1 - \
		GameManager.player.health / (0.3 * ProfileManager.health))
	else:
		danger_texture.modulate = Color(1, 1, 1, 0)

func change_dash() -> void:
	dash_bar.value = GameManager.player._dash_count

func change_score() -> void:
	score_label.text = str(GameManager.total_score)
	pass

func change_coin() -> void:
	coin_value_label.text = str(GameManager.in_level_coins)
	
func change_level() -> void:
	level_label.text = str(GameManager.current_actual_level + 1)
	gameplay_anim_player.play("level_appear")
	minimap.visible = false
	
func change_phase(is_ongoing: bool) -> void:
	if is_ongoing:
		phase_title_label.visible = true
		phase_label.visible = true
		
		phase_label.text = str(GameManager.max_phase - GameManager.current_phase + 1) \
						+ "/" + str(GameManager.max_phase)
	else:
		phase_title_label.visible = false
		phase_label.visible = false

func update_result_screen() -> void:
	if GameManager.is_locked:
		reason_to_lose_label.text = ValueStorer.locked_string
	else:
		reason_to_lose_label.text = ValueStorer.died_string
	
	var coins: int = GameManager.in_level_coins
	var survival_time: int = int(GameManager.survival_time)
	var total_destroyed_enemies: int = GameManager.total_destroyed_enemies
	var level_reached: int = GameManager.current_actual_level + 1
	var total_successful_phases: int = GameManager.total_successful_phases
	var total_score: int = GameManager.total_score
	
	survival_time_label.text = str(survival_time)
	destroyed_enemies_label.text = str(total_destroyed_enemies)
	level_reached_label.text = str(level_reached)
	phases_label.text = str(total_successful_phases)
	total_score_label.text = str(total_score)

	coins_label.text = str(coins)
	achievements_label.text = "nope"
	
	ProfileManager.update_data(coins, \
								survival_time, \
								total_destroyed_enemies, \
								level_reached, \
								total_successful_phases, \
								total_score)
	SaveSystem.save_game()

func show_restart() -> void:
	result_anim_player.play("default")
	update_result_screen()
	result_screen.visible = true
	pass

func update_minimap() -> void:
	var id_x: int = GameManager.current_id_x
	var id_y: int = GameManager.current_id_y
	
	var offset_y: int = -2
	for row in minimap.get_children():
		var offset_x: int = -2
		for column in row.get_children():
			if column is not RoomIcon:
				return
			
			if GameManager.current_id_x == id_x + offset_x and \
			GameManager.current_id_y == id_y + offset_y:
				column.state = RoomIcon.RoomState.FOUGHT
				column.change_state_visuals()
				offset_x += 1
				continue
				
			if GameManager.find_used_room(id_x + offset_x, id_y + offset_y):
				column.state = RoomIcon.RoomState.LOCKED
			elif (abs(offset_x) == 1 and abs(offset_y) == 0) or \
			(abs(offset_x) == 0 and abs(offset_y) == 1):
				column.state = RoomIcon.RoomState.AVAILABLE
			else:
				column.state = RoomIcon.RoomState.READY
			column.change_state_visuals()
			offset_x += 1
		offset_y += 1
		
	minimap.visible = true

func toggle_pause(is_toggled: bool) -> void:
	pause_ui.visible = is_toggled
	get_tree().paused = is_toggled

func retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func retire() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(retire_string)

func _on_resume_button_pressed() -> void:
	toggle_pause(false)
	pass # Replace with function body.

func _on_retry_button_pressed() -> void:
	retry()
	pass # Replace with function body.

func _on_retire_button_pressed() -> void:
	retire()
	pass # Replace with function body.
