extends Button

var mode = 2
var modeA = "Search: Strings"
var modeB = "Search: Translations"
var modeC = "Search: Both"
func _ready():
	connect("pressed",self,"_pressed")
	changeVal()
var available = true
func _pressed():
	if available:
		changeVal()
func changeVal():
	available = false
	match mode:
		0:
			mode = 1
			text = modeB
		1:
			mode = 2
			text = modeC
		2:
			mode = 0
			text = modeA
	yield(get_tree(),"idle_frame")
	available = true
