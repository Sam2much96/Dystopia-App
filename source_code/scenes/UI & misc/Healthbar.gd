# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Health Bar
# Displays Health Objects Within the Scene Tree
# Features:
# (1) Shows Player Healthbar
# (2) Runs A Recursive Loop To Get An Node That Inherits Player from THe Scene Tree ( Bad Code )

# To Do:
#(1) Implement procedural animation for Healthbar
# (2) Implement Heart Empty UI animation using a Max Health Constant
# (3) Implement Peer ID for Netwworked Multiplayer
# (4) Implement Empty Heart Animation
# (5) Implement Heart Box Scaling For Mobile Devices
# (6) Implement Tweening for healthbar animation
# *************************************************
# Bugs:
# 
# (1) Currently Only Works in Local Player not Networked Multiplayer (fixed)
# (2) Does'nt scale well on Mobile Devices
# (3) Requires Reimplementation and Animation Player (Full Refactor)
# *************************************************
extends HBoxContainer

class_name Healthbar, 'res://resources/misc/Pixel Heart 32x32.png'

"""
Connects to the player node,shows the player object hitpoints in the form of hearts,
and connects a signal to update the healthbar once player hitpoint changes
"""

var player : Player 
var networkPlayer : Player_v2_networking
var player_group : Array = []

# Idea:  Rather Than Instancing the scene, why not duplicate?
onready var heart_instance : TextureRect = $heart #: PackedScene = preload("res://scenes/UI & misc/Heart.tscn")
onready var heart_empty : TextureRect = $heart_empty #: PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")

const MAX_HEALTH = 23 # Max Health Constant
var initial_health : int 


# Placeholder HeartBox
onready var h2 : TextureRect = $heart2
onready var h3 : TextureRect = $heart3


onready var placeholder_hearts : Array = [h2,h3] # For Holding memory pointer to the placeholder heartb


# Called when the node enters the scene tree for the first time.
func _ready():
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	while (Globals.players.empty()):#(player == null):
		
		# use a global function instead
		#player_group = Globals.players #get_tree().get_nodes_in_group("player")
		
		
		## Too much Nested Ifs?
		#if not player_group.empty():
		#	for i in player_group:
		#		if i is Player: # Local Player Code Bloc
		#			player = i #player = player_group.pop_front()
		#			initial_health = player.hitpoints
		#			print_debug("Health Bar Debug")
		#			
		#		if i is Player_v2_networking: pass # Online Player Code Bloc
		#else:
		#	
		# Emitted befor Node._process()
		yield(get_tree(), "idle_frame")
	
	player = Globals.players.pop_back() # Doesnt account for player changing scene resulting in null variable
	
	# Connect Signals to Player Object
	player.connect("health_changed", self, "_on_health_changed")
	
	# Debug SIgnals
	print_debug("Is Player Ok: ",player.is_connected("health_changed", self, "_on_health_changed"), "/", player.hitpoints)
	

	
	# Set Hitpoint to Player Object Hitpoints
	_on_health_changed(player.hitpoints)


# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp : int):
	# Buggy Logic
	print_debug("Health Change Function Called")
	
	var _no_of_hearts = self.get_child_count() -2 # -1 for The unimplemented Empty Heart Scene & tween node
	
	if new_hp == 0:
		# Clears Children Nodes
		for i in self.get_children():
			i.queue_free() 
	
	
	if new_hp == _no_of_hearts:
		return
	
	# Health Increase
	if new_hp > _no_of_hearts:
		var _to_add_hearts = new_hp - _no_of_hearts # get the difference
		
		# Run A Recursive Loop
		for i in _to_add_hearts:
			heart_instance.duplicate()
	
	# Health Decrese
	# To Do : Implement Tweening for animation
	if new_hp < _no_of_hearts:
		var _to_remove_hearts = _no_of_hearts - new_hp
		
		# Recursively Delete all heart childern
		while (_to_remove_hearts > 0):
			self.get_child(_to_remove_hearts).queue_free()
			_to_remove_hearts -= 1
			
	
	# Debug Heart Update
	print_debug("Heart Update Debug: ", (self.get_child_count() -2), "/", "New HP : ",new_hp)
