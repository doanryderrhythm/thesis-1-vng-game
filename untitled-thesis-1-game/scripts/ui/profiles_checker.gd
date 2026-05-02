extends ColorRect
class_name ProfilesChecker

@onready var profiles: Control = $Banner/Cards
var profile_index: int = 0

@onready var previous_button: TextureButton = $PreviousButton
@onready var next_button: TextureButton = $NextButton

func _ready() -> void:
	profile_index = 0
	show_profiles()

func show_profiles(index: int = 0) -> void:
	var images = profiles.get_children()
	for i in profiles.get_child_count():
		if i == index:
			images[i].visible = true
		else:
			images[i].visible = false
	if index == 0:
		previous_button.disabled = true
		next_button.disabled = false
	elif index == profiles.get_child_count() - 1:
		previous_button.disabled = false
		next_button.disabled = true
	else:
		previous_button.disabled = false
		next_button.disabled = false

func switch_profile(is_next: bool) -> void:
	if is_next and profile_index + 1 < profiles.get_child_count():
		profile_index += 1
	elif !is_next and profile_index - 1 >= 0:
		profile_index -= 1
	else:
		return
	show_profiles(profile_index)

func _on_previous_button_pressed() -> void:
	switch_profile(false)
	pass # Replace with function body.

func _on_next_button_pressed() -> void:
	switch_profile(true)
	pass # Replace with function body.
