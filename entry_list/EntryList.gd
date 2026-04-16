extends VBoxContainer

const entry_button = preload("res://entry_list/EntryButton.tscn")
const bulk_bar_scene = preload("res://entry_list/BulkBar.tscn")

onready var list = $ScrollContainer/VBoxContainer
onready var searchMode = $SearchOptsBox/SearchIn
onready var searchMode2 = $SearchOptsBox/SearchShow
onready var add_entry = $SearchBox/AddConfirm
onready var add_entry_text = $SearchBox/AddConfirm/ColorRect/LineEdit

signal changed_translation(translation)
signal selection_changed(keys)

var bulk_bar
var selected_entries = []
var last_clicked_entry = ""
var cursor_entry = ""

func _ready():
	Translations.connect("translations_added", self , "adding_translations")
	searchMode.connect("done", self , "recheck_search")
	
	bulk_bar = bulk_bar_scene.instance()
	add_child_below_node($SearchOptsBox, bulk_bar)
	bulk_bar.connect("select_all", self , "select_all")
	bulk_bar.connect("deselect_all", self , "deselect_all")
	bulk_bar.connect("bulk_accept", self , "bulk_accept")
	bulk_bar.connect("bulk_delete", self , "bulk_delete")
	Translations.connect("translation_accepted", self, "_on_translation_accepted")

func _on_translation_accepted(keys):
	for c in list.get_children():
		if c.translation in keys:
			var btn = c.get_node_or_null("Button/NeedsCheck/Button")
			if btn:
				btn.visible = false
	yield(get_tree(), "idle_frame")
	_auto_advance()

func adding_translations():
	yield (get_tree(), "idle_frame")
	for a in list.get_children():
		a.queue_free()
	var l = Translations.state
	for translation in l:
		var data = l[translation]
		create_button(translation, data)
	recheck_search()
	
	if list.get_child_count():
		# Only auto-select if nothing is currently selected
		if selected_entries.empty():
			list.get_child(0)._entry_pressed()

func _auto_advance():
	var children = list.get_children()
	var start_idx = 0
	for i in range(children.size()):
		if children[i].translation == cursor_entry:
			start_idx = i
			break
	
	for i in range(start_idx + 1, children.size()):
		var c = children[i]
		if c.visible:
			var needs_check = c.get_node_or_null("Button/NeedsCheck/Button")
			if needs_check and needs_check.visible:
				c._entry_pressed()
				c.button.grab_focus()
				return

func create_button(translation, data):
	var b = entry_button.instance()
	b.list = self
	b.data = data.duplicate(true)
	b.translation = translation
	b.connect("pressed", self , "_entry_pressed")
	list.add_child(b)
	connect("selection_changed", b, "on_selection_changed")

func _entry_pressed(translation):
	var is_ctrl = Input.is_key_pressed(KEY_CONTROL)
	var is_shift = Input.is_key_pressed(KEY_SHIFT)
	
	if is_ctrl:
		if translation in selected_entries: selected_entries.erase(translation)
		else: selected_entries.append(translation)
	elif is_shift and last_clicked_entry != "":
		var btns = []
		for c in list.get_children():
			if c.visible: btns.append(c.translation)
		var a = btns.find(last_clicked_entry)
		var b = btns.find(translation)
		if a != -1 and b != -1:
			selected_entries = []
			for i in range(min(a, b), max(a, b) + 1):
				selected_entries.append(btns[i])
	else:
		selected_entries = [translation]
	
	if not is_shift:
		last_clicked_entry = translation
	cursor_entry = translation
	emit_signal("changed_translation", translation)
	update_bulk_ui()

func update_bulk_ui():
	bulk_bar.set_count(selected_entries.size())
	emit_signal("selection_changed", selected_entries)
	
	# Autoscroll to current cursor
	if cursor_entry != "":
		for child in list.get_children():
			if child.translation == cursor_entry:
				$ScrollContainer.ensure_control_visible(child)
				break

func select_all():
	selected_entries = []
	for child in list.get_children():
		if child.visible:
			selected_entries.append(child.translation)
	update_bulk_ui()

func deselect_all():
	selected_entries = []
	update_bulk_ui()

func bulk_accept():
	var loc = Translations.current_puppet_locale
	if loc:
		var acceptable = Translations.get_acceptable_keys(selected_entries, loc)
		Translations.bulk_force_accept(acceptable, loc)
	deselect_all()

func bulk_delete():
	Translations.bulk_remove_translations(selected_entries)
	deselect_all()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_UP:
			_move_selection(-1)
			get_tree().set_input_as_handled()
		elif event.scancode == KEY_DOWN:
			_move_selection(1)
			get_tree().set_input_as_handled()

func _move_selection(offset):
	var btns = []
	var cur = -1
	for c in list.get_children():
		if c.visible:
			if c.translation == cursor_entry: cur = btns.size()
			btns.append(c)
	
	if btns.empty(): return
	var next = clamp((0 if cur == -1 else cur) + offset, 0, btns.size() - 1)
	_entry_pressed(btns[next].translation)
	btns[next].button.grab_focus()

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
					child.visible = v and sm == Color(1, 1, 0, 1)
				"Show: only missing":
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					var v = n.visible
					var m = child.get_node_or_null("Button/NeedsCheck/Button/TextureRect")
					var sm = m.self_modulate
					child.visible = v and sm == Color(1, 0, 0, 1)
				_:
					var n = child.get_node_or_null("Button/NeedsCheck/Button")
					child.visible = true

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
	yield (get_tree(), "idle_frame")
	for a in list.get_children():
		if a.translation == txt:
			a._entry_pressed()
			break
