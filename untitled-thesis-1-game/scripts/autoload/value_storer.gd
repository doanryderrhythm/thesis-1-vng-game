extends Node

# KEY MAPPING
var key_left: String = "left"
var key_right: String = "right"
var key_up: String = "up"
var key_down: String = "down"
var key_dash: String = "dash"

# NODE NAMES
var rooms_node: String = "Rooms"
var enemies_node: String = "Enemies"

# VALUES
var velocity: float = 1000.0
var player_default_rate: float = 1.0
var player_dash_rate: float = 3.0

# HEALTH
var player_health: float = 100.0
var enemy_health: float = 50.0

# BULLETS
var bullet_min_angular_velocity: float = -6.0
var bullet_max_angular_velocity: float = 6.0

# ROOM
var room_distance: float = 3000.0
