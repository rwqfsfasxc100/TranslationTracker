extends Button

export var URL = ""

	
func _pressed():
	OS.shell_open(URL)
