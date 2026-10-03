extends Node

@onready var main_interface = self.get_parent()
@onready var player_container_scene = preload("res://instances/player_container.tscn")

var awaiting_verification = {}

func start(player_id) -> void:
	awaiting_verification[player_id] = {
		"timestamp": Time.get_unix_time_from_system()
	}
	main_interface.fetch_token(player_id)

func verify(player_id, token) -> void:
	var token_verification = false
	while Time.get_unix_time_from_system() - int(token.right(64)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	main_interface.return_token_verification_results(player_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(player_id)
		main_interface.multiplayer.multiplayer_peer.disconnect_peer(player_id)

func _on_verification_expiration_timeout() -> void:
	var current_time = Time.get_unix_time_from_system()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].timestamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = Array(multiplayer.get_peers())
				if connected_peers.has(key):
					main_interface.return_token_verification_results(key, false)
					main_interface.multiplayer.multiplayer_peer.disconnect_peer(key)
	print("Awaiting verification: ")
	print(awaiting_verification)
