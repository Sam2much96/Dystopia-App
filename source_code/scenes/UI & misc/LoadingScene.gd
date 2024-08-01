extends Control
"""
Loading Scene

"""

# Functionstions
# (1) Shows a Loading Scene Icon for performance heavy scenes
# (2) Runs global scene loading loop in a thread process
# (3) Logic coo-rdinating the ingame loading scene reource for better ux per device


# Exportable loading boolean
@export var LOADING : bool = false 

@onready var loaded_scene_temp : PackedScene


	

func _ready():

	
	print_debug("laading scene %s: ",Globals.current_level)
	
	
	
	if Globals.current_level.is_empty():
		push_error("Error: initial_level shouldn't be empty")
		LOADING = false
		
	if not Globals.current_level.is_empty():
		
		if Globals.os == "Android" or "iOS":
			# Features:
			# (1) run a timer then start loading for mobile devices
			# (2) Turns off loading scene for low resource heavy scenes using a Glopbal scne dictionary
			# (3) Uses Dictionary keyys number to set loading animation time
			if (Globals.current_level == Globals.Overworld_Scenes.get(1) or
			Globals.current_level == Globals.Overworld_Scenes.get(5)
			):
				
				# Only show long loading scene for overworld scenes 1 and 5 which are resource heavy
				
				await get_tree().create_timer(5).timeout
		
		LOADING = true

	
func _process(_delta):
	
	
	#Globals._to_load = Globals.current_level
	"Loads Large Scene"
	# Bug :
	# (1) Take too long (Performance Lag)
	# (2) Bad UX
	# (3) Returns a Null resource load on Vulkan Godot 4.2.2
	# Fix
	# (1) Hide Loading Screen
	# (2) Show Loading Icon WHile Scene is being Loaded
	# (3) Implement Redundancy loading code
	
	# Emptry current level initiator
	if LOADING && not Globals.current_level.is_empty():
		
		# this function loads the scene resource into a global script and returns it
		loaded_scene_temp = await Utils.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress)
		
		LOADING = false
		
		print_debug("Loaded Scene Temp: ",loaded_scene_temp)
		
		# Bug 1: Returns a Null resource load on Vulkan Godot 4.2.2
		if loaded_scene_temp != null: # successful load
			Utils.Functions.change_scene_to_packed( loaded_scene_temp, get_tree())
		if loaded_scene_temp == null: # Unsuccessful load, redundancy code
			push_error("Gloabls Scene Loader is buggy & returned a Null Packed Scene: ", loaded_scene_temp)
			get_tree().change_scene_to_packed(load(Globals.current_level))

func _exit_tree():
	# Called WHen Node Is Exiting the scene tree
	
	# FUnctions: 
	# (1) If device is mobile, free up the scene resource for less ram use and better performance
	#Globals.scene_resource.queue_free()
	#loaded_scene_temp.free()
	pass
