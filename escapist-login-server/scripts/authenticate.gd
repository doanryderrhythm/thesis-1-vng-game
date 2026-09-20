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
		
	multiplayer.multiplayer_peer = network
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
func _peer_connected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " disconnected")
