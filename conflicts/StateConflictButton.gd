extends HBoxContainer

var entry = ""
var locale = ""

var base_tr = ""
var conflicting_tr = ""

onready var btn = $Button
onready var select = $Select
onready var list = $Select/VBoxContainer/ScrollContainer/VBoxContainer
onready var displayName = locale + " | " + entry
var tr_button = preload("res://conflicts/SpecificTranslationConflict.tscn")


signal set_translation_conflict(entry,locale,how)
var selected_translation = ""
signal changed_selected_translation(how)

var current_buttons = []

func _ready():
	select.connect("confirmed",self,"selected")
	btn.text = displayName
	var basebtn = tr_button.instance()
	basebtn.entry = base_tr
	current_buttons.append(basebtn)
	var b = tr_button.instance()
	b.entry = conflicting_tr
	current_buttons.append(b)
	
	for r in current_buttons:
		r.connect("toggle_to_translation",self,"changed_selection")
		
		list.add_child(r)
		
		

func create_button(this_entry):
	var i = tr_button.instance()
	i.entry = this_entry
	i.connect("toggle_to_translation",self,"changed_selection")
	connect("changed_selected_translation",i,"changed_selected")
	return i

func changed_selection(how):
	selected_translation = how
	emit_signal("changed_selected_translation",how)

func selected():
	if selected_translation:
		select.hide()
		emit_signal("set_translation_conflict",entry,locale,selected_translation)


func _on_Button_pressed():
	select.popup_centered()

func _input(event):
	if select.is_visible_in_tree():
		if event.is_action_pressed("ui_cancel"):
			select.hide()
			get_tree().set_input_as_handled()
