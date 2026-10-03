extends Node

var network = ENetMultiplayerPeer.new()
var port = 1909
var max_players = 100

var expected_tokens = []
@onready var player_verification_process = $PlayerVerification

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

func _on_token_expiration_timeout() -> void:
	var current_time = Time.get_unix_time_from_system()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() - 1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
	print("Expected Tokens: ")
	print(expected_tokens)

func fetch_token(player_id) -> void:
	rpc_id(player_id, "fetch_token")

@rpc("any_peer") func return_token(token) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	player_verification_process.verify(player_id, token)

func return_token_verification_results(player_id, result) -> void:
	rpc_id(player_id, "return_token_verification_results", result)
