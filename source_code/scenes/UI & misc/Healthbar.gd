# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Health Bar
# Displays Health Objects Within the Scene Tree
# Features:
# Shows Player Healthbar

# To Do:
#(1) Implement procedural animation for Healthbar
# (2) Implement Heart Empty UI animation using a Max Health Constant
# (3) Implement Peer ID for Netwworked Multiplayer
# *************************************************
# Bugs:
# 
# (1) Currently Only Works in Local Player not Networked Multiplayer
# *************************************************
extends HBoxContainer

class_name Healthbar, 'res://resources/misc/Pixel Heart 32x32.png'

"""
Connects to the player node and shows a health bar in the form of hearts
"""


var player : Player 
var networkPlayer : Player_v2_networking

var heart_scene : PackedScene = preload("res://scenes/UI & misc/Heart.tscn")
const MAX_HEALTH = 23


# Disabling until ready to Implement
#var heart_empty : PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")


func _ready():
	
	# Initialization for Local Player
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	#print_debug (Globals.player)
	if not Globals.player.empty() && Globals.player.pop_front() is Player :
		player = Globals.player.pop_front() #get_tree().get_nodes_in_group("player")
		
		#if player is Player:
		#	player = player_group.pop_front()
		
			# Connect Player Node to Self
		player.connect("health_changed", self, "_on_health_changed")
		_on_health_changed(player.hitpoints)
			
	else:
		yield(get_tree(), "idle_frame") # Replace yield method
	

	

# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp):
	for child in get_children():
		child.queue_free() #removes life
	for i in new_hp:
		var heart = heart_scene.instance()
		call_deferred('add_child',heart) #adds more life
		#add_child(heart) 
	
