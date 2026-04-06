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


func _on_DoDelete_confirmed():
	Translations.remove_translation(translation)
#	yield(get_tree(),"idle_frame")
#	queue_free()

onready var doDelete = $DoDelete

func _on_Delete_pressed():
	doDelete.popup_centered()
