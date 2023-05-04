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
# *************************************************


extends Node2D
"""
REWROTE THE STATEMACHINE 16/04/22 
"""

var _Hide_touch_interface : bool

export (bool) var _Debug
onready var menu = $menu
onready var _interract = $interact
onready var stats = $stats
onready var roll = $roll
onready var slash = $slash

onready var comics = $comics
onready var joystick = $Joystick
onready var D_pad = $"D-pad"

onready var Anim = $AnimationPlayer


#signal menu
signal interract
signal attack
signal stats
signal comics
signal reset

#Rewritten State Machine
enum { MENU, INTERRACT, ATTACK, STATS, COMICS, RESET }

export var _state_controller = RESET


export (String, 'analogue', 'direction') var _control

onready var action_buttons : Array = [menu ,stats,_interract,roll, slash,comics]
onready var direction_buttons : Array = [D_pad, joystick]

func _ready():
 
	#touch_interface_debug() disabling for now

	"Touch UI Visibility"
	#toggles touch interface visibility depending on the os and screen orientation (Pc or Mobiles)
	if Globals.os != 'Android' && Globals.screenOrientation == 0: 
		_Hide_touch_interface = true
		self.hide()
		print('Hiding touch interface for ', Globals.os)
		
		pass
		#disabled for debugging purposer. Reactivate later
#########Auto sets the controller button

	reset()

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
	
# Handles Debugging Variables from the touch interface system
func touch_interface_debug(): #Debug singleton is broken
	if _Hide_touch_interface == false:
		print ('Touch Interface Debug: ', " COntrol: ",Globals.direction_control, "Global Control", Globals.direction_control )


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
	if _Debug == true:
		touch_interface_debug() # For Debug Purposes only
	
	
	
	
	
	
	
	
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

					joystick.show()
				if _control == 'direction':
					joystick.hide()
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
				if not Globals.direction_control.empty():
					_control = Globals.direction_control
				
				if Globals.direction_control == 'analogue':
					joystick.show()
					D_pad.hide()

					return
					#touch_interface_debug() # For Debug Purposes only
				elif Globals.direction_control == 'direction':
					joystick.hide()
					D_pad.show()
				
				elif Globals.direction_control.empty() && _control == "analogue":
					joystick.show()
					D_pad.hide()
				elif Globals.direction_control.empty() && _control == "direction":
					joystick.hide()
					D_pad.show()
				else:
				
					return
			else:
				return
			
		
			pass
	pass




func hide_buttons()-> void:
	for i in action_buttons:
		i.hide()
	for h in direction_buttons:
		h.hide()

func show_action_buttons()-> void:
	for j in action_buttons:
		j.show()
