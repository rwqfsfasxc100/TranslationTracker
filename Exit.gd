extends Button
func _pressed():
	OS.kill(OS.get_process_id())
