# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
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
# *************************************************


extends CanvasLayer

class_name GameHUD


onready var menu : Game_Menu = $"Menu "
onready var TouchInterface : TouchScreenHUD =  $TouchInterface
onready var _Comics = Comics_v6 #$Comics
onready var _Stats : Stats = $Stats
onready var _Status_text : StatusText = $Status_text

onready var ingame_comics_placeholer = $Comics


onready var children : Array = [menu, TouchInterface,_Comics, _Stats, _Status_text]

onready var globalInput = get_parent()


func _ready():
	# make self Global via singleton
	# Unsafe
	#GlobalInput.gameHUD = self
	
	# Make Self global via scene Tree
	# Safe
	globalInput.gameHUD = self

	#Update Current Scene Whenever Scene Tree Changes
	Globals.update_curr_scene()
