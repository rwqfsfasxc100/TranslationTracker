extends Popup

export var added = NodePath("TranslationView")
onready var tr_window = get_node_or_null(added)

var label_text = "Adding %s translations for %s languages from [%s]"
onready var header = $PanelContainer/VBoxContainer/Label

func _ready():
	Translations.connect("translations_adding",self,"adding_translations")

var overwritten = {}

var stored = {}

func adding_translations(filepath,dict):
	stored = {}
	var tr_list = []
	if "master_locale" in dict:
		Translations.master_locale = dict["master_locale"]
		dict.erase("master_locale")
	for lang in dict:
		stored.merge({lang:{}})
		var t = dict[lang]
		for i in t:
			if not i in tr_list:
				tr_list.append(i)
			stored[lang][i] = t[i]
	header.text = label_text % [tr_list.size(),dict.size(),filepath.split("/")[filepath.split("/").size() - 1]]
	add_content()
#	popup()

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
		
#		breakpoint
	Translations.emit_signal("translations_added")

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
	hide()
