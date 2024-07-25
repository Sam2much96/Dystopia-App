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


extends Area2D

class_name Exit

"""
Add this to any area2d and it will send the player to the indicated scene and spawnpoint
"""

@export var to_scene # (String, FILE, "*.tscn")
@export var spawnpoint: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body is Player:
		
		"Loads Large Scene Precursour"
		
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
			
			
	if  to_scene.is_empty():
		push_error("Error changing scenes: to_scene has no assigned scene")
		return false
		
		
		
		# Global Scene Transition
	if Utils.Functions.change_scene_to_packed(Globals.loading_scene, get_tree()) != OK:
		push_error("Error changing scene")

