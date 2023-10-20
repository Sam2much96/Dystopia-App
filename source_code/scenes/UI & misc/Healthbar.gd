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
var player_group : Array = []

var heart_instance : PackedScene = preload("res://scenes/UI & misc/Heart.tscn")
const MAX_HEALTH = 23
var initial_health : int 

# Disabling until ready to Implement
var heart_empty : PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")

"""
Connects to the player node and shows a health bar in the form of hearts
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	while (player == null):
		player_group = get_tree().get_nodes_in_group("player")
		if not player_group.empty():
			for i in player_group:
				if i is Player:
					player = i #player = player_group.pop_front()
					initial_health = player.hitpoints
				if i is Player_v2_networking: pass 
		else:
			yield(get_tree(), "idle_frame")
	
	player.connect("health_changed", self, "_on_health_changed")
	_on_health_changed(player.hitpoints)
	pass # Replace with function body.

	
	# Initialization For Networked Player
	# Using Network Player Info Packed

# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp : int):
	
	# Clears Previous HP
	for child in get_children():
		child.queue_free() #removes life
	
	# Creates New Heart Instate From Updatesd HP
	for i in new_hp:
		var heart = heart_instance.instance()
		call_deferred('add_child',heart) #adds more life
		#add_child(heart) 
	


	
func _on_health_changedV2(new_hp : int):
	# Remove existing heart nodes
	for child in get_children():
		child.queue_free()
	
	initial_health = new_hp
	# Add heart or empty heart nodes based on hitpoints
	for i in range(new_hp):
		#var heart_instance
		if i < initial_health:
			var heart = heart_instance.instance()
			pass
		if i > initial_health:
			pass
		else:
			var heart = heart_empty.instance()
			call_deferred("add_child", heart)
