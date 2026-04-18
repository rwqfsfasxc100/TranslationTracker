extends VBoxContainer

onready var id = $ID/PanelContainer/LineEdit
onready var sect = $Section/PanelContainer/LineEdit
onready var entry = $Setting/PanelContainer/LineEdit
onready var invert = $Invert/PanelContainer/CheckButton

var translation = ""
var locale = ""
func _ready():
	Translations.connect("selected_translation",self,"tr_selected")
onready var state = Translations.state
func tr_selected(how):
	yield(get_tree(),"idle_frame")
	locale = get_parent().get_node("TranslationSelector").currently_selected_locale
	if locale and locale in state[how]:
		var it = state[how][locale]
		if "mod" in it:
			id.text = it.mod
		else:
			id.text = ""
		if "section" in it:
			sect.text = it.section
		else:
			sect.text = ""
		if "setting" in it:
			entry.text = it.setting
		else:
			entry.text = ""
		if "invert" in it:
			invert.pressed = it.invert
		else:
			invert.pressed = false
#		breakpoint
	else:
		default()

func set_enabled(how):
	id.editable = how
	sect.editable = how
	entry.editable = how
	invert.disabled = !how

func default():
	set_enabled(false)
	id.text = ""
	sect.text = ""
	entry.text = ""
	invert.pressed = false

func _id_text_changed(new_text):
	if locale and locale in state[translation]:
		var sr = state[translation][locale]
		sr["mod"] = new_text


func _section_text_changed(new_text):
	if locale and locale in state[translation]:
		var sr = state[translation][locale]
		sr["section"] = new_text


func _setting_text_changed(new_text):
	if locale and locale in state[translation]:
		var sr = state[translation][locale]
		sr["setting"] = new_text


func _invert_toggled(button_pressed):
	if locale and locale in state[translation]:
		var sr = state[translation][locale]
		sr["invert"] = button_pressed
