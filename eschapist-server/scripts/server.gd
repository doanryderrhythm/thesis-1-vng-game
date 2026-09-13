extends Node

var network = ENetMultiplayerPeer.new()
var port = 1909
var max_players = 100

func _ready():
	start_server()

func start_server() -> void:
	var response := network.create_server(port, max_players)
	
	if response != OK:
		print("Failed to start server: ", response)
		return
	
	print("Server started")
	
	multiplayer.multiplayer_peer = network
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	print("Server started on port " + str(port))
	
func _peer_connected(player_id) -> void:
	print("User " + str(player_id) + " connected")	
	
func _peer_disconnected(player_id) -> void:
	print("User " + str(player_id) + " disconnected")
