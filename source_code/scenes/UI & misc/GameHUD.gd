# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Is a SIngleton Child Of GLobal Input SIngleton and Exposes its Childern To THe Scene Tree
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
#
#
#
#
# Features: 
# (1) SHows All Game Data from Different Singletons to player
# (2) Creates Global Pointer to Children Nodes from Global Input Singleton
# (3) Connects Signals Between CHildren Nodes
# *************************************************
# To DO
# (1) Implement State Machine to goggle between different Screen orientations using global orientation state
# (2) Implement Mobile Gyroscope in a process method
# (3) Fix UI misalignment
# (4) Refactor into state machines
# (5) Implement Attack Button As Inventory item UI
# (6) Make Child Of Global Input SIngleton To Remove Multiple Instance and and update curr scene every loop


# *************************************************
# Bugs :
#(1) Ingame menu bug (fixed)
# (2) Multiple State can be active at the same time Bug
# (4) Fix Intteract UI
# (5) Doesn't implement Mobile Gyroscope (f1/2 fixed)
# (6) TouchInterface State Machine is buggy
# (7) Touch Interface INterract State  State is Buggy
#		#-Icons Do not hide when dialogue ia triggered
# (8) Breaks when in scene with player networking v2
# (9) Dialogue Box positioning for mobiles is Buggy in GameHUD.tscn
# (10) Dialogue Box is Buggy (fixed)
# (11) Node and Sub Nodes Do Not Handle Or Register Inputs Well
# *************************************************


extends CanvasLayer

class_name GameHUD

# Exposes Sub Nodes TO Scene Tree Via Global Input Singleton

onready var menu : Game_Menu = $"Menu "
onready var TouchInterface : TouchScreenHUD =  $TouchInterface
onready var _Comics = GlobalInput.get_child(1) #Comics Node Pointer
onready var _Stats : Stats = $Stats
onready var _Status_text : StatusText = $Status_text
onready var heart_box : Healthbar = $MarginContainer/Healthbar
#onready var ingame_comics_placeholer = $Comics # depreciated in favour of minimap sub system


onready var children : Array = [menu, TouchInterface,_Comics, _Stats, _Status_text, heart_box]

onready var globalInput = get_tree().get_root().get_node("/root/GlobalInput")


func _ready():
	# make self Global via singleton
	# Unsafe
	#GlobalInput.gameHUD = self
	
	# Make Self global via scene Tree
	# Safe
	if is_instance_valid(globalInput):
		globalInput.gameHUD = self
	
	#Update Current Scene Whenever Scene Tree Changes
	Globals.update_curr_scene()
	
	
	# Hide Game HUD WHen Ready
	
