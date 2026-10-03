extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1910

var username
var password
var login_attempt_active: bool = false

const LOGIN_TIMEOUT_SECONDS: float = 10.0

signal on_connection_finished(is_successful: bool)

func _ready():
	pass

func _process(_delta: float) -> void:
	if multiplayer == null:
		return
	
	if not multiplayer.has_multiplayer_peer():
		return
	
	multiplayer.poll()
	
func connect_to_server(_username, _password) -> void:
	if login_attempt_active:
		return
	login_attempt_active = true

	network = ENetMultiplayerPeer.new()
	gateway_api = SceneMultiplayer.new()
	username = _username
	password = _password
	
	var response := network.create_client(ip, port)
	if response != OK:
		print("Connection failed: ", response)
		_finish_login_attempt(false)
		return
	
	get_tree().set_multiplayer(gateway_api, self.get_path())
	
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_connection_failed)
	_watch_login_timeout()

func _watch_login_timeout() -> void:
	await get_tree().create_timer(LOGIN_TIMEOUT_SECONDS).timeout
	if login_attempt_active:
		print("Login request timed out")
		_finish_login_attempt(false)

func _on_connection_succeeded() -> void:
	print("Successfully connected to login server")
	request_login()
	
func _on_connection_failed() -> void:
	print("Failed to connect to login server")
	_finish_login_attempt(false)
	
func request_login() -> void:
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""

@rpc("any_peer") func login_request(_username, _password) -> void:
	pass
	
@rpc("any_peer") func return_login_request(results) -> void:
	if not login_attempt_active:
		return

	print("Results received")
	if results == true:
		Server.connect_to_server()
	else:
		print("Please provide correct username and password")
	_finish_login_attempt(results == true)

func _finish_login_attempt(is_successful: bool) -> void:
	if not login_attempt_active:
		return

	login_attempt_active = false
	if multiplayer.connected_to_server.is_connected(_on_connection_succeeded):
		multiplayer.connected_to_server.disconnect(_on_connection_succeeded)
	if multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.disconnect(_on_connection_failed)
	if multiplayer.server_disconnected.is_connected(_on_connection_failed):
		multiplayer.server_disconnected.disconnect(_on_connection_failed)
	multiplayer.multiplayer_peer = null
	on_connection_finished.emit(is_successful)
