extends Control

var resizing = false
export var min_window_size = Vector2(1024, 720)

func _ready():
	OS.set_min_window_size(min_window_size)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			resizing = event.pressed
			accept_event()
	elif event is InputEventMouseMotion and resizing:
		var new_size = get_global_mouse_position()
		new_size.x = max(new_size.x, min_window_size.x)
		new_size.y = max(new_size.y, min_window_size.y)
		OS.set_window_size(new_size)
		accept_event()
