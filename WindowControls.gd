extends Node

export var unsaved_panel = NodePath("")
onready var panel = get_node_or_null(unsaved_panel)

func _ready():
	if panel:
		panel.connect("confirmed", self, "kill")

func _on_Minimize_pressed():
	OS.set_window_minimized(true)

func _on_Maximize_pressed():
	OS.set_window_maximized(!OS.is_window_maximized())

func _on_Exit_pressed():
	if not Translations.unsaved:
		kill()
	else:
		if panel:
			panel.popup_centered()
		else:
			kill()

func kill():
	OS.kill(OS.get_process_id())
