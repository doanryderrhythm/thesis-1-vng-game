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

@onready var collectible_alert_label: Label = $CollectibleAlertLabel

@onready var danger_texture: TextureRect = $DangerTexture

@onready var gameplay_anim_player: AnimationPlayer = $GameplayAnimationPlayer
@onready var result_anim_player: AnimationPlayer = $ResultAnimationPlayer
@onready var debug_ui_anim_player: AnimationPlayer = $DebugUIAnimationPlayer
@onready var stats_change_anim_player: AnimationPlayer = $StatsChangeAnimationPlayer

#region RESULT
@onready var reason_to_lose_label: Label = $ResultNode/Background/ReasonLabel

@onready var destroyed_enemies_label: RichTextLabel = $ResultNode/Background/ContentContainer/StatsContainer/DestroyedEnemiesContainer/StatsValueLabel
@onready var level_reached_label: RichTextLabel = $ResultNode/Background/ContentContainer/StatsContainer/LevelReachedContainer/StatsValueLabel
@onready var phases_label: RichTextLabel = $ResultNode/Background/ContentContainer/StatsContainer/PhasesContainer/StatsValueLabel
@onready var total_score_label: RichTextLabel = $ResultNode/Background/ContentContainer/StatsContainer/ScoreContainer/StatsValueLabel

@onready var coins_label: RichTextLabel = $ResultNode/Background/ContentContainer/RewardsContainer/CoinsContainer/RewardsValueLabel
#endregion

#region PLAYER STATS
@onready var move_value: Label = $VBoxContainer/MoveStats/Value
@onready var dash_value: Label = $VBoxContainer/DashStats/Value
@onready var shoot_value: Label = $VBoxContainer/ShootStats/Value
#endregion

@onready var pause_ui: ColorRect = $PauseNode
@export var retire_string: String

@onready var minimap: ColorRect = $Minimap

#region TUTORIAL
var is_tutorial_on: bool = false
@onready var tutorial_canvas: TutorialCanvas = $TutorialCanvas
#endregion

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_instance_valid(GameManager.player):
		fill_dash_bar.value = GameManager.player._dash_wait_timer.time_left
	pass
	
func toggle_tutorial(is_toggled: bool) -> void:
	is_tutorial_on = is_toggled
	tutorial_canvas.visible = is_toggled
	if is_toggled:
		tutorial_canvas.tutorial_index = 0
		tutorial_canvas.show_tutorial()
		tutorial_canvas.set_process_mode(Node.PROCESS_MODE_INHERIT)
	else:
		tutorial_canvas.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
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
	change_in_game_stats()
	
	GameManager.health_change.connect(change_health)
	GameManager.dash_change.connect(change_dash)
	GameManager.state_lose_change.connect(show_restart)
	GameManager.start_level.connect(change_level)
	GameManager.end_level.connect(update_minimap)
	GameManager.phase_change.connect(change_phase)
	GameManager.score_change.connect(change_score)
	GameManager.coin_change.connect(change_coin)
	GameManager.stats_change.connect(change_in_game_stats)
	
	update_minimap()

func change_health() -> void:
	health_bar.value = GameManager.player.health
	print(GameManager.player.health)
	if GameManager.player.health <= 0:
		danger_texture.modulate = Color(1, 1, 1, 0)
		MusicManager.reset_pitch()
	elif GameManager.player.health <= 0.3 * ProfileManager.health:
		danger_texture.modulate = Color(1, 1, 1, 1 - \
		GameManager.player.health / (0.3 * ProfileManager.health))
		MusicManager.increase_pitch((0.3 * ProfileManager.health - GameManager.player.health) \
			/ (0.3 * ProfileManager.health))
	else:
		danger_texture.modulate = Color(1, 1, 1, 0)
		MusicManager.reset_pitch()

func change_dash() -> void:
	dash_bar.value = GameManager.player._dash_count
	if dash_bar.value == 0:
		debug_ui_anim_player.play("dash_waiting")
	else:
		debug_ui_anim_player.play("RESET")

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

func change_in_game_stats(collectible_type: GameManager.CollectibleType = GameManager.CollectibleType.NONE) -> void:
	if !GameManager.player and is_instance_valid(GameManager.player):
		pass
	
	move_value.text = "%.2f" % (ProfileManager.move_speed / 100.0 * GameManager.player._offset_move_speed)
	dash_value.text = "%.2f" % (GameManager.player._total_dash)
	shoot_value.text = "%.2f" % (ValueStorer.player_bullet_speed_mult + GameManager.player._offset_bullet_speed)
	
	if collectible_type == GameManager.CollectibleType.NONE:
		return
	elif collectible_type == GameManager.CollectibleType.DASH_LENGTH:
		collectible_alert_label.text = "+ dash speed"
		collectible_alert_label.label_settings.font_color = Color(0.493, 0.846, 1.0, 1.0)
	elif collectible_type == GameManager.CollectibleType.SHOOT_SPEED:
		collectible_alert_label.text = "+ shoot speed"
		collectible_alert_label.label_settings.font_color = Color(1.0, 0.969, 0.493, 1.0)
	elif collectible_type == GameManager.CollectibleType.WALK_SPEED:
		collectible_alert_label.text = "+ move speed"
		collectible_alert_label.label_settings.font_color = Color(0.493, 1.0, 0.625, 1.0)
	elif collectible_type == GameManager.CollectibleType.HEALTH:
		collectible_alert_label.text = "+ health"
		collectible_alert_label.label_settings.font_color = Color(1.0, 0.522, 0.493, 1.0)
	stats_change_anim_player.stop()
	stats_change_anim_player.play("default")

func update_result_screen() -> void:
	if GameManager.is_locked:
		reason_to_lose_label.text = ValueStorer.locked_string
	else:
		reason_to_lose_label.text = ValueStorer.died_string
		
	var coins: int = GameManager.in_level_coins
	
	var result_data: ResultData = null
	if GameManager.level_type == GameManager.LevelType.LEVEL_NORMAL:
		result_data = ProfileManager.normal_result_data
	elif GameManager.level_type == GameManager.LevelType.LEVEL_TERRAIN:
		result_data = ProfileManager.terrain_result_data
	elif GameManager.level_type == GameManager.LevelType.LEVEL_ICY:
		result_data = ProfileManager.icy_result_data
	
	var origin_total_destroyed_enemies: int = result_data.best_enemies_destroyed
	var origin_level_reached: int = result_data.best_level_reached
	var origin_total_successful_phases: int = result_data.best_successful_phases
	var origin_total_score: int = result_data.best_score
	
	var total_destroyed_enemies: int = GameManager.total_destroyed_enemies
	var level_reached: int = GameManager.current_actual_level + 1
	var total_successful_phases: int = GameManager.total_successful_phases
	var total_score: int = GameManager.total_score
	
	var difference_total_destroyed_enemies: int = total_destroyed_enemies - origin_total_destroyed_enemies
	var difference_level_reached: int = level_reached - origin_level_reached
	var difference_total_successful_phases: int = total_successful_phases - origin_total_successful_phases
	var difference_total_score: int = total_score - origin_total_score
	
	destroyed_enemies_label.text = str(total_destroyed_enemies) + " (" + convert_difference_string_int(difference_total_destroyed_enemies) + ")"
	level_reached_label.text = str(level_reached) + " (" + convert_difference_string_int(difference_level_reached) + ")"
	phases_label.text = str(total_successful_phases) + " (" + convert_difference_string_int(difference_total_successful_phases) + ")"
	total_score_label.text = str(total_score) + " (" + convert_difference_string_int(difference_total_score) + ")"

	coins_label.text = str(coins)
	
	ProfileManager.update_data(GameManager.level_type, \
								coins, \
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

func convert_difference_string_int(num: int) -> String:
	if num > 0: return "[color=green]+" + str(num) + "[/color]"
	if num == 0: return "[color=yellow]+" + str(num) + "[/color]"
	return "[color=red]" + str(num) + "[/color]"

func convert_difference_string_float(num: float) -> String:
	if num > 0.0: return "[color=green]+" + str(num) + "[/color]"
	if num == 0.0: return "[color=yellow]+" + str(num) + "[/color]"
	return "[color=red]" + str(num) + "[/color]"

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

func _on_tutorial_exit_button_pressed() -> void:
	toggle_tutorial(false)
	pass # Replace with function body.

func _on_tutorial_button_pressed() -> void:
	toggle_tutorial(true)
	pass # Replace with function body.
