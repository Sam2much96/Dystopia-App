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
var D_pad : YSort 

var Anim : AnimationPlayer 

var action_buttons : Array = [menu ,stats,_interract,roll, slash,comics]
var direction_buttons : Array = [D_pad, joystick]


var menu_position : Vector2
var _interract_position : Vector2
var stats_position : Vector2
var roll_position : Vector2
var slash_position : Vector2
var comics_position : Vector2
var joystick_position : Vector2
var D_pad_position : Vector2

var buttons_positional_data : Array

var LineDebug : Line2D 
onready var joystick_parent: Control = $Joystick

func _ready():
 

	menu = $menu
	_interract = $interact
	stats = $stats
	roll = $roll
	slash = $slash
	comics = $comics
	joystick = $Joystick/joystick_circle2
	 
	Anim = $AnimationPlayer
	D_pad = $"D-pad"

	LineDebug = $Line2D
	#touch_interface_debug() disabling for now



	"Touch UI Visibility"
	# Disabling for Debug
	hide_self(Globals.os, Globals.screenOrientation, _Hide_touch_interface, self)

	"Auto sets the controller button"
	reset()



	#touch_interface_debug()

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
	_state_controller = STATS
	return _state_controller 


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
	D_pad_position = D_pad.position

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


# Handles Debugging Variables from the touch interface system
# Should PNly run once
func touch_interface_debug(): #Debug singleton is broken
	if _Hide_touch_interface == false && _debug.debug_panel != null && _Debug_Run == false:
		calculate_button_positional_data()
		
		"Display Screen Calculations"
		Globals.Screen.display_calculations(get_tree().get_root(), Globals)
		var dimensions = calculate_length_breadth(buttons_positional_data)
		print("Length of HUD:", dimensions.x)
		print("Breadth of HUD:", dimensions.y) # Breath of the wild lmao
		
		
		_Debug_Run = true# Runs this Debug Loop Only Once
		
		#print_debug ('Touch Interface Debug: ', 
		#" COntrol: ",Globals.direction_control, 
		#"Global Control", Globals.direction_control, 
		#'Touch Interface size: ', self.scale,
		#'Touch Interface pos: ', self.position,
		
		# *************************************************
		# Buttons Debug
		# (a) Plot a line2d with all Buttons Position (done)
		# (b) Use Line Point Dimensions to Compare Global Screen Size calculations  
		# *************************************************
		#'Menu Button Pos: ',menu_position ,
		#'Stats Button Pos:',stats_position,
		#'Interact Button Pos:',_interract_position,
		#'Roll Button Pos:',roll_position, 
		#'Slash BUtton Pos:',slash_position,
		#'Comics Button Pos:',comics_position
		#)

		# 
		
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
	





func _process(_delta):

	
	
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
	
	#ssdgsfg
	
	if Globals.screenOrientation == 1 && _control == 'direction': #works
		Anim.play("SCREEN_VERTICAL_1");
	if Globals.screenOrientation == 1 && _control == 'analogue': #works
		Anim.play("SCREEN_VERTICAL_2");
	##If screen Is Horizontal, it would be PC UI, making this code obsolete
	elif Globals.screenOrientation == 0:
		Anim.play("SCREEN_HORIZONTAL");
	else: pass;
	
	
	#write a rule that Joystick and Dpad cannot be visible at the same time
	
	"""
	State Machine For the TOuch interface
	"""
	match _state_controller:
		MENU:
			
			if _Hide_touch_interface == false: #include analogue controls
				
				hide_buttons()
				
				menu.show()
				
			pass
		INTERRACT:
			#The interract state should only show when it's close to an interactible object 
			if _Hide_touch_interface == false:

				
				hide_buttons()
				
				menu.show()
				_interract.show()

				return
				
			pass
		ATTACK:
		
			if _Hide_touch_interface == false:

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
			emit_signal('status')
			if _Hide_touch_interface == false :
				hide_buttons()
				
				stats.show()

		
			pass
		COMICS:
			if _Hide_touch_interface== false: 
				hide_buttons()

				comics.show()
				emit_signal('comics')
			
		
			pass
		RESET: #$ Too many ifs conditions #simplify state?
			if _Hide_touch_interface == false :

				
				"shows all the UI options"

				show_action_buttons()
				
				#return
				#touch_interface_debug() # For Debug Purposes only
				"SHows the directional based on a global variable?"
				if not Globals.direction_control == '':
					_control = Globals.direction_control
				
				if Globals.direction_control == 'analogue':
					joystick_parent.show()
					D_pad.hide()

					return
					#touch_interface_debug() # For Debug Purposes only
				elif Globals.direction_control == 'direction':
					joystick_parent.hide()
					D_pad.show()
				
				elif Globals.direction_control == '' && _control == "analogue":
					joystick_parent.show()
					D_pad.hide()
				elif Globals.direction_control== '' && _control == "direction":
					joystick_parent.hide()
					D_pad.show()
				else:
				
					return
			else:
				return
			
		
			pass
	pass




func hide_buttons()-> void:
	for i in action_buttons:
		if i != null:
			i.hide()
	for h in direction_buttons:
		if h != null:
			h.hide()

func show_action_buttons()-> void:
	for j in action_buttons:
		if j != null:
			j.show()
