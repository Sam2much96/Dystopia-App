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
# To-Do:
# (1) Implement GamePad Testing/Caliberating
# (2) Reuse pad and keyboard icons for other controller options
#
# *************************************************
 
extends Control

class_name Help

# Mobile UI
# Label
@onready var rotate_page : Label = $"Mobile/GridContainer/HBoxContainer/Label"
@onready var _direction : Label = $"Mobile/GridContainer/HBoxContainer2/Label"
@onready var _lives : Label = $"Mobile/GridContainer/HBoxContainer3/Label"
@onready var dash : Label = $"Mobile/GridContainer/HBoxContainer4/Label"
@onready var _attack : Label = $"Mobile/GridContainer/HBoxContainer5/Label"
@onready var _interact : Label = $"Mobile/GridContainer/HBoxContainer6/Label"
@onready var _stats : Label = $"Mobile/GridContainer/HBoxContainer7/Label"
@onready var _comics : Label = $"Mobile/GridContainer/HBoxContainer8/Label"
@onready var _zoom : Label = $"Mobile/GridContainer/HBoxContainer9/Label"

# Mobile Held
@onready var _mobile_home : Control = $Mobile

# ICons

# Keyboard UI
@onready var _pad : CanvasLayer = $PC/Pad
@onready var _keyboard : Node2D = $PC/Keyboard

var mobile_help : Array = []
var pc_help : Array = []

enum {MOBILE, PAD, KEYBOARD}

@export var _state : int = MOBILE

func _ready():
	
	
	# Mobile Help UI
	mobile_help= [rotate_page, _direction, _lives, dash, _attack,_interact, _stats, _comics, _zoom]
	
	# PC Help UI
	pc_help = [_pad, _keyboard]
	
	
	#print_debug("Mobile Help :",mobile_help) # For Debug Purposes only
	#print_debug("Pc Help :",pc_help) # For Debug Purposes only
	
	 #Hide All
	_mobile_home.hide()
	
	for t in pc_help:
		if t != null:
			t.hide()

	#print_debug(Globals.os)
	# Help State Machine
	if Globals.os == "X11" or "HTML5" or "Server" or "UWP" : # "Android", "iOS", "HTML5", "OSX", "Server", "Windows", "UWP", "X11".
		# Search for Joystick Input to Show Pad Icon
		
		PC("keyboard")
		
	if Globals.os == "Android" or "iOS": 
		
		Mobile()

func PC( type : String):
	if not type.is_empty() && type == "pad":
		_state = PAD
		_pad.show()
	if not type.is_empty() && type == "keyboard":
		_state = KEYBOARD
		_keyboard.show()
	else: push_error("Error")


func Mobile():
	_state = MOBILE
	

func manually_translate():
	# Refactor for Both PC and MObile UI
	# Manually translates Help UI
	# Set Font
	Dialogs.set_font(mobile_help, 75, "", 2)
	
	
	_mobile_home.show()
	for i in mobile_help:
		if i != null:
			i.show()
			i.set_text(Dialogs.translate_to(i.text, Dialogs.language))
	


func _exit_tree():
	# Memory Management
	Utils.MemoryManagement.queue_free_array(mobile_help)
	Utils.MemoryManagement.queue_free_array(pc_help)
