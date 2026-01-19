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
# (4) Saves game Data to disk

# To Do:
#(1) Document Functions (Done)
# (2) Write Redundancy Code for Debugging signal connections
# (3) Rewrite Exit Logic to dtrigger decision dialogue box
# *************************************************


extends Area2D

class_name Exit

export(String, FILE, "*.tscn") var to_scene
export(String) var spawnpoint = ""

# safe pointers to global singletons
onready var safe_Globals = get_node("/root/Globals")
onready var safe_Utils = get_node("/root/Utils")

func _ready():
	
	# Signals Connection Redundancy Code
	if not is_connected("body_entered", self, "_on_Exit_body_entered"):
		connect("body_entered", self, "_on_Exit_body_entered")
		push_warning("Debug Exit Signal Connections")
	
	
	
	



func _on_Exit_area_entered(area):
	if area.name == "hurtbox":
		
		print_debug("area: ", area.name)
		#Utils.Functions.change_scene_to(Globals.loading_scene, get_tree())

func _on_Exit_body_entered(body):
	
	if body is Player:
		print_debug("player body detected on exit ", body.name)
		#TRIGGERED = true
		print_debug("Debugging Exit 2d code", to_scene, "/",spawnpoint)
		
		#get_tree().change_scene_to(load(to_scene))
		
		"Loads Large Scene Precursour"
		
		#Globals.current_level = to_scene
		safe_Globals.spawn_x = body.position.x 
		safe_Globals.spawn_y = body.position.y
		safe_Globals.hp = body.hitpoints
		
		
		# Save Game
		#
		#
		# Temporarily disable for refactoring singleton resource files Jan 17, 26
		#safe_Utils.Functions.save_game(get_tree()) 
		
		#print_debug ("Finished Saving Game")
		
		if  to_scene.empty(): # Error Catcher 1
			push_error("Error changing scenes: to_scene has no assigned scene")
			return 

		if !to_scene.empty():
			print_debug("To Scene Debug: ", to_scene)

		safe_Globals.current_level = to_scene
		#print_debug("changing scene to :", to_scene)
		#get_tree().change_scene(to_scene)
			# Global Scene Transition
		safe_Utils.Functions.change_scene_to(safe_Globals.loading_scene, get_tree())
		#	push_error("Error changing scene")
		
