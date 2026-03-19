extends TextureRect
class_name SkinUI

var skin_stats: PlayerStats

@onready var skin_placeholder: TextureRect = $SkinPlaceholder
@onready var move_speed_value_text: Label = $MoveSpeedValue
@onready var dash_speed_value_text: Label = $DashSpeedValue
@onready var shoot_speed_value_text: Label = $ShootSpeedValue
@onready var bullet_damage_value_text: Label = $BulletDamageValue
@onready var health_value_text: Label = $HealthValue

@onready var unlock_button: Button = $UnlockButton
@onready var unlock_label: Label = $UnlockButton/UnlockLabel

@onready var equip_button: Button = $EquipButton

func _ready() -> void:
	update_stats()

func update_stats() -> void:
	skin_placeholder.texture = skin_stats.sprite
	move_speed_value_text.text = str(skin_stats.move_speed / 100.0)
	dash_speed_value_text.text = str(skin_stats.dash_speed)
	shoot_speed_value_text.text = str(skin_stats.bullet_res.min_speed / 100.0) \
		+ " - " + str(skin_stats.bullet_res.max_speed / 100.0)
	bullet_damage_value_text.text = str(skin_stats.bullet_res.damage)
	health_value_text.text = str(skin_stats.health)
	
	unlock_label.text = "Unlock - " + str(skin_stats.requirement)
	pass

func unlock_player() -> void:
	unlock_button.set_process_mode(Node.PROCESS_MODE_DISABLED)
	unlock_button.visible = false
	
	equip_button.set_process_mode(Node.PROCESS_MODE_INHERIT)
	equip_button.visible = true
	pass

func attempt_to_unlock() -> void:
	if ProfileManager.total_coins < skin_stats.requirement:
		return
	
	ProfileManager.total_coins -= skin_stats.requirement
	unlock_button.pressed.emit()
	unlock_player()
	ProfileManager.unlocked_codes.append(skin_stats.code)
	SaveSystem.save_game()
	pass

func _on_unlock_button_pressed() -> void:
	attempt_to_unlock()
	pass # Replace with function body.
