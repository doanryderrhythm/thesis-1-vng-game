extends ColorRect
class_name RoomIcon

enum RoomState {
	READY,
	AVAILABLE,
	FOUGHT,
	LOCKED
}

var state: RoomState

func _ready() -> void:
	pass
	
func change_state_visuals() -> void:
	if state == RoomState.READY:
		self.color = Color.WHITE
	elif state == RoomState.AVAILABLE:
		self.color = Color.YELLOW
	elif state == RoomState.FOUGHT:
		self.color = Color.GREEN
	elif state == RoomState.LOCKED:
		self.color = Color.RED
