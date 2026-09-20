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
	
func _on_connection_failed() -> void:
	print("Failed to connect to login server")
