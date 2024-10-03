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
onready var art1 :  TextureRect = $TextureRect2

onready var art3 :  TextureRect = $Sprite

onready var logo : TextureRect = $logo



#res://scenes/UI & misc/controls_illustration.gd
# 3D in 2D
# To Do : 
#  (1) Play Animation rendered to 2D
onready var viewport = $Sprite


onready var title_nodes : Array = [art1, art3,logo, viewport]

onready var position : Position2D = $Position2D 

func _ready():
	
	# Fix Menu Positioning on Mobile Devices
	
	#art3.set_texture(viewport.viewport_image)
	
	# Controls_illustratins.gd has texture positional bug
	if Globals.screenOrientation == 1:
		art1.show()
	if Globals.screenOrientation == 0:
		art1.hide()

	# Should Trigger Ads Inititialasation
	# Title Screen Is Solely Responsible for Triggering and Removing android ads
	# Temporary implementation for UX testing
	Android.ads()


func _exit_tree():
	# Memory Leak Management
	Utils.MemoryManagement.queue_free_array(title_nodes)
#	_menu.queue_free()
	Android._no_ads()

