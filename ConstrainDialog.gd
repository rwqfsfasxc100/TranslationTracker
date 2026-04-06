extends FileDialog

func _ready():
	connect("resized", self, "_on_resized")

func _on_resized():
	var win_size = OS.get_window_size()
	var new_size = rect_size
	new_size.x = min(new_size.x, win_size.x)
	new_size.y = min(new_size.y, win_size.y)
	if new_size != rect_size:
		rect_size = new_size
