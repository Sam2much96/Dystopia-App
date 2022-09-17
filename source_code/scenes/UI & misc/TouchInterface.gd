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

# TO DO:
# (1) Fix the joystick code  (fixed)
# (2) Update the interract state to be usable
# (3) Hidetouch interface / Touch interface reset bug (workaround) CLicking other buttons on the touch UI resets this bug on touch UI
#(4) Edit Documentation to be neater (Online documetation)
# (5) Joystick Colors?
# *************************************************


extends Node2D
"""
REWROTE THE STATEMACHINE 16/04/22 
"""

export (bool) var _Hide_touch_interface

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


signal menu
signal interract
signal attack
signal stats
signal comics
signal reset

#Rewritten State Machine
enum { MENU, INTERRACT, ATTACK, STATS, COMICS, RESET }

export var _state_controller = RESET


export (String, 'analogue', 'direction') var _control
func _ready():
#Changes D-pad Controls from control once the Touch Interface is ready
	if _control != null:
		Globals.direction_control = _control 
		touch_interface_debug()

#toggles touch interface visibility depending on the os (Pc or Mobiles)
	if Globals.os != str('Android') or str('ios'): # Detecting OS type is buggy on Android builds
		if _Hide_touch_interface == true: #
			self.hide()
			print('Hiding touch interface', Globals.os)

#########Auto sets the controller button

	reset()

# I wrote all the states within functions. I should'vve instead written them within a process fucntion
"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""
func reset():  #resets node visibility statuses
	_state_controller = RESET
	return _state_controller 

#Enimerate each of the following states

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
		print ('Touch Interface Debug: ', " COntrol: ",_control, "Global Control", Globals.direction_control )

func _process(_delta):
	if _Debug == true:
		touch_interface_debug() # For Debug Purposes only
	
	# Changes the button Layout depending on the screen orientation
	if Globals.screenOrientation == 1: #works
		Anim.play("SCREEN_VERTICAL");
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
				stats.hide()
				menu.show()
				D_pad.hide()

				joystick.hide()
				_interract.hide()
				comics.hide()
				slash.hide()
				roll.hide()

				emit_signal("menu")
			pass
		INTERRACT:
			#The interract state should only show when it's close to an interactible object 
			if _Hide_touch_interface == false:

				emit_signal('interract')
				stats.hide()
				menu.show()
				D_pad.hide()

				joystick.hide()
				_interract.show()
				comics.hide()
				slash.hide()
				roll.hide()
				return
				
			pass
		ATTACK:
		
			if _Hide_touch_interface == false:

				emit_signal('attack')
				stats.hide()
				menu.show()
				_interract.hide()
				comics.hide()
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
				stats.show()
				menu.hide()
				D_pad.hide()

				joystick.hide()
				_interract.hide()
				comics.hide()
				slash.hide()
				roll.hide()
				
		
			pass
		COMICS:
			if _Hide_touch_interface== false: 
				stats.hide()
				menu.hide()
				D_pad.hide()

				joystick.hide()
				_interract.hide()
				comics.show()
				slash.hide()
				roll.hide()

				emit_signal('comics')
			
		
			pass
		RESET: #$ Too many ifs conditions #simplify state?
			if _Hide_touch_interface == false :

				emit_signal('reset')
				#for child in get_children():
				#	child.show()
				"shows all the UI options"
				stats.show()
				menu.show()
				_interract.show()
				comics.show()
				slash.show()
				roll.show()
				return
				#touch_interface_debug() # For Debug Purposes only
				"SHows the directional based on a global variable?"
				if _control == 'analogue':
					joystick.show()
					D_pad.hide()

					return
					#touch_interface_debug() # For Debug Purposes only
				elif _control == 'direction':
					joystick.hide()
					D_pad.show()

					
					#touch_interface_debug() # For Debug Purposes only
					return
				else:
					return
			
		
			pass
	pass
