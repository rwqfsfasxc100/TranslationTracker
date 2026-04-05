extends Node

var locales_dv = [ "cs_CZ", "de", "el_GR", "en", "es", "fr", "hu_HU", "it_IT", "ja", "ko_KR", "nb_NO", "nl_NL", "pl", "pt_BR", "ru_RU", "th", "uk_UA", "zh_CN", "zh_HK" ]
var default = "en"

var unsaved = false

var state = {}
var master_locale = "en"

var current_locales = ["en"]

signal translations_adding(file, translations)
signal translations_added()

func _ready():
	get_tree().connect("files_dropped",self,"load_file")


func load_file(files,screen):
	OS.move_window_to_foreground()
	for fi in files:
		var f = ProjectSettings.localize_path(fi)
		var t = null
		if f.ends_with("REPLACE_TRANSLATIONS.gd"):
			t = ParseTranslations.load_translation_driver(f)
		else:
			t = ParseTranslations.load_translation_file(f)
		emit_signal("translations_adding",f,t)

func export_state():
	
	
	
	pass
