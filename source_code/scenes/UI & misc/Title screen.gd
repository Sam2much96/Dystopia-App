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

"""
The purpose of this code is to beautify the UI programmatically
"""



onready var art1 :  TextureRect = $TextureRect2
onready var logo : TextureRect = $logo



onready var viewport : TextureRect = $Sprite
onready var position : Position2D = $Position2D 

onready var title_nodes : Array = [art1, logo, viewport]

onready var _local_android : android = get_node("/root/Android")



func _ready():
	
	# Controls_illustratins.gd has texture positional bug
	if Globals.screenOrientation == 1:
		art1.show()
	if Globals.screenOrientation == 0:
		art1.hide()
	
	
	# Show THe Menu Button On Android
	_local_android.show_only_menu()



func _exit_tree():
	# Memory Leak Management
	Utils.MemoryManagement.queue_free_array(title_nodes)
	_local_android._no_ads()


