extends HBoxContainer

export (String,"master","puppet") var type = "master"

onready var selector = $OptionButton

onready var tr_list = get_node_or_null("../../../../ListBox/EntryList")
onready var text_edit = get_node_or_null("../TextEdit")
onready var config_manager = get_node_or_null("../ConfigManager")

func _ready():
	Translations.connect("translations_added",self,"rescope")
	tr_list.connect("changed_translation",self,"change_this_translation")
	text_edit.connect("text_changed",self,"update_text")
	var prefix = ""
	match type:
		"master":
			prefix = "Master "
		"puppet":
			prefix = "Puppet "
			selector.connect("item_selected",self,"change_selected_locale")
	$Label.text = prefix + $Label.text

var puppet_locales = []

func rescope():
	selector.clear()
	match type:
		"master":
			var master_locale = Translations.master_locale
			
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
	match type:
		"master":
			currently_selected_locale = Translations.master_locale
		"puppet":
			currently_selected_locale = ""
			if puppet_locales.size():
				var this = puppet_locales[idx]
				currently_selected_locale = this
	
	

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
	text_edit.text = value
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
			this_tr[currently_selected_locale] = {"string":"","version_hash":0,"mod":"","section":"","setting":"","invert":false}
		this_tr[currently_selected_locale]["string"] = newText
		
