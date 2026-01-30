extends VBoxContainer

const entry_button = preload("res://entry_list/EntryButton.tscn")

func create_button():
	var b = entry_button.instance()
	b.list = self
	


func _entry_pressed(translation):
	pass
