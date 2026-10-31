extends Node

var network = ENetMultiplayerPeer.new()
var port = 1911
var max_servers = 5

func _ready():
	start_server()
	
func start_server() -> void:
	var response := network.create_server(port, max_servers)
	if response != OK:
		print("Connection failed: ", response)
		return
	
	print("Authentication server started")
	
	multiplayer.multiplayer_peer = network
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
func _peer_connected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " disconnected")

@rpc("any_peer") func authenticate_player(username, password, player_id) -> void:
	var token = ""
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	
	if not PlayerData.player_ids.has(username):
		result = false
	else:
		var retrieved_salt = PlayerData.player_ids[username].get("salt", "")
		var hashed_password = generate_hashed_password(password, retrieved_salt)
		if not PlayerData.player_ids[username].get("password", "") == hashed_password:
			result = false
		else:
			randomize()
			var generated_token = str(randi()).sha256_text() + str(int(Time.get_unix_time_from_system()))
			var game_server = "GameServer1"
			if GameServers.distribute_login_token(generated_token, game_server):
				result = true
				token = generated_token
			else:
				result = false
	
	rpc_id(gateway_id, "authentication_results", result, player_id, token)

@rpc("any_peer") func create_account(username, password, player_id) -> void:
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var message
	if PlayerData.player_ids.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(password, salt)
		PlayerData.player_ids[username] = {
			"password": hashed_password,
			"salt": salt
		}
	
	rpc_id(gateway_id, "create_account_results", result, player_id, message)

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt

func generate_hashed_password(password, salt):
	var hashed_password = password
	var rounds = pow(2, 3)
	while rounds > 0:
		hashed_password = str(hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password

@rpc("any_peer") func authentication_results(_result, _player_id, _token) -> void:
	pass

@rpc("any_peer") func create_account_results(_result, _player_id, _message) -> void:
	pass
