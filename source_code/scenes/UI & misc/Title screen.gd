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
@onready var art1 :  TextureRect = $TextureRect
@onready var art2 :  TextureRect = $TextureRect
@onready var art3 :  TextureRect = $Sprite2D

@onready var menu : TouchScreenButton = $menu
#onready var notifications : Popup = $Notification2
@onready var logo : TextureRect = $logo
@onready var _ad_placeholder : Appodeal = $Appodeal
@onready var _comic_placehlder : Control = $Control
@onready var _menu = $"Menu "
@onready var _viewport : SubViewport = $SubViewport
@onready var title_nodes : Array = [art1, art2, art3,_viewport,menu,logo,_ad_placeholder,_menu, _comic_placehlder]

#res://scenes/UI & misc/controls_illustration.gd
# 3D in 2D
@onready var viewport = $SubViewport
#onready var _tex = $Sprite

func _ready():
	
	# Seed Random Number
	randomize()
	
	# TItle Screen Art
	# Spawn A Random Page In a Random COmic Chapter
	# 
	#Comics_v6.Functions.load_comics(
	#	Comics_v6.comics[int(round(rand_range(1,7)))], 
	#	[],
	#	get_tree(), 
	#	true, 
	#	true, 
	#	true , 
	#	5, 
	#	Comics_v6.Kinematic_2d, 
	#	_comic_placehlder
	#	)
	
	art3.set_texture(viewport.get_texture())
	
	# Controls_illustratins.gd has texture positional bug
	if Globals.screenOrientation == 1:
		art1.show()
		art2.hide()
	if Globals.screenOrientation == 0:
		art1.hide()
		art2.show()



func _exit_tree():
	# Memory Leak Management
	Utils.MemoryManagement.queue_free_array(title_nodes)
#	_menu.queue_free()


