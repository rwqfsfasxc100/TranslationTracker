extends Popup

onready var tr_window = get_node_or_null(NodePath("TranslationView"))
onready var change_master_diag = get_node_or_null(NodePath("ChangeMaster"))

var label_text = "Adding %s translations for %s languages from [%s]"
onready var header = $PanelContainer/VBoxContainer/Label

func _ready():
	Translations.connect("translations_adding",self,"handle_incoming_translations")
	change_master_diag.get_cancel().connect("pressed",self,"handle_conflicts_within_import")
	change_master_diag.get_ok().connect("pressed",self,"handle_conflicts_within_import")

var overwritten = {}

var stored = {}

var importing = {}
var conflicting_imports = {}
var conflicting_with_current = {}
func handle_incoming_translations(dict : Dictionary):
	format_translation_dict(dict)
	handle_change_in_master()
	
	pass
	breakpoint

var change_master = []

func format_translation_dict(d : Dictionary):
	var tr_list = []
	var tl_state = Translations.state
	for fn in d:
		var dict = d[fn]
		if "master_locale" in dict and dict["master_locale"] != Translations.master_locale:
			change_master = dict["master_locale"]
		dict.erase("master_locale")
		for lang in dict:
			var t = dict[lang]
			for i in t:
				if i in tl_state and lang in tl_state[i]:
					if not i in conflicting_with_current:
						conflicting_with_current.merge({i:{}})
					if not lang in conflicting_with_current[i]:
						conflicting_with_current[i].merge({lang:[]})
					conflicting_with_current[i][lang].append(t[i].duplicate(true))
				else:
					if not i in importing:
						importing.merge({i:{}})
					if not lang in importing[i]:
						importing[i].merge({lang:t[i].duplicate(true)})
					else:
						if t[i]["string"] != importing[i][lang]["string"]:
							if not i in conflicting_imports:
								conflicting_imports.merge({i:[]})
							if not lang in conflicting_imports:
								conflicting_imports[i].append(lang)

func add_and_overwrite(dict : Dictionary):
	
	
	pass

func adding_translations(dict):
	stored.clear()
	
	add_and_overwrite(dict)
	add_content()

func add_content():
	var items = {}
	for lang in stored:
		var entries = stored[lang]
		if not lang in Translations.current_locales:
			Translations.current_locales.append(lang)
		Translations.current_locales.sort()
		for entry in entries:
			if not entry in items:
				items.merge({entry:{}})
			var t = entries[entry]
			if entry in Translations.state:
				if not entry in overwritten:
					overwritten.merge({entry:{}})
				overwritten[entry].merge({lang:t})
			items[entry].merge({lang:t})
	stored = items.duplicate(true)
#	Translations.state.merge(stored)
	for translation in stored:
		var data = stored[translation]
		var cstate = Translations.state
		if translation in cstate:
			var st = cstate[translation]
			for lang in data:
				st[lang] = data[lang]
		else:
			cstate[translation] = data.duplicate(true)
	conflicting_imports.clear()
	conflicting_with_current.clear()
	importing.clear()
	Translations.finished()

func show_viewer(data):
	var tr = data.keys()[0]
	var item = data[tr]
	var show_data = ""
	for locale in item.keys():
		if show_data != "":
			show_data = show_data + "\n\n"
		show_data = show_data + "'%s' (%s): \n" % [locale,TranslationServer.get_locale_name(locale)] + item[locale]
#	tr_window.window_title = tr
#	tr_window.dialog_text = show_data
#	tr_window.popup_centered()

func _on_Button_pressed():
	stored.clear()
	importing.clear()
	conflicting_imports.clear()
	conflicting_with_current.clear()
	hide()


# Handles for conflicts while importing

func handle_change_in_master():
	if change_master:
		change_master_diag.options = change_master
		change_master_diag.show()
	else:
		handle_conflicts_within_import()

func handle_conflicts_within_import():
	if conflicting_imports:
		pass
	else:
		handle_conflicts_between_state()

func handle_conflicts_between_state():
	pass



