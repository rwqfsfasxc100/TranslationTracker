extends HBoxContainer

onready var root = get_tree().get_root().get_node("Boot")

func _ready():
	$Button.connect("pressed",root,"_entry_pressed")
	
	
	pass

func pressed():
	pass
