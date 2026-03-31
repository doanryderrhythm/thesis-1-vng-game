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

func select_texture() -> void:
	if item_type == ItemType.LOCKED:
		texture = locked_sprite
	elif item_type == ItemType.UNLOCKED:
		texture = unlocked_sprite
	elif item_type == ItemType.EQUIPPED:
		texture = equipped_sprite

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
