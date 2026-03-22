extends Node2D
class_name BigSpike

@onready var spike_ready: AnimatedSprite2D = $SpikeReady
@onready var spike_spawn: Sprite2D = $SpikeSpawn
@onready var spike_blur: Sprite2D = $SpikeBlur

@onready var spawn_collider: CollisionShape2D = $HitArea2D/CollisionShape2D

var damage: float = 7.5

var ready_timer: float
var spawn_timer: float
var current_timer: float = 0

enum SpikeState {
	READY,
	SPAWN,
}

var state: SpikeState = SpikeState.READY

func _ready() -> void:
	spike_ready.play("default")
	
	spike_spawn.visible = false
	spike_blur.visible = false
	spawn_collider.disabled = true

func _process(delta: float) -> void:
	current_timer += delta
	if state == SpikeState.READY and current_timer >= ready_timer:
		current_timer -= ready_timer
		state = SpikeState.SPAWN
		spike_spawn.visible = true
		spike_blur.visible = true
		spawn_collider.disabled = false
	elif state == SpikeState.SPAWN and current_timer >= spawn_timer:
		if is_instance_valid(self):
			queue_free()
