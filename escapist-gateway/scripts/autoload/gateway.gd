extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var port = 1910
var max_players = 100

func _ready() -> void:
	start_server()
	
func _process(_delta: float) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	
	multiplayer.poll()

func start_server() -> void:
	var response := network.create_server(port, max_players)
	if response != OK:
		print("Connection failed: ", response)
		return

	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _peer_connected(player_id) -> void:
	print("User " + str(player_id) + " connected")
	
func _peer_disconnected(player_id) -> void:
	print("User " + str(player_id) + " disconnected")

@rpc("any_peer") func login_request(username, password) -> void:
	print("Login request received")
	var player_id = multiplayer.get_remote_sender_id()
	Authenticate.authenticate_player(username, password, player_id)

@rpc("any_peer") func return_login_request(_result) -> void:
	pass

func send_login_result(result, player_id) -> void:
	rpc_id(player_id, "return_login_request", result)
