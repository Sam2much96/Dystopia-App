# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a touch interface consisting of Touch 2d buttons and a Touch screen Joystick
# information used by the ingame UI node.
# 

# Features:
# (1) A State Machine for the touch interface to hint the player and not clutter the ui
# (2) Emits it's state as a signal
# (3) Touch OS enables or Disables the touch interface depending on if a touch screen is present and the Globals.os. _Hide_touch_interface boolean variable
# (4) uses Globals.screenOrientation to change the button arrangements for mobiles
# (5) Connects to signals from Dialogues and COmics SIngletons
# (5) Changes Menu Button Colour Depending on Scene
# (6) Touchscreen HUD does adjusts to phone orientation on android 
#
# Bugs :
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
# (9) State machine is not optimized at all (processor hog) (1/2)
# (10) TOuch Interface should be adjustible on mobile using drag and drop
# (11) TOuch Interface Format and Scaling should be exported function to android singleton (DOne)
# (12) Implement Drag and Drop Customization using state machines and postion registers
# (13) Vibration Bug when Rescaling
# *************************************************


extends Node2D


class_name TouchScreenHUD #, "res://resources/misc/Android 32x32.png"

var _Hide_touch_interface : bool

#Debug
@onready var _debug = get_tree().get_root().get_node("/root/Debug")

# Comics Singleton Pointer
@onready var _comics = get_tree().get_root().get_node("/root/Comics_v6")
# Pointer to Parent
@onready var parent = get_parent()

# Pointer to menu node from Parent
@onready var menu2 = parent.get_child(4)

# Pointer to Global Menu Pointer
@onready var menu3 = GlobalInput.menu

#State Machine
enum { _MENU, _INTERRACT, _ATTACK, _STATS, _COMICS, _RESET }

@export var _state_controller : int = _STATS
@export var _control : String # Dupli9cate of Globals._controller_type # (String, 'modern', 'classic') 
var _Debug_Run : bool = false

@export var enabled : bool # Local Variant for stroing if device is android from adnroid singleton

#signal menu
signal interract
signal attack
signal stats
signal comics
signal reset


var _menu : TouchScreenButton 
var _interract : TouchScreenButton 
var stats_ : TouchScreenButton
var roll : TouchScreenButton 
var slash  : TouchScreenButton 

var comics_ : TouchScreenButton 
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

@onready var joystick_parent: Control = $Joystick

'UI button as arrays'
@onready var action_buttons : Array 
@onready var direction_buttons : Array 


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
	#
	GlobalInput.TouchInterface = self
	Android.TouchInterface = self
	
	
	if not Android.is_android():
		self.hide() 
	else: print_debug("Showing Touch Interface")
	
	enabled = Android.is_android()
	
	# Update scene Temporarily Disabled
	#Globals.update_curr_scene()
	
	#print_debug( " Global Touch HUD: ", GlobalInput.TouchInterface)
	
	# To DO  : 
	# (1) Improve Touch HUD for mobile players
	# (2) Add touch hud drag and drop using refactored comics script
	# (3) Fix hud auto orientation for mobile
	
	# Turn off this setup script if not running on Android
	if ( Globals.os == "Android" or Android.is_android()):
		_menu = $menu
		_interract = $Control/InterractButtons/interact
		stats_ = $Control/InterractButtons/stats
		roll = $Control/ActionButtons/roll
		slash = $Control/ActionButtons/slash
		comics_ = $Control/InterractButtons/comics
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
		
		# Select Users Preferred Direction Controls 
		
		if str(Globals.direction_control )== "classic" :
			direction_buttons = [D_pad]
		elif str(Globals.direction_control) == "modern" :
			direction_buttons = [ _joystick, joystick2]
			
			# Default Direction Button should be Analgue
		else: direction_buttons = [ _joystick, joystick2]

	#print_debug(direction_buttons, Globals.direction_control)

		"Touch UI Visibility"
		# moved to ANdroid singleton
		# Disabling for debugging
		#hide_self(Globals.os, Globals.screenOrientation, _Hide_touch_interface, self)
		
		"Touch Menu Button Customization"
		# Customizes 
		if Globals.curr_scene == "HouseInside":
			_menu.self_modulate = Color(255,255,255) # white
		else: _menu.self_modulate = Color(0,0,0) # black
		
		"Auto sets the controller button"
		reset_()
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
		
		"Set Initial Touch HUD Layout"
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
	
	
	# Debug Required Pointers
	#print_debug(parent, menu2, menu3)
		
		"Mobile Specific Signals"
		print_debug("Stats Signals and Menu signals implementation are broken")
		# COnnect signals from dialogue
		# DIalogues to self
		Dialogs.connect("dialog_started", Callable(self, "interract"))
		Dialogs.connect("dialog_ended", Callable(self, "reset"))

		# Comics to Touch Interface
		if is_instance_valid(_comics): # Buggy Singleton Instance
			_comics.connect('comics_showing', Callable(self, '_on_comics_showing'))
			_comics.connect('comics_showing', Callable(self, '_on_comics_hidden'))

		# Menu to Touch Interface
		# Quick Hacky Fiz
		if is_instance_valid(menu2): # Error Catcher 1
			menu2.connect("menu_showing", Callable(self, "menu")) 
			menu2.connect("menu_hidden", Callable(self, "reset"))
		
		# REdundancy code
		# connects menu from global pointer
		if is_instance_valid(menu2):
			if not (menu3.is_connected("menu_showing", Callable(self, "menu")) &&
			menu3.is_connected("menu_hidden", Callable(self, "reset"))
			):
				menu3.connect("menu_showing", Callable(self, "menu")) 
				menu3.connect("menu_hidden", Callable(self, "reset"))
		# Networking TImer to Touch Interface
		# Resets Using Networking timer
		Networking.timer.connect("timeout", Callable(self, "reset")) 

		# Connects Stats Ui Signals To Touchscreen HUD for Mobile
		if is_instance_valid(Inventory._stats_ui):
			Inventory._stats_ui.connect("status_showing", Callable(self, "status"))
			Inventory._stats_ui.connect("status_hidden", Callable(self, "reset"))
			
			# Debug Signals

		# Debug SIgnals
		# Convert to Unit Tests instead
		# TO DO:
		# (1) Debug Code
		# (2) Update Documentation
		if is_instance_valid(Dialogs && Comics_v6 && menu3 && Networking):
			if not (Dialogs.is_connected("dialog_started", Callable(self, "interract")) &&
				Dialogs.is_connected("dialog_ended", Callable(self, "reset")) &&
				_comics.is_connected('comics_showing', Callable(self, '_on_comics_showing')) &&
				_comics.is_connected('comics_showing', Callable(self, '_on_comics_hidden')) &&
				menu3.is_connected("menu_showing", Callable(self, "menu")) &&
				menu3.is_connected("menu_hidden", Callable(self, "reset")) &&
				Networking.timer.is_connected("timeout", Callable(self, "reset"))) == true:

				# Debug Node Signal Connections
				print_debug(
					Dialogs.is_connected("dialog_started", Callable(self, "interract")),
					Dialogs.is_connected("dialog_ended", Callable(self, "reset")),
					_comics.is_connected('comics_showing', Callable(self, '_on_comics_showing')),
					_comics.is_connected('comics_showing', Callable(self, '_on_comics_hidden')),
					menu3.is_connected("menu_showing", Callable(self, "menu")), 
					menu3.is_connected("menu_hidden", Callable(self, "reset")),
					Networking.timer.is_connected("timeout", Callable(self, "reset")) 
					)




# I wrote all the states within functions. I should'vve instead written them within a process fucntion
"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""
func reset_():  #resets node visibility statuses
	_state_controller = _RESET
	return _state_controller 

#Enumerate each of the following states

func status():  #used by ui scene when status is clicked
	
	hide_buttons()
	stats_.show()


func comics__():  #used by ui scene when comics is clicked
	_state_controller = _COMICS
	return _state_controller 


func menu(): #used by ui scene when menu is clicked
	_state_controller = _MENU
	return _state_controller 

func interract_(): #used by ui scene when interract is clicked
	print_debug("interract")
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


func attack_(): #used by ui scene when attack is clicked 
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
#func set_controller(_control):
# Unused Code, depreciated
#	if Globals.direction_control.empty():
#		print("COntroller Type: :",Globals.direction_control)
#		_control == Globals.direction_control
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
	# Processed every frame? (1/2)
	
	# nested If Statements?
	
	"Touch Interface State Machine?"
	if enabled:
		 
		# Duplicate of Input.gd GLobal Input SIngleton
		if GlobalInput._state == GlobalInput.COMICS or Input.is_action_just_pressed("comics"):
			if _comics.enabled == true:
				
				if _state_controller != _COMICS : # and _Comics.loaded_comics == true:
					comics__()
				
			if not _comics.enabled : #or _Comics.loaded_comics == false:
				reset_()
		if GlobalInput._state == GlobalInput.PAUSE or Input.is_action_just_pressed("pause"):
			if GlobalInput._Stats.enabled_ == true : # GLobal Pointer to Stats HUD
				status() #calls a display function int the touch interface scene
				
		if GlobalInput._state == GlobalInput.MENU or Input.is_action_just_pressed('menu'):
			if GlobalInput.menu.enabled :
				
				menu()
			if not GlobalInput.menu.enabled:
				reset_()
		if GlobalInput._state == GlobalInput.ATTACK or Input.is_action_just_pressed('attack'):
			if _state_controller != _ATTACK:
				attack_()
				
				# Uses Networking Timer to Reset Touch Interface
				# Use Local TImer Instead
				Networking.start_check(3)
		if GlobalInput._state == GlobalInput.COMICS or Input.is_action_just_pressed('comics'):
			if GlobalInput._Comics.enabled :
				comics__()
		else : 
			reset_()
		
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



func _physics_process(delta):
	


	
	#write a rule that Joystick and Dpad cannot be visible at the same time
	
	"""
	State Machine For the TOuch interface
	"""
	# TO DO : 
	# (1) Reformat to Physcis Processs to reduce process calls in main scene tree
	if enabled:
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
				
				stats_.show()
			_COMICS:
				#kj;kn;k
				#Anim.play("COMICS")
				hide_buttons()
				comics_.show()
			
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
	
	comics__() 


func _on_comics_hidden():
	print_debug("Comics Hidden")
	reset_()

