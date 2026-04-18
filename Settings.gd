extends Node

var cfg = {
	"load":{
		"last_path":"",
	},
}
var filepath = "user://settings.cfg"
var file = File.new()
var dir = Directory.new()
var c = ConfigFile.new()

signal config_changed()

func _ready():
	load_config()

func load_config():
	if not dir.file_exists(filepath):
		c.clear()
		for section in cfg:
			for setting in cfg[section]:
				var entry = cfg[section][setting]
				c.set_value(section,setting,entry)
		c.save(filepath)
	c.clear()
	c.load(filepath)
	for section in c.get_sections():
		for setting in c.get_section_keys(section):
			var entry = c.get_value(section,setting,cfg[section][setting])
			cfg[section][setting] = entry

func get_value(section,setting):
	return cfg[section][setting]

func set_value(section,setting,entry):
	cfg[section][setting] = entry
	save_config()
	emit_signal("config_changed")

func save_config():
	c.clear()
	for section in cfg:
		for setting in cfg[section]:
			var entry = cfg[section][setting]
			c.set_value(section,setting,entry)
	c.save(filepath)



func getFps():
	return Engine.iterations_per_second
