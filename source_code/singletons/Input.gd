# *************************************************
# godot3-RPG by Samuel Harrison
# Released under MIT License
# *************************************************
# INPUT SINGLE4TON
#
# Code Logic handles all input in the game/app project
# It also implements an Input Buffer for netwoked multiplayer
# To DO
#(1) Should implement Vibrations for haptic feedback
# (2) Implement Input Lag (Delay) For Multiplayer Gameplay
# *************************************************

extends Control

class_name Input_Buffer

# For Storing An Array of Input Data FOr Networking Multiplayer
var input_buffer : Array = []

enum {LEFT,RIGHT,UP,DOWN,ATTACK,ROLL,BLOCK, RESET, COMICS, NEXTPANEL, PREVPANEL, DRAG}

# State Machine
var _state : int = LEFT

# Frame Counter
var _frame_counter : int = 0

var pressed : bool = false

func _input(event):
	# Player Input
	
	if Input.is_action_pressed("move_left"):
		
		_state = LEFT
		#facing = LEFT
		pressed = true
		pass
	if Input.is_action_just_released("move_left"):
		
		_state = RESET
		pressed = false
		pass
	
	if Input.is_action_pressed("move_right"):
		
		_state = RIGHT
		#facing = RIGHT
		pass
	if Input.is_action_just_released("move_right"):
		
		_state = RESET
		#facing = RIGHT
		pass
	if Input.is_action_pressed("move_up"):
		
		_state = UP
		#facing = UP
		pass
	if Input.is_action_just_released("move_up"):
		
		_state = UP
		#facing = UP
		pass
	if Input.is_action_pressed("move_down"):
		
		_state = DOWN
		#facing = DOWN
		pass
	if Input.is_action_just_released("move_down"):
		
		_state = DOWN
		#facing = DOWN
		pass
	if Input.is_action_just_pressed("attack"):
		
		_state = ATTACK
		pass
	if Input.is_action_just_released("attack"):
		
		_state = ATTACK
		pass
	if Input.is_action_just_pressed("roll"):
		
		_state = ROLL
		pass
	if Input.is_action_just_released("roll"):
		
		_state = ROLL
		pass
	
	# Comics Input
	if event.is_action_pressed("reset"):
		
		_state = RESET
		pass
	if event.is_action_pressed("next_panel"):
		
		_state = NEXTPANEL
		pass
	if event.is_action_pressed("comics"):
		
		_state = COMICS
		pass
	if event is InputEventScreenDrag : 
		_state = DRAG

	# Ingame Menu
	if event.is_action_pressed("menu"):
		pass
	
	# Dialogues
	if event.is_action_pressed("interact") :
		pass
	
	# HUD
	if Input.is_action_just_pressed("pause"):
		pass

	"Auto Scroller"
	# Connects to Global Comics Swipe Feature and Game Menu Scroller function
	#'AutoScroller'
	# Implemented but Requires Proper Swipe Gesture Callibration
	# 

	if Comics_v6._state == Comics_v6.SWIPE_RIGHT:
		
		
		# Scroll Down
		#Game_Menu.scroll(false, true,scroller)
		pass
	if Comics_v6._state == Comics_v6.SWIPE_DOWN:
		
		# Scroll Up
		#Game_Menu.scroll(true, true,scroller)
		pass
	

func _process(delta : float):
	
	
	_frame_counter += round(delta)
	
		# Save Input Pressed to Input Buffer
		# Works but stores wrong data
	#	if not input_buffer.has(str(event)):
	#		input_buffer.append(str(event))
		#print_debug(event)
		
	if _frame_counter % 12 == 0:
		# REGISTER INPUT
		# Buggy
		#print(input_buffer, _state)
		if input_buffer.empty() == true :
			input_buffer.append(_state)
			#pressed = false
		if input_buffer.empty() == false && pressed == true:
			#if int(input_buffer.pop_back() + 1) == _state:
			input_buffer.insert(int(input_buffer.size()-1), _state)
			#print(input_buffer, _state, input_buffer.pop_back())
			#pressed= false


	# Logic for Storing Inpute States as Array[Int]
	#if input_buffer.empty() :
	#	input_buffer.append(_state)
	#if input_buffer.pop_back() != _state:
	#	input_buffer.append(_state)
	#if input_buffer.pop_back() == _state: pass

		# Prevent Memory Leak/ Stack Overflow error 
		if input_buffer.size() > 200:
			input_buffer.clear()


