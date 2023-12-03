# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a touch interface consisting of Touch 2d buttons and a Touch screen Joystick
# information used by the ingame UI node.
# 

# Features:
# A State Machine for the touch interface to hint the player and not clutter the ui
# Emits it's state as a signal
#Touch OS enables or Disables the touch interface depending on if a touch screen is present and the Globals.os. _Hide_touch_interface boolean variable
# uses Globals.screenOrientation to change the button arrangements for mobiles
# Bugs
#(1) using animation player resets the Joystick/D-pad optionality

# TO DO:
# (0) _on_comics_showing() is not working
# (1) Fix the joystick code  (1/2)
# (2) Update the interract state to be usable
# (3) Hidetouch interface / Touch interface reset bug (workaround) CLicking other buttons on the touch UI resets this bug on touch UI
#(4) Edit Documentation to be neater (Online documetation)
# (5) Joystick Colors?
# (6) Fix Brken Ingame Controller changer (fixed 1/2)
# (7) Should Resize to fit Screen Diameters using Global Scripts & Variables
# # (a) Write a Resize function using Global Screen Orientation Calculation and Screen Size
#	#	# (b) Variables available : Globals.os, Globals.screen Orientation, Globals.screenSize,Globals.viewport_size, GLobals.center_of_viewport
#		#(c) set grouped buttons positioning programmatically
# (8) ReWrite Logic Using Animation Player Nodes to fix Stuck Button Bug
# (9) State machine is not optimized at all (processor hog)
# *************************************************


extends Node2D
#extends Input_Buffer

class_name TouchScreenHUD

var _Hide_touch_interface : bool

#Debug
onready var _debug = get_tree().get_root().get_node("/root/Debug")

#State Machine
enum { _MENU, _INTERRACT, _ATTACK, _STATS, _COMICS, _RESET }

export (int) var _state_controller = _STATS
export (String, 'modern', 'classic') var _control # Dupli9cate of Globals._controller_type
var _Debug_Run : bool = false


#signal menu
signal interract
signal attack
signal stats
signal comics
signal reset


var _menu : TouchScreenButton 
var _interract : TouchScreenButton 
var stats : TouchScreenButton
var roll : TouchScreenButton 
var slash  : TouchScreenButton 

var comics : TouchScreenButton 
var _joystick : TouchScreenButton 
var joystick2 : TouchScreenButton 
var D_pad : Control 

var Anim : AnimationPlayer 





'UI control Parents'
var interract_buttons : Control
var action_interract_buttons : Control

"Dimensions Calculator"
var dimensions : Vector2  
var dimensional_diff : Vector2  

var buttons_positional_data : Array

var LineDebug : Line2D 

onready var joystick_parent: Control = $Joystick

'UI button as arrays'
onready var action_buttons : Array 
onready var direction_buttons : Array 


# debug COunter counts how many times a mehtod has been called
var counter : int = 0
#func _enter_tree():
	#"Global Pointer" # DEepreciated in favor of GlobalInput Singleton
	#Globals._TouchScreenHUD = self

# Helper booleans for Stopping Loop Processing
var _action_button_showing : bool
var _direction_button_showing : bool


func _ready():
	
	# Make Global Pointer
	if GlobalInput.TouchInterface == null:
		GlobalInput.TouchInterface = self
	
	#print_debug( " Global Touch HUD: ", GlobalInput.TouchInterface)


	_menu = $menu
	_interract = $Control/InterractButtons/interact
	stats = $Control/InterractButtons/stats
	roll = $Control/ActionButtons/roll
	slash = $Control/ActionButtons/slash
	comics = $Control/InterractButtons/comics
	_joystick = $Joystick/joystick_circle
	joystick2 = $Joystick/joystick_circle2
	 
	Anim = $AnimationPlayer
	D_pad = $"D-pad"

	LineDebug = $Line2D
	#touch_interface_debug() disabling for now

	action_interract_buttons = $Control/ActionButtons 
	interract_buttons = $Control/InterractButtons

	"Set Button Arraqys for easy on/off"
	action_buttons = [
		_menu ,
		stats,
		_interract,
		roll, 
		slash,
		comics
		]
	
	# 
	
	if str(Globals.direction_control )== "classic" :
		direction_buttons = [D_pad]
	elif str(Globals.direction_control) == "modern" :
		direction_buttons = [ _joystick, joystick2]
		
		# Default Direction Button should be Analgue
	else: direction_buttons = [ _joystick, joystick2]

	#print_debug(direction_buttons, Globals.direction_control)

	"Touch UI Visibility"
	
	# Disabling for debugging
	hide_self(Globals.os, Globals.screenOrientation, _Hide_touch_interface, self)

	"Auto sets the controller button"
	reset()
	Utils.Screen.calculate_button_positional_data(
		_menu, 
		_interract,
		stats, 
		roll, 
		slash, 
		comics, 
		_joystick, 
		D_pad
		)
	

	Utils.Screen._adjust_touchHUD_length(Anim)

	"Display Screen Calculations"
	Utils.Screen.display_calculations(get_tree().get_root(), Utils)
	
	# Calculates the Length and Breadth of All Touchscreen HUD buttons
	dimensions = Utils.Functions.calculate_length_breadth(buttons_positional_data)
	
	# calculates a dimensional difference between the center of the vuewport aand the Button onscreen positions 
	dimensional_diff = dimensions - Globals.center_of_viewport 
	
	#For debug purposes only
	#print_debug("HUD Dimensions:", dimensions) # Breath of the wild lmao
	#print_debug("Dimension difference: ",dimensional_diff )
	
	#print_debug("Global Direction COntrols : ",Globals.direction_control, "/",dimensions, "/",dimensional_diff)





static func hide_self(operating_sys: String, screenOrientation : int, _Hide_touch_interface : bool, _node : TouchScreenHUD) -> void:
	#toggles touch interface visibility depending on the os and screen orientation (Pc or Mobiles)
	if operating_sys != 'Android' && screenOrientation == 0 :
		_Hide_touch_interface = true
		_node.hide()
		#print_debug('Hiding touch interface for ', Globals.os)



# I wrote all the states within functions. I should'vve instead written them within a process fucntion
"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""
func reset():  #resets node visibility statuses
	_state_controller = _RESET
	return _state_controller 

#Enumerate each of the following states

func status():  #used by ui scene when status is clicked
	
	hide_buttons()
	stats.show()


func comics():  #used by ui scene when comics is clicked
	_state_controller = _COMICS
	return _state_controller 


func menu(): #used by ui scene when menu is clicked
	_state_controller = _MENU
	return _state_controller 

func interract(): #used by ui scene when interract is clicked
	_state_controller = _INTERRACT
	
	# Note: 
	# Duplicate of State Machine Commands
	# TOuch Interface State machine is buggy
	# This might be due to the Scene Tree Pause that
	# Is triggered by certain Game HUD Modules
	hide_buttons()
	_menu.show()
	_interract.show()
	#return _state_controller  


func attack(): #used by ui scene when attack is clicked 
	_state_controller = _ATTACK
	return _state_controller 






# Handles Debugging Variables from the touch interface system
# Should PNly run once
func touch_interface_debug(): #Debug singleton is broken
	if _Hide_touch_interface == false && _debug.debug_panel != null && _Debug_Run == false:

		_Debug_Run = true# Runs this Debug Loop Only Once
		
		#RepositionButtonsHUD()
		# *************************************************
		# Buttons Debug
		# (a) Plot a line2d with all Buttons Position (done)
		# (b) Use Line Point Dimensions to Compare Global Screen Size calculations  
		# *************************************************
		
		for i in buttons_positional_data:
			LineDebug.add_point(i)
			
			

	#update Globals Direction Control variable to Local Variable
	# Should Fix  Broken Joystick/ Direction Changer
	#Changes D-pad Controls from control once the Touch Interface is ready
	#placeholder method
func set_controller(_control):
	if Globals.direction_control.empty():
		print("COntroller Type: :",Globals.direction_control)
		_control == Globals.direction_control
		#return
	

#func _RepositionButtonsHUD()-> void:
#	#pass
#	action_interract_buttons.set_position(action_interract_buttons.get_position() + dimensional_diff)
#	interract_buttons.set_position(action_interract_buttons.get_position() + dimensional_diff)
	


func _input(event):
	" UI logic" # 
	
	# State Machine Logic
	" UI Animation"
	# Controls the Touch interface state machine from the player's input 
	# Refactored
	# Processed every frame?
	
	# nested If Statements?
	
	"Touch Interface State Machine?"
	
	# Duplicate of Input.gd GLobal Input SIngleton
	if GlobalInput._state == GlobalInput.COMICS or Input.is_action_just_pressed("comics"):
		if Comics_v6.enabled == true:
			
			if _state_controller != _COMICS : # and _Comics.loaded_comics == true:
				comics()
			
		if not Comics_v6.enabled : #or _Comics.loaded_comics == false:
			reset()
	if GlobalInput._state == GlobalInput.PAUSE or Input.is_action_just_pressed("pause"):
		if GlobalInput._Stats.enabled == true : # GLobal Pointer to Stats HUD
			status() #calls a display function int the touch interface scene
			
	if GlobalInput._state == GlobalInput.MENU or Input.is_action_just_pressed('menu'):
		if GlobalInput.menu.enabled :
			
			menu()
		if not GlobalInput.menu.enabled:
			reset()
	if GlobalInput._state == GlobalInput.ATTACK or Input.is_action_just_pressed('attack'):
		if _state_controller != _ATTACK:
			attack()
			
			# Uses Networking Timer to Reset Touch Interface
			# Use Local TImer Instead
			Networking.start_check(3)
	if GlobalInput._state == GlobalInput.COMICS or Input.is_action_just_pressed('comics'):
		if GlobalInput._Comics.enabled :
			comics()
	else : 
		reset()
	
	'Interract UI'
	# Disabled for Debugging
	#
	# Hard connects to all interractible objects connected via the global variable
	#if Globals.near_interractible_objects == true : #&& Input.is_action_just_pressed("interact"):
		#TouchInterface.status()
	#	print_debug("Player near Interractible Object", Globals.near_interractible_objects)
	#elif Globals.near_interractible_objects == null or false:
	#	# if Input.is_action_just_pressed("interact") : return TouchInterface.reset()
	#	#return TouchInterface.reset()
	#	print_debug("PLayer Left Interactibe object")

	# *************************************************


	if Input.is_action_pressed("pause"):
		_state_controller = _STATS
	if Input.is_action_pressed("comics"):
		_state_controller = _COMICS
	if Input.is_action_pressed("interact"):
		_state_controller = _INTERRACT



func _process(delta):
	


	
	#write a rule that Joystick and Dpad cannot be visible at the same time
	
	"""
	State Machine For the TOuch interface
	# Works
	"""

		# calls to state machine work
	match _state_controller:
		_MENU:
			
			hide_buttons()
			
			_menu.show()
			
		_INTERRACT:
			#The interract state should only show when it's close to an interactible object 
			#if _Hide_touch_interface == false:
			
			hide_buttons()
			
			_menu.show()
			_interract.show()
				
		_ATTACK:
			
			emit_signal('attack')
		
			hide_buttons()
			
			_menu.show()
			slash.show()
			roll.show()
			if _control == Globals._controller_type[1]: # modern
				D_pad.hide()
				joystick_parent.show()
				
			if _control == Globals._controller_type[2]: # classic
				joystick_parent.hide()
				D_pad.show()
		_STATS:
			hide_buttons()
			
			stats.show()
		_COMICS:
			#kj;kn;k
			#Anim.play("COMICS")
			hide_buttons()
			comics.show()
		
		_RESET: 
			"shows all the UI options"
			show_action_buttons()
			
			show_direction_buttons()



func hide_buttons() :
	# Beware:  Hide Buttons FUnctions Clashes with UI Animation NOde player. The Animation node player Takes priority and canels 
	#	#	#GDScript Calls to this method
	
	#print_debug("ACTION BUTTONS: ",action_buttons)# for debug purposes only
	#print_debug('Global Controller;',Globals.direction_control)
	#print_debug("DIRECTION BUTTONS ", direction_buttons)
	
	# Reset Helper Booleans
	_action_button_showing = false
	_direction_button_showing = false
	
	
	for i in direction_buttons :
		#if i.visible() :
		i.hide()
	for x in action_buttons:
		if x.visible:
			x.hide()
	# hackky bug fix for D-pad UI showing Bug
	D_pad.hide()



func show_action_buttons() :
	# SHows the Action buttons recursively
	
	if _action_button_showing == false:
		for j in action_buttons:
			if j != null:
				j.show()
		_action_button_showing = true
		return _action_button_showing
	if _action_button_showing:
		pass


func show_direction_buttons():
	# 
	# Shows direction Button
	
	#if _direction_button_showing == false:
		
	#	print_debug("Direction Buttons : ",direction_buttons)
	#	print_debug("Direction COntrols : ",Globals.direction_control)
		
	for j in direction_buttons:
		j.show()
	_direction_button_showing = true
	
	return _direction_button_showing
	
	#if _direction_button_showing == true:
	#	pass

func _on_comics_showing(): # Doesnt Work
	print_debug("Comics SHowing")
	
	comics() 


func _on_comics_hidden():
	print_debug("Comics Hidden")
	reset()

