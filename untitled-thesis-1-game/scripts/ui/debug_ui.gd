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

@onready var stats_value_label: Label = $ResultNode/Background/ContentContainer/StatsContainer/HBoxContainer/StatsValueLabel
@onready var rewards_value_label: Label = $ResultNode/Background/ContentContainer/RewardsContainer/HBoxContainer/RewardsValueLabel

@onready var pause_ui: ColorRect = $PauseNode
@export var retire_string: String

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_instance_valid(GameManager.player):
		fill_dash_bar.value = GameManager.player._dash_wait_timer.time_left
	pass
	
func set_up() -> void:
	health_bar.min_value = 0
	health_bar.max_value = ProfileManager.health
	
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
	GameManager.phase_change.connect(change_phase)
	GameManager.score_change.connect(change_score)
	GameManager.coin_change.connect(change_coin)

func change_health() -> void:
	health_bar.value = GameManager.player.health
	if GameManager.player.health <= 0:
		danger_texture.modulate = Color(1, 1, 1, 0)
	elif GameManager.player.health <= 0.3 * ProfileManager.health:
		danger_texture.modulate = Color(1, 1, 1, 1 - GameManager.player.health / (0.3 * ProfileManager.health))
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
	
func change_phase(is_ongoing: bool) -> void:
	if is_ongoing:
		phase_title_label.visible = true
		phase_label.visible = true
		
		phase_label.text = str(GameManager.current_phase)
	else:
		phase_title_label.visible = false
		phase_label.visible = false

func update_result_screen() -> void:
	stats_value_label.text = str(int(GameManager.survival_time)) + "\n" + \
							str(GameManager.total_destroyed_enemies) + "\n" + \
							str(GameManager.current_actual_level + 1) + "\n" + \
							str(GameManager.total_successful_phases) + "\n" + \
							str(GameManager.total_score)
	rewards_value_label.text = str(GameManager.in_level_coins) + "\nnope"

func show_restart() -> void:
	result_anim_player.play("default")
	update_result_screen()
	result_screen.visible = true
	pass

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
