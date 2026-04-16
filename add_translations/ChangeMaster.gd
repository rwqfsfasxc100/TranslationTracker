extends ConfirmationDialog

var options = []

onready var opts = $VBoxContainer/OptionButton
onready var label = $VBoxContainer/Label
onready var list = $VBoxContainer/ScrollContainer/Label
func _ready():
	connect("confirmed",self,"confirmed")
	opts.connect("item_selected",self,"changed")

func confirmed():
	Translations.master_locale = options[sel]

func changed(how):
	sel = how

var sel = 0
func show():
	list.text = ""
	opts.clear()
	for opt in options:
		opts.add_item(opt)
		list.text = list.text + opt + "\n"
	opts.selected = 0
	label.text = "Imported translations contain different master locale(s) to the current"
