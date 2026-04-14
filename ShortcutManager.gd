extends Node

var last_column_index = 0

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var active_modal = _find_visible_dialog(get_tree().root)
		if active_modal:
			if event.scancode in [KEY_Y, KEY_ENTER, KEY_KP_ENTER]:
				if _confirm_modal(active_modal): get_tree().set_input_as_handled()
				return
			if event.scancode in [KEY_N, KEY_ESCAPE]:
				if _cancel_modal(active_modal): get_tree().set_input_as_handled()
				return
		
		if event.alt:
			if event.scancode == KEY_LEFT:
				_switch_focus(-1)
				get_tree().set_input_as_handled()
			elif event.scancode == KEY_RIGHT:
				_switch_focus(1)
				get_tree().set_input_as_handled()
		
		if event.control and event.scancode == KEY_F:
			var boot = get_tree().current_scene
			if boot:
				var el = boot.find_node("EntryList", true, false)
				if el: el.get_node("SearchBox/Search").grab_focus()
			get_tree().set_input_as_handled()

func _confirm_modal(modal) -> bool:
	if modal is AcceptDialog:
		modal.get_ok().emit_signal("pressed")
		modal.hide()
		return true
	return false

func _cancel_modal(modal) -> bool:
	if modal is ConfirmationDialog:
		modal.get_cancel().emit_signal("pressed")
	if modal is WindowDialog:
		modal.hide()
		return true
	return false

func _find_visible_dialog(node):
	if node is WindowDialog and node.visible: return node
	for child in node.get_children():
		var res = _find_visible_dialog(child)
		if res: return res
	return null

func _switch_focus(offset):
	var boot = get_tree().current_scene
	if not boot: return
	
	var entry_list = boot.find_node("EntryList", true, false)
	var viewer = boot.find_node("TranslationViewer", true, false)
	var text_master = viewer.get_child(0).find_node("TextEdit", true, false) if viewer else null
	var text_puppet = viewer.get_child(1).find_node("TextEdit", true, false) if viewer else null
	
	var columns = [entry_list, text_master, text_puppet]
	var vp = get_viewport()
	var current_focus = vp.get_focus_owner() if vp.has_method("get_focus_owner") else null
	
	var current_col_idx = last_column_index
	for i in range(columns.size()):
		if columns[i] and (columns[i] == current_focus or columns[i].is_a_parent_of(current_focus)):
			current_col_idx = i
			break
	
	var next_idx = posmod(current_col_idx + offset, columns.size())
	var target = columns[next_idx]
	if not target: target = columns[posmod(next_idx + offset, columns.size())]
	
	last_column_index = next_idx
	if not target: return
	
	if target == entry_list:
		var list_container = target.get_node("ScrollContainer/VBoxContainer")
		var focused = false
		if "cursor_entry" in target and target.cursor_entry != "":
			for child in list_container.get_children():
				if child.translation == target.cursor_entry:
					child.get_node("Button").grab_focus()
					focused = true
					break
		if not focused and list_container.get_child_count() > 0:
			list_container.get_child(0).get_node("Button").grab_focus()
		elif not focused:
			target.get_node("SearchBox/Search").grab_focus()
	else:
		target.grab_focus()
		if target is TextEdit:
			target.cursor_set_line(target.cursor_get_line())
