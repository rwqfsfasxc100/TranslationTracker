extends Node

var locales_dv = [ "cs_CZ", "de", "el_GR", "en", "es", "fr", "hu_HU", "it_IT", "ja", "ko_KR", "nb_NO", "nl_NL", "pl", "pt_BR", "ru_RU", "th", "uk_UA", "zh_CN", "zh_HK" ]
var default = "en"

var unsaved = false

var state = {}

signal translations_added(file, translations)

func _ready():
	var lang = "cs_CZ"
	var s = lang.split("_")
	var l = TranslationServer.get_locale_name(lang)
	var l2 = TranslationServer.get_language_name(s[0])
	var l3 = ""
	if s.size() >= 2:
		l3 = TranslationServer.get_country_name(s[1])
	get_tree().connect("files_dropped",self,"load_file")


func load_file(files,screen):
	OS.move_window_to_foreground()
	var t = {}
	var f = ""
	if files.size() > 0:
		f = ProjectSettings.localize_path(files[0])
		t = ParseTranslations.load_translation_file(f)
	emit_signal("translations_added",f,t)
