extends Node

#region KEY MAPPING
var key_left: String = "left"
var key_right: String = "right"
var key_up: String = "up"
var key_down: String = "down"
var key_dash: String = "dash"
#endregion

#region NODE NAMES
var rooms_node: String = "Rooms"
var enemies_node: String = "Enemies"
var enemy_particles_node: String = "EnemyParticles"
var bullet_particles_node: String = "BulletParticles"
var bullets_node: String = "Bullets"
var lazers_node: String = "Lazers"
var spikes_node: String = "Spikes"
#endregion

#region VALUES
var velocity: float = 1000.0
var player_default_rate: float = 1.0
var player_dash_rate: float = 3.0
var enemy_radius: float = 55.0
var player_bullet_speed_mult: float = 3.0
var max_dash_count: int = 3
var dash_wait_time: float = 2.0
#endregion

#region HEALTH
var player_health: float = 100.0
var enemy_health: float = 50.0
#endregion

#region BULLETS
var bullet_min_angular_velocity: float = -6.0
var bullet_max_angular_velocity: float = 6.0
#endregion

#region ROOM
var room_distance: float = 3000.0
#endregion

#region COLORS
var circle_color_1_1: Color = Color.from_rgba8(255, 255, 0, 255)
var circle_color_2_1: Color = Color.from_rgba8(255, 255, 103, 255)
var circle_color_3_1: Color = Color.from_rgba8(255, 255, 161, 255)
var circle_color_4_1: Color = Color.from_rgba8(100, 100, 0, 255)

var circle_color_1_1_moving: Color = Color.from_rgba8(255, 131, 0, 255)
var circle_color_2_1_moving: Color = Color.from_rgba8(255, 173, 87, 255)
var circle_color_3_1_moving: Color = Color.from_rgba8(255, 212, 167, 255)
var circle_color_4_1_moving: Color = Color.from_rgba8(125, 64, 0, 255)

var diamond_color_1_1: Color = Color.from_rgba8(0, 88, 255, 255)
var diamond_color_2_1: Color = Color.from_rgba8(80, 140, 255, 255)
var diamond_color_4_1: Color = Color.from_rgba8(156, 191, 255, 255)

var diamond_color_1_1_moving: Color = Color.from_rgba8(151, 0, 255, 255)
var diamond_color_2_1_moving: Color = Color.from_rgba8(189, 94, 255, 255)
var diamond_color_4_1_moving: Color = Color.from_rgba8(213, 152, 255, 255)

var square_color_1_1: Color = Color.from_rgba8(0, 255, 0, 255)
var square_color_2_1: Color = Color.from_rgba8(99, 255, 99, 255)
var square_color_4_1: Color = Color.from_rgba8(160, 255, 160, 255)

var square_color_1_1_moving: Color = Color.from_rgba8(0, 255, 153, 255)
var square_color_2_1_moving: Color = Color.from_rgba8(88, 255, 188, 255)
var square_color_4_1_moving: Color = Color.from_rgba8(159, 255, 217, 255)

var triangle_color_1_1: Color = Color.from_rgba8(255, 0, 144, 255)
var triangle_color_1_2: Color = Color.from_rgba8(255, 75, 177, 255)
var triangle_color_2_1: Color = Color.from_rgba8(255, 150, 209, 255)
var triangle_color_3_1: Color = Color.from_rgba8(152, 0, 86, 255)
var triangle_color_3_2: Color = Color.from_rgba8(86, 0, 48, 255)

var triangle_color_1_1_moving: Color = Color.from_rgba8(255, 0, 0, 255)
var triangle_color_1_2_moving: Color = Color.from_rgba8(255, 79, 79, 255)
var triangle_color_2_1_moving: Color = Color.from_rgba8(255, 150, 150, 255)
var triangle_color_3_1_moving: Color = Color.from_rgba8(156, 0, 0, 255)
var triangle_color_3_2_moving: Color = Color.from_rgba8(80, 0, 0, 255)
#endregion
