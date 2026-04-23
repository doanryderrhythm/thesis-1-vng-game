extends Node

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var main_menu_music: AudioStreamOggVorbis = load("res://music/main_menu.ogg")

@onready var normal_music: AudioStreamOggVorbis = load("res://music/normal.ogg")
@onready var terrain_music: AudioStreamOggVorbis = load("res://music/terrain.ogg")
@onready var icy_music: AudioStreamOggVorbis = load("res://music/icy.ogg")

func change_music(music: AudioStreamOggVorbis) -> void:
	if music == stream_player.stream:
		return
	
	stream_player.stream = music
	stream_player.play()

func start_gameplay_music(level_type: GameManager.LevelType) -> void:
	if level_type == GameManager.LevelType.LEVEL_NORMAL:
		change_music(normal_music)
	elif level_type == GameManager.LevelType.LEVEL_TERRAIN:
		change_music(terrain_music)
	elif level_type == GameManager.LevelType.LEVEL_ICY:
		change_music(icy_music)

func stop_gameplay_music() -> void:
	stream_player.stop()

func toggle_filter_effect(is_toggled: bool) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(bus_index, 0, is_toggled)

func increase_pitch(value: float) -> void:
	stream_player.pitch_scale = 1.0 + value * 0.6

func reset_pitch() -> void:
	stream_player.pitch_scale = 1.0
