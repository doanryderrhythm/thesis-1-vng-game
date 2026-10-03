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
	print("Authentication request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	
	print("Starting authentication")
	if not PlayerData.player_ids.has(username):
		print("User not recognized")
		result = false
	elif not PlayerData.player_ids[username].password == password:
		print("Incorrect password")
		result = false
	else:
		print("Successful authentication")
		result = true
	
	print("Authentication result send to gateway server")
	rpc_id(gateway_id, "authentication_results", result, player_id)

@rpc("any_peer") func authentication_results(_result, _player_id) -> void:
	pass
