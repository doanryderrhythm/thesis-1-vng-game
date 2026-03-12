extends TextureRect
class_name SkinUI

var skin_stats: PlayerStats

@onready var skin_placeholder: TextureRect = $SkinPlaceholder
@onready var move_speed_value_text: Label = $MoveSpeedValue
@onready var dash_speed_value_text: Label = $DashSpeedValue
@onready var shoot_speed_value_text: Label = $ShootSpeedValue
@onready var bullet_damage_value_text: Label = $BulletDamageValue
@onready var health_value_text: Label = $HealthValue

@onready var equip_button: Button = $EquipButton

func _ready() -> void:
	update_stats()

func update_stats() -> void:
	skin_placeholder.texture = skin_stats.sprite
	move_speed_value_text.text = str(skin_stats.move_speed / 100.0)
	dash_speed_value_text.text = str(skin_stats.dash_speed)
	shoot_speed_value_text.text = str(skin_stats.bullet_res.min_speed) + " - " + str(skin_stats.bullet_res.max_speed)
	bullet_damage_value_text.text = str(skin_stats.bullet_res.damage)
	health_value_text.text = str(skin_stats.health)
	pass
