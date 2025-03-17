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
# (3) Exit Should Be on Collision Layer 3

# To Do:
#(1) Document Functions (Done)
# (2) Write Redundancy Code for Debugging signal connections
# *************************************************


extends Area2D

class_name Exit

"""
Add this to any area2d and it will send the player to the indicated scene and spawnpoint
"""

export(String, FILE, "*.tscn") var to_scene
export(String) var spawnpoint = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Signals Connection Redundancy Code
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")
		push_warning("Debug Exit Signal Connections")

func _on_body_entered(body):
	print_debug("Debugging Exit 2d code", to_scene, "/",spawnpoint)
	
	if body is Player:
		
		"Loads Large Scene Precursour"
		
		Globals.current_level = to_scene
		Globals.spawn_x = body.position.x+ 200 
		Globals.spawn_y = body.position.y +200
		Globals.player_hitpoints = body.hitpoints
		
		
		# Rewrite to Serialise Quest data and show documentation
		
		Utils.Functions.save_game(
			[body], 
			body.hitpoints, 
			body.position.x, 
			body.position.y, 
			to_scene, 
			"", 
			Globals.kill_count, 
			"", 
			null, 
			""
		) 
		
		print_debug ("Finished Saving Game")
	
	if  to_scene.empty(): # Error Catcher 1
		push_error("Error changing scenes: to_scene has no assigned scene")
		return 

	if !to_scene.empty():
		print_debug("To Scene Debug: ", to_scene)

	Globals.current_level = to_scene
	#print_debug("changing scene to :", to_scene)
	#get_tree().change_scene(to_scene)
		# Global Scene Transition
	Utils.Functions.change_scene_to(Globals.loading_scene, get_tree()) #!= OK:
	#	push_error("Error changing scene")
