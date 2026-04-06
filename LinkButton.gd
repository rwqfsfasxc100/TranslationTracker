extends Button

export var URL = ""

var ok = true
func _ready():
	connect("pressed",self,"_pressed")
	
func _pressed():
	if ok:
		ok = false
		OS.shell_open(URL)
