extends Popup

export var container = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer")
onready var list = get_node_or_null(container)

export var added = NodePath("TranslationView")
onready var tr_window = get_node_or_null(added)

var label_text = "Adding %s translations for %s languages from [%s]"
onready var header = $PanelContainer/VBoxContainer/Label

func _ready():
	Translations.connect("translations_added",self,"adding_translations")

const entry_item = preload("res://entry_list/AddedEntry.tscn")

var overwritten = {}

var stored = {}

func adding_translations(filepath,dict):
	var languages = dict.keys()
	stored = {}
	var tr_list = []
	for lang in languages:
		stored.merge({lang:{}})
		var t = dict[lang]
		for i in t:
			if not i in tr_list:
				tr_list.append(i)
			stored[lang][i] = t[i]
	header.text = label_text % [tr_list.size(),languages.size(),filepath.split("/")[filepath.split("/").size() - 1]]
	add_content()
	popup()

func add_content():
	var items = {}
	for lang in stored:
		var entries = stored[lang]
		
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
	
	for item in items:
		
		var button = entry_item.instance()
		button.data = {item:items[item]}
		button.connect("shower",self,"show_viewer")
		list.add_child(button)
		pass

func show_viewer(data):
	var tr = data.keys()[0]
	var item = data[tr]
	var show_data = ""
	for locale in item.keys():
		if show_data != "":
			show_data = show_data + "\n\n"
		show_data = show_data + "'%s' (%s): \n" % [locale,TranslationServer.get_locale_name(locale)] + item[locale]
	tr_window.window_title = tr
	tr_window.dialog_text = show_data
	tr_window.popup_centered()

func _on_Button_pressed():
	hide()
	for i in list.get_children():
		i.queue_free()
