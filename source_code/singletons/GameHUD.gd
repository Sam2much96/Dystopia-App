# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Is a SIngleton Child Of GLobal Input SIngleton and Exposes its Childern To THe Scene Tree
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
#
# # Exposes Sub Nodes TO Scene Tree Via Global Input Singleton
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
#(1) 
# (2) Multiple State can be active at the same time Bug
# (4) Fix Interact UI (1/3)
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


"Safe Pointers To Singletons"
#onready var globalInput = get_tree().get_root().get_node("/root/GlobalInput")
onready var android_ = get_node("/root/Android")
onready var safe_Utils = get_node("/root/Utils")
onready var safe_Globals = get_node("/root/Globals")

# Export Null Pointer TO Other Scene Setters
var menu : Game_Menu setget setMenu, getMenu
var TouchInterface : TouchControls setget set_TouchInterface, get_TouchInterface ##: TouchScreenHUD 
var _Stats : Stats setget setStatsHUD, getStatsHUD
var _Status_text  : StatusText
var heart_box  : HealthbarV2
var dialog_box : DialogBox
var children : Array


"Safe Pointer To Singletons"


func _ready():
	# Individually set each variable when ready if they are null
	# This prevents memory address overwrites and updates from redundancy code on object
	# Each sub object has ready codes to update to this global parent class
	# But the code may trigger slower or faster that this parent loop
	if menu == null:
		menu = $"%Menu "#$"%Menu"
	if _Stats == null:
		_Stats = $"%Stats"
	if _Status_text == null:
		_Status_text = $"%Status_text"
	if heart_box == null:
		heart_box = $"%Healthbar"
	if dialog_box == null:
		dialog_box =$"%Dialog_box"
	if TouchInterface == null:
		TouchInterface = $"%TouchInterface"

	
	children = [menu, TouchInterface, _Stats, _Status_text,dialog_box, heart_box]
	
	#print_debug("HUD Debug 1 :", children)
	
	# Check For Broken Links
	#Utils.UI.check_for_broken_links(children)
	
	# make self Global via singleton
	# using setter and getter functions
	
	# Make Self global via scene Tree
	# Safe


	if is_instance_valid(android_):
		
		android_.GameHUD_ = self
	
	#Update Current Scene Whenever Scene Tree Changes
	safe_Globals.update_curr_scene()
	
	
	# Hide Game HUD WHen Ready

# Connects to the following:
# (1) Player Object
# (2) Android Object
func set_TouchInterface(hud: TouchControls) :
	TouchInterface = hud

func get_TouchInterface() -> TouchControls:
	return TouchInterface

func setMenu(hud: Game_Menu):
	menu = hud

func getMenu() -> Game_Menu:
	return menu

func setStatsHUD(hud : Stats):
	_Stats = hud

func getStatsHUD()-> Stats:
	return _Stats

func _exit_tree():
	# Memory Leak Management
	#
	# Clears all ui buttons
	
	safe_Utils.MemoryManagement.queue_free_array(children)
	self.queue_free()
