# *************************************************
# godot4-Dystopia-game by INhumanity_arts
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
# (4) Implement Empty Heart Animation
# (5) Implement Heart Box Scaling For Mobile Devices
# *************************************************
# Bugs:
# 
# (1) Currently Only Works in Local Player not Networked Multiplayer (fixed)
# (2) Does'nt scale well on Mobile Devices
# (3) Requires Reimplementation and Animation Player (Full Refactor)
# *************************************************
@icon("res://resources/misc/Pixel Heart 32x32.png")
extends HBoxContainer

class_name Healthbar

"""
Connects to the player node and shows a health bar in the form of hearts
"""

var player : Player 
var networkPlayer : Player_v2_networking
var player_group : Array = []

var heart_instance : PackedScene = preload("res://scenes/UI & misc/Heart.tscn")
const MAX_HEALTH = 23 # Max Health Constant
var initial_health : int 

# Disabling until ready to Implement
var heart_empty : PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")

"""
Connects to the player node and shows a health bar in the form of hearts
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	#while (player == null):
	#	
	#	# use a global function instead
	#	player_group = get_tree().get_nodes_in_group("player")
	#	# Too much Nested Ifs?
	#	if not player_group.is_empty():
	#		for i in player_group:
	#			if i is Player:
	#				player = i #player = player_group.pop_front()
	#				initial_health = player.hitpoints
	#				
	#				#print_debug(111111) #works
	#			if i is Player_v2_networking: pass 
	#	else:
			
			# Emitted befor Node._process()
	#		await get_tree().idle_frame
	
	
	# Connect Signals to Player Object
	#player.connect("health_changed", Callable(self, "_on_health_changed"))
	
	# Debug SIgnals
	#print_debug(player.is_connected("health_changed", Callable(self, "_on_health_changed")))
	

	
	# Set Hitpoint to Player Object Hitpoints
	#_on_health_changed(player.hitpoints)
	pass

# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp : int):
	
	# Clears Previous HP
	for child in get_children():
		child.queue_free() #removes life
	
	if not new_hp > MAX_HEALTH:
		# Creates New Heart Instate From Updatesd HP
		# inefficient code
		for i in new_hp:
			
			var heart = heart_instance.instantiate(0)
			
			self.call_deferred('add_child',heart) #adds more life bars


func get_heart_count()-> int:
	# Gets The Number Of Heart Nodes Created
	# Updates It To The Inspector Tab
	# Parses Through It's Childern and Gets a Count of Certain Types
	# Updates Health Count TO Inspector Tab and Houts Hidden Health Tabs
	# *************************************************
	
	var hp_child : Array = self.get_children()
	var HEALTH_COUNT = 0 # Clear Prev Health COunt
	var HEALTH_LOST = 0
	for i in hp_child:
		if i is TextureRect :
			if i.visible == true: # Counts Only Visible Heart Boxes
				HEALTH_COUNT +=1
			if i.visible == false:
				HEALTH_LOST +=1
				
	return HEALTH_COUNT


func _exit_tree() -> void:
	player = null
	networkPlayer = null
	heart_empty = null
