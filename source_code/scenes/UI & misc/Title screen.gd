# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Title Screen
# 

# Features:
# (1)  Shows Two UI
# (2) Connects to Global Screen Orientation to Trigger different Arts.

# To-Do:
# (1) Finish D-pad to Joystick button change illustration 
# (2) Add Swipe Gestures on/off controls
# (3) Add Default Config Settings Depending on OS

extends Control

class_name TitleScreen



#changes Title Screen Art using Global Screen Orientation
@onready var art1 :  TextureRect = $TextureRect2

@onready var logo : TextureRect = $logo

@onready var title_nodes : Array = [art1, logo]

@onready var safe_Utils = get_node("/root/Utils")


func _ready():
	
	pass




func _exit_tree():
	# Memory Leak Management
	safe_Utils.MemoryManagement.queue_free_array(title_nodes)
