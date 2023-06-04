# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Idol
# Saves Player Object details via Global Script to Local Storage
# Features:
# (1) Saves Player Information to Local Storage
# (2) Connects to the Global Functions class for Saving Functions

# To Do:
#(1) Document
# *************************************************

extends Area2D

class_name Idol

"""
IDOL SCRIPT
this triggers an autosave spawnpoint feature one within its kinematic body 2d
"""


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered") #connects the signals with code
	connect("body_exited", self, "_on_body_exited")
	pass # Replace with function body.

func _on_body_entered(body):
	if body is Player:
		
		# Debugger
		var _debug = get_tree().get_root().get_node("/root/Debug")
		_debug.Autosave_debug = str(' Autosaving player position:', (body.position) )
		
		Globals.spawn_x = body.position.x #saves the player's position to spawnpoint
		Globals.spawn_y = body.position.y
		Globals.player_hitpoints = body.hitpoints
		Globals.Functions.save_game(
			[body], 
			body.hitpoints, 
			body.position.x, 
			body.position.y, 
			null, 
			Globals.os, 
			Globals.kill_count, 
			null,null,null,null
			)


func _on_body_exited(body):
	if body is Player:
		if Engine.has_singleton('Debug'):
			var Debug = Engine.get_singleton('Debug')
			Debug.Autosave_debug = str ('')
