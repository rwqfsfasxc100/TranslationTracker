extends Control

func _ready():
	get_tree().connect("files_dropped",self,"load_file")


func load_file(files,screen):
	pass
