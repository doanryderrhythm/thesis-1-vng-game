extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1912

@onready var game_server = get_node("/root/Server")

func _ready():
	connect_to_server()

func _process(_delta: float) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	
	multiplayer.poll()
	
func connect_to_server() -> void:
	var response := network.create_client(ip, port)
	if response != OK:
		print("Player connection failed: ", response)
		return
		
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
func _on_connection_succeeded() -> void:
	print("Successfully connected to game server hub")

func _on_connection_failed() -> void:
	print("Failed to connect to game server hub")

@rpc("any_peer") func receive_login_token(token) -> void:
	game_server.expected_tokens.append(token)
