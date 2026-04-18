extends Button

var entry = ""

func _ready():
	text = entry

signal toggle_to_translation(which)

func _pressed():
	emit_signal("toggle_to_translation",entry)

func changed_selected(how):
	pressed = (how == entry)
