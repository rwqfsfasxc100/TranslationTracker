extends HBoxContainer

export (String,"master","puppet") var type = "master"

onready var selector = $OptionButton

onready var tr_list = get_node_or_null("../../../../ListBox/EntryList")
onready var text_edit = get_node_or_null("../TextEdit")
onready var config_manager = get_node_or_null("../ConfigManager")
onready var remove_locale_btn = $RemoveLocale
onready var remove_locale_diag = $RemoveConfirm
onready var add_locale_btn = $AddLocale
onready var add_locale_diag = $AddConfirm
onready var add_locale_txt = $AddConfirm/ColorRect/LineEdit
onready var swap_locale_btn = $SwapLocale

func _ready():
	Translations.connect("translations_added",self,"rescope")
	tr_list.connect("changed_translation",self,"change_this_translation")
	text_edit.connect("text_changed",self,"update_text")
	remove_locale_btn.connect("pressed",self,"openRmv")
	remove_locale_diag.connect("confirmed",self,"remove_this_locale")
	add_locale_btn.connect("pressed",self,"openAdd")
	add_locale_diag.connect("confirmed",self,"add_this_locale")
	swap_locale_btn.connect("pressed",self,"swap_locale")
	var prefix = ""
	remove_locale_btn.disabled = true
	swap_locale_btn.disabled = true
	match type:
		"master":
			prefix = "Master "
			var master_locale = Translations.master_locale
			selector.add_item(master_locale)
			swap_locale_btn.text = ">"
		"puppet":
			prefix = "Puppet "
			selector.connect("item_selected",self,"change_selected_locale")
			swap_locale_btn.text = "<"
	$Label.text = prefix + $Label.text

var puppet_locales = []

func rescope():
	selector.clear()
	match type:
		"master":
			var master_locale = Translations.master_locale
			if master_locale in Translations.current_locales:
				selector.add_item(master_locale)
			pass
		"puppet":
			var master_locale = Translations.master_locale
			var all_locales = Translations.current_locales
			puppet_locales = []
			for l in all_locales:
				if l != master_locale:
					puppet_locales.append(l)
					selector.add_item(l)
	change_selected_locale(0)
	

var currently_selected_locale = ""

func change_selected_locale(idx):
	if Translations.current_locales:
		match type:
			"master":
				currently_selected_locale = Translations.master_locale
			"puppet":
				currently_selected_locale = ""
				if puppet_locales.size():
					var this = puppet_locales[idx]
					currently_selected_locale = this
		if currently_selected_locale == "":
			remove_locale_btn.disabled = true
		else:
			remove_locale_btn.disabled = false
		swap_locale_btn.disabled = Translations.current_locales.size() < 2
		selector.selected = idx
		change_this_translation(current_translation)

var current_translation = ""
func change_this_translation(translation):
	current_translation = translation
	var from_state = Translations.state.get(translation,{}).get(currently_selected_locale,"")
	var value = ""
	match typeof(from_state):
		TYPE_STRING:
			value = from_state
		TYPE_DICTIONARY:
			if "string" in from_state:
				value = from_state.string
	var opout = value.c_unescape()
	text_edit.text = opout
	if currently_selected_locale:
		if current_translation:
			text_edit.readonly = false
			config_manager.set_enabled(true)
			config_manager.translation = current_translation
			config_manager.locale = currently_selected_locale
		else:
			text_edit.readonly = true
			config_manager.set_enabled(false)
	else:
		text_edit.readonly = true
		config_manager.set_enabled(false)

func update_text():
	if current_translation:
		var newText = text_edit.text
		var state = Translations.state
		var this_tr = state.get(current_translation,{})
		if not currently_selected_locale in this_tr:
			this_tr[currently_selected_locale] = Translations.blank_entry_dict.duplicate(true)
		this_tr[currently_selected_locale]["string"] = newText
		

func openRmv():
	remove_locale_diag.popup_centered()

func remove_this_locale():
	Translations.remove_locale(currently_selected_locale)

func openAdd():
	add_locale_diag.popup_centered()
	add_locale_txt.grab_focus()

func add_this_locale():
	var txt = add_locale_txt.text
	if txt:
		match type:
			"master":
				Translations.add_locale(txt,true)
			"puppet":
				Translations.add_locale(txt,false)
#				yield(get_tree(),"idle_frame")
				puppet_locales.append(txt)
				puppet_locales.sort()
				change_selected_locale(puppet_locales.find(txt))
		add_locale_diag.hide()
		

func swap_locale():
	if type == "puppet":
		Translations.swap_locale_to(currently_selected_locale)
