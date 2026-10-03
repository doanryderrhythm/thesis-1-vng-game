extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var port = 1912
var max_players = 100

var game_server_list = {}

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
	print("GameServerHub started")
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _peer_connected(game_server_id) -> void:
	print("Game server " + str(game_server_id) + " connected")
	game_server_list["GameServer1"] = game_server_id
	print(game_server_list)
	
func _peer_disconnected(game_server_id) -> void:
	print("Game server " + str(game_server_id) + " disconnected")

func distribute_login_token(token, game_server) -> void:
	var game_server_peer_id = game_server_list[game_server]
	rpc_id(game_server_peer_id, "receive_login_token", token)
