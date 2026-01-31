extends Button

export var unsaved_panel = NodePath("")
onready var panel = get_node_or_null(unsaved_panel)

func _ready():
	panel.connect("confirmed",self,"kill")

func _pressed():
	if not Translations.unsaved:
		kill()
	else:
		panel.popup_centered()

func kill():
	OS.kill(OS.get_process_id())
