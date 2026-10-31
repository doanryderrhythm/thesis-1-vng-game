extends Node

@onready var main_interface = self.get_parent()
@onready var player_container_scene = preload("res://instances/player_container.tscn")

var awaiting_verification = {}

func start(player_id) -> void:
	if awaiting_verification.has(player_id):
		return

	awaiting_verification[player_id] = {
		"timestamp": Time.get_unix_time_from_system()
	}
	main_interface.request_token(player_id)

func verify(player_id, token) -> void:
	if not awaiting_verification.has(player_id):
		return

	if typeof(token) != TYPE_STRING or token.length() <= 64:
		_fail_verification(player_id)
		return

	var token_timestamp = token.substr(64)
	if not token_timestamp.is_valid_int():
		_fail_verification(player_id)
		return

	var timestamp = token_timestamp.to_int()
	var current_time = Time.get_unix_time_from_system()
	if timestamp > current_time or current_time - timestamp > 30:
		_fail_verification(player_id)
		return

	while awaiting_verification.has(player_id):
		current_time = Time.get_unix_time_from_system()
		if timestamp > current_time or current_time - timestamp > 30:
			_fail_verification(player_id)
			return

		if main_interface.expected_tokens.has(token):
			main_interface.expected_tokens.erase(token)
			awaiting_verification.erase(player_id)
			main_interface.send_token_verification_result(player_id, true)
			return

		var elapsed = current_time - awaiting_verification[player_id].timestamp
		if elapsed >= 30:
			_fail_verification(player_id)
			return

		await get_tree().create_timer(1.0).timeout

func cancel(player_id) -> void:
	awaiting_verification.erase(player_id)

func _fail_verification(player_id) -> void:
	if not awaiting_verification.has(player_id):
		return

	awaiting_verification.erase(player_id)
	var connected_peers = Array(main_interface.multiplayer.get_peers())
	if connected_peers.has(player_id):
		main_interface.send_token_verification_result(player_id, false)
		main_interface.multiplayer.multiplayer_peer.disconnect_peer(player_id)

func _on_verification_expiration_timeout() -> void:
	var current_time = Time.get_unix_time_from_system()
	for player_id in awaiting_verification.keys():
		var start_time = awaiting_verification[player_id].timestamp
		if current_time - start_time >= 30:
			_fail_verification(player_id)
	print("Awaiting verification: ")
	print(awaiting_verification)
