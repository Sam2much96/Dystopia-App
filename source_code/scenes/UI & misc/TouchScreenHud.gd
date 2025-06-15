# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a touch interface consisting of Touch 2d buttons and a Touch screen Joystick
# information used by the ingame UI node.
# Created Using Godot UI Noes And Texture Buttons For Better UI functionality

# Features:
# (1) A State Machine for the touch interface to hint the player and not clutter the ui
# (2) Emits it's state as a signal
# (3) Touch OS enables or Disables the touch interface depending on if a touch screen is present and the Globals.os. _Hide_touch_interface boolean variable
# (4) uses Globals.screenOrientation to change the button arrangements for mobiles
# (5) Connects to signals from Dialogues and COmics SIngletons
# (6) Changes Menu Button Colour Depending on Scene
# (7) Touchscreen HUD does adjusts to phone orientation on android 
# (8) It features a different Touch Interface States exported as Functions, and A StateMachine for
#		Differentiating Between Different Touch Input Types i.e. Stylus, Dpad and joystick
#		And Mapping Different Inputs To UI Action
# (9) It Acts As A Hud FOr The Active Player Item via The Action Buttons e.g. Sword Item, Bow Items
# (10) Calling Attack and Roll signal twince when pressed and when down introduces double punch/ double click
#
# (12) Connects to Signals from the Stats, Menu and Dilog box objects in GameHUD

#
# Bugs :



# TO DO:

# (1) Fix the joystick code  (1/2)
# (2) Update the interract state to be usable
#(4) Edit Documentation to be neater (Online documetation)
# (5) Joystick Colors?
# (6) Fix Brken Ingame Controller changer (fixed 1/2)
# (7) Should Resize to fit Screen Diameters using Global Scripts & Variables
# # (a) Write a Resize function using Global Screen Orientation Calculation and Screen Size
#	#	# (b) Variables available : Globals.os, Globals.screen Orientation, Globals.screenSize,Globals.viewport_size, GLobals.center_of_viewport
#		#(c) set grouped buttons positioning programmatically (Done)
# (10) TOuch Interface should be adjustible on mobile using drag and drop
# (11) TOuch Interface Format and Scaling should be exported function to android singleton (DOne)
# (12) Implement Drag and Drop Customization using state machines and postion registers
# (15) Shoud Export An Inspector Item String List THat Triggers Different HUD States 
# (16) Implement Stylus and Swipe COntrolls for Mobile Devices like LOZ Phantom Hourglass

 
# (19) Add touch hud drag and drop using refactored comics script (1/2)
# # (21) Implement procedural animation for Touch Interface Via Functions to be called from Game HUD -> Android Setup
#
# (22) Touch hud should hold the previous states for the TOuch interface to reset back to previous state
# (23) Create functions that export the state controller 
# (24) Make Global screen class containing all screen code similar to LOZ spirit tracks
# 	- it should contain multitouch and export path finding code
# *************************************************


extends Control


class_name TouchScreenHUD, "res://resources/misc/Android 32x32.png"


#Debug
#onready var _debug = get_tree().get_root().get_node("/root/Debug")


#Safe Global Input Ponter
onready var _Input = get_tree().get_root().get_node("/root/GlobalInput")
onready var node_input = Input  # Generates this nodes Node _input()


# Pointer to menu node from Parent

onready var menuObj : Game_Menu = Android.ingameMenu

onready var StatsObj : Stats = $"%Stats"

# Pointer to Global Menu Pointer
# use a setget function for this call to menu objed
#onready var menu3 = _Input.menu

#State Machine
# Use A Match Conditional for differentiating Input Types
# Stylus Should Only Catch TOuch Screen Inputs
# add functions to state machine
enum DragNDrop { D_PAD_, JOYSTICK, STYLUS , CONFIG, DEBUG } # Config State for Drag ANd Drop Mode


enum { DOWN, LEFT, UP, RIGHT, MENU, SLASH, ROLL, INTERACT, STATS, RESET, SHOW, HIDE} # Touch interface Internal State Machine

export (int) var touch_controller = MENU

# for storing data for state transition logic
#var current_state = touch_controller
#var previous_state = touch_controller


#export (String, 'modern', 'classic', "stylus") var _control # Dupli9cate of Globals._controller_type

#var _Debug_Run : bool = false

export (bool) var enabled # Local Variant for stroing if device is android from adnroid singleton

#signal menu
#signal interract
signal attack
#signal stats
#signal comics
#signal reset


var _menu : TextureButton 
var _interract : TextureButton 
var stats_ : TextureButton
var roll : TextureButton 
var slash  : TextureButton 

#var comics_ : TextureButton 
var _joystick : TouchScreenButton
var joystick2 : TouchScreenButton 
#var D_pad : Control 

#var Anim : AnimationPlayer 

var _up : TextureButton
var _down : TextureButton
var _left : TextureButton
var _right : TextureButton


#'UI control Parents'

"Dimensions Calculator"
var dimensions : Vector2  
var dimensional_diff : Vector2  

#var buttons_positional_data : Array

#var LineDebug : Line2D 

onready var joystick_parent: Control # = $Joystick

'UI button as arrays'
onready var all_UI_Nodes : Array
onready var action_buttons : Array 


"Scene Tree"
onready var __scene_tree : SceneTree = get_tree()

var input_buffer : Control



func _ready():
	
		# Make Global Pointer
	#
	#GlobalInput.TouchInterface = self # global input is depreciated to to a Touch Interface sub class
	Android.TouchInterface = self
	
	input_buffer = Input_Buffer.new()
	
	add_child(input_buffer)
	
	# Code Mutates Enabled
	#
	# 
	#if Android.is_android() == false:
	#	self.hide()
	#	enabled = false
	#	self.set_process(false)

	
	######## Begin Setting Nodes #
	_menu = $"%menu"
	_interract = $"%interact"
	stats_ = $"%stats"
	roll = $"%roll"
	slash = $"%slash"
	#comics_ = $"%comics"
	#_joystick = $Joystick/joystick_circle
	#joystick2 = $Joystick/joystick_circle2
	 
	#Anim = $AnimationPlayer
	#D_pad = $"D-pad"
	#LineDebug = $Line2D
	#touch_interface_debug() disabling for now
	
	_up = $"%up"
	_down = $"%down"
	_left = $"%left"
	_right = $"%right"
	

	#action_interract_buttons = $Control/ActionButtons 
	#interract_buttons = $Control/InterractButtons
	
	# Debug Broken Lins
	
	all_UI_Nodes = [_menu ,stats_, _interract, roll, slash, _up, _down, _left, _right ]
	
	# Error Catcher For Broken UI Links
	Utils.UI.check_for_broken_links(all_UI_Nodes)
	
	# Check For Broken signal connections
	
	
	
	"Set Button Arraqys for easy on/off"
	action_buttons = [
		_menu ,
		stats_,
		_interract,
		roll, 
		slash
		]
	
	#analogue_joystick  = [ _joystick, joystick2]
	#d_pad = [ _up, _down, _left, _right]
	
	
		# Select Users Preferred Direction Controls 
		
	#if str(Globals.direction_control )== "classic" :
	#	direction_buttons = d_pad
	#elif str(Globals.direction_control) == "modern" :
	#	#direction_buttons = analogue_joystick
	#	print_debug("Joystick Inputs Require Refactoring")
	# Default Direction Button should be Analgue
	#else: pass #direction_buttons = analogue_joystick
	
	# already set with default state machine
	#reset()
	#menu()
	
	# Turn off this setup script if not running on Android
	if enabled:
		
		# Connect Button Signals
		#print_debug("Connect Body Signals")
		
		
		#print_debug(direction_buttons, Globals.direction_control)

		"Touch UI Visibility"
		# moved to ANdroid singleton
		
		
		
		
		"Touch Menu Button Customization"
		# Customizes 
		if Globals.curr_scene == "HouseInside":
			_menu.self_modulate = Color(255,255,255) # white
		else: _menu.self_modulate = Color(0,0,0) # black
		
		
		
		
		
		"Display Screen Calculations"
		Utils.Screen.display_calculations(get_tree().get_root(), Utils)
		
		# Calculates the Length and Breadth of All Touchscreen HUD buttons
		# To DO: 
		# (1) Refactor for algorithmic solution
		#dimensions = Utils.Functions.calculate_length_breadth(buttons_positional_data)
		
		# calculates a dimensional difference between the center of the vuewport aand the Button onscreen positions 
		#dimensional_diff = dimensions - Globals.center_of_viewport 
	
	#For debug purposes only
	#print_debug("HUD Dimensions:", dimensions) # Breath of the wild lmao
	#print_debug("Dimension difference: ",dimensional_diff )
	
	#print_debug("Global Direction COntrols : ",Globals.direction_control, "/",dimensions, "/",dimensional_diff)
	
	
	# Debug Required Pointers
	#print_debug(parent, menu2, menu3)
		
		"Mobile Specific Signals"
		#print_debug("Stats Signals and Menu signals implementation are broken")
		
		# COnnect signals from dialogue
		# Dialogues to self
		Dialogs.dialog_box.connect("dialog_started", self, "interract")
		Dialogs.dialog_box.connect("dialog_ended", self, "show_all_buttons")

		# Menu to Touch Interface Connection
		# Temporarily disabled for UI refactor
		
		"Connect Signals To Menu"
		# Bugs : 
		# (1) Signal Spammer from Menu State machine
		#	#Fix : Boolean checker for signal emitting
		
		menuObj.connect("menu_hidden_in_ui", self, "menu__") 
		menuObj.connect("menu_hidden_in_game", self, "show__") 
		menuObj.connect("menu_showing", self, "menu__") 
		
		# debug signal connections
		print_debug("Menu Signals Debug: ",menuObj.is_connected("menu_hidden_in_ui", self, "menu") , menuObj.is_connected("menu_hidden_in_game", self, "show_all_buttons"), menuObj.is_connected("menu_showing", self, "menu") )
		
		
		
		# Connects Stats Ui Signals To Touchscreen HUD for Mobile
		StatsObj.connect("_enabled", self ,"status")
		StatsObj.connect("_not_enabled", self ,"show_all_buttons")
		
		if (
			StatsObj.is_connected("_enabled", self ,"status") &&
			StatsObj.is_connected("_not_enabled", self ,"show_all_buttons") != true 
		) :
			push_error("Stats x TouchHUD signal is broken")
		
		
		
		menu() # triggers default menu scene on start of game application
	if not enabled:
		pass


func _process(_delta):
	
	# only check for button press events
	# Guard clause: Only proceed if the event is an InputEventKey or InputEventMouseButton and is pressed
	#if not ((event is InputEventKey or event is InputEventMouseButton) and event.pressed):
	#	return
	
	#print("Button pressed:", event)
	if enabled:
		
		
		# Touch Interface Simple State Machine
		match touch_controller:
			MENU:
				return menu() # shows only menu button
			INTERACT:
				return interract() # shows only interract button
			DOWN:
				return
			UP: 
				return
			LEFT :
				return
			RIGHT : 
				return
			SLASH:
				return
			ROLL :
				return
			#RESET:
			#	return reset() # hides all UI buttons
			STATS:
				return status() # shows only status Button
			SHOW:
				return show_all_buttons() # shows all touch hud buttons
			HIDE:
				return hide_buttons()
	


"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""

"Exported Global State Machine Functions"

func menu__():
	touch_controller = MENU

func show__():
	touch_controller = SHOW

func hide__():
	touch_controller = HIDE

func stats__():
	touch_controller = STATS

func interact__():
	touch_controller = INTERACT

"Local State Machine Functions"



func status():  #used by ui scene when status is clicked
	print_debug("Status Triggered")
	hide_buttons()
	stats_.show()



func menu(): 
	#used by ui scene when menu is clicked
	# hides all buttons aand shows the menu ui button only
	#print_debug("Menu Showing Triggered")
	#print_stack()
	#print_debug("Menu Button triggered")
	hide_buttons()
	_menu.show()
	#touch_controller = MENU
	#debug_visibility_() # for temporarily debugging touch buttons state

func interract(): #used by ui scene when interract is clicked
	print_debug("Interract Triggered")
	hide_buttons()
	_menu.show()
	_interract.show()
	#return _state_controller  


func attack(): #used by ui scene when attack is clicked 
	#_state_controller = _ATTACK
	#return _state_controller 
	print_debug("Attack Triggered")
	emit_signal('attack')

	hide_buttons()

	_menu.show()
	slash.show()
	roll.show()
	
	#if _control == Globals._controller_type[1]: # modern
	#	#D_pad.hide()
	#	#
	#	for i in d_pad:
	#		i.hide()
	#	joystick_parent.show()

	#if _control == Globals._controller_type[2]: # classic
	#	joystick_parent.hide()
	#	for i in d_pad:
	#		i.show()







func show_all_buttons():
	#print_stack()
	# This function is connected to the dialogue box _on_Timer_timeout functoin
	# This function trigger the Touchscreen HUD to be visible or show only certain buttons
	show_action_buttons()
	#show_direction_buttons()


func hide_buttons() :

	# Reset Helper Booleans
	#_action_button_showing = false
	#_direction_button_showing = false
	
	
	
	#for i in direction_buttons :
		#if i.visible() :
	#	i.hide()
	for x in action_buttons:
		if x.visible:
			x.hide()
	# hackky bug fix for D-pad UI showing Bug
	#for i in d_pad:
	#	i.hide()
	
	
	# Release UI FOus
	#debug_visibility()

func show_action_buttons() :
	#print_stack()
	
	# SHows the Action buttons recursively
	#print_debug("Showing Action Buttons")
	if enabled:
		for j in action_buttons:
			j.show()


#func show_direction_buttons() -> void:
	#print_debug("Showing Direction Buttons")
#	if enabled:
#		for j in direction_buttons:
#			j.show()



"""
VISIBILITY LOGIC
"""

# Visibility logic for the touchhud interface for Android


func debug_visibility_():
	# debug the menu objects visibilty as an array of data
	# helps in debugging visibility nodes
	var dg = []
	for i in all_UI_Nodes:
		dg.append(i.visible)
	print_debug("visibility check: ", dg)



"""
PROCEDURAL ANIMATION FOR UI POSITIONING
"""
#
# (1) Methods Are TO Be called from GameHUD animation player Via ANdroid Singleton for Screen Orientation Positioning
func Horizontal():
	# Position UI Nodes For Horizontal Screens
	_left.rect_position =Vector2(83.482,453.99)
	_left.rect_size =Vector2(87,87)
	#_left.rect_rotation =179.7
	_left.rect_scale = Vector2(1,1)
	
	_up.rect_position = Vector2(69.482,392.99)
	_up.rect_size = Vector2(87,87)
	#_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(1,1)
	
	_right.rect_position = Vector2(127.482,372.99)
	_right.rect_size = Vector2(87,87)
	#_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(1,1)
	
	_down.rect_position =Vector2(147.482,440.989)
	_down.rect_size = Vector2(87,87)
	#_down.rect_rotation = 90.3
	_down.rect_scale = Vector2(1,1)
	
	
	_menu.rect_position = Vector2(32,48)
	_menu.rect_size = Vector2(166,143)
	_menu.rect_scale = Vector2(0.5,0.5)
	
	
	# this is the default position for stats & interract buttons
	stats_.rect_position = Vector2(872,35)
	stats_.rect_size = Vector2(166,103)
	stats_.rect_scale = Vector2(1,1)
	
	_interract.rect_position = Vector2(864,142)
	_interract.rect_size = Vector2(166,103)
	_interract.rect_scale = Vector2(1,1)
	
	
	# position the action buttons
	
	# move down only the slash and roll buttons
	
	slash.rect_position =Vector2(839,342)
	slash.rect_scale = Vector2(1,1)
	slash.rect_size = Vector2(110,206)
	
	roll.rect_position = Vector2(736,447)
	roll.rect_size = Vector2(110,103)
	roll.rect_scale = Vector2(1,1)
	
	
	
	return 0


func Vertical():
	# Position UI Nodes HFor Horizontal Screens
	_left.rect_position =Vector2(133.964,1920.99)
	_left.rect_size =Vector2(87,87)
	#_left.rect_rotation =179.7
	_left.rect_scale = Vector2(2,2)
	
	_up.rect_position = Vector2(95.446,1786.98)
	_up.rect_size = Vector2(87,87)
	#_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(2,2)
	
	_right.rect_position = Vector2(213.964,1742.99)
	_right.rect_size = Vector2(87,87)
	#_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(2,2)
	
	_down.rect_position =Vector2(254.964,1865.99)
	_down.rect_size = Vector2(87,87)
	#_down.rect_rotation = 90.3
	_down.rect_scale = Vector2(2,2)
	
	
	_menu.rect_position = Vector2(32,48)
	_menu.rect_size = Vector2(166,143)
	_menu.rect_scale = Vector2(1,1)
	
	# move down only the slash and roll buttons
	
	slash.rect_position =Vector2(867,1558)
	slash.rect_scale = Vector2(1.5,1.5)
	slash.rect_size = Vector2(110,206)
	
	roll.rect_position = Vector2(705,1653)
	roll.rect_size = Vector2(110,103)
	roll.rect_scale = Vector2(2,2)
	
	
	# this is the default position for stats & interract buttons
	stats_.rect_position = Vector2(872,35)
	stats_.rect_size = Vector2(166,103)
	stats_.rect_scale = Vector2(1,1)
	
	_interract.rect_position = Vector2(864,142)
	_interract.rect_size = Vector2(166,103)
	_interract.rect_scale = Vector2(1,1)
	
	
	return 0

"""
UI Button Connections
"""
# via Global Input Singleton
# Bugs : 
# (1) Pressed Signals Introduces Stuct Input Bug On Mobile Devices
func _on_menu_pressed():
	return 0


func _on_stats_pressed():
	return 0



func _on_interact_pressed():
	return 0 


func _on_roll_pressed():
	#print_debug("Roll Button Pressed")
	return _Input.parse_input(_Input.NodeInput,__scene_tree,"roll", true)


func _on_slash_pressed():
	#print_debug("Attack Button Pressed")
	return _Input.parse_input(_Input.NodeInput,__scene_tree,"attack", true)


func _on_right_pressed():
	
	return 0 


func _on_up_pressed():
	return 0 


func _on_left_pressed():
	return 0 



func _on_down_pressed():
	return 0




func _on_down_button_down():
	return _Input.parse_input(node_input,__scene_tree,"move_down", true)


func _on_down_button_up():
	return _Input.parse_input(node_input,__scene_tree,"move_down", false)


func _on_left_button_down():
	return _Input.parse_input(node_input,__scene_tree,"move_left", true)


func _on_left_button_up():
	return _Input.parse_input(node_input,__scene_tree,"move_left", false)


func _on_up_button_up():
	return _Input.parse_input(node_input,__scene_tree,"move_up", false)


func _on_up_button_down():
	return _Input.parse_input(node_input,__scene_tree,"move_up", true)




func _on_right_button_up():
	return _Input.parse_input(node_input,__scene_tree,"move_right", false)


func _on_right_button_down():
	return _Input.parse_input(node_input,__scene_tree,"move_right", true)


func _on_stats_button_up():
	return _Input.parse_input(node_input,__scene_tree,"pause", false)


func _on_stats_button_down():
	return _Input.parse_input(node_input,__scene_tree,"pause", true)



func _on_interact_button_up():
	return _Input.parse_input(node_input,__scene_tree,"interact", false)



func _on_interact_button_down():
	return _Input.parse_input(node_input,__scene_tree,"interact", true)


func _on_roll_button_up():
	return _Input.parse_input(node_input,__scene_tree,"roll", false)

func _on_roll_button_down():
	return _Input.parse_input(node_input,__scene_tree,"roll", true)

func _on_slash_button_up():
	return _Input.parse_input(node_input,__scene_tree,"attack", false)


func _on_slash_button_down():
	return _Input.parse_input(node_input,__scene_tree,"attack", true)


func _on_menu_button_up():
	return _Input.parse_input(node_input,__scene_tree,"menu", false)


func _on_menu_button_down():
	print_debug("Menu Button Pressed")
	return _Input.parse_input(node_input,__scene_tree,"menu", true)



func check_screen_orientation(orientation : int):
	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile
	orientation = Screen.Orientation()


class Input_Buffer extends Control:
	# *************************************************
	# godot3-RPG by Samuel Harrison
	# Released under MIT License
	# *************************************************
	# INPUT SINGLE4TON
	#
	# Code Logic handles all input in the game/app project
	# *************************************************
	# Features:
	# (1) It implements an Input Buffer for netwoked multiplayer
	# (2) The Input Buffer stores players 12 last input
	#
	# *************************************************
	# TO-DO:
	#
	# (1) Should implement Vibrations for haptic feedback (1/2)
	# (2) Implement Input Lag (Delay) For Multiplayer Gameplay
	# (3)Create pointer to all nodes that connect and interract with game hud and Touchhud
	# (4) Refactor to sub class within Touch interface
	# *************************************************
	# Notes:
	# (1) Vibration is a Battery & Performance hog
	# (2) Vibration is currently only implemented on Android, porting would require custom libraries
	# *************************************************
	# Bugs:
	# (1) Fix Joystick v2 vibration spams 
	#
	# *************************************************



	# For Storing An Array of Input Data FOr Networking Multiplayer
	var input_buffer = []

	enum {LEFT,RIGHT,UP,DOWN,ATTACK,ROLL,BLOCK, RESET, 
	COMICS, NEXTPANEL, PREVPANEL, DRAG, PAUSE, MENU, 
	INTERRACT, DIALOGUE
	}
	var reg_inputs : Array = ["move_left", "move_right","move_up", "move_down", "attack", "roll", "interact", "menu", "pause"]


	# State Machine
	export (int) var state  


	var pressed : bool = false

	# Vibration Settings
	export (bool) var vibrate_ = true
	export (bool) var saveBuffer = false;


	# Game HUD : pointers updated from game hud
	# Each of these Objects Use/ REquire Player input
	# Having them always in memory is a good thing
	# *************************************************
	var menu : Game_Menu setget set_gameMenu, get_gameMenu
	var TouchInterface : TouchScreenHUD setget set_touchHUD, get_touchHUD

	var Stats_ : Stats setget set_statsHUD, get_statsHUD
	var _Status_text : StatusText setget set_statusText, get_statusText

	# Game HUD + set get functions
	var gameHUD : GameHUD setget set_gameHUD, get_gameHUD

	# Mobile Joystick
	var joystick 


	var NodeInput = Input # Generates this nodes Node _input()

	onready var children : Array = self.get_children()

	func _unhandled_input(event):
		# Player Input
		# Implement Player Objects Movement State Machine Simplified
		
		if Input.is_action_pressed("move_left"):
			
			state = LEFT
			#facing = LEFT
			pressed = true
			vibrate(40, Globals.os)
		if Input.is_action_just_released("move_left"):
			
			state = RESET
			pressed = false
			#pass
		
		if Input.is_action_pressed("move_right"):
			
			state = RIGHT
			#facing = RIGHT
			vibrate(40,Globals.os)
		if Input.is_action_just_released("move_right"):
			
			state = RESET
			#facing = RIGHT
			#pass
		if Input.is_action_pressed("move_up"):
			
			state = UP
			#facing = UP
			vibrate(40,Globals.os)
		if Input.is_action_just_released("move_up"):
			
			state = RESET
			#facing = UP
			#pass
		if Input.is_action_pressed("move_down"):
			
			state = DOWN
			#facing = DOWN
			vibrate(40,Globals.os)
		if Input.is_action_just_released("move_down"):
			
			state = RESET
			#facing = DOWN
			#pass
		if Input.is_action_just_pressed("attack"):
			
			state = ATTACK
			
			vibrate(75,Globals.os)
		if Input.is_action_just_released("attack"):
			
			state = RESET
			
		if Input.is_action_just_pressed("roll"):
			
			state = ROLL
			#pass
		if Input.is_action_just_released("roll"):
			
			state = RESET
			#pass
			vibrate(40,Globals.os)
		
		# Comics Input
		if event.is_action_pressed("reset"):
			
			state = RESET
			#pass
		if event.is_action_pressed("next_panel"):
			
			state = NEXTPANEL
			#pass
		if event.is_action_pressed("comics"):
			
			state = COMICS
			
		if event is InputEventScreenDrag : 
			state = DRAG

		# Ingame Menu
		if event.is_action_pressed("menu"):
			state = MENU
		
		if event.is_action_released("menu"):
			state = RESET
		
		# Dialogues
		if event.is_action_pressed("interact") :
			state = INTERRACT
		
		if event.is_action_released("interact") :
			#_state = RESET
			pass
		# HUD
		if Input.is_action_just_pressed("pause"):
			state = PAUSE
		
		if Input.is_action_just_released("pause"):
			state = RESET
		
		
		if saveBuffer:
			if input_buffer.empty() == true && pressed:
				input_buffer.append(state)
				return
			
			if not input_buffer.empty() && int(input_buffer[input_buffer.size()-1]) != state:
				input_buffer.append(state)
				return

			# Prevent Memory Leak/ Stack Overflow error 
			if input_buffer.size() > 12:
				#	print(input_buffer, _state, input_buffer.pop_front())
					input_buffer.clear()
					#return


	# Add More Parameters To Determine Button Press Length
	static func parse_input(node_input : Input ,tree: SceneTree, action : String, _pressed : bool) -> int:
		#This Logic Creates and Parses Input actions programmatically
		# Bugs: Holds Input, Should Press and Release Input
		var a = InputEventAction.new()
		var end_frame : int = (Simulation.get_frame_counter() + 50)
		a.action = action
		
		# Handle Input
		# Node Imput Is used TO generate Node._input() methods
		if (Simulation.get_frame_counter() < end_frame):
			# To DO : 
			# (1) Implement Combo System
			#print_debug("Input Debug: ",Simulation.get_frame_counter(), "/", end_frame)
			a.pressed = _pressed
			node_input.parse_input_event(a)
		
		# Release Input
		elif (Simulation.get_frame_counter() >= end_frame):
			a.pressed = false
			#print_debug("Input Debug: ",Simulation.get_frame_counter(), "/", end_frame)
			node_input.parse_input_event(a)
		
		
		
		tree.set_input_as_handled()

		
		return 0

	func vibrate(duration_ms : int, os : String):
		
		if Globals.os == "Android" && vibrate_ : #or "iOS" or "HTML5":
			
			if joystick == null :# Fixes Mobile joystick spamm vibration bug
				# Shoud Connect to Controls so it can be turned on/off
				
				# Vibration on Mobile Devices
				Input.vibrate_handheld(duration_ms)
				# 2 seconds wait time before next vibratino
				#Networking.start_check_v2(5)
				

	func roll_direction_calculation()-> Vector2:
		var calc = Vector2(- int( Input.is_action_pressed("move_left") ) + int( Input.is_action_pressed("move_right") ), -int( Input.is_action_pressed("move_up") ) + int( Input.is_action_pressed("move_down") )).normalized()
		return calc


	# Returns an Input Buffer for simulations calculations
	# concats the input buffer array into a string
	func _get_input_buffer() -> int:
		return int(Utils.array_to_string(input_buffer.duplicate()))


	func set_gameHUD(hud : GameHUD):
		gameHUD = hud

	func get_gameHUD() -> GameHUD:
		return gameHUD


	func set_statsHUD(stats_hud: Stats):
		Stats_ = stats_hud

	func get_statsHUD() -> Stats:
		return Stats_

	func set_statusText(st_Text: StatusText) :
		_Status_text = st_Text


	func get_statusText() -> StatusText :
		return _Status_text

	func set_touchHUD(obj : TouchScreenHUD): 
		TouchInterface = obj

	func get_touchHUD() -> TouchScreenHUD:
		return TouchInterface



	func set_gameMenu(obj : Game_Menu):
		menu = obj 

	func get_gameMenu() -> Game_Menu:
		return menu


	func _exit_tree():
		# Memory Leak Management
		#
		# Clears all ui buttons
		
		Utils.MemoryManagement.queue_free_array(children)
		self.queue_free()





"Screen Class "
class Screen  :
	
	
	var screenOrientation : int
	var screenOrientationSettings : int = OS.get_screen_orientation()
	
	# This Apps Global Screen Orientation
	enum { SCREEN_HORIZONTAL, SCREEN_VERTICAL} 
		
	
	# Should Get Screen Size, Screen Scale and All screen properties
	# Should Debug this data to the Debug Singleton
	# Should only be called once
	static func debug_screen_properties():
		print ('OS Screen Orientation: ', OS.get_screen_orientation())
		print('Global Screen Orientation: ',Globals.screenOrientation)
		# match this variable to Global Screen Orientation
		print ('Screen Size 1: ',OS.get_screen_size(-1)) #yes. This variable changes when screen rotates
		print ('Screen Scale: ',OS.get_screen_scale())
		pass


	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile
	static func Orientation() -> int:
		'Screen Size Resolution'
		var screenSize : Vector2
		
		var screenOrientation : int
		
		'Algorithm for Calculating Screen Orientation'
		# Features:
		# (1) uses an Integer from the Global Singleton to stroe the calculation
		# (2) Returns an integer representain an Enumeration of the screen orientation
		var screen : Vector2 =OS.get_screen_size(-1) # get the current screen size
		
		
		# screen orientation enum copied from Globals main
		# To Do: Write an algorithm that compares the x and y values for OS.get_screen_size(-1) and the OS.get_screen_orientation() parameters
		# to determine if Screen is Horizontal or vertical. Use the Result to set Screen Orientation
		# in a process function
		
		
		# Resizes window the preselected sizes
		# Sets Default Screen Orientation for Android
		# Disabled
		#if GlobalScript.os == "Android":
		#	screenOrientation = GlobalScript.SCREEN_VERTICAL
		#else: screenOrientation = GlobalScript.SCREEN_HORIZONTAL 
		
		
		
		# Algorithmic calculation using screen orientation
		# And screen size to determine if the screen 
		# is horizontal or vertical
		
		if screen.x > screen.y:
			screenOrientation = SCREEN_HORIZONTAL
		if screen.x < screen.y:
			screenOrientation = SCREEN_VERTICAL

		# for debug purposes only
		#print_debug("Screen orientation is: ", screenOrientation, "/",'screen size :',screen)


		
		#screenOrientation = OS.get_screen_orientation() # Should return a 6 for AutoRotate on Ndroid # Should ideally be a process function
		
		return screenOrientation
		
	static func calculateViewportSize( t : CanvasItem ) -> Vector2 :
		return t.get_viewport_rect().size



	static func display_calculations( display, GlobalScript):
		'Screen Display Calculations'
		if display is CanvasItem:
			# Get Viewport Size, Make it Globally accessible
			GlobalScript.viewport_size = calculateViewportSize(display)
			#Globals.center_of_viewport = Globals.calc_center_of_rectangle(Globals.viewport_size)
			
		if display is Viewport:
			GlobalScript.viewport_size = display.size
		
		
		GlobalScript.center_of_viewport = GlobalScript.calc_center_of_rectangle(GlobalScript.viewport_size)
		
		# Prints out the Current Viewport Size
		# TO DO:
		# (1) Fix double resizing bug
		# (2) Provide GLobal framework for scaling UI nodes
		# (3) Export ALgorithm and apply to touch hud VErtical() and Horizontal()_ functions
		print_stack()
		print_debug("Viewport Size: ", GlobalScript.viewport_size ,"/","Center of Viewprt: ", GlobalScript.center_of_viewport ) # for debug purposes only
		
	
	
	static func scroll(direction : bool , visible : bool, _scroller : ScrollContainer)-> void:
		# DOCS : https://godotengine.org/qa/92054/how-programmatically-scroll-horizontal-list-texturerects
		# using a boolean because it allows for only two options in it's data structure
		# True is up, false is down
		# Max is 449
		var scroll_constant : int = 4
		# Requires Delta Parameter for smooth scrolling 
		# but running this function as a static function means
		# it scrolls choppily
		
		
		if visible && direction:
			_scroller.scroll_vertical += 20 * scroll_constant  #* delta
		elif visible && !direction:
			_scroller.scroll_vertical -= 20 * scroll_constant  #* delta

			#print (scroller.scroll_vertical )#= scroll_constant  * delta
	
	
	static func calculate_button_positional_data(
	menu : TextureButton, 
	_interract : TextureButton,
	stats : TextureButton, 
	roll : TextureButton, 
	slash : TextureButton, 
	comics : TextureButton, 
	joystick : TouchScreenButton,
	 D_pad : Control
	)-> Array:
		
		print_stack()
		assert(Globals.os =="Android", "Test Device is Not Android")
		
		# Returns an Array containing the position of all Touch HUD items
		# Only Used in Mobile devices for adjusting TOuchscreen HUD
		# Rewrite as Static function under utils screen class (Done)
	# *************************************************
		var buttons_positional_data : Array = []
		
		# Create Variable
		
		
		var menu_position : Vector2
		var _interract_position : Vector2
		var stats_position : Vector2
		var roll_position : Vector2
		var slash_position : Vector2
		var comics_position : Vector2
		var joystick_position : Vector2
		var D_pad_position : Vector2
		
		
		# BUTTONS POSITIONAL DATA 
		menu_position = menu.position
		_interract_position = _interract.position
		stats_position = stats.position
		roll_position = roll.position
		slash_position = slash.position
		comics_position = comics.position
		joystick_position = joystick.position
		D_pad_position = D_pad.get_rect().position

		buttons_positional_data = [
			menu_position,
			stats_position,
			comics_position,
			_interract_position,
			slash_position,
			roll_position,
			
			#joystick_position, # Joystick Positional data is buggy in debugg
			D_pad_position,
			menu_position
		]
		return buttons_positional_data
	
	
	static func _adjust_touchHUD_length(Anim : AnimationPlayer):
		
		# *************************************************
		"Touch Screen UI"
		#
		# Features
		# (1) Uses a Global Screen Orienation variable
		# (2) Uses an Animation Player to Set Node Position
		#
		# Bugs
		# (1) Disaligns on Different Mobile Devices
		# To Do
		# (1) Implement Globals Screnn Class Calculations
		# (2) Use Scene Display Calculations to Fix Misalignment Bug on Mobile Devices 
		# (3) Implement Calculations in the Animation Player
		# *************************************************
		
		
		
		#'Changes the button Layout depending on the screen orientation for Mobile UI'
		#implement joystick and D-pad variations
		#print_stack() # for debugging multiple method calls
		if Globals.screenOrientation == 1 : #&& Globals.direction_control == Globals._controller_type[2]: #worksif _action_button_showing == false
			Anim.play("SCREEN_VERTICAL");
		#if Globals.screenOrientation == 1 && Globals.direction_control == Globals._controller_type[1]: #works
		#	Anim.play("SCREEN_VERTICAL");
		##If screen Is Horizontal, it would be PC UI, making this code obsolete
		elif Globals.screenOrientation == 0:
			Anim.play("SCREEN_HORIZONTAL");
		else: pass
	
	
	# Deprecoated
	static func resize_window(x : int,y : int): #resizes the game window
		Globals.screenSize = Vector2(x,y);
		return OS.set_window_size(Vector2(x,y));

	# Convert bytes to Megabytes
	static func _ram_convert(bytes) :
		if bytes >= int(1):
			var _mb = String(round(float(bytes) / 1_048_576))
			return _mb
