extends HBoxContainer

var list

export var translation : String = ""

func _ready():
	$Button.connect("pressed",list,"_entry_pressed",[translation])
	
	
	pass

func pressed():
	pass
