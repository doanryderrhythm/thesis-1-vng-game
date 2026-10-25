extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var port = 1910
var max_players = 100

var cert = load("res://certificate/X509_certificate.crt")
var key = load("res://certificate/X509_key.key")

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
	
	network.host.dtls_server_setup(TLSOptions.server(key, cert))

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

@rpc("any_peer") func create_account_request(username, password) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var valid_request = true
	if username == "":
		valid_request = false
	if password == "":
		valid_request = false
	if password.length() <= 8:
		valid_request = false
	
	if valid_request == false:
		return_create_account_request(valid_request, player_id, 1)
	else:
		Authenticate.create_account(username, password, player_id)

@rpc("any_peer") func return_login_request(_result, _token) -> void:
	pass

@rpc("any_peer") func return_create_account_request(_result, _player_id, _message) -> void:
	pass

func send_login_result(result, player_id, token) -> void:
	rpc_id(player_id, "return_login_request", result, token)

func send_create_account_result(result, player_id, message) -> void:
	rpc_id(player_id, "return_create_account_request", result, message)
