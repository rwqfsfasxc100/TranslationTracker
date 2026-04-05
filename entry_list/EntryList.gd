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
