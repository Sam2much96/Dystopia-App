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
onready var direction_buttons : Array 
onready var analogue_joystick : Array
onready var d_pad : Array

"Scene Tree"
onready var __scene_tree : SceneTree = get_tree()


# Helper booleans for Stopping Loop Processing
#var _action_button_showing : bool
#var _direction_button_showing : bool



#onready var TouchInput = Input 

func _ready():
	
		# Make Global Pointer
	#
	GlobalInput.TouchInterface = self
	Android.TouchInterface = self
	
	
	# Code Mutates Enabled
	#
	# 
	if Android.is_android() == false:
		self.hide()
		enabled = false
		self.set_process(false)

	
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
	d_pad = [ _up, _down, _left, _right]
	
	
		# Select Users Preferred Direction Controls 
		
	if str(Globals.direction_control )== "classic" :
		direction_buttons = d_pad
	elif str(Globals.direction_control) == "modern" :
		#direction_buttons = analogue_joystick
		print_debug("Joystick Inputs Require Refactoring")
	# Default Direction Button should be Analgue
	else: pass #direction_buttons = analogue_joystick
	
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
	show_direction_buttons()


func hide_buttons() :

	# Reset Helper Booleans
	#_action_button_showing = false
	#_direction_button_showing = false
	
	
	
	for i in direction_buttons :
		#if i.visible() :
		i.hide()
	for x in action_buttons:
		if x.visible:
			x.hide()
	# hackky bug fix for D-pad UI showing Bug
	for i in d_pad:
		i.hide()
	
	
	# Release UI FOus
	#debug_visibility()

func show_action_buttons() :
	#print_stack()
	
	# SHows the Action buttons recursively
	#print_debug("Showing Action Buttons")
	if enabled:
		for j in action_buttons:
			j.show()


func show_direction_buttons() -> void:
	#print_debug("Showing Direction Buttons")
	if enabled:
		for j in direction_buttons:
			j.show()



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
	_left.rect_rotation =179.7
	_left.rect_scale = Vector2(1,1)
	
	_up.rect_position = Vector2(69.482,392.99)
	_up.rect_size = Vector2(87,87)
	_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(1,1)
	
	_right.rect_position = Vector2(127.482,372.99)
	_right.rect_size = Vector2(87,87)
	_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(1,1)
	
	_down.rect_position =Vector2(147.482,440.989)
	_down.rect_size = Vector2(87,87)
	_down.rect_rotation = 90.3
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
	_left.rect_rotation =179.7
	_left.rect_scale = Vector2(2,2)
	
	_up.rect_position = Vector2(95.446,1786.98)
	_up.rect_size = Vector2(87,87)
	_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(2,2)
	
	_right.rect_position = Vector2(213.964,1742.99)
	_right.rect_size = Vector2(87,87)
	_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(2,2)
	
	_down.rect_position =Vector2(254.964,1865.99)
	_down.rect_size = Vector2(87,87)
	_down.rect_rotation = 90.3
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
