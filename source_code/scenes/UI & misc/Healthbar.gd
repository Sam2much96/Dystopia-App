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
# (2) Does'nt scale well on Mobile Devices (Fixed)
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
onready var heart_empty : TextureRect #= $heart_empty #: PackedScene = preload ("res://scenes/UI & misc/HeartEmpty.tscn")

const MAX_HEALTH = 23 # Max Health Constant

export (int) var HEALTH_COUNT : int = 0
export (int) var HEALTH_LOST : int = 0 # Use

# Placeholder HeartBox
onready var h2 : TextureRect = $heart2
onready var h3 : TextureRect = $heart3


onready var placeholder_hearts : Array = [h2,h3] # For Holding memory pointer to the placeholder heartb
onready var additional_hearts : Array 

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
		
		if i is TextureRect :
			if i.visible == true: # Counts Only Visible Heart Boxes
				HEALTH_COUNT +=1
			if i.visible == false:
				HEALTH_LOST +=1
		if i is Tween: # unused tween animation node for healthbar anims
			pass
		else:
			pass
	#print_debug("Heart Count Debug: ",HEALTH_COUNT)
	return HEALTH_COUNT


func _on_health_changed(new_hp: int):
	push_warning("Health Change Function Called: "+  str(new_hp))
	
	# Update Heart Count Variables
	get_heart_count()
	
	# If health is 0, hide all hearts
	if new_hp == 0:
		heart_instance.hide()
		h2.hide()
		h3.hide()
		return
	# If health is 1, hide all hearts
	if new_hp == 1:
		heart_instance.show()
		h2.hide()
		h3.hide()
		return
	if new_hp == 2:
		heart_instance.show()
		h2.show()
		h3.hide()
		return
	if new_hp == 3:
		heart_instance.show()
		h2.show()
		h3.show()
		for i in additional_hearts:
			i.hide()
		
		#Utils.MemoryManagement.queue_free_array(additional_hearts)
		return
	
	
	# Guard Clause: If new health equals current heart count, return
	if new_hp == HEALTH_COUNT:
		return
	
	"""
	HEALTH INCREASE Logic
	"""
	# Health Increase past 3 with No Health Lost
	if new_hp > HEALTH_COUNT and HEALTH_LOST == 0:
		var hearts_to_add = new_hp - HEALTH_COUNT  # Get the difference
		print_debug("Health Box Increase 111: ", hearts_to_add)

		# Add additional hearts
		for _i in range(hearts_to_add):
			var new_heart = h3.duplicate()
			additional_hearts.append(new_heart)
			#self.call_deferred("add_child", new_heart)

	# Health Increase past 3 with Some Health Lost
	elif new_hp > HEALTH_COUNT and HEALTH_LOST > 0:
		#print(111111)
		var hearts_to_restore = min(new_hp - HEALTH_COUNT, HEALTH_LOST)
		print_debug("Restoring Hidden Hearts: ", hearts_to_restore)

		for child in self.get_children():
			if hearts_to_restore > 0 && child is TextureRect && !child.visible:
				child.show()
				hearts_to_restore -= 1
				HEALTH_LOST -= 1

		# If there are still more hearts to add after restoring hidden ones
		var extra_hearts_needed = new_hp - (HEALTH_COUNT + hearts_to_restore)
		print_debug("Additional Hearts to Add: ", extra_hearts_needed)

		for i in range(extra_hearts_needed):
			var new_heart = h3.duplicate()
			self.call_deferred("add_child", new_heart)

	"""
	HEALTH DECREASE Logic
	"""
	if new_hp < HEALTH_COUNT:
		var to_remove_hearts = HEALTH_COUNT - new_hp
		
		while to_remove_hearts > 0:
			for child in self.get_children():
				if child is TextureRect and child.visible:
					child.hide()
					HEALTH_LOST += 1
					to_remove_hearts -= 1
					break  # Ensure only one heart is hidden per loop iteration

