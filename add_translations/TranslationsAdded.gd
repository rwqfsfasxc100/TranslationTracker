extends Popup

onready var tr_window = get_node_or_null(NodePath("TranslationView"))
onready var change_master_diag = get_node_or_null(NodePath("ChangeMaster"))
onready var import_conflicts_diag = get_node_or_null(NodePath("ImportConflicts"))
onready var state_conflicts_diag = get_node_or_null(NodePath("StateConflicts"))

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
#	breakpoint

var change_master = []

func format_translation_dict(d : Dictionary):
	for fn in d:
		var dict = d[fn]
		if "master_locale" in dict and dict["master_locale"] != Translations.master_locale:
			change_master = dict["master_locale"]
		dict.erase("master_locale")
		for lang in dict:
			var t = dict[lang]
			for i in t:
				if not i in importing:
					importing.merge({i:{}})
				if not lang in importing[i]:
					importing[i].merge({lang:t[i].duplicate(true)})
				else:
					var thisItem = t[i]["string"]
					var currentImportItem = importing[i][lang]["string"]
					if thisItem != currentImportItem:
						if not i in conflicting_imports:
							conflicting_imports.merge({i:{}})
						if not lang in conflicting_imports:
							conflicting_imports[i][lang] = []
						conflicting_imports[i][lang].append(thisItem)
#						conflicting_imports[i][lang].append(importing[i][lang]["string"])
#					else:
#						breakpoint

func add_and_overwrite(dict : Dictionary):
#	for lang in dict:
#		stored.merge({lang:{}})
#		var t = dict[lang]
#		for i in t:
#			stored[lang][i] = t[i]
	
	for entry in dict:
		var t = dict[entry]
		for lang in t:
			if not lang in stored:
				stored[lang] = {}
			stored[lang][entry] = dict[entry][lang]
			pass
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
	stored.clear()
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

var import_conflict_button = preload("res://conflicts/ImportConflictButton.tscn")
var state_conflict_button = preload("res://conflicts/StateConflictButton.tscn")

onready var import_conflict_list = $ImportConflicts/VBoxContainer/ScrollContainer/VBoxContainer
onready var state_conflict_list = $StateConflicts/VBoxContainer/ScrollContainer/VBoxContainer
func handle_conflicts_within_import():
	for b in import_conflict_list.get_children():
		Tool.remove(b)
	if conflicting_imports:
		for ir in conflicting_imports:
			var current = importing[ir]
			var langs = conflicting_imports[ir]
			for lang in current:
				if lang in langs:
					var ld = langs[lang]
					var c = current[lang]
					var b = import_conflict_button.instance()
					b.base_tr = c.string
					b.conflicting_tr = ld
					b.entry = ir
					b.locale = lang
					b.connect("set_translation_conflict",self,"override_import_from_import_conflict")
					import_conflict_list.add_child(b)
		import_conflicts_diag.popup_centered()
	else:
		import_conflicts_diag.hide()
		handle_conflicts_between_state()

func handle_conflicts_between_state():
	for b in state_conflict_list.get_children():
		Tool.remove(b)
	var tl_state = Translations.state
	for i in importing:
		var t = importing[i]
		for lang in t:
			if i in tl_state and lang in tl_state[i]:
				var cData = tl_state[i][lang]
				var tData = t[lang].duplicate(true)
				if cData["string"] != tData["string"]:
					if not i in conflicting_with_current:
						conflicting_with_current.merge({i:{}})
					if not lang in conflicting_with_current[i]:
						conflicting_with_current[i][lang] = {}
					conflicting_with_current[i][lang] = tData
	
	
	if conflicting_with_current:
		for ir in conflicting_with_current:
			var current = tl_state[ir]
			var langs = conflicting_with_current[ir]
			for lang in current:
				if lang in langs:
					var ld = langs[lang]
					var c = current[lang]
					
					
					var b = state_conflict_button.instance()
					b.base_tr = c.string
					b.conflicting_tr = ld.string
					b.entry = ir
					b.locale = lang
					b.connect("set_translation_conflict",self,"override_import_from_state_conflict")
					state_conflict_list.add_child(b)
		state_conflicts_diag.popup_centered()
	else:
		state_conflicts_diag.hide()
		adding_translations(importing.duplicate(true))

func override_import_from_import_conflict(entry,locale,selected_translation):
	if not entry in importing:
		importing[entry] = {}
	if not locale in importing[entry]:
		importing[entry][locale] = {}
	importing[entry][locale]["string"] = selected_translation
	
	conflicting_imports[entry][locale].erase(selected_translation)
	if conflicting_imports[entry][locale].size() == 0:
		conflicting_imports[entry].erase(locale)
	if conflicting_imports[entry].size() == 0:
		conflicting_imports.erase(entry)
	handle_conflicts_within_import()

func override_import_from_state_conflict(entry,locale,selected_translation):
	var tl_state = Translations.state
	if not entry in importing:
		importing[entry] = {}
	if not locale in importing[entry]:
		importing[entry][locale] = {}
	importing[entry][locale]["string"] = selected_translation
	conflicting_with_current[entry].erase(locale)
	
	if conflicting_with_current[entry].size() == 0:
		conflicting_with_current.erase(entry)
	
	
	var cState = tl_state[entry][locale]["string"]
	if cState == selected_translation:
		importing[entry].erase(locale)
		if importing[entry].size() == 0:
			importing.erase(entry)
	else:
		tl_state[entry].erase(locale)
		if tl_state[entry].size() == 0:
			tl_state.erase(entry)
	handle_conflicts_between_state()
