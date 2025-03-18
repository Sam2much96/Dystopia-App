# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Grass
# SHared COnde Between Grass/Flower Objects Within the Scene Tree
# Features:
# 
# (1) Uses List comparison to detect and Destroy self when colliding with pre-saved area name
# (2) Implements Item Spawner Spawn method when destroyed
# (3) Code Base is factored into an Aniamation State Machine form factor
# (4) Shares code base and scene structure with Flowers.tscn and Grasses.tscn

# To Do:
#(0) Refactor codebase into Animation Player implementation (1.3)
#(1) Make translucient (Done)
#(2) Should only run shader once interracting with either player or enemy (optimization)
# (3) Optimize Ram for Mobile and PC(1/2)
		# Lots of Detection going on in this node from every collision object (2/2)
		# Fix: Implement Layers and Layer masks (Not Needed)
# (4) Fix all duplicate Code (Done)
# (5) Animation States for Optiimization
# (6) Mobile Optimization & Debugging
# *************************************************

extends Area2D
#export var debug : bool

class_name grass

onready var nodeName : String = self.get_name() 

onready var timer : Timer = $Timer
onready var anim : AnimationPlayer = $AnimationPlayer

onready var item_spawner :itemSpawner = $itemSpawner

#List of Aread 2D groups that can destroy this node

var list: Array = ["player_sword", "enemy_sword"] 

var similar_names : Array = [] #list comparer

onready var _music_singleton = get_node_or_null("/root/Music")
onready var _grass_sfx : String = _music_singleton.grass_sfx.get(0)

func _ready():
	#anim.play("idle",-1,1.0,0.0) 
	
	# Connect Signls
	if not (is_connected("area_entered", self, "_on_grass_area_entered") 
	):
		connect("area_entered", self, "_on_grass_area_entered")
	
	if not (is_connected("area_entered", self, "_on_flowers_area_entered")
	):
		connect("area_entered", self, "_on_flowers_area_entered")
	
	# Debug Signals
	
	#print_debug(
	#	is_connected("area_entered", self, "_on_grass_area_entered"),
	#	is_connected("area_entered", self, "_on_flowers_area_entered")
	#	)
	
	timer.connect("timeout", self, "_queue_free")
	
	
	
"""Destroys the Grass when it's Attacked by Either Player or Enemy Sword collision"""
# The collision layer and mask settings also ensure this outcome
#************TO MUCH DETECTION**************#

func _on_grass_area_entered(area):
	# Stores an Array of all objects colliding with grass object
	update_collision_list(area.name)
	
	
	_destroy_if(similar_names)


func _destroy_if (area: Array)-> void: # Works
	for p in area:
		if list.has(p):
			anim.play("destroy")
			
			
			_music_singleton.play_track(_grass_sfx)
			
			debug_grass(p) # for debug purposes only

func idle()-> void:
	anim.play("idle")

func move()-> void:
	anim.play("move")


func set_timer(time: int)->void:
	timer.one_shot = true
	timer.autostart = true
	timer.start(time)


func _on_flowers_area_entered(area):
	update_collision_list(area.name) 
	_destroy_if(similar_names)


func update_collision_list( area : String)-> void:
	
	
	if not similar_names.has(area):
		similar_names.append(area)
	elif similar_names.has(area):
		pass

func debug_grass( area_name : String)-> void: 
	print_debug (area_name+' cuts ' + nodeName, "/",similar_names)
	#print (similar_names) #list of all objects grass and flower nodes collide with

func destroy():
	# Exported Destroy FUnction for Scenetree Objects
	anim.play("destroy")

	_music_singleton.play_track(_grass_sfx)

func _auto_delete():
	# An Autodelete method called in the Destroy Animation as an animated function
	self.queue_free()

