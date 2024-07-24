extends Control
"""
Loading Scene

"""

# Functionstions
# (1) Shows a Loading Scene Icon for performance heavy scenes
# (2) Runs global scene loading loop in a thread process
# (3) Logic coo-rdinating the ingame loading scene reource for better ux per device


# Exportable loading boolean
export (bool) var LOADING = false 

onready var loaded_scene_temp : PackedScene


	

func _ready():

	
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

	
func _process(_delta):
	
	
	#Globals._to_load = Globals.current_level
	"Loads Large Scene"
	# Bug :
	# (1) Take too long (Performance Lag)
	# (2) Bad UX
	
	# Fix
	# (1) Hide Loading Screen
	# (2) Show Loading Icon WHile Scene is being Loaded
	
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
		#return
	# Null resource load
	#if LOADING && Globals.scene_resource == null:
		#play loading animation
	#	pass
		
	#if LOADING && Globals.scene_resource != null: # scene re resource must be a packed scene

		
		LOADING = false
		
		print_debug("Loaded Scene Temp: ",loaded_scene_temp)
		Utils.Functions.change_scene_to( loaded_scene_temp, get_tree())



func _exit_tree():
	# Called WHen Node Is Exiting the scene tree
	
	# FUnctions: 
	# (1) If device is mobile, free up the scene resource for less ram use and better performance
	#Globals.scene_resource.queue_free()
	#loaded_scene_temp.free()
	pass
