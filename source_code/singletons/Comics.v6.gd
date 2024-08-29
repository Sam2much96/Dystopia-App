# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Comics V6
# This is a plugin containing the comics bool page logic
# A comic book module for Godot game engine.
# All Swipe Detection Logic are implemented in the Inputs sections
# **************************************************************************************************
#
# Features:
#
#(1) Loads, Zooms and Drags Comic Pages
#(2) Uses New multitouch gestures by implementing a touch input manager
#(3) Decentralized Storage IPFS module (1/2)
#(4) Swipe Gestures as Global Events (done)
#(5) Uses Networking Timer as await parameters for changing Panel
# **************************************************************************************************
#
# To-Do:
#
# (0) Organize code for better readability (done)
#(1) connect this script with  the dialogue singleton for translation and wordbubble fx co-ordination
#(2) Update Logic to be used by Texture React nodes NFT
# (3) Add more parameters to the drag() function to be reusable in other scripts (done)
# (4) Copy NFT storage codes to save downloaded comic chapters locally. It'll optimize file sizes
# (5) Implement State Machine (1/4)
# (6) Implement Extendible (NFT) drag and Drop (Done)
		# Implemeny godot-rust-ipfs cat for steamlined downloads
# (7) Implement Page state and Pages state 
# (8) Expand on this mechanics (2/3)
# (9) Dystopia App Swipe Gestures Using Swipe Detection
# (10) Each page Should Have Zoom and Position Data Separate from Other Pages
# (11) Use Polygon 2d instead of Animated sprite for comics pages
# (12) Use Networking Timer as Regression code for Swipe End Position Detection
# (13) Use Line2D as debug state to Debug Swipe Direction 
# (14) Connect to Global Input Singleton
# (15) Add FileChecks to comics scenes as regression checks called via Wallet Singleton functions
# (16) Should SHow Swipe Paths
# (17) Comics Singleton is now a global object
# (18) Implement Global COmics as Title Screen Art (Comics UI)
# **************************************************************************************************
#
# Bugs:
#
# (1) it has a wierd updatable bug that's visible in the debug panel
# (2) Center Page is buggy because Callibration is off Screen Center 
# (3) Drag and Drop across small distances is buggy (fixed)
# (4) Set frame state is buggy when combine with swipe gestures (fixed)
# (5) Callibration is buggy for Swipe Detection and Registration (1/2)
# (6) unimplemented feature on Line 1408
# (7) Swipe Gestures is buggy, requires refactoring
# (8) 
# **************************************************************************************************



extends Control

#class_name Comics


export (bool) var enabled #: bool 
export (bool) var LastPage  = false 
# Web 3 Activator for Downloading Content
#export (bool) var web3 : bool 
export (bool) var _loaded_comics = false
export (bool) var SwipeLocked    = true # Temporarily disabling for testing
export (int) var  current_frame    = 0 # Global Frame Variable

#Stores comics current page as a global variable 
#export var current_page : int  = -2# Global page variable, same as above, but differentiating for testing



export (PackedScene) var current_comics #: PackedScene


#************File Checkers*************#

#************Wallet Save Path**********************#

export (Dictionary) var comics = {
	1: 'res://scenes/Comics/chapter 1/chapter 1.tscn',
	2:'res://scenes/Comics/chapter 2/chapter 2.tscn',
	3:'res://scenes/Comics/chapter 3/chapter 3.tscn',
	4:"res://scenes/Comics/chapter 4/chapter 4.tscn",
	5:"res://scenes/Comics/chapter 5/chapter 5.tscn",
	6:"res://scenes/Comics/chapter 6/chapter 6.tscn",
	7:"res://scenes/Comics/chapter 7/chapter 7.tscn",
	8: 'res://scenes/Comics/Outside/outside.tscn'
	
}


#should ideally download from the Internet



export (Array) var memory = [] #use this variable to store current frame and comics info

export (int) var current_chapter
export (PackedScene) var next_scene

export (bool) var can_drag = false
export (bool) var zoom = false
var comics_placeholder = Control.new()

#var buttons

onready var Kinematic_2d = KinematicBody2D.new()
#onready var camera2d = $Kinematic_2D/placeholder/Camera2D 
#var _position : Vector2 
var center = Vector2(0,0) # should be used in a center comics method
var target =Vector2(0,0) 
#onready var origin : Vector2 = get_viewport_rect().size/2#set origin point to the center of the viewport

# Can Use a Tween Node to implement Drag and Drop
var comics_sprite = AnimatedSprite


#var _input_device

var _comics_root = self



#"Bug FIx from <200 absolute Distances"

export (Array) var target_memory_x= [] #stores vector 2 of previous targets
export (Array) var target_memory_y= [] #stores vector 2 of previous targets





#**********Swipe Detection Direction Calculation Parameters************#
export (Array) var swipe_target_memory_x  = [] # for swipe direction x calculation
export (Array) var swipe_target_memory_y  = [] # for swipe direction y calculation
var direction = Vector2(0,0)
export (float) var swipe_parameters = 1.0 # is 1 in Dystopia-App
export (float) var x1 = 0.0
export (float) var x2 = 0.0
export (float) var y1 = 0.0
export (float) var y2 = 0.0
#export(float,0.5,1.5) var MAX_DIAGONAL_SLOPE  = 1.3
var SwipeSpeed = Vector2()
export(int) var SwipeCounter = 0 # for limiting swipe detection.registration


const SWIPE_AWAIT = 0.4

onready var _debug_= get_tree().get_root().get_node("/root/Debug")
onready var cmx_root = get_tree().get_nodes_in_group("Cmx_Root").pop_front()

# Timer Needed for Detecting Swipe Stopped Directions

#onready var _e : Timer = $Timer# Use Manual Timer
onready var _e = Timer.new()

func _ready():
	
	#connect signals
	connect_signals()
	
	# Update current scene 
	Globalss.update_curr_scene()
	
	#Kinematic_2d = KinematicBody2D.new()  #the kinematic 2d node for drag and drop
	
	
	
	
	
	
	enabled = false
	#target = Vector2() duplicate code 
	
	# add timer to tree
	_comics_root.call_deferred('add_child',_e)
	
	# Make Timer Accessible to Swipe Class
	#Swipe._init_(_e) # Buggy Inititaliser. Swipe Timer Node is not inside Tree and needs refactor
	
	# Connect signals
	_e.connect("timeout",self, "_on_Timer_timeout")
	# Signals are connected manually
	# Redundancy Code
	if not _e.is_connected("timeout",self, "_on_Timer_timeout"):
		push_error("Swipe Timer Signals Are Disconnected")
		






#"INPUT "
# multiplatform inputs
# Input class has Multiple Bugs
# UnOptimized Codes
func _input(event): 
	"""
	#Comic panel changer
	"""
	
	
	#print (event.is_action_pressed("next_panel") )
	#print (SwipeLocked)
	
	
	#if event.is_action_pressed("reset"): # for reseting Comics FIlecheckers
	#	_ready() # Depreciated
	
	# Button Controls
	
	if event.is_action_pressed("next_panel") && comics_sprite != null : 
		# Buggy
		" If Not on Comics Last Page"
		#print_debug(111111)
		#if LastPage == false:
		current_frame = next_panel(comics_sprite)
		if LastPage == true:
			#comics_placeholder.queue_free()
			print_debug("Last Page", LastPage)
			
			# reset current frame
			current_frame = -1
			pass
	
	if event.is_action_pressed("prev_panel") :
		current_frame  = prev_panel(comics_sprite)


#Toggles comics visibility on/off
#It disappears if not enabled 
	"Enables and Disables Comics Node (when Comics button is pressed)"
	
	if  enabled == false and event.is_action_pressed("comics") : #SImplifying this code bloc
		enabled = true 
		emit_signal("comics_showing")
	elif enabled == true and event.is_action_pressed("comics") :
		enabled = false
		emit_signal("comics_hidden")

	"Controller for Joypad"
	
	# Disabling zoom for debugging
	
	#if event is InputEventJoypadButton && self.visible == true:
	#	if event.is_action_pressed("ui_select"): _zoom()

	"""
	CONSOLE CONTROLS
	
	"""
	# Temporarily disabled for back porting
	if event == InputEvent.JOYSTICK_MOTION && self.visible == true:
		var axis = event.get_axis_value()
		print('JoyStick Axis Value' ,axis)
	#	
		#Changes Page Panels
		if round(axis) == 1:
			next_panel(comics_sprite)
		if round(axis) == -1:
			prev_panel(comics_sprite)
	#	pass

	"Stops From Processing Mouse Inputs"
	
	

	if event == InputEvent.MOUSE_BUTTON:
		pass
	if event == InputEvent.MOUSE_MOTION:
		pass




	"""
	TOUCH INPUT
	"""
	# buggy
	
	
	
	"Handles Screen Dragging"
	# Can only drag is Swipe Locked
	# SwipeLocked is buggy
	# Switched between True and False
	if (event == InputEvent.SCREEN_DRAG && comics_sprite != null) : 
			Functions.drag_v2(comics_sprite,event.get_position())


	"""
	Global Swipe Detection
	
	"""
	# Uses Swipe Speed to trigger swipe detection and registration 
	# Turning Off Swipe Detection
	#if (event is InputEventScreenDrag && SwipeCounter < 2 && !SwipeLocked): 
	#	
	#	
	#	push_error("Swipe Detection is Buggy")
	#	# Debug the screen drag event
	#	#print_debug("index/",event.get_index(), "/speed: ", event.get_speed())
	#	
	#	# Checks for Swipe Speed
	#	SwipeSpeed = event.get_speed()
	#	if abs(SwipeSpeed.x) > 1000 or abs(SwipeSpeed.y) > 1000: 
	#	
	#	
	#	# A Timer for disabling Swipe Action Temporarily
	#		Networking.start_check(SWIPE_AWAIT)
	#		
	#		
	#		# should save event positions to an array and 
	#		# run calculations using the first and last array positions
	#		# Swipe position detector implemented it as state controller changer
	#		#
	#		# Saves Initial Input event to AN Array and Starts a timer
	#		# swipe registration is buggy
	#		Swipe._start_detection(
	#			event.get_position(),
	#			_e, 
	#			swipe_target_memory_x, 
	#			swipe_target_memory_y
	#			)
	#		# Debug initial Swipe Detection
	#		
	#		#print_debug("1: ", swipe_target_memory_x, swipe_target_memory_y)
	#		
	#		# create a timer
	#		# TImer time should be a constant
	#		#yield(get_tree().create_timer(SWIPE_AWAIT), "timeout")
	#		
	#		"Detect Swipe State"
	#		# Registers the Swipe End Position
	#		# should be called in a timeout method instead of input
	#		Swipe._end_detection(
	#			event.get_position(), 
	#			Vector2(0,0), 
	#			_e, 
	#			swipe_target_memory_x, 
	#			swipe_target_memory_y, 
	#			Swipe.swipe_start_position, 
	#			swipe_parameters,  
	#			x1,
	#			x2,
	#			y1,
	#			y2, 
	#			Swipe.MAX_DIAGONAL_SLOPE
	#			)
	#
	#		"Visualize swipe"
	#		#print_debug(event.position)
	#		
	#		print_debug("2: ", swipe_target_memory_x, swipe_target_memory_y)
	#		#Swipe._visualize_swipe([event.position,Swipe.swipe_start_position], $Line2D, get_tree())
	#		
	#		#visualises the last swipe position and the initial swipe position
	#		Swipe._visualize_swipe([event.position, Vector2(swipe_target_memory_x[0],swipe_target_memory_y[0])], $Line2D, get_tree())
	#		
	#		SwipeCounter += 1 # stops multiple swipe registrations

	#ewefrwe
	#print("_state Debug: ",_state) #for debug purposes only
	" Zoom 2"
	# works
	if event == InputEvent.SCREEN_TOUCH :
		
		target =  event.get_position()
		if event.get_index() == int(2): # and event is InputEventScreenPinch : #zoom if screentouch is 2 fingers & uses input manager from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases

			print_debug ("zoom")
			Functions._zoom(cmx_root, !zoom) #you can use get_index to get the number of fingers
			
			zoom = !zoom
			return zoom



	if event == InputEvent.MOUSE_BUTTON && event.doubleclick :
		Functions._zoom(comics_placeholder, zoom)



	# Reset Swipe Details
	#SwipeLocked = false
	#can_drag = true

func _process(delta):
	
	#print (str(SwipeLocked) + str(can_drag) + str(Networking.Timeout)) # SwipeLockked is Buggy # For Debug purposes only
	
	#" Auto Swipe Locks whenever Networking Timer is used"
			# Lock Swipe for 4 secofs

	" Kinematics 2D Error catcher"
	if not is_instance_valid(Kinematic_2d):
		Kinematic_2d= KinematicBody2D.new() 

	"Limits memory usage for Drag and Drop bug fixer"
	#optimize code
	if target_memory_x.size() > 30:
		target_memory_x.clear() 
	if target_memory_y.size() > 30:
		target_memory_y.clear() 


	# ReWrite to Use State machine
	# Rewrite as Godot Unit Tests
	# AUtimatically sets the Loaded comic boolean?
	if current_comics != null:
		_loaded_comics = true
	#print(position,target)
	if current_comics == null or current_frame == null  : #error catcher 
		#emit_signal("freed_comics") disabling signals for now
		_loaded_comics = false
	
	
	if _loaded_comics == true:
		#emit_signal("loaded_comics")
		pass
	
	"VISIBILITY"
	# add counter
	if enabled == true: #toggles visibility 
		show() 

	if enabled == false:
		hide() 
		
	memory=get_tree().get_nodes_in_group("comics") #an array of all comics in the scene tree

	if memory.empty() != true :
		pass
	elif memory.empty() == true:
		#current_comics = load_comics()
		pass
	if _loaded_comics == true && memory.size() >= 2: #double instancing error fix
		get_tree().queue_delete(memory.front()) 
		_loaded_comics = false 


	#_state = SET_FRAME # for debug purposes , disable later


	"""Updates the Comic Debug to a global debug singleton"""
	if enabled:
		if _debug_ != null && _debug_.enabled == true:
			#var Debug  = Engine.get_singleton('Debug')
			_debug_.Comics_debug = str(
				'CFrme:', current_frame, "SL:", SwipeLocked , 'cd: ',can_drag, 'Enbled',enabled,'loaded comics: ',_loaded_comics,
				' Zoom: ',zoom, 'cp: ', 'cs: ', comics_sprite
				)


func _on_Timer_timeout():
	"""
	Triggers A Timer Lag between Swipe Input and Swipe Registration.
	Resets SwipeCounter
	"""
	# Reset Swipe Locked
	SwipeLocked = false
	Swipe._on_Timer_timeout()
	SwipeCounter = 0


func close_comic(): #-> void:
	print_debug("Closing COmic")
	#comics_sprite.hide() 
	comics_placeholder.hide()
	#Kinematic_2d.hide()
	enabled = false 
	_loaded_comics = false #working buggy
	current_frame = 0 # working buggy
	emit_signal("freed_comics")

#'sets comic page to center of screen'


func next_panel(comics_sprite) : #-> int:
	# Type Checks
	assert(comics_sprite == AnimatedSprite)
	
	# Works
	if (
		!can_drag && 
		!SwipeLocked && 
		Input.is_action_pressed("next_panel") && 
		comics_sprite != null
	): 
		
		current_frame = abs(current_frame + 1 )
		#var next_frame : int =  (current_frame + 1) 

		emit_signal("panel_change")
		comics_sprite.set_frame(current_frame)
		
		# Stops a swipe overflow for comic pages
		SwipeLocked = true
	
	else :
		push_error("Waiting for swipe lock to timeout"+ str(can_drag)+ str(SwipeLocked) + str(comics_sprite))

	return current_frame



func prev_panel(comics_sprite) : #-> int:
	# Type Checks
	assert(comics_sprite == AnimatedSprite)
	
	# Works
	if !can_drag && !SwipeLocked && Input.is_action_pressed("prev_panel") && comics_sprite != null: #&& !Timemout:
	#if comics_sprite != null && !Timemout:
		
		Networking.start_check(1)
		
		current_frame = abs(current_frame - 1 )
		#var next_frame : int =  (current_frame + 1) 

		emit_signal("panel_change")
		comics_sprite.set_frame(current_frame)
		
		#print (current_frame)
		#current_frame = next_frame
		SwipeLocked = true
		
		
		# Centers Comic page
		comics_sprite.position = Comics_v6.origin
			#center_page()
		#	return int(current_frame) 
	" Play SFX "
	if Music.music_on == true:
		Music.play_sfx(Music.comic_sfx)
		
	return current_frame


class Local extends Reference:

	# Comics Name as Strings
	const comic_names = {
		1 : "Neo Sud, the new south"
	} 

	# Comic Scene paths & WebP Images
	const comics_ = {
	"Chap1 Scene": "user://Comics/chapter 1/chapter 1.tscn",
	"Chap1 Panel": "user://Comics/Comics/chapter 1/chapter 1 Neo sud, the new south webp.webp",
		3:'res://scenes/Comics/chapter 3/chapter 3.tscn',
		4:"res://scenes/Comics/chapter 4/chapter 4.tscn",
		5:"res://scenes/Comics/chapter 5/chapter 5.tscn",
		6:"res://scenes/Comics/chapter 6/chapter 6.tscn",
		7:"res://scenes/Comics/chapter 7/chapter 7.tscn",
		8: 'res://scenes/Comics/Outside/outside.tscn'
		
	}


	const comics_local_path = {
		1: "user://Comics/chapter 1/",
		2: "user://Comics/chapter 2/"
	}
	




class Swipe : #extends Reference:
	
	
	# Bugs:
	
	# (1) Print Overflow
	# (2) Coflates Swipe and Touch Input simultaneously
	# (3) Cannot be turned off 
	# (4) Buggy Calibration (1/2)
	#	# - Adding Calibration Debug by using a line2d node + Touch Interface doces 
	# (5) Rewrite Class Methods into static functions for better readability
	# (6) Update Documentation
	
	#**********Swipe Detection Direction Calculation Parameters************#
	const swipe_start_position = Vector2()
	const swipe_parameters  = 0.1
	const MAX_DIAGONAL_SLOPE  = 1.3

	#" Swipe Direction Detection"
	# Configures Swipe Timer settings
	static func _init_(_e): # Not tested yet
			# Type Checks
			assert(typeof(_e) != TYPE_NIL)
			assert(typeof(_e) == TYPE_OBJECT)
			#assert(_e == Timer)
			assert(_e.is_inside_tree())
			
			# Redundancy Code
			if _e == null: # Error Catcher
				_e = Timer.new()
			
			#for swipe detection
			_e.one_shot = false
			_e.wait_time = 3
			_e.name = str ('swipe detection timer')
			
			
			# Add Swipe Detection Timer to Scene Tree
			# Duplicate code
			#Comics_v6._comics_root.call_deferred('add_child',_e)

			
			
	static func _on_Timer_timeout():
		#if self.visible : # Only Swipe Detect once visible
		Comics_v6.emit_signal('swiped_canceled', swipe_start_position)
		Comics_v6.SwipeCounter = 0 # reset swipe counter
		print_debug ('on timer timeout: ', Comics_v6.SwipeCounter) #for debug purposes delete later


	#func connect_signals(_c : Timer, _e : Timer)-> bool:
	#		return bool(_c.connect('Timeout',_e,_on_Timer_timeout())) #connect timer to node with code
#	#		return true

	
	#Buggy swipe direction
	# Use an Array to store the first position and all end positions
	# Difference between both extremes is the swipe position
	static func clear_memory(swipe_target_memory_x, swipe_target_memory_y) : #-> void:
		# Type Checks
		assert(typeof(swipe_target_memory_y) == TYPE_ARRAY)
		assert(typeof(swipe_target_memory_x) == TYPE_ARRAY)
		
		swipe_target_memory_x.clear()
		swipe_target_memory_y.clear()


	# Bug: Does not Save Proper Swiper Start Position thus breaking the Positional Calibration when ending detection
	static func _start_detection(
		_position ,  
		_e ,
		swipe_target_memory_x , 
		swipe_target_memory_y 
		): #for swipe detection
		
		# Type Checks
		assert(typeof(swipe_target_memory_y) == TYPE_ARRAY)
		assert(typeof(swipe_target_memory_x) == TYPE_ARRAY)
		assert(_e == Timer)
		assert(_e.is_inside_tree() == true)
		assert(typeof(_position) == TYPE_VECTOR2)
		
		"Saves Initial Swipe Position to Memory"
		if not swipe_target_memory_x.has(_position.x): 
			swipe_target_memory_x.append(_position.x)
		if not swipe_target_memory_y.has(_position.y):
			swipe_target_memory_y.append(_position.y)
			
		"Start a timer"
		_e.start()
		#print_debug ('started swipe detection :', "/", "x: ", swipe_target_memory_x, "y: ", swipe_target_memory_y ) #for debug purposes delete later
	
	
	#"Only Two Swipe Directions Are Currently Implemented" # (fixing)
	# Contains a Calibration Bug (fixing)
	# Swipe start position is buggy
	static func _end_detection(
		final_position , 
		direction , # a memory location for storing direction calculation 
		_e, 
		swipe_target_memory_x, 
		swipe_target_memory_y, 
		swipe_start_position, 
		swipe_parameters, 
		x1,
		x2,
		y1,
		y2,
		MAX_DIAGONAL_SLOPE
		):
		
		# Type Checks
		assert(typeof(final_position) == TYPE_VECTOR2)
		assert(typeof(direction) == TYPE_VECTOR2)
		assert(_e == Timer)
		assert(_e.is_inside_tree() == true)
		assert(typeof(swipe_target_memory_x) == TYPE_ARRAY)
		assert(typeof(swipe_target_memory_y) == TYPE_ARRAY)
		assert(typeof(swipe_start_position) == TYPE_VECTOR2)
		#assert(x1 == float)
		#assert(x2 == float)
		#assert(y1 == float)
		#assert(y2 == float)
		
		direction = (final_position - swipe_start_position).normalized()
		"""
		SWIPE CALIBRATOR
		
		"""
		# Requires Refactoring , Better Calibration, Proper Documentation
		# calibration logic is fixed (1/2)
		
		"Calibration Logic"
		
		if round(direction.x) == -1: # Doesnt work
			print('left swipe 1') #for debug purposes

		
		# Horizontal Calculation
		
		if round(direction.x) == 1: # works
			print_debug('left swipe 2') #for debug purposes
			

			#direction_var = "Left"
			
			
			
			# Play Animation
			#GlobalAnimation.get_child(0).play("SWIPE_LEFT")
			print_debug("Swipe Left")
			
			# next panel
			
			next_panel()


			return 0
		
		"Up and Down"
		
		if -sign(direction.y) < -swipe_parameters: # works
			print('down swipe 1 ') #for debug purposes
			
			next_panel()
			
			#direction_var = "Right"
			
			
			# Play Animation
			#GlobalAnimation.get_child(0).play("SWIPE_DOWN")
			print_debug("Swipe Down")
			
			# next panel
			
			#prev_panel()

			
			#if Globals.curr_scene == "Comics____2":
			
			return 0
		
		if -sign(direction.y)  > swipe_parameters: # Doesnt work
			print('up swipe 1') #for debug purposes
			prev_panel()
			
			
			# Play Animation
			print_debug("Swipe Up")
			return #GlobalAnimation.get_child(0).play("SWIPE_UP")
		
		
		# Saves swipe direction details to memory
		# It'll improve start position - end position calculation
		if not swipe_target_memory_x.has(final_position.x) && final_position.x != null: 
			swipe_target_memory_x.append(final_position.x)
		if not swipe_target_memory_y.has(final_position.y) && final_position.y != null:
			swipe_target_memory_y.append(final_position.y)
		_e.stop()
		
		#Works
		if (
			swipe_target_memory_x.size() >= 3 && 
			swipe_target_memory_y.size() >= 3  
			#swipe_target_memory_x.pop_back() != null
			
			):
			
			x1 = swipe_target_memory_x.pop_front()
			x2  = swipe_target_memory_x.pop_back()
			
			y1 = swipe_target_memory_y.pop_front()
			y2  = swipe_target_memory_y.pop_back()
			
			#print_debug ("Swipe Detection Debug: ",x1,"/",x2,"/",y1,"/",y2,"/", swipe_target_memory_x.size()) #For Debug purposes only 
			
			#separate x & y position calculations for x and y swipes
			#
			"Horizontal Swipe"
			if x1 && x2  != null && swipe_target_memory_x.size() > 2:
				
				#calculate averages got x and y
				
				var x_average = 0 #initialise with integer 
				x_average = Utils.calc_average(swipe_target_memory_x)
				
				print_debug ("X average: ",x_average)
				print (x1, "/",x2)
				direction.x  = (x1-x2)/x_average
				
				print_debug ("direction x: ",direction.x)
				
				print_debug ('end detection: ','direction: ',direction ,'position',final_position, "max diag slope", MAX_DIAGONAL_SLOPE) #for debug purposes only
				#print ("X: ",swipe_target_memory_x)#*********For Debug purposes only
				#print ("Y: ",swipe_target_memory_x)#*********For Debug purposes only
			
			"Vertical Swipe"
			if y1 && y2 != null && swipe_target_memory_y.size() > 2:
				var y_average = 0 
				y_average = Utils.calc_average(swipe_target_memory_y)
				
				#print ("Y average: ",y_average) #*********For Debug purposes only
				#print (y1, "/",y2) #*********For Debug purposes only
				#direction.y  = (y1-y2)/y_average #*********For Debug purposes only
				
				#print ("direction y: ",direction.y) #*********For Debug purposes only
				
				#print ('end detection: ','direction: ',direction ,'position',__position, "max diag slope", MAX_DIAGONAL_SLOPE) #for debug purposes only
				#print ("X: ",swipe_target_memory_x)#*********For Debug purposes only
				#print ("Y: ",swipe_target_memory_x)#*********For Debug purposes only
			



			if abs (direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE:
				return
			if abs (direction.x) > abs(direction.y):
				
				print_debug ('Direction on X: ', direction.x, "/", direction.y) #horizontal swipe debug purposs
			if -sign(direction.x) < swipe_parameters:
				print_debug('left swipe') #for debug purposes
				
			
			if -sign(direction.x) > swipe_parameters:
				print_debug('right swipe') #for debug purposes
				
				# Play Animation
				return print_debug("SWIPE_RIGHT")
			
				
			if abs (direction.y) > abs(direction.x):
				#emit_signal('swiped',Vector2(-sign(direction.y), 0.0))
				print ('Direction on Y: ', direction.x) #horizontal swipe debug purposs
				
			"Up & Down"
			
			# Works
			if -sign(direction.y) < -swipe_parameters:
				print('up swipe 2') #for debug purposes
				
				#direction_var = "Up"
				prev_panel()
				
				# Play Animation
				return print_debug("SWIPE_UP")
				
				#doenst work
				#_state = SWIPE_UP
			
				
			if -sign(direction.y)  > swipe_parameters:
				print('down swipe 2') #for debug purposes
				
				next_panel()
				
				# Play Animation
				return print_debug("SWIPE_DOWN")
				
			#emit_signal('swiped', Vector2(0.0,-sign(direction.y))) #vertical swipe
				#	print ('poot poot poot') 
		
		if swipe_target_memory_x.size() && swipe_target_memory_y.size() > 50:
			clear_memory( swipe_target_memory_x, swipe_target_memory_y)

		else: return

	#"""
	#Visualises swipe data onsreen for Easier 
	#Swipe Debugging and Caliberation
	#"""
	static func _visualize_swipe(swipe_positional_data, LineDebug, tree): # works
		# Type Checks
		assert(typeof(swipe_positional_data) == TYPE_ARRAY)
		assert(tree == SceneTree)
		assert(LineDebug == LineShape2D)
		
		if (LineDebug != null && Debug.enabled):
			for i in swipe_positional_data:
				LineDebug.add_point(i)
			
			# clear LineDebug after end detection
			yield(tree.create_timer(2.5),"timeout")
			
			LineDebug.clear_points()
			


	static func next_panel():
		# Temporarily disabled for backporting
		var a = {"action": "next_paned", "pressed": true, "strength": 1} 
		#a.action = "next_panel"
		#a.pressed = true
		#a.strength = 1
		
		#InputEventAction.set_as_action(a["action"], a["pressed"])
		
		#Input.parse_input_event(a)


	static func prev_panel():
		# Temporarily disabled for backporting
		var a = 0#InputEventAction.new()
		#a.action = "prev_panel"
		#a.pressed = true
		#a.strength = 1
		
		Input.parse_input_event(a)


class Functions extends Reference:
	
	
	static func show_comics (comics_chap, cmx_root, comic_main  ) : #-> Control:
		# Type Checks
		assert(comics_chap == Node)
		assert(cmx_root == Control)
		assert(cmx_root.is_inside_tree())
		assert(comics_chap.is_inside_tree())
		
		comic_main.emit_signal("loaded_comics")
		#comic_main.add_child(comics_chap)
		comic_main.call_deferred("add_child", comics_chap)
		comic_main._loaded_comics = true
		return cmx_root
	
	static func load_comics(
		current_comics, 
		memory ,
		scenetree, 
		enabled , 
		can_drag , 
		zoom, 
		current_frame, 
		Kinematic_2d, 
		comics_placeholder 
		) : #-> AnimatedSprite: 

		# Type Checks
		assert(typeof(current_comics) == TYPE_STRING)
		assert(typeof(memory) == TYPE_ARRAY)
		assert(scenetree == SceneTree)
		assert(typeof(enabled) == TYPE_BOOL)
		assert(typeof(can_drag) == TYPE_BOOL)
		assert(typeof(zoom) == TYPE_BOOL)
		assert(typeof(current_frame) == TYPE_INT)
		assert(Kinematic_2d == KinematicBody2D)
		assert(comics_placeholder == Control)
		
		var err = PackedScene
		err = Utils.Functions.LoadLargeScene(
					current_comics, 
					Globals.scene_resource, 
					Globals._o, 
					Globals.scene_loader, 
					Globals.loading_resource, 
					Globals.a, 
					Globals.b, 
					Globals.progress
					)
		var node = AnimatedSprite
		
		
		if current_comics != null && err.can_instance() == true:
			for _p in scenetree.get_nodes_in_group('Cmx_Root'):
				enabled = true
				zoom = false
				can_drag = true
				current_frame =  int(0)
				
				#Kinematic_2d =  CharacterBody2D.new()
				#comics_placeholder = Control.new()
				
				Kinematic_2d.name= 'Kinematic_2d'
				comics_placeholder.name = 'comics_placeholder'
		
				comics_placeholder.set_mouse_filter(2)

				_p.call_deferred('add_child',comics_placeholder) #reparents comic placeholder node 

				print ('Comic root:',_p)

				
				comics_placeholder.add_child(Kinematic_2d)
				
		
				var collision_shape =CollisionShape2D.new()
				var shape = RectangleShape2D.new() #new code
				shape.set_extents((Vector2(300,300))) #new code
				collision_shape.set_shape (shape) #new code
		
				#Kinematic Body 2D
				Kinematic_2d.add_child(collision_shape) #set the collision shape
				
				var comics_main = scenetree.get_root().get_node("/root/Comics_v6")
				
				"connect signals"
				# Doesnt work
				Kinematic_2d.connect("mouse_entered", comics_main,  "mouse_entered")
				Kinematic_2d.connect("mouse_exited",comics_main ,  "on_mouse_exited")
				
				# Debug connections 
				
				
				
				#Loaded Comic Signal
				Comics_v6.emit_signal("loaded_comics")
				
				
				
				# Debug Packed Scene
				#print (err.can_instantiate())
				"Load Comics Scene"
				if err.can_instance(): # 
					
					node = err.instance(0)
					
					 
					
					# SET NODE NAME
					node.name = Local.comic_names[1]
					
					#load comics extension script
					node.set_script(Comics_v6.Extensions)
					
					node.set_frame(Comics_v6.current_frame)
					
					Kinematic_2d.add_child(node) 
					#collision_shape.add_child(node)
					
				
					# Returns instantiated node
					return node
				
				#position pages
				#_x.position =Kinematic_2d.get_position()


				# Error Catcher 1
				if current_comics == "" and !err.can_instance()   :
					push_error('unable to instance comics scene')
					pass
				if memory.empty() != true && current_comics == "": #error catcher 1
					
					current_comics = memory[0] # load from memory

				if memory.empty() == true && current_comics == "": #error catcher 2
					push_error('current comics empty')
					
					print ("Loading Default comic" + Comics_v6.comics[1])
					
					current_comics = Comics_v6.comics[1] #default comic


				Comics_v6._loaded_comics = true
				Comics_v6.comics_placeholder.show()
				Comics_v6.emit_signal("comics_showing")
				#center_page()

				return node
		return node


	#******************************Drag 1 is Buggy , v2 works Best**********************#
	static func drag(_target, 
	_position , 
	_body , 
	center, 
	target_memory_x , 
	target_memory_y
	) : 
		
		# Type Parameters Check
		assert(typeof(_target) == TYPE_VECTOR2)
		assert(typeof(_position) == TYPE_VECTOR2)
		assert(typeof(center) == TYPE_VECTOR2)
		assert(_body == KinematicBody2D)
		assert(typeof(target_memory_x) == TYPE_ARRAY)
		assert(typeof(target_memory_y) == TYPE_ARRAY)
		
		#add more parameters
		# Input manager from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases 
		print ("-----------Dragging------------")
		
		#center = Globals.sumaVectores(_target, _position)
		
		#print ("Center Debug: "+ str(center)) 3 FOR DEBUG
		_body.set_position(_target)
		
		
		" Drag n Drop Logic"
		
		
		"If Distance to input target is greater than 200"
		#for large size drags
		if abs(_position.distance_to(_target)) > 200: #if its far...
			##use suma vectores function for vector maths
			
			_body.move_and_slide(center)
			#print ('moving to center') #for debug purposes only


	#******************************Bug Begins**********************#

			"If Distance is less than 200"
			#for small size drags
			#Buggy 
		if abs(_position.distance_to(_target)) < 200 : #if its close
					#_body.move_and_slide(target)
					#how to fix
					
				"""
				I can calculate the difference between the last 2 drags to fix this bug
				drag bug is caused by sudden disparity between the target vectors
				if the previous target position is different by a large amount, discard it and wait for next target input
				"""
					
				var x = 0 # initialise memory with integer pointer
				var y = 0 
				
				x= _target.x
				y= _target.y
				
				target_memory_x.append(x) #works
				target_memory_y.append(y) #works
				
				# Rejects buggy input targets
				# Save both x & y inputs in similar array to properly debug
				if abs(target_memory_x[target_memory_x.size() - 2] - x) > 3: #if more than 3 buggy inputs have been saved
					#print ('Error x axis') #for debug purposes only
					#print ('x axis size debug: ' ,target_memory_x.size()) #for debug purposes only
					
					#print (target_memory_x) #temporarily disabling for debug purposes
					
					
					
					
					
					#deletes bad input
					target_memory_x.erase(x) #temporarily disabling for debugging
					
					
					
					
					#target_memory_x.remove(target_memory_x[-1]) #deletes error #introduces bug
					if target_memory_x.size() == 1:
						_body.move_and_slide(Vector2(target_memory_x[0], target_memory_y.back()))
						#_body.position = Vector2(target_memory_x[0], target_memory_y.back())
						#_body.move_and_slide()
					
					#Erases Faulty Horizontal Input
					if target_memory_x.size() > 1:
						var adjusted_target = Vector2(target_memory_x[target_memory_x.size() - 2], target_memory_y.back())
						_body.move_and_slide(adjusted_target)
						#_body.position = Vector2(target_memory_x[target_memory_x.size() - 2], target_memory_y.back())
						#_body.move_and_slide()
					
					
				if abs(target_memory_y[target_memory_y.size() - 2] - x) > 3:
					#print ('Error y axis')
					#print ('y axis size debug: ' ,target_memory_y.size()) 
					
					#print (target_memory_y) #temporarily disabling for debug purposes
					

					#deletes bad input
					target_memory_y.erase(y) #temporarily disabling for debugging
					
					
					
					
					
					if target_memory_y.size() == 1: #error catcher
						
						#moves to a predicted presaved axis
						return _body.move_and_slide(Vector2(target_memory_x.back(), target_memory_y[0]))
						#_body.position = Vector2(target_memory_x.back(), target_memory_y[0])
						#_body.move_and_slide()
					
					elif target_memory_y.size() > 1:
						
						var adjusted_target = Vector2(target_memory_x.back(), target_memory_y[target_memory_y.size() - 1])
						
						#moves to a predicted presaved axis
						return _body.move_and_slide(adjusted_target)



	static func drag_v2(comics_sprite, target) : #-> void:
		
		# Type Checks
		assert(typeof(target) == TYPE_VECTOR2)
		assert(comics_sprite == AnimatedSprite)
		
		
		if comics_sprite != null: # Error Catcher 1
			comics_sprite.set_position(target)

	static func _zoom(comics_placeholder, zoom) : #-> bool:
		# Type Checks
		assert(comics_placeholder == Control)
		assert(typeof(zoom) == TYPE_BOOL)
		
		if comics_placeholder != null:
			var scale =comics_placeholder.get_scale()
			if scale == Vector2(1,1)  :
				#print ('zoom in') #for debug purposes only
				comics_placeholder.set_scale(scale * 2) 
				zoom = true
				return true 
			if scale > Vector2(1,1):
				#print ('zoom out') #for debug purposes only
				scale = comics_placeholder.get_scale()
				comics_placeholder.set_scale(scale / 2) 
				zoom = false
		return zoom 

	static func _zoom_2(comics_placeholder, zoom ) : #-> bool:
		# Type Checks
		assert(comics_placeholder == Node)
		assert(typeof(zoom) == TYPE_BOOL)
		
		var scale =comics_placeholder.get_scale()
		print (scale)
		if scale == Vector2(1,1)  :
			#print ('zoom in') #for debug purposes only
			comics_placeholder.set_scale(scale * 2) 
			zoom = true
			return true 
		if scale > Vector2(1,1):
			#print ('zoom out') #for debug purposes only
			scale = comics_placeholder.get_scale()
			comics_placeholder.set_scale(scale / 2) 
			zoom = false
		return zoom 



class Extensions extends AnimatedSprite:
	#"""
	#The goal of this script is to store and send comic page details 
	#to the comic class script from the Comics Animated Sprite. 
	#"""
	# TO DO: Implement Polymorphism for all Chapter pages
	# It should also synconize data with the word bubble in a way that is playable 
	# IS a port of Comics_panels_extensions script v1

	# Features
	# (1) Loads into comics node Programmatically
	# (2) Syncs Comics node info to Singleton
	export (Vector2) var panel = Vector2()
	export (int) var word_buble_count = 0

	var TotalPageCount = 0
	var CurrentPage = 0

	#const PageData : Array = [0,1,2,3,4,5,6] # total page count



	export (Dictionary) var Chapter_Data = {
		"Word Bubbles": word_buble_count,
		"All Pages" : TotalPageCount,
		"Name" : "Neo Sud, the New South",
		"Current Page": CurrentPage,
	}

		# Update 
	func _process(_delta):
		
		#print(Comics_v6.current_frame, "/", CurrentPage) # for debug purposes
		
		# Makes Current Page a Local integer
		CurrentPage = self.get_frame()

		"Last Page Conditionals"
		# Bug: Invalid get index 'LastPage' (on base: 'Control (Comics.v6.gd)').
		if (CurrentPage + 1) == (TotalPageCount) && bool(Comics_v6.LastPage) == false: # Make Practical 
			Comics_v6.LastPage = true
			return Comics_v6.LastPage

	func _ready():
		Comics_v6.comics_sprite = self
		TotalPageCount = self.frames.get_frame_count('default')
		
		" Mobile OS Conditionals"
		if Globals.screenOrientation == Globals.SCREEN_VERTICAL:
			
			# Upscale on Mobile Devices
			self.set_scale(Vector2(1.3,1.3))
		
		#print_debug("Extension Script Initialized" + str(Comics_v6.comics_sprite) )


# It Uses a camera 2d to simulate guided view. Should not be used when running the game
#func guided_view()-> void: #Unwriten code
#	#It's supposed tobe a controlled zoom
#	# USing matrix of array positions to guide a camera smoothing
#	# ANd a physics process
#	pass


func _on_Rotate_pressed():#Page Rotation #Rewrite this function as a module
	if _loaded_comics == true:
		var _r = Kinematic_2d.get_rotation_degrees()
		var _s = self.get_scale()
	#print(_r, _s) #for debug purposes only
		if _r <= 0:
			self.set_scale(Vector2(0.9,0.9))
			Kinematic_2d.set_rotation_degrees(90)
			comics_placeholder.set_position ( center) 
		if _r >= 90:
			self.set_scale(Vector2(1,1))
			Kinematic_2d.set_rotation_degrees(0)
			comics_placeholder.set_position ( center)


static func load_local_image_texture_from_global(node , _local_image_path, expand, stretch_mode) : #-> void:
	# Type checks
	assert (node == TextureFrame)
	assert(typeof(_local_image_path) == TYPE_STRING)
	assert(typeof(expand) == TYPE_BOOL)
	assert(typeof(stretch_mode) == TYPE_INT)
	
	#print_debug ("NFT debug: ", NFT) #for debug purposes only
	var texture = ImageTexture.new()
	var image = Texture.new() #Image.new()
	image.load(_local_image_path)
	texture.create_from_image(image)
	node.show()
	node.set_texture(texture) #cannot load directly from local storage without permissions
		#print (NFT.texture) for debug purposes only
	node.set_expand(expand)
	node.set_stretch_mode(stretch_mode) 







#"""
#button connections 
#"""


func _on_chap_1_pressed():
	print ("loading chapter 1")
	_load_comics(1)
	

func _on_chap_2_pressed(): #Simplify this function
	print ("loading chapter 2")
	# works
	#_load_comics(2)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app")

func _on_chap_3_pressed(): #Simplify this function
	print ("loading chapter 3")
	# works
	#_load_comics(3)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app")



func _on_chap_4_pressed():
	print ("loading chapter 4")
	
	# works
	#_load_comics(4)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app")

func _on_chap_5_pressed():
	print ("loading chapter 5")
	# works
	#_load_comics(5)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app")


func _on_chap_6_pressed():
	print ("loading chapter 6")
	# works
	#_load_comics(6)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app") # placeholder url's

func _on_chap_7_pressed():
	print ("loading chapter 7")
	# works
	#_load_comics(7)
	OS.shell_open("https://inhumanity-arts.itch.io/dystopia-app")# placeholder url's

	# Polymorphic synamic code for loading Conics Sprite via Static functions
func _load_comics(chapter_no):
	# Type Checks
	assert(typeof(chapter_no) == TYPE_INT)
	
	return Functions.show_comics(
		Functions.load_comics(comics[chapter_no], 
		memory,get_tree(),
		enabled, 
		can_drag, 
		zoom,current_frame, 
		Kinematic_2d, 
		comics_placeholder
		), cmx_root, self)


func connect_signals() : #-> bool: #connects all required signals in the parent node
	
	
	if not Kinematic_2d.is_connected("mouse_entered", self, "mouse_entered"):
		Kinematic_2d.connect("mouse_entered", self, "mouse_entered")
		Kinematic_2d.connect("mouse_exited", self, "mouse_exited")

	# connect Timer Signals for Swipe Locker

	return false




func _on_back_pressed():
	Globals._go_to_title()
