extends Button

var moving = false

func down():
	moving = true

func up():
	moving = false

func _input(event):
	if moving and event is InputEventMouseMotion:
		var pos = OS.get_window_position()
		var translate = pos + event.relative
		OS.set_window_position(translate)
