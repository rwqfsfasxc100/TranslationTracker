extends Node

var locales_dv = [ "cs_CZ", "de", "el_GR", "en", "es", "fr", "hu_HU", "it_IT", "ja", "ko_KR", "nb_NO", "nl_NL", "pl", "pt_BR", "ru_RU", "th", "uk_UA", "zh_CN", "zh_HK" ]
var default = "en"

var unsaved = false

var state = {}
var master_locale = "en"
const default_master_locale = "en"

var current_locales = ["en"]
const default_locales = ["en"]

signal translations_adding(file, translations)
signal translations_added()

const blank_entry_dict = {
	"string":"",
	"version_hash":0,
	"mod":"",
	"section":"",
	"setting":"",
	"invert":false,
}

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

func remove_translation(translation, update = true):
#	yield(get_tree(),"idle_frame")
	if translation in state:
		state.erase(translation)
	if update:
		finished()

func add_translation(entry):
	if not entry in state:
		state[entry] = {}
	for locale in current_locales:
		state[entry][locale] = blank_entry_dict.duplicate(true)
	finished()

func add_locale(locale,is_master = false):
	current_locales.append(locale)
	current_locales.sort()
	if is_master:
		master_locale = locale
	for item in state:
		var std = state[item]
		if not locale in std:
			var tf = blank_entry_dict.duplicate(true)
			pass
	finished()

func swap_locale_to(locale):
	master_locale = locale
	finished()

func remove_locale(locale, update = true):
#	yield(get_tree(),"idle_frame")
	if locale in current_locales:
		current_locales.erase(locale)
	for translation in state:
		if locale in state[translation]:
			state[translation].erase(locale)
	if update:
		finished()

var state_hash = 0
func finished():
	if master_locale in current_locales:
		for lv in state:
			var tv = state[lv]
			if master_locale in tv:
				var ml = tv[master_locale]
				if "string" in ml:
					var vhash = hash(ml.string)
					for loc in tv:
						var th = tv[loc]
						if "version_hash" in th:
							th.version_hash = vhash
	fix_locale_state()
	var h = hash(state) + hash(current_locales) + hash(master_locale)
	if h != state_hash:
		unsaved = true
	state_hash = h
	emit_signal("translations_added")

var script_base = "extends Node\n\nconst TRANSLATIONS = %s"
var file = File.new()
func format_state() -> Dictionary:
	var out = {"master_locale":master_locale}
	for t in state:
		var data = state[t]
		for lang in data:
			var ld = data[lang].duplicate(true)
			if not lang in out:
				out[lang] = {}
			out[lang][t] = ld
	
	return out

func fix_locale_state():
	if current_locales.empty():
		current_locales = default_locales.duplicate(true)
	if not master_locale:
		master_locale = default_master_locale
	

func clear_state():
	state.clear()
	for t in state:
		remove_translation(t)
	for c in current_locales:
		remove_locale(c)
	
	finished()
	pass

func export_state(path):
	var txt = script_base % JSON.print(format_state(),"\t")
	file.open(path,File.WRITE)
	file.store_string(txt)
	file.close()
	unsaved = false
