extends Button


onready var box = get_node_or_null(NodePath("../SearchOptsBox"))
func _ready():
	connect("pressed",self,"_pressed")

var can = true
func _pressed():
	if can:
		can = false
		box.visible = !box.visible
		yield(get_tree(),"idle_frame")
		can = true
