# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is the random item spawner script
# information used by the enemy and player nodes .
# Features
# (1) Spawns an item randomly
# To do
# (1) Random spawn function
# Bugs
# (1) Spawns an item most of the time. It's spawn function should be more randomized
# (2) Shuffle Code is buggy

# Goals:
# (1) It makes the player work harder
# (2) It makes the Player follow goals that improve the game state
# *************************************************

extends Marker2D

class_name itemSpawner

"""
Add this to any node. spawn instances an Item.tscn node with the defined values
"""
#rewrite code to load from inspector tab
#add multiple instances for weapons, xtra health and generic stuff

@export var spawn_1 : PackedScene
@export var spawn_2 : PackedScene
@export var spawn_3 : PackedScene
@export var spawn_4 : PackedScene
@export  var spawn_5 : PackedScene
@export  var item_scene : PackedScene #use export packed scene
#export(String) var item_type = "Generic Item"
@export var amount: int = 1

@export var random_spawn : bool
@onready var _spawn : Array = [spawn_1,spawn_2,spawn_3, spawn_4, spawn_5]

func _ready():
	if random_spawn == false:
		print('loading default item')
		print ('Default item: ',item_scene)


func spawn(): #organize this code to switch btw random spawn and single spawn
	if random_spawn == false:
		if item_scene == null:
			push_error('default spawn item cannot be null')
			item_scene= load("res://scenes/items/Item.tscn")
		
	if random_spawn == true:
		_spawn.shuffle()
		item_scene = _spawn.pop_back()
	
	# instance the item scene
	var _item = item_scene.instantiate() 
	
	owner.get_parent().call_deferred("add_child", _item)
	_item.global_position = global_position
	#_item.item_type = _item
	
	'Exempts Coin from Amount changes'
	if not _item.name == 'coins':
		_item.amount = amount
	return 0
