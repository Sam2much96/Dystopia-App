# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Shows Noob Players Help
#
# Features:
# (1) Contains UI for Mobile,PC, Console
# (2) Features Translations
#
# *************************************************
 
extends Control

class_name Help

# UI
onready var rotate_page : Label = $"Control/GridContainer/HBoxContainer/Label"
onready var _direction : Label = $"Control/GridContainer/HBoxContainer2/Label"
onready var _lives : Label = $"Control/GridContainer/HBoxContainer3/Label"
onready var dash : Label = $"Control/GridContainer/HBoxContainer4/Label"
onready var _attack : Label = $"Control/GridContainer/HBoxContainer5/Label"
onready var _interact : Label = $"Control/GridContainer/HBoxContainer6/Label"
onready var _stats : Label = $"Control/GridContainer/HBoxContainer7/Label"
onready var _comics : Label = $"Control/GridContainer/HBoxContainer8/Label"
onready var _zoom : Label = $"Control/GridContainer/HBoxContainer9/Label"

onready var mobile_help : Array = [
	rotate_page, _direction, _lives, dash, _attack,
	_interact, _stats, _comics, _zoom
]

onready var pc_help : Array = []

enum {MOBILE, PC}

export (int) var _state = MOBILE

func _ready():
	print_debug("Help: ", show_help(Globals.os))

func show_help(os : String) -> int :
	# Nested IF's?
	# Bad Code Alert
	if not os.empty(): # Error Catcher 1
		if os == "Android" or "iOS":
			_state = MOBILE
		else:
			_state = PC
	return _state
	if os.empty(): # Error Catcher 2
		push_error("Global OS cannot be Empty")

func _process(delta):
	# Help State Machine
	match _state:
		MOBILE:
			pass
		PC:
			pass


func _exit_tree():
	# Memory Management
	Utils.MemoryManagement.queue_free(mobile_help)
