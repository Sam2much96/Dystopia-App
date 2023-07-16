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
# (1) Fix the joystick code  (fixed)
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
# *************************************************


extends Node2D

class_name TouchScreenHUD

var _Hide_touch_interface : bool

#Debug
onready var _debug = get_tree().get_root().get_node("/root/Debug")

#State Machine
enum { MENU, INTERRACT, ATTACK, STATS, COMICS, RESET }

export var _state_controller = RESET
export (String, 'analogue', 'direction') var _control
var _Debug_Run : bool = false


#signal menu
signal interract
signal attack
signal stats
signal comics
signal reset


var menu : TouchScreenButton 
var _interract : TouchScreenButton 
var stats : TouchScreenButton
var roll : TouchScreenButton 
var slash  : TouchScreenButton 

var comics : TouchScreenButton 
var joystick : TouchScreenButton 
var joystick2 : TouchScreenButton 
var D_pad : Control 

var Anim : AnimationPlayer 




var menu_position : Vector2
var _interract_position : Vector2
var stats_position : Vector2
var roll_position : Vector2
var slash_position : Vector2
var comics_position : Vector2
var joystick_position : Vector2
var D_pad_position : Vector2

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
func _enter_tree():
	"Global Pointer"
	Globals._TouchScreenHUD = self

	print_debug("Global Direction COntrols : ",Globals.direction_control)

func _ready():
 

	menu = $menu
	_interract = $Control/InterractButtons/interact
	stats = $Control/InterractButtons/stats
	roll = $Control/ActionButtons/roll
	slash = $Control/ActionButtons/slash
	comics = $Control/InterractButtons/comics
	joystick = $Joystick/joystick_circle
	joystick2 = $Joystick/joystick_circle2
	 
	Anim = $AnimationPlayer
	D_pad = $"D-pad"

	LineDebug = $Line2D
	#touch_interface_debug() disabling for now

	action_interract_buttons = $Control/ActionButtons 
	interract_buttons = $Control/InterractButtons

	"Set Button Arraqys for easy on/off"
	action_buttons = [menu ,stats,_interract,roll, slash,comics]
	
	if str(Globals.direction_control )== "direction" :
		direction_buttons = [D_pad]
	elif str(Globals.direction_control) == "analogue" :
		direction_buttons = [joystick, joystick2]
	else: direction_buttons = [D_pad, joystick, joystick2]

	"Touch UI Visibility"
	# Disabling for Debug
	hide_self(Globals.os, Globals.screenOrientation, _Hide_touch_interface, self)

	"Auto sets the controller button"
	reset()

	calculate_button_positional_data()
	
	"Display Screen Calculations"
	Globals.Screen.display_calculations(get_tree().get_root(), Globals)

	dimensions = calculate_length_breadth(buttons_positional_data)
	dimensional_diff = dimensions - Globals.center_of_viewport 
	print_debug("HUD Dimensions:", dimensions) # Breath of the wild lmao
	print_debug("Dimension difference: ",dimensional_diff )

	#touch_interface_debug()



func _input(event):
	
	
	"Actions Triggered by Global Input Keys"
	if event.is_action_pressed("pause"):
		_state_controller = STATS
	if event.is_action_pressed("comics"):
		_state_controller = COMICS
	if event.is_action_pressed("interact"):
		_state_controller = INTERRACT

static func hide_self(operating_sys: String, screenOrientation : int, _Hide_touch_interface : bool, _node : TouchScreenHUD) -> void:
	#toggles touch interface visibility depending on the os and screen orientation (Pc or Mobiles)
	if operating_sys != 'Android' && screenOrientation == 0 :
		_Hide_touch_interface = true
		_node.hide()
		print('Hiding touch interface for ', Globals.os)



# I wrote all the states within functions. I should'vve instead written them within a process fucntion
"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""
func reset():  #resets node visibility statuses
	_state_controller = RESET
	return _state_controller 

#Enumerate each of the following states

func status():  #used by ui scene when status is clicked
	
	hide_buttons()
	stats.show()


func comics():  #used by ui scene when comics is clicked
	_state_controller = COMICS
	return _state_controller 


func menu(): #used by ui scene when menu is clicked
	_state_controller = MENU
	return _state_controller 

func interract(): #used by ui scene when interract is clicked
	_state_controller = INTERRACT
	return _state_controller  


func attack(): #used by ui scene when attack is clicked 
	_state_controller = ATTACK
	return _state_controller 



func calculate_button_positional_data()-> void:

	
# *************************************************
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

func calculate_length_breadth(point_positions: Array) -> Vector2:
	var min_x = float('inf')
	var max_x = -float('inf')
	var min_y = float('inf')
	var max_y = -float('inf')

	# Find the minimum and maximum x and y coordinates
	for point in point_positions:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	# Calculate the length and breadth
	var length = max_x - min_x
	var breadth = max_y - min_y

	return Vector2(length, breadth)


func ScreenCalculationLogic():
	
	# *************************************************
	"Touch Screen UI"
	#hvliyilycic
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
	
	if Globals.screenOrientation == 1 && _control == 'direction': #works
		Anim.play("SCREEN_VERTICAL_1");
	if Globals.screenOrientation == 1 && _control == 'analogue': #works
		Anim.play("SCREEN_VERTICAL_2");
	##If screen Is Horizontal, it would be PC UI, making this code obsolete
	elif Globals.screenOrientation == 0:
		Anim.play("SCREEN_HORIZONTAL");
	else: pass;


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
	

func RepositionButtonsHUD()-> void:
	#pass
	action_interract_buttons.set_position(action_interract_buttons.get_position() + dimensional_diff)
	interract_buttons.set_position(action_interract_buttons.get_position() + dimensional_diff)
	


func _process(_delta):

	
	
	#write a rule that Joystick and Dpad cannot be visible at the same time
	
	"""
	State Machine For the TOuch interface
	# Works
	"""

		# calls to state machine work
	match _state_controller:
		MENU:
			
			#if _Hide_touch_interface == false: #include analogue controls
			
			#Anim.play("MENU")
			hide_buttons()
				
			menu.show()
				
			#pass
			
		INTERRACT:
			#The interract state should only show when it's close to an interactible object 
			#if _Hide_touch_interface == false:
					
			hide_buttons()
			
			menu.show()
			_interract.show()
				#return
				
			#pass
		ATTACK:
		
			#if _Hide_touch_interface == false:
			emit_signal('attack')
		
			hide_buttons()
			
			#stats.hide()
			menu.show()
			#_interract.hide()
			#comics.hide()
			slash.show()
			roll.show()
			if _control == 'analogue':
				D_pad.hide()
				joystick_parent.show()
				
			if _control == 'direction':
				joystick_parent.hide()
				D_pad.show()

			pass
		STATS:
			#state = 'status'
			#emit_signal('status')
			#if _Hide_touch_interface == false :
				#print_debug("Status")
			hide_buttons()
			
			stats.show()
			#Anim.play("STATUS")
		
			#pass
		COMICS:
			#if _Hide_touch_interface== false: 
			#hide_buttons()
			
			Anim.play("COMICS")
				#emit_signal('comics')
			
		
			pass
		RESET: #$ Too many ifs conditions #simplify state?
			#if _Hide_touch_interface == false :
					
			"shows all the UI options"
			show_action_buttons()
			
			show_direction_buttons()


	ScreenCalculationLogic()

func hide_buttons() :
	# Beware:  Hide Buttons FUnctions Clashes with UI Animation NOde player. The Animation node player Takes priority and canels 
	#	#	#GDScript Calls to this method
	print_debug("ACTION BUTTONS: ",action_buttons)# for debug purposes only
	print_debug("DIRECTION BUTTONS ", direction_buttons)
	
	for i in action_buttons :
		i.hide()
		for x in direction_buttons:
			x.hide()
				

func show_action_buttons()-> void:
	for j in action_buttons:
		if j != null:
			j.show()

func show_direction_buttons()-> void:
	#print_debug("Direction Buttons : ",direction_buttons)
	#print_debug("Direction COntrols : ",Globals.direction_control)
	
	for j in direction_buttons:
		j.show()


func _on_comics_showing(): # Doesnt Work
	print_debug("Comics SHowing")
	comics() 


func _on_comics_hidden():
	print_debug("Comics Hidden")
	reset()

