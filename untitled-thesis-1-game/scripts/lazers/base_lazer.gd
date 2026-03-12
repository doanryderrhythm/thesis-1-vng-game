extends Node2D
class_name BaseLazer

@onready var raycast_A: RayCast2D = $RayCasts/RayCastA
@onready var raycast_B: RayCast2D = $RayCasts/RayCastB

@onready var point_A: Sprite2D = $LazerPoints/PointA
@onready var point_B: Sprite2D = $LazerPoints/PointB

@onready var warning_lazer: Line2D = $WarningLazer
@onready var finish_lazer: Line2D = $FinishLazer

@onready var warning_timer: Timer = $WarningTimer
@onready var finish_timer: Timer = $FinishTimer

@onready var lazer_hit_collision: CollisionShape2D = $HitArea2D/CollisionShape2D

@onready var lazer_shoot_audio: AudioStreamPlayer2D = $LazerShootAudio

var is_spawned: bool = false;

var warning_timer_value: float = 1.5
var finish_timer_value: float = 1

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var damage: float = 12.5

func _ready() -> void:
	lazer_hit_collision.disabled = true
	
	warning_timer.wait_time = warning_timer_value
	finish_timer.wait_time = finish_timer_value
	
	warning_timer.start()

func _process(_delta: float) -> void:
	warning_lazer.default_color = Color(1, 1, 1, 0.5 * (1 - warning_timer.time_left / warning_timer_value))
	pass

func _physics_process(_delta: float) -> void:
	if raycast_A.is_colliding() and raycast_B.is_colliding() and !is_spawned:
		var pos_A = raycast_A.get_collision_point()
		var pos_B = raycast_B.get_collision_point()
		point_A.position = to_local(pos_A)
		point_B.position = to_local(pos_B)
		anim_player.play("default")
		warning_lazer.clear_points()
		warning_lazer.add_point(to_local(pos_A))
		warning_lazer.add_point(to_local(pos_B))
		finish_lazer.clear_points()
		finish_lazer.add_point(to_local(pos_A))
		finish_lazer.add_point(to_local(pos_B))
		lazer_hit_collision.shape.a = to_local(pos_A)
		lazer_hit_collision.shape.b = to_local(pos_B)
		is_spawned = true

func _on_warning_timer_timeout() -> void:
	finish_lazer.visible = true
	finish_lazer.process_mode = Node.PROCESS_MODE_INHERIT
	finish_timer.start()
	lazer_shoot_audio.play()
	
	lazer_hit_collision.disabled = false
	pass # Replace with function body.

func _on_finish_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
