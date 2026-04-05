extends VBoxContainer

onready var id = $ID/PanelContainer/LineEdit
onready var sect = $Section/PanelContainer/LineEdit
onready var entry = $Setting/PanelContainer/LineEdit
onready var invert = $Invert/PanelContainer/CheckButton

var translation = ""
var locale = ""

func set_enabled(how):
	id.editable = how
	sect.editable = how
	entry.editable = how
	invert.disabled = !how
