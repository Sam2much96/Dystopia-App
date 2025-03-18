




# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Loading
# (1) Shows a loading screen with a message
# (2) Uses a shader to load
#
# *************************************************

# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# Functions:
#
# (1) Shows a Loading Scene Icon for performance heavy scenes
# (2) Runs global scene loading loop in a thread process
# (3) Logic coo-rdinating the ingame loading scene reource for better ux per device
#
# *************************************************
#
# Bugs:
# (1) Breaks sometimes
# (2) No debug
# (3) No Output
# (4) Breaks whenever dialog trigger is used in the same scene
#
# *************************************************

#extends Control

extends ColorRect
"""
Loading Scene

"""
class_name loading


# Exportable loading boolean
export (bool) var LOADING = false 

onready var loaded_scene_temp : PackedScene 


export (bool) var VISIBLE

onready var Progress : ProgressBar = $VBoxContainer/ProgressBar
onready var Number : Label= $VBoxContainer/Number
onready var message : Label = $VBoxContainer/Message


# loading throbber
onready var  loading2 : TextureRect = $VBoxContainer/loading2


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
	if LOADING && not Globals.current_level.empty():
		
		# this function loads the scene resource into a global script and returns it
		loaded_scene_temp = Utils.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress)
		
		# Null resource load
		#
		
		LOADING = false
		
		print_debug("Loaded Scene Temp: ",loaded_scene_temp)
		if loaded_scene_temp != null: # successful load
			print_debug("Loading successfull")
			Utils.Functions.change_scene_to( loaded_scene_temp, get_tree())
		if loaded_scene_temp == null : # unsuccessfull load redundancy code backported from 4.2.2 Vulkan
			get_tree().change_scene_to(load(Globals.current_level))
			print_debug("Loading failed")





func _ready():
	Progress.hide()
	Number.hide()
	
	
	# COnnect Signals for redundancy errors
	if not is_connected("visibility_changed",self,"_on_loading_visibility_changed"):
		connect("visibility_changed",self,"_on_loading_visibility_changed")

	print_debug("laading scene %s: ",Globals.current_level)
	
	
	
	if Globals.current_level.empty():
		push_error("Error: initial_level shouldn't be empty")
		LOADING = false
		
	if not Globals.current_level.empty():
		
		if Globals.os == "Android" or "iOS":
			# Features:
			# (1) run a timer then start loading for mobile devices
			# (2) Turns off loading scene for low resource heavy scenes using a Glopbal scne dictionary
			# (3) Uses Dictionary keyys number to set loading animation time
			if (Globals.current_level == Globals.Overworld_Scenes.get(1) or
			Globals.current_level == Globals.Overworld_Scenes.get(5)
			):
				
				# Only show long loading scene for overworld scenes 1 and 5 which are resource heavy
				
				yield(get_tree().create_timer(5), "timeout")
				
				
		LOADING = true





func _on_loading_visibility_changed():
	# connects to a Github node signal
	VISIBLE = visible
	visibility_logic(VISIBLE)


func visibility_logic( _visible : bool):
	if _visible:
		loading2.show()
		loading2.material.set_shader_param("speed",5)
	if not _visible:
		Progress.hide()
		Progress.set_value(0)
		Number.hide()
		Number.set_text("...")
		loading2.material.set_shader_param("speed",0)

# Shows a Progress Bar
func show_progress(value : float , max_value : float):
	Progress.show()
	Progress.set_value(range_lerp(value,0,max_value,0,100))

func hide_progress():
	Progress.hide()

# Shows a Progress Number
func show_number(value : float , ref_value : float, type : String):
	Number.show()
	Number.set_text(str(value)+" "+type+" downloaded (of ~"+str(ref_value)+" "+type+")")

func hide_number():
	Number.hide()
