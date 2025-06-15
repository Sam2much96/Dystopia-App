
# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Joystick version 2
#
# Controls 2 Touch Screen Buttons As Child Nodes And Can Map TO Different FUnctionalitiys
#
# The purpose of this code is to expand the Directional options to the Player
# It runs as a child of the touch interface node and is enabled & disabled via a global variable (bool) linked to the TOuch Interface
# It can be turned off and un in the game's Control scene, but it's buggy nature has made it unusable
# It is possible to change the Joystick's color and use that as a player hint
# On 16/04/22, i tried to write down the above pieces of code
# *************************************************
# Features :
# (1) Custom Button Mapping
#
# *************************************************
# Bugs :
#
# (1) Misalignment in the joystick circles
# (2) Break code blocs into functions for better processing
# (3) Stuck input bug from input action
# (4) make white & black theme for joysitck circle
# (5) Add a color changer setting function
# (6) Disable the joystick conrol function use hidden analogue instead
# (7) Input event is not consumed (fixed)
# (8) Mobile joystick spamm vibration bug
# *************************************************
# To-Do :
# (1) It is possible to change the Joystick's color and use that as a player hint
# (2) Refactor State Machine to remove multiple runs and stuck states
# *************************************************


extends Control

class_name JoystickV2


export (bool) var enabled 

###############JoyStick Controller################
var joystick_debug
var touchInsideJoystick #= false
var maxlength



# The Joystick Direction as A Vector 2
export (int) var x
export (int) var y

# Custom Button Mapping
export(bool) var custom_mapping = false

export(String) var up = ""
export(String) var down = ""
export(String) var left = ""
export(String) var right = ""

var __input = null
onready var the_action : String

onready var the_event

onready var joystick_circle : JoystickCircle = $joystick_circle
onready var outer_circle : JoystickCircle = $joystick_circle2

enum {MOVE_UP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, RELEASE, NULL}


export var state = RELEASE

# Depreciated in favor of Global Input
var prev_inputs = [] # An aray to store the last two joystick inputs


# Removes all unhandleled event from the node
func _unhandled_input(event):
	if event:
		return
	
	
# tHIS FUNCTION IS BEING CALLED NON-STOP
func release(): #pass it a variable
	#######reseting functionr#########   #it is the release state as a function 
	#the previous action gets stuck in the scene tree as input
	if self.visible == true:
		#print('released digital joystick') #for debug purposes only1
		
		#print ('reset digital joystick: ',the_event, the_action )
		__input.pressed = false
		#touchInsideJoystick = false
		#__input.action = ''
		#Input.parse_input_event(__input)
		
		parse_input_function(__input)
		
		#Input.action_release(__input.action)
		
		release_the_action(__input.action)
		state = RELEASE	
		
		#vibrate = true
		
		return state

func _ready():
	if enabled:
		__input =InputEventAction.new()
	
	"""
	ERROR CHECKERS
	"""
	# Check That Custom Button Mapping is Available
	if custom_mapping == true:
		if (up.empty() or
		down.empty() or
		left.empty() or
		right.empty()):
			push_error(" CUstom Button Mapping cannot be empty once enabled")


func _input(event):
	if not enabled: # Guard Clause 1
		return
	
	if not self.visible: # GUard Clause 2
		return
	
	
	" Disable Swipe Detection"
	# depreciated
	#Comics_v6.SwipeLocked = true
	
	
	if event is InputEventScreenDrag and self.visible == true :
		
		GlobalInput.joystick = self
		#print(str((event.get_relative())))  #for debug purposes only
		the_event = event
		
		if touchInsideJoystick == true && joystick_circle.is_pressed() == true:
			#start_debug()
			#######sets joystic circle to touch event direction ############
			joystick_circle.pos.x = joystick_circle.pos.x + event.relative.x
			joystick_circle.pos.y = joystick_circle.pos.y + event.relative.y
				
				
			maxlength = outer_circle.circle_size - joystick_circle.circle_size
	################################################################# 

	###################Clamps the Joystick cirle withing a radius#############################
			if joystick_circle.pos.length() > maxlength: # SHould be in a separate functio
				var angle = joystick_circle.pos.angle()
				joystick_circle.pos.x = cos(angle) * maxlength 
				joystick_circle.pos.y = sin(angle) * maxlength

			x = round(joystick_circle.pos.x/maxlength) #divide x and y by max length
			y = round(joystick_circle.pos.y/maxlength)

			#return (x)
			#return (y)
############################Joystick Analogue Controls controls here####################

		" ________BEGINNING OF JOYSTICK LOGIC_______  "
		#Its called in input so it doesn't eat CPU Processes or threads
		# Might rewrtire into a separate function if the debug process comes out negative?
		# 
		if joystick_circle.is_pressed():
			if x == (1) and y == (0) : 
				#release() 
				state =MOVE_RIGHT
			if x == (-1) and y ==(0): 
				#release()
				state = MOVE_LEFT
			if x == (0) and y ==(1) :
				#release()
				state = MOVE_DOWN
			if x == (0) and y == (-1) : 
				#release()
				state = MOVE_UP
			if x == abs(0) and y == abs(0)  : 
				state = RELEASE #The directional controls work here and above works
			else:
				#state = RELEASE
				#release()
				#print (x,y) # for debug purposes only
				return state
				
		if not joystick_circle.is_pressed() :
			return

#######Resets Joystick if event is released##############################
	if event is InputEventScreenTouch and event.pressed == false:
		joystick_circle.pos.x = 0
		joystick_circle.pos.y = 0
		###### Additional codes
		x = 0
		y= 0
		# check if any action is pressed and then release them here
		#print(check_if_any_Input_action_is_pressed())

		
		#state = 4  
		touchInsideJoystick = false
		state = RELEASE
		#release()
		#stop_debug()
		return state #__input
	if event is InputEventScreenTouch and event.pressed == true: #add a douch colision that is the size of joystick outter circle
		touchInsideJoystick = true
		#state = RELEASE #buggy
		#start_debug()

###################################################################################################
		 #####The 8 directional analogur code is working
		" ________END OF JOYSTICK LOGIC_______  "


# UnOptimized Code Bloc?
func _process(delta):
	if not enabled: # Guard Clause 1 
		return
	
	if not self.visible: # GUard Clause 2
		return
	
	#if self.visible:
		
		# Dwpreciated for Global Input Singleton
	if prev_inputs.size() >= 10: # Stores only 2 input values max
		prev_inputs.erase(prev_inputs.pop_front()) # Removes the first values
		# Remove values that already exist
	
	"""
	DEBYG INPUT ACTIONS
	"""
	var debug_ = false
	#print (state) # For debug purposes only 
	if debug_ == true: # For Debug Purposes Only 
		print (x,y, check_if_any_Input_action_is_pressed(), str(__input.action), " Pressed:",str(__input.pressed)) # For debug Purposes only
		

	###################Input Action State Machine#####################################
	# *************************************************
	# godot3-Dystopia-game by INhumanity_arts
	# Released under MIT License
	# *************************************************
	# Joystick State Machine
	# Controls the Joystick Object every frame
	# Bugs:
	# (1) Stuck state : Statemachine does not allow switing states per frame  
	# (2) Bad Code requires refactoring to fix multiple returns and Export variables (1/2)
	# *************************************************
		if self.visible && enabled: # Performance Optimizer
			match state:
				MOVE_UP: #improve your state machine
					if joystick_circle.is_pressed() == true:
						#release()
						__input.action = up
						__input.pressed =true
						
						# Converts negative values to positive
						__input.strength = abs(y)
						#Input.parse_input_event(__input) # The bug is coming from this line of code duplicates
						parse_input_function(__input)
						
						the_action = __input.action 
						
						start_debug()
						#state = 0
						the_action = __input.action
						return the_action
						#print(__input.as_text()) #for debugging release
					
						#return state
				MOVE_DOWN:
					if joystick_circle.is_pressed() == true:
						#release()
						__input.action = down
						__input.pressed =true
						
						# Converts negative values to positive
						__input.strength = abs(y)
						#Input.parse_input_event(__input) # The bug is coming from this line of code duplicates
						
						parse_input_function(__input)
						
						the_action = __input.action
						start_debug()
						#state = 1
						the_action = __input.action
						return the_action
						#print(__input.as_text()) #for debugging release

				MOVE_RIGHT:
					if joystick_circle.is_pressed() == true:
						
						__input.action = right
						__input.pressed =true
						__input.strength = abs(x)
						#Input.parse_input_event(__input) # The bug is coming from this line of code duplicates
						
						parse_input_function(__input)
						
						the_action = __input.action
						start_debug()
						#state = 2
						the_action = __input.action
						return the_action
						#print(__input.as_text()) #for debugging release
						#reset()

				MOVE_LEFT:
					if joystick_circle.is_pressed() == true:
						#release()
						__input.action = left
						__input.pressed = true
						__input.strength = abs(x)
						#Input.parse_input_event(__input) # WHy Multiple separate input parse?
						parse_input_function(__input)
						#start_debug() # For Debug PUrposes only
						#state = 3
						the_action = __input.action
						return the_action
						#print(__input.as_text()) #for debugging release
						#reset()

				NULL:
					return
				RELEASE: #this is buggy it introduces a stuck button bug
					release() 
					if joystick_circle.is_pressed()!= true:
						release()
					if the_action != null && joystick_circle.is_pressed() == true: #write two inputs at the same time error code #THeres a stuc button bug
						#print(the_action) #two actions stacking introduces bug
						if __input.is_action_pressed(the_action) == true: #if my action pressed is true
							if __input.get_action_strength(the_action) != 0:
								__input.pressed =false #stuck button bug
								__input.strength = 0
								#reset() # The code breaks here
								#print('The current action',the_action) #for debug purposes only
								#Input.parse_input_event(__input) # The bug is coming from this line of code duplicates
								
								parse_input_function(__input)
								
								print_debug ('1111') # For Debug purposes only
							if __input.get_action_strength(the_action) == 0:
								release()
						#Input.action_release(the_action)#; update()
						release_the_action(the_action)
							#state = 4
							#stop_debug()
							
						return the_action
			##############################################################################
			
			#print_debug(the_action, typeof(the_action)) # for debug purposes only


		if touchInsideJoystick == false:
			#release()
			state = RELEASE

		" Fixes stuck action function : Error catcher 3"
		#if (__input.action)== "move_left" or "move_right" or "move_up" or "move_down":
		#	if bool(__input.pressed) == false :
		if (x)== 0 && (y) == (0): 
			" Fixes Stuck input bug"
			#
			# By Loopiing through the last 10 input sand releasing them
			#
			for _i in prev_inputs: 
				__input.action = _i #uses a for loop to release all previous inputs
			
				__input.strength = 0
				__input.pressed = false
				#release_the_action(__input)
				return parse_input_function(__input)
				#return #state = NULL
			
		else: return
		#if bool(__input.pressed) == true:
		#			return
		#		if (x)!= 0 or (y) != (0):
		#			return
		#		return state
			








func start_debug():
###############________Debugs the Joystick Node__________########################S
	if touchInsideJoystick == true && joystick_circle.is_pressed() == true:
		joystick_debug = str(
			'Joypad Debug')+ '/'+'x ' +str(x) + ',' +'y ' +str(y) + ' state: '+str (state) + '/'+' Touch inside Joystick:'+ str(touchInsideJoystick)+ '/'+ 'Input Action: '+str(__input.action + 'Pressed: '+ str(__input.pressed) +'/'# + str(the_event)
			)
	#print (joystick_debug) #disable when not debugging
		var _debug = get_node("/root/Debug")
		
		if _debug.enabled:
			#
			_debug.misc_debug = joystick_debug
		#print(__input.as_text(), the_event) #for debugging release
	else:
		stop_debug()



func stop_debug():
	var _debug = get_node("/root/Debug")
	joystick_debug = str ('')
	_debug.misc_debug = joystick_debug




# Tries Fixing code duplicates in the Joystick logic and state Machine
func parse_input_function(event):
	if not prev_inputs.has(event.action): # Saves the Input to an Array
		prev_inputs.append(event.action) # if it doesn't exist in the Array
	if prev_inputs.has(event.action): #array data manipulation
		prev_inputs.erase(event.action)
		prev_inputs.append(event.action)
	
	# TO Do : 
	# (1) Refactor TO Use Global Input SIngleton
	#Input.parse_input_event(event)
	
	return 0

# Tries Fixing code duplicates in the Joystick logic and state Machine
func release_the_action(event):
	return Input.action_release(event)

# Checks if any input action is pressed and returns a boolean
func check_if_any_Input_action_is_pressed()-> bool:
	return __input.action.empty() # For debug Purposes only
	

