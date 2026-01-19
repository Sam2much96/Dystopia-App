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




onready var title_nodes : Array = [art1, logo] #, viewport

onready var _local_android : android = get_node("/root/Android")
onready var safe_Globals = get_node("/root/Globals")
onready var safe_Utils = get_node("/root/Utils")


func _ready():
	
	
	
	# Titlescreen ads trigger
	if _local_android.BANNER_READY:
		_local_android._ads.show_banner()



func _exit_tree():
	# Memory Leak Management
	safe_Utils.MemoryManagement.queue_free_array(title_nodes)
	#_local_android._no_ads() # disabled on Aug 22 /2025. Not needed as no dpad on screen
# disable banner ads
	print_debug("Disabling Banner Ads on game start")
	#_local_android._ads.hide_banner()
