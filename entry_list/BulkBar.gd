extends HBoxContainer

signal select_all()
signal deselect_all()
signal bulk_accept()
signal bulk_delete()

onready var count_label = $Count
var current_count = 0

func set_count(n):
	current_count = n
	if n > 1:
		visible = true
		count_label.text = str(n) + " selected"
	else:
		visible = false

func _on_All_pressed():
	emit_signal("select_all")

func _on_None_pressed():
	emit_signal("deselect_all")

func _on_Accept_pressed():
	var loc = Translations.current_puppet_locale
	var acceptable = Translations.get_acceptable_keys(get_parent().selected_entries, loc)
	var n = acceptable.size()
	if n == 0:
		return # Nothing to accept (all are missing or already valid)
	
	$AcceptConfirm.dialog_text = "Are the puppet translations equivalent to the master translations for %d outdated items?" % [n]
	$AcceptConfirm.popup_centered()

func _on_Delete_pressed():
	$DeleteConfirm.popup_centered()

func _on_AcceptConfirm_confirmed():
	emit_signal("bulk_accept")

func _on_DeleteConfirm_confirmed():
	emit_signal("bulk_delete")
