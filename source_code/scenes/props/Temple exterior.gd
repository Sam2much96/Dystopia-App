# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Temple Exterior
# 
# Features:
#  
#  (1) Saves Player Object and Scene Variables to Global Script
# (2) Changes Scene from Outside Level to Temple Interior scene

# To Do:
#(1) Document (Done)
# (2) Implement One Way Collisions  
# *************************************************

extends StaticBody2D

class_name TempleExterior

@export var to_scene = "res://scenes/levels/Temple interior.tscn" # (String, FILE, "*.tscn")
@export var spawnpoint: String = ''

#func _ready():
	#$to_inside.to_scene = to_scene
	#$to_inside.spawnpoint = spawnpoint
	
	#Globals.prev_scene = get_tree().get_current_scene().get_name() #saves current scene as pervious scene
	#Globals.prev_scene_spawnpoint =$to_inside/spawnpoint.position #updates your position and saves
	# depreciated methods
	#Globals.save_game()
	#Globals.spawnpoint = Globals.spawnpoint #i dunno what this does but lets see what happens
	#pass # Replace with function body.
