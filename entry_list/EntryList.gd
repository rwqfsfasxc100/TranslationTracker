extends VBoxContainer

const entry_button = preload("res://entry_list/EntryButton.tscn")
onready var list = $ScrollContainer/VBoxContainer

signal changed_translation(translation)

onready var searchMode = $SearchOptsBox/SearchIn
onready var searchMode2 = $SearchOptsBox/SearchShow
func _ready():
	Translations.connect("translations_added",self,"adding_translations")
	
	searchMode.connect("done",self,"recheck_search")
	
func adding_translations():
	yield(get_tree(),"idle_frame")
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

func recheck_search():
	var txt = $SearchBox/Search.text
	_on_Search_text_changed(txt)

func _on_Search_text_changed(new_text):
	if new_text:
		for child in list.get_children():
			var do = false
			var chr = child.translation.to_upper()
			var nr = new_text.to_upper()
			match searchMode.text:
				"Search: Strings":
					if "translation" in child and chr.split(nr).size() > 1:
						do = true
				"Search: Translations":
					if "data" in child and child.data:
						for tr in child.data:
							var td = child.data[tr].string
							if td.split(new_text).size() > 1:
								do = true
				"Search: Both":
					if "translation" in child and chr.split(nr).size() > 1:
						do = true
					if "data" in child and child.data:
						for tr in child.data:
							var td = child.data[tr].string.to_upper()
							if td.split(nr).size() > 1:
								do = true
			child.visible = do
	else:
		for child in list.get_children():
			child.visible = true
	
	for child in list.get_children():
		if child.visible:
			match searchMode2.text:
				"Show: only complete":
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					child.visible = !n.visible
				"Show: only outdated":
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					var v = n.visible
					var m = child.get_node_or_null("Button/NeedsCheck/Button/TextureRect")
					var sm = m.self_modulate
					child.visible = v and sm == Color(1,1,0,1)
				"Show: only missing":
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					var v = n.visible
					var m = child.get_node_or_null("Button/NeedsCheck/Button/TextureRect")
					var sm = m.self_modulate
					child.visible = v and sm == Color(1,0,0,1)
				_:
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					child.visible = true

onready var add_entry = $SearchBox/AddConfirm
onready var add_entry_text = $SearchBox/AddConfirm/ColorRect/LineEdit

func _on_AddNew_pressed():
	add_entry.popup_centered()
	add_entry_text.grab_focus()


func _on_AddConfirm_confirmed():
	var txt = add_entry_text.text
	if txt and not txt in Translations.state:
		Translations.add_translation(txt)
		add_entry.hide()
		select_translation(txt)

func select_translation(txt):
	yield(get_tree(),"idle_frame")
	for a in list.get_children():
		if a.translation == txt:
			a._entry_pressed()
			break
