extends Node2D
class_name BigSpike

@onready var spike_ready: AnimatedSprite2D = $SpikeReady
@onready var spike_spawn: Sprite2D = $SpikeSpawn

@onready var ready_timer: Timer = $ReadyTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_collider: CollisionShape2D = $HitArea2D/CollisionShape2D

var damage: float = 7.5

func _ready() -> void:
	spike_ready.play("default")
	
	spike_spawn.visible = false
	spawn_collider.disabled = true

func _on_ready_timer_timeout() -> void:
	spike_spawn.visible = true
	spawn_timer.start()
	spawn_collider.disabled = false
	pass # Replace with function body.

func _on_spawn_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
