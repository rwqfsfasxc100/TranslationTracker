extends Button

signal shower(data)
var data = {}

func _ready():
	var keys = data.keys()
	if keys.size() > 0:
		text = keys[0]

func _on_AddedEntry_pressed():
	emit_signal("shower",data)
