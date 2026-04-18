extends WindowDialog

func _input(event):
	if is_visible_in_tree():
		if event.is_action_pressed("ui_cancel"):
			hide()
			get_tree().set_input_as_handled()
