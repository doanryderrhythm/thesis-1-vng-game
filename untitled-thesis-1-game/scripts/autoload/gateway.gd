extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1910

@onready var cert = load("res://resources/certificate/X509_certificate.crt")

var username
var password
var new_account
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
	
func connect_to_server(_username, _password, _new_account) -> void:
	if login_attempt_active:
		return
	login_attempt_active = true

	network = ENetMultiplayerPeer.new()
	gateway_api = SceneMultiplayer.new()
	
	username = _username
	password = _password
	new_account = _new_account
	
	var response := network.create_client(ip, port)
	if response != OK:
		print("Connection failed: ", response)
		_finish_login_attempt(false)
		return
	
	network.host.dtls_client_setup("EschapistMultiplayer", TLSOptions.client(cert))
	
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_connection_failed)
	_watch_login_timeout()

func _watch_login_timeout() -> void:
	await get_tree().create_timer(LOGIN_TIMEOUT_SECONDS).timeout
	if login_attempt_active:
		if new_account:
			print("Account creation request timed out")
		else:
			print("Login request timed out")
		_finish_login_attempt(false)

func _on_connection_succeeded() -> void:
	print("Successfully connected to login server")
	if new_account:
		request_create_account()
	else:
		request_login()
	
func _on_connection_failed() -> void:
	print("Failed to connect to login server")
	_finish_login_attempt(false)
	
func request_login() -> void:
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password.sha256_text())
	username = ""
	password = ""

func request_create_account() -> void:
	print("Connecting to gateway to request account creation")
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""

@rpc("any_peer") func login_request(_username, _password) -> void:
	pass
	
@rpc("any_peer") func create_account_request(_username, _password) -> void:
	pass
	
@rpc("any_peer") func return_login_request(results, token) -> void:
	if not login_attempt_active:
		return

	print("Results received")
	if results == true:
		Server.token = token
		Server.connect_to_server()
	else:
		print("Please provide correct username and password")
	_finish_login_attempt(results == true)

@rpc("any_peer") func return_create_account_request(results, message) -> void:
	if not login_attempt_active:
		return

	print("Results received")
	if results == true:
		print("Account created, please proceed with logging in")
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("The username already exist, please use a different username")
	_finish_login_attempt(false)

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
