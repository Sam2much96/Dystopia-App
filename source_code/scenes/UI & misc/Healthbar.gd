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
# (7) Re-draw Empty heart Sprite
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
onready var HeartScene : PackedScene = load("res://scenes/UI & misc/Heart.tscn")
onready var heart_instance : TextureRect = $heart #: PackedScene = preload("res://scenes/UI & misc/Heart.tscn")
onready var heart_empty : TextureRect = $heart_empty #: PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")

const MAX_HEALTH = 23 # Max Health Constant

export (int) var HEALTH_COUNT : int = 0
export (int) var HEALTH_LOST : int = 0 # Use

# Placeholder HeartBox
onready var h2 : TextureRect = $heart2
onready var h3 : TextureRect = $heart3


onready var placeholder_hearts : Array = [h2,h3] # For Holding memory pointer to the placeholder heartb


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Store Heart Count TO Inspector
	HEALTH_COUNT = get_heart_count()



func get_heart_count() -> int:
	# Gets The Number Of Heart Nodes Created
	# Updates It To The Inspector Tab
	# Parses Through It's Childern and Gets a Count of Certain Types
	# Updates Health Count TO Inspector Tab and Houts Hidden Health Tabs
	# *************************************************
	var hp_child : Array = self.get_children()
	
	# Initialize with Zero 
	HEALTH_COUNT = 0 # Clear Prev Health COunt
	
	for i in hp_child:
		if i is Tween:
			pass
		if i is TextureRect :
			if i.visible == true: # Counts Only Visible Heart Boxes
				HEALTH_COUNT +=1
			if i.visible == false:
				HEALTH_LOST +=1
		else:
			pass
	#print_debug("Heart Count Debug: ",HEALTH_COUNT)
	return HEALTH_COUNT


# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp : int):
	# Buggy Logic
	print_debug("Health Change Function Called: ", new_hp)
	
	# Update THe Heart COunt Variables
	get_heart_count() # -1 for The unimplemented Empty Heart Scene & tween node
	
	if new_hp == 0:
		# Hide The Last Heart If Player Life Updates As Zero
		
		# Clears Children Nodes and hides the heart instance for duplicating
		
		#h2.queue_free()
		#h3.queue_free() # Code Breaks Here
		heart_instance.hide()
	
	# If THe Plaer HP is THe same As The current Viible Hearts on Screen Return
	# It is a Guard Clause
	if new_hp == HEALTH_COUNT:
		return
	
	"""
	HEALTH INCREASE Logic
	"""
	# To Do : Implement Tweening for animation
	
	# Health Increase past 3 with No Health Lost
	if new_hp > HEALTH_COUNT && HEALTH_LOST == 0 :
		var hearts_to_add = new_hp - HEALTH_COUNT # get the difference
		# Debug the difference and show HP
		print_debug("health Box Increase 111: ", hearts_to_add)
		
		# Run A Recursive Loop TO Duplicate Additional Hearts
		for i in hearts_to_add:
			var t = h3.duplicate()# HeartScene.instance()
			self.call_deferred("add_child", t)
			#self.add_child(t)
	
	# Health Increase past 3 with Some Health Lost
	if new_hp > HEALTH_COUNT && HEALTH_LOST > 0 :
		var hearts_to_add = new_hp - HEALTH_COUNT # get the difference
		# Debug the difference and show HP
		print_debug("health Box Increase222 : ", hearts_to_add)
		
		# Run A Recursive Loop TO Duplicate Additional Hearts
		for i in hearts_to_add:
			#self.get_child(hearts_to_add).show() # get a child and show it
			HEALTH_LOST =-1
			for u in self.get_children():
				u.show()
	"""
	HEALTH DECREASE Logic
	"""
	
	# Health Decrese
	# State : Works
	
	# If The New Health is Lower Than THe Current Health Count
	if new_hp < HEALTH_COUNT:
		var _to_remove_hearts = HEALTH_COUNT - new_hp
		
		# Recursively HIde all heart childern
		while (_to_remove_hearts > 0):
			self.get_child(_to_remove_hearts).hide()
			_to_remove_hearts -= 1
			HEALTH_LOST +=1 # Increase THe health lost variable
			
	
	# Debug Heart Update
	#print_debug("Heart Update Debug: ", (self.get_child_count() -2), "/", "New HP : ",new_hp)



