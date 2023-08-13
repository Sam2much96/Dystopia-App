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
# 
# Bugs 
# (1) Double Areads
# *************************************************

extends Area2D

class_name Idol

"""
IDOL SCRIPT
this triggers an autosave spawnpoint feature one within its kinematic body 2d
"""


var _debug : debug = Engine.get_singleton('Debug')

func _connect_signals() -> void:
	
	"Backup Signal connector"
	
	if not is_connected("body_entered", self, "_on_body_entered"):
		# warning-ignore:return_value_discarded
		connect("body_entered", self, "_on_body_entered") #connects the signals with code
	
	if not is_connected("body_exited", self, "_on_body_exited"):
		connect("body_exited", self, "_on_body_exited")
	


	else: pass 

func _ready():
	"Get Debugger Class"
	if _debug == null:
		if is_instance_valid(get_tree().get_root().get_node("/root/Debug")) :
			_debug = get_tree().get_root().get_node("/root/Debug")
		#print_debug("Error: ",(_debug == OK))
	if _debug == null:
		if Engine.has_singleton('Debug'):
			#var Debug = Engine.get_singleton('Debug')
			_debug = Engine.get_singleton('Debug')

	print_debug("Debugger Instance:", _debug)

func _save(body):
	#if body is Player:
		
		# Debugger
		#var _debug = get_tree().get_root().get_node("/root/Debug")
		if _debug != null: 
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


func _reset_autosave_debugger() -> void:
	#if body is Player:
	if _debug != null:
		_debug.Autosave_debug = str ('')
