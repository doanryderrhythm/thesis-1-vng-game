extends TextureRect
class_name CharacterUIItem

@onready var locked_sprite: Texture2D = load("res://sprites/ui/player/player_locked.png")
@onready var unlocked_sprite: Texture2D = load("res://sprites/ui/player/player_unlocked.png")
@onready var equipped_sprite: Texture2D = load("res://sprites/ui/player/player_equipped.png")

@onready var character_texture: TextureRect = $CharacterTexture

var player_stats: PlayerStats

enum ItemType {
	LOCKED,
	UNLOCKED,
	EQUIPPED,
}

var item_type: ItemType = ItemType.LOCKED

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_clicked()

func _on_clicked() -> void:
	ProfileManager.custom_index_selected.emit(get_parent().get_children().find(self))
	
	var shop_scene = get_tree().current_scene
	if shop_scene.sfx_player != null:
		shop_scene.change_player_anim.stop()
		shop_scene.change_player_anim.play("RESET")
		shop_scene.sfx_player.stream = AudioStorer.navigate_character
		shop_scene.sfx_player.play()
	pass

func select_texture() -> void:
	if item_type == ItemType.LOCKED:
		texture = locked_sprite
		character_texture.modulate = Color.WHITE
	elif item_type == ItemType.UNLOCKED:
		texture = unlocked_sprite
		character_texture.modulate = Color.WHITE
	elif item_type == ItemType.EQUIPPED:
		texture = equipped_sprite
		character_texture.modulate = Color.DEEP_SKY_BLUE

func insert_player_stats(stats: PlayerStats) -> void:
	player_stats = stats
	character_texture.texture = player_stats.sprite
	
	for code in ProfileManager.unlocked_codes:
		if stats.code == code:
			item_type = ItemType.UNLOCKED
			select_texture()
			break

func equip() -> void:
	item_type = ItemType.EQUIPPED
	select_texture()

func unequip() -> void:
	item_type = ItemType.UNLOCKED
	select_texture()
