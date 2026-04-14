extends HBoxContainer

var list

signal pressed(translation)

export var translation : String = ""
var data = {}

onready var button = $Button
onready var label = $Button/Label
onready var check_hash = $Button/NeedsCheck
onready var check_hash_button = $Button/NeedsCheck/Button
onready var check_hash_icon = $Button/NeedsCheck/Button/TextureRect

onready var selection_overlay = Panel.new()

func _ready():
	button.connect("pressed",self,"_entry_pressed")
	Translations.connect("puppet_translation_changed",self,"recheck_puppet")
	Translations.connect("selected_translation",self,"selected_translation")
	label.text = translation
	button.hint_tooltip = translation
	
	# Setup selection overlay
	selection_overlay.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	selection_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.4, 0.9, 0.25) # Transparent blue
	style.border_width_left = 3
	style.border_color = Color(0.1, 0.6, 1.0, 1.0) # Bright blue edge
	selection_overlay.add_stylebox_override("panel", style)
	button.add_child(selection_overlay)
	selection_overlay.visible = false
	
	yield(get_tree(),"idle_frame")
	recheck_hash()

var trSelNow = ""
func selected_translation(how):
	trSelNow = how

func on_selection_changed(keys):
	selection_overlay.visible = translation in keys

func _entry_pressed():
	Translations.emit_signal("selected_translation",translation)
	emit_signal("pressed",translation)

var kill = false
func _on_DoDelete_confirmed():
	kill = true
	Translations.remove_translation(translation)
#	yield(get_tree(),"idle_frame")
#	queue_free()

onready var doDelete = $DoDelete

func _on_Delete_pressed():
	doDelete.popup_centered()

var is_missing = false
var current_puppet_locale = ""
func recheck_hash():
	if Translations.clearing or kill:
		return
	var visibility = false
	is_missing = false
	var master_locale = Translations.master_locale
	var state = Translations.state
	if master_locale in data:
		var sstr = hash(state[translation][master_locale]["string"])
		if current_puppet_locale in data:
			check_hash_icon.self_modulate = Color(1,1,0,1)
			check_hash_button.hint_tooltip = "The selected puppet locale's translation is not up-to-date to the master translation"
			var mstr = state[translation][current_puppet_locale]["version_hash"]
			if mstr != sstr:
				visibility = true
			else:
				
				visibility = false
		else: 
			if current_puppet_locale:
				visibility = true
				check_hash_button.hint_tooltip = "The selected puppet locale's translation is missing"
				check_hash_icon.self_modulate = Color(1,0,0,1)
				is_missing = true
	else: visibility = false
	check_hash_button.visible = visibility
	
onready var confirm_locale_box = check_hash.get_node("ConfirmLocale")
func _on_Button_pressed():
	if trSelNow == translation and not is_missing:
		confirm_locale_box.popup_centered()
	
	
func recheck_puppet(to):
	current_puppet_locale = to
	recheck_hash()

func _on_ForceAccept_confirmed():
	if current_puppet_locale in data:
		var master_locale = Translations.master_locale
		var state = Translations.state[translation]
		var h = hash(state[master_locale]["string"])
		state[current_puppet_locale]["version_hash"] = h
		data[current_puppet_locale]["version_hash"] = h
		Translations.check_hash()
		check_hash_button.visible = false
	
	pass # Replace with function body.
