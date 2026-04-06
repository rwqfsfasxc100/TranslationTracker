extends Button

var mode = 2
var modeA = "Search: Strings"
var modeB = "Search: Translations"
var modeC = "Search: Both"

signal done()

onready var showToggle = get_node_or_null(NodePath("../SearchShow"))

func _ready():
	connect("pressed",self,"_pressed")
	showToggle.connect("pressed",self,"_shower_pressed")
	changeVal()
	_shower()
var available = true
func _pressed():
	if available:
		changeVal()

func changeVal():
	available = false
	match mode:
		0:
			mode = 1
			text = modeB
		1:
			mode = 2
			text = modeC
		2:
			mode = 0
			text = modeA
	yield(get_tree(),"idle_frame")
	available = true
	emit_signal("done")


var searchMode = 3

var searchModeA = "Show: all"
var searchModeB = "Show: only complete"
var searchModeC = "Show: only outdated"
var searchModeD = "Show: only missing"

func _shower_pressed():
	if available:
		_shower()

func _shower():
	available = false
	match searchMode:
		0:
			searchMode = 1
			showToggle.text = searchModeB
		1:
			searchMode = 2
			showToggle.text = searchModeC
		2:
			searchMode = 3
			showToggle.text = searchModeD
		3:
			searchMode = 0
			showToggle.text = searchModeA
	yield(get_tree(),"idle_frame")
	available = true
	emit_signal("done")
