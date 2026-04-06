extends VBoxContainer

onready var id = $ID/PanelContainer/LineEdit
onready var sect = $Section/PanelContainer/LineEdit
onready var entry = $Setting/PanelContainer/LineEdit
onready var invert = $Invert/PanelContainer/CheckButton

var translation = ""
var locale = ""

func set_enabled(how):
	id.editable = how
	sect.editable = how
	entry.editable = how
	invert.disabled = !how


func _id_text_changed(new_text):
	var state = Translations.state
	
	pass # Replace with function body.


func _section_text_changed(new_text):
	var state = Translations.state
	
	pass # Replace with function body.


func _setting_text_changed(new_text):
	var state = Translations.state
	
	pass # Replace with function body.


func _invert_toggled(button_pressed):
	var state = Translations.state[translation]
	if locale in state:
		state = state[locale]
		if "invert" in state:
			state["invert"] = button_pressed
