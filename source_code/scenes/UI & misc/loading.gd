# *************************************************
# godot4-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Loading
# (1) Shows a loading screen with a message
# (2) Uses a shader to load
#
# *************************************************
# Functions:
#
# (1) Shows a Loading Scene Icon for performance heavy scenes
# (2) Runs global scene loading loop in a thread process
# (3) Logic coo-rdinating the ingame loading scene reource for better ux per device
#
# *************************************************
#
# to do:
# (1) creaete a scene atlas for loading all scenes  and lock them into a resources file
#
# *************************************************

#extends Control

extends ColorRect
"""
Loading Scene

"""
class_name loading


# Exportable loading boolean
@export var LOADING : bool = false 

@onready var loaded_scene_temp : PackedScene 


@export var VISIBLE : bool

@onready var Progress : ProgressBar = $VBoxContainer/ProgressBar
@onready var Number : Label= $VBoxContainer/Number
@onready var message : Label = $VBoxContainer/Message


# loading throbber
@onready var  loading2 : TextureRect = $VBoxContainer/loading2

@onready var randomHints : String



'Scene Loading variables'
#var scene_resource : PackedScene # Large Resouce Scene Placeholder
#var _to_load : String  # Large Resource Placeholder Variable
var _o : ResourceFormatLoader#for polling resource loader
#var err
var a : int # Loader progress variable (a/b) 
var b : int
#var loading_resource : bool = false
@onready var scene_loader= ResourceLoader
@onready var progress : float

@onready var timer  = $Timer
#signal loaded(a,b)

# android singleton safe pointer
#onready var safe_Android = get_node("/root/Android")

# global singleton 
@onready var safe_Globals = get_node("/root/Globals")

# music singleton
@onready var safe_Music = get_node("/root/Music")

# dialogs singleton
@onready var safe_Dialogs = get_node("/root/Dialogs")

# utils singleton
@onready var safe_Utils = get_node("/root/Utils")

# game hud singleton
@onready var safe_HUD = get_node("/root/GameHud")

func _ready():
	
	# trigger the menu hidden state
	safe_HUD.menu.hidden()
	
	#Progress.hide()
	Number.hide()
	
	# placeholder progress bar until resource interractive loader can be polled and waited
	show_progress(5,20)
	
	# COnnect Signals for redundancy errors
	#if not self.is_connected("visibility_changed",_on_loading_visibility_changed()):
	#	self.connect("visibility_changed",_on_loading_visibility_changed())

	
	# connect loading poll signal
	
	#connect("loaded", self,"show_progress", [a,b])
	
	print_debug("laading scene %s :",[safe_Globals.current_level])
	
	# show random hints
	
	# Shows Random Hints using a Dictionary shuffle algorithm
	randomHints = safe_Music.shuffle(safe_Dialogs.hints)
	
	# depreciated in favour of translations server implementation
	# Translates them to the User's Language
	#message.set_text(Dialogs.translate_to( randomHints, Dialogs.language))
	
	# load the initial
	# to do:
	#(1) make current level an onready variable at the top of this script
	if safe_Globals.current_level.is_empty():
		push_error("Error: initial_level shouldn't be empty")
		LOADING = false
		
	if not safe_Globals.current_level.is_empty():
		
		# depreciated android code
		#if safe_Globals.os == "Android" or "iOS":
		#	# Features:
		#	# (1) run a timer then start loading for mobile devices
		#	# (2) Turns off loading scene for low resource heavy scenes using a Glopbal scne dictionary
		#	# (3) Uses Dictionary keyys number to set loading animation time
		#	if (safe_Globals.current_level == safe_Globals.Overworld_Scenes.get(1) or
		#	safe_Globals.current_level == safe_Globals.Overworld_Scenes.get(5) or 
		#	safe_Globals.current_level == safe_Globals.Overworld_Scenes.get(3) 
		#	):
				
				# Only show long loading scene for overworld scenes 1 and 5 which are resource heavy
				
				# set 2 different times for mobile and pc
				#yield(get_tree().create_timer(5), "timeout")
		#		timer.start(3)
		#		return
				
		#if safe_Globals.os == "X11" or "Windows" or "HTML5"or "OSX"or "Server"or "UWP":
			#timer.start(1) # start loading immediately
		LOADING = true





func _process(_delta):
	
	
	"Loads Large Scene"
	# Bug :
	# (1) Take too long (Performance Lag)
	# (2) Bad UX
	# (3) Returns a Null resource load on Vulkan Godot 4.2.2
	#
	# Fix
	# (1) Hide Loading Screen
	# (2) Show Loading Icon WHile Scene is being Loaded
	# (3) Implement Redundancy loading code
	# Emptry current level initiator
	if LOADING && not safe_Globals.current_level.is_empty():
		
		#get_tree().change_scene_to_packed(load(safe_Globals.current_level))
		
		# this function loads the scene resource into a global script and returns it
		# temporarily depreciated for refactoring Jan 21, 26
		loaded_scene_temp = await LoadLargeScene(
		safe_Globals.current_level, 
		loaded_scene_temp, 
		a, 
		b, 
		progress,
		self
		)
		
		# Null resource load
		#
		
		LOADING = false
		
		print_debug("Loaded Scene Temp: ",loaded_scene_temp)
		if loaded_scene_temp != null: # successful load
			print_debug("Loading successfull")
			
			# only show progress bars for these scenes else change instantly
			if (safe_Globals.current_level == safe_Globals.Overworld_Scenes.get(1) or
			safe_Globals.current_level == safe_Globals.Overworld_Scenes.get(5)
			):
				show_progress(20,20)
				await get_tree().create_timer(2).timeout
				
			# TO DO : 
			# connect a signal from the loading screen to Touchscreen HUD
			# the signal will connect to show all button once Gamescenes are loaded
			# and will also connect to menu() once no game scene is loaded 
			
			
			safe_Utils.Functions.change_scene_to_packed(loaded_scene_temp, get_tree())
		if loaded_scene_temp == null : # unsuccessfull load redundancy code backported from 4.2.2 Vulkan
			push_error("Loading failed")
			#get_tree().change_scene_to(load(Globals.current_level))
			print_debug("Loading failed")






#func _on_loading_visibility_changed():
#	# connects to a Github node signal
#	VISIBLE = visible
#	visibility_logic(VISIBLE)


func visibility_logic( _visible : bool):
	if _visible && loading2:
		loading2.show()
		loading2.material.set_shader_parameter("speed",5)
	if not _visible:
		Progress.hide()
		Progress.set_value(0)
		Number.hide()
		Number.set_text("...")
		loading2.material.set_shader_parameter("speed",0)

# Shows a Progress Bar
func show_progress(value : float , max_value : float):
	Progress.show()
	#yield(get_tree(), "idle_frame") # pause for idle frame breaks the loader
	#print_debug("Show Progress Triggered: ", value, "/",max_value)
	Progress.set_value(remap(value, 0, max_value, 0, 100))

func hide_progress():
	Progress.hide()

# Shows a Progress Number
func show_number(value : float , ref_value : float, type : String):
	Number.show()
	Number.set_text(str(value)+" "+type+" downloaded (of ~"+str(ref_value)+" "+type+")")

func hide_number():
	Number.hide()

# Utils functions deserialised for debugging
static func LoadLargeScene(
	scene_to_load: String, 
	sc_resource: PackedScene, 
	a_: int, 
	b_: int, 
	progress_: float, 
	loader: loading
) -> PackedScene:
	
	if scene_to_load.is_empty():
		push_error("Error: Scene path is empty.")
	
	if sc_resource != null:
		push_error("Error: Scene resource is already loaded.")
	
	# Load the scene asynchronously
	var load_status = ResourceLoader.load_threaded_request(scene_to_load)
	
	if load_status != OK:
		push_error("Error: Failed to start threaded loading.")
		return null
	
	print_debug("Starting asynchronous scene load >>>> : " + scene_to_load)
	
	loader.LOADING = true
	
	var progress = []
	
	while bool(loader.LOADING) == true:
		
		var status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
		
		match status:
			
			ResourceLoader.THREAD_LOAD_IN_PROGRESS: # Still loading
				
				if progress.size() > 0:
					var current_progress = progress[0]
					# Convert 0.0-1.0 progress to stage numbers for compatibility
					a_ = int(current_progress * 100)
					b_ = 100
					loader.show_progress(a_, b_)
				
				await loader.get_tree().process_frame # Wait for next frame
			
			ResourceLoader.THREAD_LOAD_LOADED: # Finished loading
				sc_resource = ResourceLoader.load_threaded_get(scene_to_load)
				print_debug("Resource Loaded: ", sc_resource)
				loader.LOADING = false
			
			ResourceLoader.THREAD_LOAD_FAILED: # Loading failed
				push_error("Problems loading Scene. Debug Globals scene loader")
				push_error(str(progress_) + "% " + str(scene_to_load))
				loader.LOADING = false
			
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE: # Invalid resource
				push_error("Invalid resource: " + scene_to_load)
				loader.LOADING = false
	
	if sc_resource != null:
		return sc_resource
	else:
		push_error("There was an Error. Loading the Scene Resource is null")
		return null

# used for timing load times
func _on_Timer_timeout():
	LOADING = true
