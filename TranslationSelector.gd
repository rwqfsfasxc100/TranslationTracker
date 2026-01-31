extends HBoxContainer

export (String,"master","puppet") var type = "master"

func _ready():
	var prefix = ""
	match type:
		"master":
			prefix = "Master "
		"puppet":
			prefix = "Puppet "
	$Label.text = prefix + $Label.text
