# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Comics V5
# This is a plugin containing the comics bool page logic
# A comic book module for Godot game engine.
# I implemented A touch input manager here
# *************************************************
# Features
#(1) Loads, Zooms and Drags Comic Pages
#(2) Uses New multitouch gestures by implementing a touch input manager
#(3) Decentralized Storage IPFS module (1/2)
#(4) Swipe Gestures as Global Events

#
# To DO:
# (0) Organize code for better readability
#(1) connect this script with  the dialogue singleton for translation and wordbubble fx co-ordination
#(2) Update Logic to be used by Texture React nodes NFT
# (3) Add more parameters to the drag() function to be reusable in other scripts
# (4) Copy NFT storage codes to save downloaded comic chapters locally. It'll optimize file sizes
# (5) Implement State Machine (on It)
# (6) Implement Extendible (NFT) drag and Drop (Done)
		# Implemeny godot-rust-ipfs cat for steamlined downloads
# (7) Implement Page state and Pages state
# (8) Expand on this mechanics
# (9) Dystopia App Swipe Gestures Using Swipe Detection
# *************************************************
# Bugs:
# (1) it has a wierd updatable bug that's visible in the debug panel
# (2) Center Page is buggy because Callibration is off Screen Center
# (3) Drag and Drop across small distances is buggy (fixed)
# (4) Set frame state is buggy when combine with swipe gestures
# (5) Callibration is off for Swipe Gestures
# *************************************************



extends Control



signal comics_showing
signal loaded_comics 
signal freed_comics
signal panel_change
signal swiped(direction)
signal swiped_canceled(start_position)
#export(float,1.0,1.5) var MAX_DIAGONAL_SLOPE =1.3  


export var enabled : bool 
export var LastPage : bool = false 
# Web 3 Activator for Downloading Content
export var web3 : bool 
export var _loaded_comics : bool = false
export var SwipeLocked : bool 
export var  current_frame : int   = 0 # Global Frame Variable

#Stores comics current page as a global variable 
export var current_page : int  = -2# Global page variable, same as above, but differentiating for testing



var current_comics : PackedScene

"Prealoaded Comics"
# host on ipfs and use local user directory to store comic files
# run file checks to verify image downloadds and load
#programmatically
# Size optimization


#************File Checkers*************#
var FileCheck1=File.new() #checks local comics storage

var FileDirectory=Directory.new() #deletes all theon reset



#************Wallet Save Path**********************#
#var comic_write_path : String = "user://Comic"  
var comic_dir : String = "user://Comics"
#var chapter : String = "chapter "


var CHECK_COMICS_LOCAL_STORAGE : bool = false

var comics : Dictionary = {
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



var memory : Array = [] #use this variable to store current frame and comics info

var current_chapter : int
var next_scene : PackedScene

var can_drag : bool = false
var zoom : bool = false
var comics_placeholder : Control = Control.new()

#onready var animation = $AnimationPlayer 
var buttons

var Kinematic_2d :  KinematicBody2D = KinematicBody2D.new()  #the kinematic 2d node for drag and drop
#onready var camera2d = $Kinematic_2D/placeholder/Camera2D 
var _position : Vector2 
var center : Vector2
var target =Vector2(0,0) 
onready var origin : Vector2 = get_viewport_rect().size/2#set origin point to the center of the viewport

# Can Use a Tween Node to implement Drag and Drop
var comics_sprite : AnimatedSprite


var _input_device

var _comics_root = self



"Bug FIx from <200 absolute Distances"

var target_memory_x: Array = [] #stores vector 2 of previous targets
var target_memory_y: Array = [] #stores vector 2 of previous targets




#**********Swipe Detection Direction Calculation Parameters************#
var swipe_target_memory_x : Array = [] # for swipe direction x calculation
var swipe_target_memory_y : Array = [] # for swipe direction y calculation
var direction : Vector2
var swipe_parameters : float = 0.1 # is 1 in Dystopia-App
var x1 #: float
var x2 #: float
var y1 #: float
var y2 #: float
#export(float,0.5,1.5) var MAX_DIAGONAL_SLOPE  = 1.3





"Rewriting As a Fininte State Machine"

enum {START_SWIPE, END_SWIPE, DOWNLOAD_IMAGE, NEXT_PANEL, 
PREV_PANEL, DRAG, LOAD, ZOOM ,SET_FRAME,IDLE ,SWIPE_UP,
SWIPE_DOWN, SWIPE_LEFT, SWIPE_RIGHT, NOT_SWIPING, ERROR
} 

# Swipe Direction Enum (Struct)
#enum { } 
#export (String, 'Up', "Down", "Left", "Right", "Idle") var direction_var ="Idle"
var direction_var : String = "idle"

#var dir_var = NOT_SWIPING

var _state = IDLE

#var _e : Timer = Timer.new()

onready var _debug_= get_tree().get_root().get_node("/root/Debug")
onready var cmx_root : Control = get_tree().get_nodes_in_group("Cmx_Root").pop_front()

var _e : Timer = Timer.new()

func _ready():
	
	#connect signals
	connect_signals()
	
	# Update current scene 
	Globals.update_curr_scene()
	
	
	
	
	
	"Load ingame Comics"
	# Works but Comics node has underlying bugs that need fixingx
	# Not Working!
	if Globals.curr_scene == "Outside" && _loaded_comics == false && comics_sprite == null:
		print ("-----Loading GamePlay Comics-----")
		comics_sprite =  Functions.load_comics(
			comics[8], 
			memory,
			get_tree(),
			enabled, 
			can_drag, 
			zoom,
			current_frame, 
			Kinematic_2d, 
			comics_placeholder
			)

		Functions.show_comics(
			comics_sprite, 
			cmx_root, 
			self
		)
		
		_loaded_comics =true
		return _loaded_comics
	
	
		
	
	enabled = false
	#target = Vector2() duplicate code 
	
	# add timer to tree
	_comics_root.call_deferred('add_child',_e)
	
	# Make Timer Accessible to Swipe Class
	Swipe._init_(_e)
	

	
	# Create HTTP Request Nodes
	# Only create & use these nodes it Dowloading content
	
	if web3: 
		Online._init()





"INPUT "
#multiplatform inputs
# Input class has Multiple Bugs

func _input(event): 
	"""
	#Comic panel changer
	"""
	
	
	#print (event.is_action_pressed("next_panel") )
	#print (SwipeLocked)
	if event.is_action_pressed("reset"): # for reseting Comics FIlecheckers
		_ready()
	
	if event.is_action_pressed("next_panel") && comics_sprite != null : # && enabled : #button controls
		" If Not on Comics Last Page"
		if LastPage == false:
			current_frame = next_panel(comics_sprite)
		elif LastPage == true:
			#comics_placeholder.queue_free()
			pass
	
	if event.is_action_pressed("prev_panel") :
		current_frame  = prev_panel(comics_sprite)


#Toggles comics visibility on/off
#It disappears if not enabled 
	"Enables and Disables Comics Node (when Comics button is pressed)"
	#if not enabled && event.is_action_pressed("comics") : 
	#	enabled = true
	#else: enabled = !enabled
	
	if  enabled == false and event.is_action_pressed("comics") : #SImplifying this code bloc
		enabled = true 
	elif enabled == true and event.is_action_pressed("comics") :
		enabled = false

	"Controller for Joypad"
	
	# Disabling zoom for debugging
	
	#if event is InputEventJoypadButton && self.visible == true:
	#	if event.is_action_pressed("ui_select"): _zoom()

	"""
	CONSOLE CONTROLS
	
	"""
	if event is InputEventJoypadMotion and self.visible == true:
		var axis = event.get_axis_value()
		print('JoyStick Axis Value' ,axis)
		
		#Changes Page Panels
		if round(axis) == 1:
			next_panel(comics_sprite)
		if round(axis) == -1:
			prev_panel(comics_sprite)
		pass

	"Stops From Processing Mouse Inputs"
	if event is InputEventMouse:
		pass
		

	if event is InputEventMouseButton:
		pass
	if event is InputEventMouseMotion:
		pass


	"Handles Multitouch Gesture"
	#Documentation: https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki
	# Use Global Animation Player to play Swipe Gesture Actions
	# Export Animation Resource File from AlgoWallet App
	# Load Animation As resource file
	#if event is InputEventScreenTwist:
	#	print ("Input: Screen Twist / Action: Rotate")
	
	# Zoom in/out Gesture
	#if event is InputEventScreenPinch :
	#	print ("Input: Screen Pinch / Action: Zoom In/Out")
	
	# Zoom in/out gesture
	#if event is InputEventMultiScreenTap :
	#	print ("Input: Screen Tap / Action: Zoom in/OUt")



	# Handle Touch
	"""
	CONTROLS THE TOUCH INPPUT FOR THE COMICS NODE
	"""
	
	
	
	
	"Handles Screen Dragging"
	# Can only drag is Swipe Locked
	# SwipeLocked is buggy
	# Switched between True and False
	if event is InputEventScreenDrag : 
		if comics_sprite != null : 
		#print (current_comics) # for debug purposes only
			#can_drag = true
			Functions.drag_v2(comics_sprite,event.get_position())
			#Functions.drag(event.position, event.position, Kinematic_2d,center, target_memory_x, target_memory_y)


	"Swipe Direction Debug"
	# Should Ideally be in COmics script. Requires rewrite for better structure
	# The current implementation is a fast hack
	if event is InputEventScreenDrag && !SwipeLocked : #kinda works, for NFT Drag & Drop
		#Networking.start_check(4) #should take a timer as a parameter
		#if Networking.Timeout == false:
		
		
		Networking.start_check(4)
		
		# should save event positions to an array and 
		# run calculations using the first and last array positions
		# Swipe position detector implemented it as state controller changer
		#
		Swipe._start_detection(
			event.position,
			true,
			_e, 
			swipe_target_memory_x, 
			swipe_target_memory_y
			)
		
		
		"Detect Swipe State"
		_state = Swipe._end_detection(
			event.position, 
			Vector2(0,0), 
			direction_var,
			_state, 
			_e, 
			swipe_target_memory_x, 
			swipe_target_memory_y, 
			Swipe.swipe_start_position, 
			swipe_parameters,  
			x1,x2,y1,y2, 
			Swipe.MAX_DIAGONAL_SLOPE
			)
	
	

	
		#print("_state Debug: ",_state) #for debug purposes only
	" Zoom 2"
	if event is InputEventScreenTouch :
		
		target =  event.get_position()
		#if event is  InputEventMultiScreenDrag == true : # Works
			#target =  event.get_position()
		if event.get_index() == int(2): # and event is InputEventScreenPinch : #zoom if screentouch is 2 fingers & uses input manager from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases
		#if event.is_double_tap():
			
			print ("zoom")
			Functions._zoom(cmx_root, !zoom) #you can use get_index to get the number of fingers
			
			zoom = !zoom
			return zoom



	if event is InputEventMouseButton && event.doubleclick :
		Functions._zoom(comics_placeholder, zoom)



	# Reset Swipe Details
	#SwipeLocked = false
	#can_drag = true

func _process(_delta):
	
	#print (str(SwipeLocked) + str(can_drag) + str(Networking.Timeout)) # SwipeLockked is Buggy # For Debug purposes only
	
	#" Auto Swipe Locks whenever Networking Timer is used"
			# Lock Swipe for 4 secofs

	"Limits memory usage for Drag and Drop bug fixer"
	#optimize code
	if target_memory_x.size() > 30:
		target_memory_x.clear() 
	if target_memory_y.size() > 30:
		target_memory_y.clear() 


	# ReWrite to Use State machine
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
		show() #Disabling for debugging
		
		#print ("Enabled")
		
		pass

	if enabled == false:
		hide() #Disabling for debugging
		#print ("DIsabled")
		pass
	memory=get_tree().get_nodes_in_group("comics") #an array of all comics in the scene tree

	if memory.empty() != true :
		pass
	elif memory.empty() == true:
		#current_comics = load_comics()
		pass
	if _loaded_comics == true && memory.size() >= 2: #double instancing error fix
		get_tree().queue_delete(memory.front()) 
		_loaded_comics = false 


	_state = SET_FRAME # for debug purposes , disable later


	"""Updates the Comic Debug to a global debug singleton"""
	if enabled:
		if _debug_ != null && _debug_.enabled == true:
			#var Debug  = Engine.get_singleton('Debug')
			_debug_.Comics_debug = str(
				'Curr frme:', current_frame , 'Cmx: ',current_comics, 'Enbled',enabled,'can drag: ',#can_drag,
				' Zoom: ',zoom 
				)

	"Unused State Machine implementation"
	match _state:
		SWIPE_UP:
			direction_var = "Up"
			# Play Animation
			#return GlobalAnimation.get_child(0).play("SWIPE_UP")
		SWIPE_DOWN:
			
			direction_var = "Down"
			
			pass
		SWIPE_LEFT:
			direction_var = "Left"
			# Play Animation
			#GlobalAnimation.get_child(0).play("SWIPE_LEFT")
			#return prev_panel()  
			#return GlobalAnimation.get_child(0).queue("RESET")  
			
			#pass
		SWIPE_RIGHT:
			
			direction_var ="Right"
			
			# Play Animation
			#GlobalAnimation.get_child(0).play("SWIPE_RIGHT")
			#return next_panel()
			#return GlobalAnimation.get_child(0).queue("RESET")
		ERROR:
			pass
		IDLE:
			pass
		START_SWIPE:
			pass
		END_SWIPE:
			pass
		DOWNLOAD_IMAGE:
			
			" Downloads Comics "
			#Runs Directory and File Checks for Comic Nodes & Images
			
			# Check if comics folder exists locally
			#if not FileDirectory.dir_exists(comic_dir):
			#	"Creates Comics Directory if it doesn't exist"
			#	create_comics_directory(comic_dir)
			
			# Creates Comic Chapter Paths
			#if not FileDirectory.dir_exists(Local.comics_local_path[1]):
			#	create_comics_directory(Local.comics_local_path[1])
			#	pass
			
			if !Networking.good_internet && !Networking.Timeout:
				Networking._check_if_device_is_online(Swipe.q)
				Networking.start_check(4)
			
			# If local Comics Doesnt exist
			
			if not FileCheck1.file_exists(Local.comics_["Chap1 Panel"])  && Networking.good_internet:
				#GKHGHGHKGK
				# download Comics from IPFS using Networking Gateway
				"IPFS Downloads"
				
				# Downloads Comic scenes and Imgs from IPFS
				#Networking.url = comics_[0]
				
				#comics_IPFS
				Networking. _connect_to_ipfs_gateway(false,Online.comics_IPFS[1], Networking.gateway[2], Swipe.q2) # Downloads Spritesheet  
				Networking. _connect_to_ipfs_gateway(false,Online.comics_IPFS[3], Networking.gateway[2], Swipe.q3)  # Downloads Scene
			#	return
			# Check if image is available for chapter 1
			if FileCheck1.file_exists(Local.comics_["Chap1 Panel"]) :
				# load the Comic if it's available
				print ("Comic is Available Locally. Loading....Placeholder")
				pass
			
			# If not, download spritesheet from IPFS
			
			
			# check if CHapter 1 scene exists
			
			# Check if chapter 1 Comics and Scene are available
			
			# load chapter 1 scene from local memory if all are true
			
		NEXT_PANEL:
			pass
		PREV_PANEL:
			pass
		DRAG:
			pass
		LOAD:
			
			
			#return Functions.load_comics(current_chapter)
			
			pass



func close_comic()-> void:
	comics_sprite.queue_free() 
	#comics_placeholder = null
	enabled = false 
	_loaded_comics = false #working buggy
	current_frame = -2 # working buggy
	emit_signal("freed_comics")

'sets comic page to center of screen'


func next_panel(comics_sprite : AnimatedSprite) -> int:
	
# Works
	if !can_drag && !SwipeLocked && Input.is_action_pressed("next_panel") && comics_sprite != null: #&& !Timemout:
	#if comics_sprite != null && !Timemout:
		
		Networking.start_check(1)
		
		current_frame = abs(current_frame + 1 )
		#var next_frame : int =  (current_frame + 1) 

		emit_signal("panel_change")
		comics_sprite.set_frame(current_frame)
		
		#print (current_frame)
		#current_frame = next_frame
		SwipeLocked = true
		
		# Centers Comic page
		#comics_sprite.set_position(Comics_v6.origin)
			#center_page()
		#	return int(current_frame) 
	" Play SFX "
	if Music.music_on == true:
		Music.play_sfx(Music.comic_sfx)
		

	return current_frame



func prev_panel(comics_sprite : AnimatedSprite)-> int:
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



class Online extends Reference:
	
	var q : HTTPRequest
	var q2 : HTTPRequest
	var q3 : HTTPRequest
	
	const comics_IPFS : Dictionary = {
		1 : "QmSpXTc7gE1Mj3HdKDGuwr87cuiiLP3homXuKbWVxoG4TX", #Chap 1 scene
		2 : "QmWvgWit9REFghWLgofgormkr3QsKd2pXcxMtMxHdKMTZV", # Chap 1 sprite sheet
		3 : "QmW3HJX8iADTFdNMBhuDsVqhQLajE8xwPw2XmonmL2HofA", # Icon Pixel Icon
	}

	func _init():
		q = HTTPRequest.new() # checks internet connection, makes it a Global boolean
		q2 = HTTPRequest.new() # Downloads imgs
		q3 = HTTPRequest.new() # Downloads Comic Scenes


		Comics_v6._comics_root.call_deferred('add_child',q) # checks internet connection, makes it a Global boolean
		Comics_v6._comics_root.call_deferred('add_child',q2) # Downloads imgs
		Comics_v6._comics_root.call_deferred('add_child',q3) # Downloads Comic Scenes
		
		
	
	'Performs a Bunch of HTTP requests'
	# Duplicate of Wallet Codes
	#(1) To Check if internet connection is good 
	# (2) To download Images from IPFS 
	# Q1
	static func _http_request_completed_Internet(result, response_code, headers, body): #works with https connection
		print (" request done 1: ", result) #********for debug purposes only
		print (" headers 1: ", headers)#*************for debug purposes only
		print (" response code 1: ", response_code) #for debug purposes only

		if not body.empty():
				Networking.good_internet = true
			
			
		if body.empty(): #returns an empty body
				push_error("Result Unsuccessful")
				Networking.good_internet = false
				#Networking.stop_check()
				
				
				#Retry Check 
				if Networking.Timeout:
					Networking._check_if_device_is_online(Swipe.q)


	# Q2

	static func _http_request_completed_Images(result, response_code, headers, body): #works with https connection
		print (" request done 2: ", result) #********for debug purposes only
		print (" headers 2: ", headers)#*************for debug purposes only
		print (" response code 2: ", response_code) #for debug purposes only
		
		#if not is_image_available_at_local_storage: 
		"Should Parse the NFT's meta-data to get the image ink"
		print ('request successful')
		
		"Downloads the NFT image"
		print (" request successful", typeof(body))
		
			
			#check if body is image type
		#Comics_v5.set_comic_image_(Networking.download_image_(body, Local.comics_["Chap1 Panel"],q2)) #works
		
		if body.empty():
			push_error("Problem downloading Image ")




	# Q3

	static func _http_request_completed_Scenes(result, response_code, headers, body): #works with https connection
		print (" request done 3: ", result) #********for debug purposes only
		print (" headers 3: ", headers)#*************for debug purposes only
		print (" response code 3: ", response_code) #for debug purposes only
		
		#if not is_image_available_at_local_storage: 
		"Should Parse the NFT's meta-data to get the image ink"
		print ('request successful')
		
		"Downloads the NFT image"
		print (" request successful", typeof(body))
		
		
		#check if body is image type
		#set_comic_image_(Networking.download_image_(body, Local.comics_["Chap1 Panel"],q2)) #works
		
		
		#Comics_v5.load_local_comic(Networking.download_scene_(body, Local.comics_["Chap1 Scene"],q3))

		
		
		if body.empty():
			push_error("Problem downloading Image ")



class Local extends Reference:

	# Comics Name as Strings
	const comic_names : Dictionary = {
		1 : "Neo Sud, the new south"
	} 

	# Comic Scene paths & WebP Images
	const comics_ : Dictionary = {
	"Chap1 Scene": "user://Comics/chapter 1/chapter 1.tscn",
	"Chap1 Panel": "user://Comics/Comics/chapter 1/chapter 1 Neo sud, the new south webp.webp",
		3:'res://scenes/Comics/chapter 3/chapter 3.tscn',
		4:"res://scenes/Comics/chapter 4/chapter 4.tscn",
		5:"res://scenes/Comics/chapter 5/chapter 5.tscn",
		6:"res://scenes/Comics/chapter 6/chapter 6.tscn",
		7:"res://scenes/Comics/chapter 7/chapter 7.tscn",
		8: 'res://scenes/Comics/Outside/outside.tscn'
		
	}


	const comics_local_path : Dictionary = {
		1: "user://Comics/chapter 1/",
		2: "user://Comics/chapter 2/"
	}
	




class Swipe :
	
	#**********Swipe Detection Direction Calculation Parameters************#
	const swipe_start_position : Vector2 = Vector2()
	const swipe_parameters : float = 0.1
	const MAX_DIAGONAL_SLOPE : float = 1.3

	" Swipe Direction Detection"
	#var _e = Timer.new()
	static func _init_(_e : Timer): # Not tested yet
			_e
			
			
			
			#for swipe detection
			_e.one_shot = true
			_e.wait_time = 0.5
			_e.name = str ('swipe detection timer')
			
			
			# Add Swipe Detection Timer to Scene Tree
			Comics_v6._comics_root.call_deferred('add_child',_e)


	func _on_Timer_timeout():
		#if self.visible : # Only Swipe Detect once visible
		emit_signal('swiped_canceled', swipe_start_position)
		print ('on timer timeout: ',swipe_start_position) #for debug purposes delete later


	func connect_signals(_c : Timer, _e : Timer)-> bool:
			return bool(_c.connect('Timeout',_e,_on_Timer_timeout())) #connect timer to node with code
#			return true

	
	#Buggy swipe direction
	# Use an Array to store the first position and all end positions
	# Difference between both extremes is the swipe position
	static func clear_memory(swipe_target_memory_x: Array, swipe_target_memory_y :Array)-> void:
		swipe_target_memory_x.clear()
		swipe_target_memory_y.clear()


	static func _start_detection(
		_position, 
		enabled: bool, 
		_e : Timer ,
		swipe_target_memory_x : Array, 
		swipe_target_memory_y : Array 
		): #for swipe detection
		
		#use current scene to trigger cinematic
		Globals.update_curr_scene()
		if enabled == true:
			#swipe_start_position = _position
			if not swipe_target_memory_x.has(_position.x): 
				swipe_target_memory_x.append(_position.x)
			if not swipe_target_memory_y.has(_position.y):
				swipe_target_memory_y.append(_position.y)
			
			
			_e.start()
			print ('start swipe detection :') #for debug purposes delete later

	"Only Two Swipe Directions Are Currently Implemented"

	# Contains a Calibration Bug

	static func _end_detection(
		__position, direction : Vector2, 
		direction_var, _state, _e : Timer, 
		swipe_target_memory_x : Array, 
		swipe_target_memory_y : Array, 
		swipe_start_position : Vector2, 
		swipe_parameters: float, 
		x1,x2,y1,y2,
		MAX_DIAGONAL_SLOPE
		):
	
		direction = (__position - swipe_start_position).normalized()
		"""
		SWIPE CALIBRATOR
		
		"""
			
		if round(direction.x) == -1: # Doesnt work
			print('left swipe 1') #for debug purposes
			#next_panel()
			
			
			
			# Play Animation
			GlobalAnimation.get_child(0).play("SWIPE_LEFT")
			return GlobalAnimation.get_child(0).queue("RESET")
			
			
		if round(direction.x) == 1: # works
			print('left swipe 1') #for debug purposes
			
			
			#prev_panel()
			
			direction_var = "Left"
			
			
			
				# Play Animation
			GlobalAnimation.get_child(0).play("SWIPE_LEFT")
			
			# next panel
			
			next_panel()


			return _state
		
		"Up and Down"
		
		if -sign(direction.y) < -swipe_parameters: # works
			print('down swipe 1 = wrong calibration error ') #for debug purposes
			print (" recalibrating to right swipe")
			#next_panel()
			
			direction_var = "Right"
			
			
			# Play Animation
			GlobalAnimation.get_child(0).play("SWIPE_RIGHT")
			
			# next panel
			
			prev_panel()

			
			#if Globals.curr_scene == "Comics____2":
			
			return _state
		
		if -sign(direction.y)  > swipe_parameters: # Doesnt work
			print('up swipe 1') #for debug purposes
			#prev_panel()
			
			
			# Play Animation
			return GlobalAnimation.get_child(0).play("SWIPE_UP")
		
		
		# Saves swipe direction details to memory
		# It'll improve start position - end position calculation
		if not swipe_target_memory_x.has(__position.x) && __position.x != null: 
			swipe_target_memory_x.append(__position.x)
		if not swipe_target_memory_y.has(__position.y) && __position.y != null:
			swipe_target_memory_y.append(__position.y)
		_e.stop()
		
		#Works
		if swipe_target_memory_x.size() && swipe_target_memory_y.size() >= 3 && swipe_target_memory_x.pop_back() != null:
			x1 = swipe_target_memory_x.pop_front()
			x2  = swipe_target_memory_x.pop_back()
			
			y1 = swipe_target_memory_y.pop_front()
			y2  = swipe_target_memory_y.pop_back()
			
			#print ("Swipe Detection Debug: ",x1,"/",x2,"/",y1,"/",y2,"/", swipe_target_memory_x.size()) #For Debug purposes only 
			
			#separate x & y position calculations for x and y swipes
			#
			"Horizontal Swipe"
			if x1 && x2  != null && swipe_target_memory_x.size() > 2:
				
				#calculate averages got x and y
				
				var x_average: int = Globals.calc_average(swipe_target_memory_x)
				
				print ("X average: ",x_average)
				print (x1, "/",x2)
				direction.x  = (x1-x2)/x_average
				
				print ("direction x: ",direction.x)
				
				print ('end detection: ','direction: ',direction ,'position',__position, "max diag slope", MAX_DIAGONAL_SLOPE) #for debug purposes only
				#print ("X: ",swipe_target_memory_x)#*********For Debug purposes only
				#print ("Y: ",swipe_target_memory_x)#*********For Debug purposes only
			
			"Vertical Swipe"
			if y1 && y2 != null && swipe_target_memory_y.size() > 2:
				var y_average: int = Globals.calc_average(swipe_target_memory_y)
				
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
				
				print ('Direction on X: ', direction.x, "/", direction.y) #horizontal swipe debug purposs
			if -sign(direction.x) < Swipe.swipe_parameters:
				print('left swipe') #for debug purposes
				
				if Globals.curr_scene == "Comics____2":
					_state = SWIPE_LEFT
			
			if -sign(direction.x) > Swipe.swipe_parameters:
				print('right swipe') #for debug purposes
				
				# Play Animation
				return GlobalAnimation.get_child(0).play("SWIPE_RIGHT")
			
				
			if abs (direction.y) > abs(direction.x):
				#emit_signal('swiped',Vector2(-sign(direction.y), 0.0))
				print ('Direction on Y: ', direction.x) #horizontal swipe debug purposs
				
			"Up & Down"
			
			# Works
			if -sign(direction.y) < -Swipe.swipe_parameters:
				print('up swipe 2') #for debug purposes
				
				direction_var = "Up"
				
				
				# Play Animation
				return GlobalAnimation.get_child(0).play("SWIPE_UP")
				
				#doenst work
				#_state = SWIPE_UP
			
				
			if -sign(direction.y)  > swipe_parameters:
				print('down swipe 2') #for debug purposes
				
				# Play Animation
				return GlobalAnimation.get_child(0).play("SWIPE_DOWN")
				
			#emit_signal('swiped', Vector2(0.0,-sign(direction.y))) #vertical swipe
				#	print ('poot poot poot') 
		
		if swipe_target_memory_x.size() && swipe_target_memory_y.size() > 50:
			Swipe.clear_memory( swipe_target_memory_x, swipe_target_memory_y)

		else: return


	static func next_panel():
		var a = InputEventAction.new()
		a.action = "next_panel"
		a.pressed = true
		a.strength = 1
		
		Input.parse_input_event(a)


	static func prev_panel():
		var a = InputEventAction.new()
		a.action = "prev_panel"
		a.pressed = true
		a.strength = 1
		
		Input.parse_input_event(a)


class Functions extends Reference:
	
	
	static func show_comics (comics_chap : Node, cmx_root : Control, comic_main  )-> Control:
		comic_main.emit_signal("loaded_comics")
		cmx_root.add_child(comics_chap)
		comic_main._loaded_comics = true
		return cmx_root
	
	static func load_comics(
		current_comics : String, 
		memory : Array ,
		scenetree: SceneTree, 
		enabled : bool, 
		can_drag : bool, 
		zoom : bool , 
		current_frame : int, 
		Kinematic_2d: KinematicBody2D, 
		comics_placeholder : Control
		) -> AnimatedSprite: 

		
		#var err : PackedScene = load(current_comics)
		var err : PackedScene = Globals.Functions.LoadLargeScene(
					current_comics, 
					Globals.scene_resource, 
					Globals._o, 
					Globals.scene_loader, 
					Globals.loading_resource, 
					Globals.a, 
					Globals.b, 
					Globals.progress
					)
		var node : AnimatedSprite
		
		
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
					node.set_script(Extensions)
					
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
	static func drag(_target : Vector2, _position : Vector2, _body :  KinematicBody2D, center : Vector2, target_memory_x : Array, target_memory_y: Array)-> void: #pass this method some parmeters
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
			#_body.move_and_slide(center) #move and slide to center
			#print (111111111111111)
			#print (_body.position, "////", center)# for debug purposes only
			
			
			#_body.position = center
				
			#_body.position =  $Position2D.position# center
			
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
					
				var x : int = _target.x
				var y : int = _target.y
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
						_body.move_and_slide(Vector2(target_memory_x.back(), target_memory_y[0]))
						#_body.position = Vector2(target_memory_x.back(), target_memory_y[0])
						#_body.move_and_slide()
					
					elif target_memory_y.size() > 1:
						
						var adjusted_target = Vector2(target_memory_x.back(), target_memory_y[target_memory_y.size() - 1])
						
						#moves to a predicted presaved axis
						_body.move_and_slide(adjusted_target)
						#_body.move_and_slide()
					

				#code base is too long to debug. Simplify
				# Bugs out
				# Disabling for debugging
				#if not abs(target_memory_y[int(target_memory_y.size()) - 2] - x) && abs(target_memory_x[int(target_memory_x.size()) - 2] - x) > 3 :
				
				#	_body.move_and_slide(_target)



	static func drag_v2(comics_sprite : AnimatedSprite, target : Vector2)-> void:
		if comics_sprite != null: # Error Catcher 1
			comics_sprite.set_position(target)

	static func _zoom(comics_placeholder : Control, zoom : bool)-> bool:
		
		#if _loaded_comics == true:
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

	static func _zoom_2(comics_placeholder : Node, zoom : bool)-> bool:
		
		#if _loaded_comics == true:
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
	"""
	The goal of this script is to store and send comic page details 
	to the comic class script from the Comics Animated Sprite. 
	"""
	# TO DO: Implement Polymorphism for all Chapter pages
	# It should also synconize data with the word bubble in a way that is playable 
	# IS a port of Comics_panels_extensions script v1

	# Features
	# (1) Loads into comics node Programmatically
	# (2) Syncs Comics node info to Singleton
	export var panel : Vector2
	export var word_buble_count : int 

	var TotalPageCount : int = 0
	var CurrentPage : int = 0

	#const PageData : Array = [0,1,2,3,4,5,6] # total page count



	export var Chapter_Data : Dictionary = {
		"Word Bubbles": word_buble_count,
		"All Pages" : TotalPageCount,
		"Name" : "Neo Sud, the New South",
		"Current Page": CurrentPage,
	}

		# Update 
	func _process(_delta):
		
		#print(Comics_v6.current_frame, "/", CurrentPage) # for debug purposes
		
		#CurrentPage = comics.get_frame()
		
		# Makes Current Page a Local integer
		CurrentPage = self.get_frame()

		#print(CurrentPage, "/", TotalPageCount) # for Debug purposes only
		
		# Last Page
		if (CurrentPage + 1) == (TotalPageCount) : # Make Practical 
			#print ("freeing comics placeholder method")
			#self.queue_free()
			Comics_v6.LastPage = true

	func _ready():
		Comics_v6.comics_sprite = self
		TotalPageCount = self.frames.get_frame_count('default')
		
		print_debug("Extension Script Initialized" + str(Comics_v6.comics_sprite) )


# It Uses a camera 2d to simulate guided view. Should not be used when running the game
func guided_view()-> void: #Unwriten code
	#It's supposed tobe a controlled zoom
	pass


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





static func load_local_image_texture_from_global(node : TextureRect, _local_image_path: String, expand: bool, stretch_mode: int)-> void:
	#print ("NFT debug: ", NFT) #for debug purposes only
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(_local_image_path)
	texture.create_from_image(image)
	node.show()
	node.set_texture(texture) #cannot load directly from local storage without permissions
		#print (NFT.texture) for debug purposes only
	node.set_expand(expand)
	node.set_stretch_mode(stretch_mode) 







"""
button connections 
"""
	
static func mouse_entered():
	print(111111)

static func mouse_exited():
	print(2222)



func _on_chap_1_pressed():
	print ("loading chapter 1")
	
	# works
	# Make Comic a global object
	comics_sprite =  Functions.load_comics(
		comics[1], 
		memory,
		get_tree(),
		enabled, 
		can_drag, 
		zoom,
		current_frame, 
		Kinematic_2d, 
		comics_placeholder
		)

	Functions.show_comics(
		comics_sprite, 
		cmx_root, 
		self
		)

func _on_chap_2_pressed(): #Simplify this function
	print ("loading chapter 2")
	# works
	Functions.show_comics(Functions.load_comics(comics[2], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)


func _on_chap_3_pressed(): #Simplify this function
	print ("loading chapter 3")
	# works
	Functions.show_comics(Functions.load_comics(comics[3], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)




func _on_chap_4_pressed():
	print ("loading chapter 4")
	
	# works
	Functions.show_comics(Functions.load_comics(comics[4], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)



func _on_chap_5_pressed():
	print ("loading chapter 5")
	# works
	Functions.show_comics(Functions.load_comics(comics[5], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)



func _on_chap_6_pressed():
	print ("loading chapter 6")
	# works
	Functions.show_comics(Functions.load_comics(comics[6], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)


func _on_chap_7_pressed():
	print ("loading chapter 7")
	# works
	Functions.show_comics(Functions.load_comics(comics[7], memory,get_tree(),enabled, can_drag, zoom,current_frame, Kinematic_2d, comics_placeholder), cmx_root, self)


#func create_comics_directory(path_to : String)-> void:
## Creates a Comics folder.
#	if not FileDirectory. dir_exists(path_to):
#		FileDirectory.make_dir(path_to)
#	else: return 

func connect_signals()-> bool: #connects all required signals in the parent node
	
	# TO DO: 
	# (1) Implement Server Storage
	
	if web3:
		#checks internet connectivity
		if not Online.q.is_connected("request_completed", self, "_http_request_completed_Internet"):
			return Online.q.connect("request_completed", self, "_http_request_completed_Internet")

		#checks Image downloader
		if not Online.q2.is_connected("request_completed", self, "_http_request_completed_Images"):
			return Online.q2.connect("request_completed", self, "_http_request_completed_Images")

		#checks Scene downloader
		if not Online.q3.is_connected("request_completed", self, "_http_request_completed_Scenes"):
			return Online.q3.connect("request_completed", self, "_http_request_completed_Scenes")


	if not Kinematic_2d.is_connected("mouse_entered", self, "mouse_entered"):
		Kinematic_2d.connect("mouse_entered", self, "mouse_entered")
		Kinematic_2d.connect("mouse_exited", self, "mouse_exited")

	# connect Timer Signals for Swipe Locker

	return false





func _on_zoom_pressed():
	Functions._zoom_2(comics_sprite, !zoom)
	zoom = !zoom
	return zoom
