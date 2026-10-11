extends Node

var X509_cert_filename = "X509_certificate.crt"
var X509_key_filename = "X509_key.key"

@onready var X509_cert_path = "user://certificate/" + X509_cert_filename
@onready var X509_key_path = "user://certificate/" + X509_key_filename

var CN = "EschapistMultiplayer"
var O = "DoanRyder"
var C = "VN"
var not_before = "20261011000000"
var not_after = "20271010235900"

func _ready() -> void:
	var error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://certificate")
	)

	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Failed to create Certificate directory: " + str(error))
		return

	create_X509_cert()

func create_X509_cert() -> void:
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
