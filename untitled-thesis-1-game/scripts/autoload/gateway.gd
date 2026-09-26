extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1910

var username
var password

func _ready():
	pass

func _process(_delta: float) -> void:
	if multiplayer == null:
		return
	
	if not multiplayer.has_multiplayer_peer():
		return
	
	multiplayer.poll()
	
func connect_to_server(_username, _password) -> void:
	network = ENetMultiplayerPeer.new()
	gateway_api = SceneMultiplayer.new()
	username = _username
	password = _password
	
	var response := network.create_client(ip, port)
	if response != OK:
		print("Connection failed: ", response)
		return
	
	get_tree().set_multiplayer(gateway_api)
	
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_succeeded() -> void:
	print("Successfully connected to login server")
	request_login()
	
func _on_connection_failed() -> void:
	print("Failed to connect to login server")
	# GET THE BUTTON TO ENABLE
	
func request_login() -> void:
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""
	
@rpc("any_peer") func return_login_request(results) -> void:
	print("Results received")
	if results == true:
		Server.connect_to_server()
		# DISABLE LOGIN SCREEN
	else:
		print("Please provide correct username and password")
		# REENABLE LOGIN BUTTON
	multiplayer.connected_to_server.disconnect(_on_connection_succeeded)
	multiplayer.connection_failed.disconnect(_on_connection_failed)
