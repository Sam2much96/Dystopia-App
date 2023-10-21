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



#changes Title Screen Art using Global Screen Orientation
onready var art1 :  TextureRect = $TextureRect
onready var art2 : TextureRect = $TextureRect2

onready var menu : TouchScreenButton = $menu
#onready var notifications : Popup = $Notification2
onready var logo : TextureRect = $logo
onready var _ad_placeholder : Appodeal = $Appodeal
onready var _menu = $"Menu "
onready var title_nodes : Array = [art1, art2, menu,logo,_ad_placeholder,_menu]



func _ready():
	
	# Memory Pointers to Title Screen Subnodes
	
	
	
	"Titl screen Art"
	if Globals.screenOrientation == 0:
		art1.show()
		art2.hide()
	elif Globals.screenOrientation == 1:
		art1.hide()
		art2.show()
#	else: pass



func _exit_tree():
	# Memory Leak Management
	Utils.MemoryManagement.queue_free_array(title_nodes)
#	_menu.queue_free()


