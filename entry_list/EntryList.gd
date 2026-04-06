extends VBoxContainer

const entry_button = preload("res://entry_list/EntryButton.tscn")
onready var list = $ScrollContainer/VBoxContainer

signal changed_translation(translation)

func _ready():
	Translations.connect("translations_added",self,"adding_translations")

func adding_translations():
	for a in list.get_children():
		a.queue_free()
	var l = Translations.state
	for translation in l:
		var data = l[translation]
		create_button(translation,data)
#	yield(get_tree(),"idle_frame")
	if list.get_child_count():
		list.get_child(0)._entry_pressed()

func create_button(translation,data):
	var b = entry_button.instance()
	b.list = self
	b.data = data.duplicate(true)
	b.translation = translation
	b.connect("pressed",self,"_entry_pressed")
	list.add_child(b)


func _entry_pressed(translation):
	emit_signal("changed_translation",translation)


func _on_Search_text_changed(new_text):
	if new_text:
		for child in list.get_children():
			if "translation" in child and child.translation.split(new_text).size() > 1:
				child.visible = true
			else:
				child.visible = false
	else:
		for child in list.get_children():
			child.visible = true


onready var add_entry = $SearchBox/AddConfirm
onready var add_entry_text = $SearchBox/AddConfirm/ColorRect/LineEdit

func _on_AddNew_pressed():
	add_entry.popup_centered()
	add_entry_text.grab_focus()


func _on_AddConfirm_confirmed():
	var txt = add_entry_text.text
	if txt:
		Translations.add_translation(txt)
		
		add_entry.hide()
