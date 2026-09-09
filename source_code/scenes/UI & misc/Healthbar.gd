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

# Last hitpoint value the bar was drawn for. -1 = nothing drawn from live data yet,
# so the three placeholder hearts from Healthbar.tscn stay until the player spawns.
var _rendered_hp : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	# ( issue #80 / #106 ) The old _ready() was fully commented out, so the health bar
	# was never connected to the player and never updated. Player.gd keeps
	# Globals.player_hitpoints in sync on every hit, so poll that each frame - the
	# same approach minimap.gd uses to follow the player. This also works for the
	# networked player, which updates the same global.
	pass

func _process(_delta):
	var hp : int = Globals.player_hitpoints
	if hp == _rendered_hp:
		return
	# Ignore the pre-spawn state (hp still 0) so the placeholder hearts are not
	# wiped before the player exists; once a real value has shown, hp 0 (death)
	# is honoured and clears the bar.
	if hp <= 0 and _rendered_hp <= 0:
		return
	_rendered_hp = hp
	_on_health_changed(max(hp, 0))

# Should Implement a New Constant for Max Health
func _on_health_changed(new_hp : int):
	
	# Clears Previous HP
	for child in get_children():
		child.queue_free() #removes life
	
	if not new_hp > MAX_HEALTH:
		# Creates New Heart Instate From Updatesd HP
		# inefficient code
		for i in new_hp:

			var heart = heart_instance.instantiate()

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
