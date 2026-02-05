extends BaseCharacter
class_name StaticEnemy

func _process(_delta: float) -> void:
	look_at(GameManager.player.position)
