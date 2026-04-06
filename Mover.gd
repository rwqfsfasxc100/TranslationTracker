extends Button

onready var export_diag = get_node_or_null(NodePath("../ExportDiag"))
onready var import_diag = get_node_or_null(NodePath("../ImportDiag"))
onready var export_btn = get_node_or_null(NodePath("../Export"))

var moving = false

func down():
	moving = true

func up():
	moving = false

func _ready():
	export_btn.disabled = true
	Translations.connect("translations_added",self,"check_availability")

func check_availability():
	export_btn.disabled = Translations.state.empty()

func _input(event):
	if moving and event is InputEventMouseMotion:
		var pos = OS.get_window_position()
		var translate = pos + event.relative
		OS.set_window_position(translate)


func _on_Import_pressed():
	var dir = Settings.get_value("load","last_path")
	if dir:
		import_diag.set_current_dir(dir)
	var win_size = OS.get_window_size()
	import_diag.rect_size = Vector2(min(import_diag.rect_size.x, win_size.x), min(import_diag.rect_size.y, win_size.y))
	import_diag.popup_centered()


func _on_Export_pressed():
	var dir = Settings.get_value("load","last_path")
	if dir:
		export_diag.set_current_dir(dir)
	export_diag.set_current_file("REPLACE_TRANSLATIONS.gd")
	var win_size = OS.get_window_size()
	export_diag.rect_size = Vector2(min(export_diag.rect_size.x, win_size.x), min(export_diag.rect_size.y, win_size.y))
	export_diag.popup_centered()


func _on_ImportDiag_files_selected(paths):
	if paths:
		var path = paths[0]
		var p1 = path.split(path.split("/")[path.split("/").size() - 1])[0]
		Settings.set_value("load","last_path",p1)
		Translations.load_file(paths,0)


func _on_ExportDiag_file_selected(path):
	if path:
		var p1 = path.split(path.split("/")[path.split("/").size() - 1])[0]
		Settings.set_value("load","last_path",p1)
		Translations.export_state(path)
