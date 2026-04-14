extends Node

var locales_dv = [ "cs_CZ", "de", "el_GR", "en", "es", "fr", "hu_HU", "it_IT", "ja", "ko_KR", "nb_NO", "nl_NL", "pl", "pt_BR", "ru_RU", "th", "uk_UA", "zh_CN", "zh_HK" ]
var default = "en"

var unsaved = false

var state = {}
var master_locale = "en"
const default_master_locale = "en"

var current_locales = ["en"]
const default_locales = ["en"]
var current_puppet_locale = ""

signal translations_adding(file, translations)
signal translations_added()
signal puppet_translation_changed(to)
signal selected_translation(how)


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
	connect("puppet_translation_changed", self, "_on_puppet_changed")


func _on_puppet_changed(to):
	current_puppet_locale = to

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

func bulk_force_accept(translations: Array, locale: String):
	for t in translations:
		if t in state:
			var master_data = state[t].get(master_locale)
			if master_data and locale in state[t]: # Only if it exists in target locale
				state[t][locale]["version_hash"] = hash(master_data["string"])
	finished()

func get_acceptable_keys(keys: Array, locale: String) -> Array:
	var out = []
	for t in keys:
		if t in state:
			var master_data = state[t].get(master_locale)
			if master_data and locale in state[t]:
				# Check if actually outdated
				var master_hash = hash(master_data["string"])
				if state[t][locale]["version_hash"] != master_hash:
					out.append(t)
	return out

func bulk_remove_translations(translations: Array):
	for t in translations:
		if t in state:
			state.erase(t)
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
	fix_locale_state()
	check_hash()
	emit_signal("translations_added")

func check_hash():
	var h = hash(state) + hash(current_locales) + hash(master_locale)
	if h != state_hash:
		unsaved = true
	state_hash = h

var script_base = "extends Node\n\n# This translation file is generated automatically\n# Do not modify anything directly, as this can break things for those working on them\n# Please use Translation Tracker to modify these yourself, and contact the mod author to implement them\n# https://github.com/rwqfsfasxc100/TranslationTracker/releases/latest\n\nconst TRANSLATIONS = %s"
var file = File.new()

func fix_locale_state():
	if current_locales.empty():
		current_locales = default_locales.duplicate(true)
	if not master_locale:
		master_locale = default_master_locale
	
var clearing = false
func clear_state():
	clearing = true
	for c in get_tree().get_root().get_node("Boot/PanelContainer/VBoxContainer/Texts/ListBox/EntryList/ScrollContainer/VBoxContainer").get_children():
		c.queue_free()
	master_locale = default_master_locale
	current_locales = default_locales.duplicate(true)
	state.clear()
	for t in state:
		remove_translation(t)
	for c in current_locales:
		remove_locale(c)
	
	finished()
	clearing = false
	pass

func export_state(path):
	var txt = script_base % JSON.print(format_state(),"\t")
	file.open(path,File.WRITE)
	file.store_string(txt)
	file.close()
	unsaved = false

func format_state() -> Dictionary:
	var out = {"master_locale":master_locale}
	for t in state:
		var data = state[t]
		for lang in data:
			var ld = data[lang].duplicate(true)
			var s = ld.string
			if s:
				if not lang in out:
					out[lang] = {}
				if lang == master_locale:
					ld.version_hash = hash(s)
				var m = ld.get("mod",null)
				var se = ld.get("section",null)
				var st = ld.get("setting",null)
				if not m or not se or not st:
					ld.erase("mod")
					ld.erase("section")
					ld.erase("setting")
					ld.erase("invert")
				out[lang][t] = ld
	return out
