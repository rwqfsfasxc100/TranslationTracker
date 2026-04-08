extends Label

func _ready():
	Translations.connect("selected_translation",self,"change")

func _physics_process(delta):
	rect_size = get_parent().rect_size

func change(how):
	if how:
		text = how
	else:
		text = ""
