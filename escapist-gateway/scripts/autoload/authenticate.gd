extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1911

func _ready():
	connect_to_server()
	
func connect_to_server() -> void:
	var response := network.create_client(ip, port)
	if response != OK:
		print("Player connection failed: ", response)
		return
		
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
func _on_connection_succeeded() -> void:
	print("Successfully connected to authentication server")

func _on_connection_failed() -> void:
	print("Failed to connect to authentication server")
