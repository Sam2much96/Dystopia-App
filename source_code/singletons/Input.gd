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
# *************************************************
# Notes:
# (1) Vibration is a Battery & Performance hog
# (2) Vibration is currently only implemented on Android, porting would require custom libraries
# *************************************************
# Bugs:
# (1) Fix Joystick v2 vibration spams
#
# *************************************************



extends Control

class_name Input_Buffer

# For Storing An Array of Input Data FOr Networking Multiplayer
@export var input_buffer : Array = []

enum {LEFT,RIGHT,UP,DOWN,ATTACK,ROLL,BLOCK, RESET, 
COMICS, NEXTPANEL, PREVPANEL, DRAG, PAUSE, MENU, 
INTERRACT, DIALOGUE
}

# State Machine
@export var _state : int 

# Frame Counter
#var _frame_counter : int = 0

var pressed : bool = false

# Vibration Settings
@export var vibrate : bool = true



# Game HUD : pointers updated from game hud
# Each of these Objects Use/ REquire Player input
# Having them always in memory is a good thing
# *************************************************
var menu : Game_Menu
var TouchInterface : TouchScreenHUD
var _Comics = Comics_v6 #$Comics

var _Stats : Stats
var _Status_text : StatusText 


var gameHUD : GameHUD
#"Ingame HUD"
## Mobiles
#var _TouchScreenHUD : TouchScreenHUD

# Mobile Joystick
var joystick 

func _input(event):
	# Player Input
	# Implement Player Objects Movement State Machine Simplified
	
	if Input.is_action_pressed("move_left"):
		
		_state = LEFT
		#facing = LEFT
		pressed = true
		vibrate_(40, Globals.os)
	if Input.is_action_just_released("move_left"):
		
		_state = RESET
		pressed = false
		#pass
	
	if Input.is_action_pressed("move_right"):
		
		_state = RIGHT
		#facing = RIGHT
		vibrate_(40,Globals.os)
	if Input.is_action_just_released("move_right"):
		
		_state = RESET
		#facing = RIGHT
		#pass
	if Input.is_action_pressed("move_up"):
		
		_state = UP
		#facing = UP
		vibrate_(40,Globals.os)
	if Input.is_action_just_released("move_up"):
		
		_state = RESET
		#facing = UP
		#pass
	if Input.is_action_pressed("move_down"):
		
		_state = DOWN
		#facing = DOWN
		vibrate_(40,Globals.os)
	if Input.is_action_just_released("move_down"):
		
		_state = RESET
		#facing = DOWN
		#pass
	if Input.is_action_just_pressed("attack"):
		
		_state = ATTACK
		
		vibrate_(75,Globals.os)
	if Input.is_action_just_released("attack"):
		
		_state = RESET
		
	if Input.is_action_just_pressed("roll"):
		
		_state = ROLL
		#pass
	if Input.is_action_just_released("roll"):
		
		_state = RESET
		#pass
		vibrate_(40,Globals.os)
	
	# Comics Input
	if event.is_action_pressed("reset"):
		
		_state = RESET
		#pass
	if event.is_action_pressed("next_panel"):
		
		_state = NEXTPANEL
		#pass
	if event.is_action_pressed("comics"):
		
		_state = COMICS
		#pass
	if event is InputEventScreenDrag : 
		_state = DRAG

	# Ingame Menu
	if event.is_action_pressed("menu"):
		_state = MENU
	
	if event.is_action_released("menu"):
		_state = RESET
	
	# Dialogues
	if event.is_action_pressed("interact") :
		_state = INTERRACT
	
	if event.is_action_released("interact") :
		#_state = RESET
		pass
	# HUD
	if Input.is_action_just_pressed("pause"):
		_state = PAUSE
	
	if Input.is_action_just_released("pause"):
		_state = RESET





	"Auto Scroller"
	# Connects to Global Comics Swipe Feature and Game Menu Scroller function
	#'AutoScroller'
	# Implemented but Requires Proper Swipe Gesture Callibration
	# 
	# Depreciated State Machibne
	#if Comics_v6._state == Comics_v6.SWIPE_RIGHT:
		
		
		# Scroll Down
		#Game_Menu.scroll(false, true,scroller)
	#	pass
	#if Comics_v6._state == Comics_v6.SWIPE_DOWN:
		
		# Scroll Up
		#Game_Menu.scroll(true, true,scroller)
	#	pass

	if input_buffer.is_empty() == true && pressed:
		input_buffer.append(_state)
		return
	
	if not input_buffer.is_empty() && int(input_buffer[input_buffer.size()-1]) != _state:
		input_buffer.append(_state)
		return

	# Prevent Memory Leak/ Stack Overflow error 
	if input_buffer.size() > 12:
		#	print(input_buffer, _state, input_buffer.pop_front())
			input_buffer.clear()
			return



func parse_input( action : String, _pressed : bool):
	#This Logic Creates and Parses Input actions programmatically
	
	var a = InputEventAction.new()
	a.action = action
	a.button_pressed = _pressed
	Input.parse_input_event(a)


func vibrate_(duration_ms : int, os : String):
	# Nested if?
	if Globals.os == "Android" && vibrate : #or "iOS" or "HTML5":
		
		if joystick == null :# Fixes Mobile joystick spamm vibration bug
			# Shoud Connect to Controls so it can be turned on/off
			
			# Vibration on Mobile Devices
			Input.vibrate_handheld(duration_ms)
			# 2 seconds wait time before next vibratino
			Networking.start_check_v2(5)


func roll_direction_calculation()-> Vector2:
	var calc = Vector2(- int( Input.is_action_pressed("move_left") ) + int( Input.is_action_pressed("move_right") ), -int( Input.is_action_pressed("move_up") ) + int( Input.is_action_pressed("move_down") )).normalized()
	return calc


# Returns an Input Buffer for simulations calculations
# concats the input buffer array into a string
func _get_input_buffer() -> int:
	return int(Utils.array_to_string(input_buffer.duplicate()))


#func show_loading(): # depreciated
#	gameHUD._loading.show()
