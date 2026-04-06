extends OptionButton

export (NodePath) var diag_box = NodePath("")
onready var diag = get_node_or_null(diag_box)
export (NodePath) var line_edit = NodePath("")
onready var textBox = get_node_or_null(line_edit)

func _ready():
	diag.connect("about_to_show",self,"fill")
	connect("item_selected",self,"sv")


var available_locales = []
func fill():
	clear()
	textBox.text = ""
	available_locales = []
	var valid = Translations.locales_dv
	var current = Translations.current_locales
	available_locales.append("")
	add_item("")
	for a in valid:
		if not a in current:
			available_locales.append(a)
			add_item(a)

func sv(how):
	if how > 0:
		var l = available_locales[how]
		textBox.text = l
