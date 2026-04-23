extends CanvasLayer
class_name TutorialCanvas

@onready var tutorial_images: Control = $Tutorials
var tutorial_index: int = 0

func _ready() -> void:
	tutorial_index = 0
	show_tutorial()

func show_tutorial(index: int = 0) -> void:
	var images = tutorial_images.get_children()
	for i in tutorial_images.get_child_count():
		if i == index:
			images[i].visible = true
		else:
			images[i].visible = false

func switch_tutorial(is_next: bool) -> void:
	if is_next and tutorial_index + 1 < tutorial_images.get_child_count():
		tutorial_index += 1
	elif !is_next and tutorial_index - 1 >= 0:
		tutorial_index -= 1
	else:
		return
	show_tutorial(tutorial_index)

func _on_previous_button_pressed() -> void:
	switch_tutorial(false)
	pass # Replace with function body.

func _on_next_button_pressed() -> void:
	switch_tutorial(true)
	pass # Replace with function body.
