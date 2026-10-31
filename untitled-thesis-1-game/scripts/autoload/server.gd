extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909

var token

func _ready():
	pass
	
func connect_to_server() -> void:
	var response := network.create_client(ip, port)
	if response != OK:
		print("Player connection failed: ", response)
		return
		
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
func _on_connection_succeeded() -> void:
	print("Connection succeeded")

func _on_connection_failed() -> void:
	print("Connection failed")

@rpc("authority") func fetch_token() -> void:
	rpc_id(1, "return_token", token)

@rpc("any_peer") func return_token(_token) -> void:
	pass

@rpc("authority") func return_token_verification_results(result) -> void:
	if result == true:
		print("Successful token verification")
	else:
		print("Login failed, please try again")
