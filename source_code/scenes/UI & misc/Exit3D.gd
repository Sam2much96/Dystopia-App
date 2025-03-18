extends Area


# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Exit
# Add this to any area2d and it will send the player to the indicated scene and spawnpoint
#
# Features:
# (1) Saves Player Information to Local Storage once Player Object is Detected.
# (2) Connects to Globals Functions class for Saving Player Object Information

# To Do:
#(1) Document Functions
# *************************************************




class_name Exit3D

"""
Add this to any area3d and it will send the player to the indicated scene and spawnpoint
"""
export(bool) var Enabled


export(String, FILE, "*.tscn") var to_scene
export(String) var spawnpoint = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect Signal To Self Only If Not Connected
	if is_connected("body_entered", self, "_on_body_entered") == false:
		connect("body_entered", self, "_on_body_entered")
	
	# update current scene
	# use current scene to trigger cinematic
	Globals.update_curr_scene() 


func _on_body_entered(body):
	# Buggy not workinh
	# Using timer node instead
	if body is Camera:
		print_debug("11111111111")
		Globals.current_level = to_scene
		Globals.spawn_x = body.position.x+ 200 
		Globals.spawn_y = body.position.y +200
		Globals.player_hitpoints = body.hitpoints
		
		
		Utils.Functions.save_game(
			[body], 
			body.hitpoints, 
			(body.position.x+ 200), 
			(body.position.y +200), 
			to_scene, 
			"", 
			Globals.kill_count, 
			"", 
			null, 
			""
			) 
			
			



func _on_Timer_timeout():
	#print_debug(Globals.curr_scene)
	if  to_scene == "":
		push_error("Error changing scenes: to_scene has no assigned scene")
		return false
		#Globals.prev_scene_spawnpoint = $spawnpoint.position 
	
	if Globals.curr_scene == "Overworld3D":
		"Loads Large Scene"
		print_debug("creates a bug in the titlescreen")
		
		
		Globals.current_level = to_scene
		
		# Global Scene Transition
		Utils.Functions.change_scene_to(Globals.loading_scene, get_tree())
