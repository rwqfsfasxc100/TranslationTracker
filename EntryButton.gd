extends HBoxContainer

var list

signal pressed(translation)

export var translation : String = ""
var data = {}

onready var button = $Button
onready var label = $Button/Label

func _ready():
	button.connect("pressed",self,"_entry_pressed")
	label.text = translation
	button.hint_tooltip = translation
	
	pass

func _entry_pressed():
	emit_signal("pressed",translation)
