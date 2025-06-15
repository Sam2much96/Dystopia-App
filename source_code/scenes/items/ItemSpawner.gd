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
# (1) Spawns an item most of the time. It's spawn function should be more randomized (VRF?)
# (2) 

# Goals:
# (1) It makes the player work harder
# (2) It makes the Player follow goals that improve the game state
# *************************************************

extends Position2D

class_name itemSpawner

"""
Add this to any node. spawn instances an Item.tscn node with the defined values
"""
#rewrite code to load from inspector tab
#add multiple instances for weapons, xtra health and generic stuff

export (PackedScene) var spawn_1
export (PackedScene) var spawn_2
export (PackedScene) var spawn_3
export (PackedScene) var spawn_4
export (PackedScene) var spawn_5
export (PackedScene) var spawn_6
export (PackedScene) var item_scene  #use export packed scene
#export(String) var item_type = "Generic Item"
export(int) var amount = 1

export (bool) var random_spawn
onready var spawn_ : Array = [spawn_1,spawn_2,spawn_3, spawn_4, spawn_5, spawn_6]

#func _ready():
#	if random_spawn == false:
#		print_debug ('loading default item/ Default item: ',item_scene)


func spawn(): #organize this code to switch btw random spawn and single spawn
	if random_spawn == false: # reduncancy code for item spawner
		if item_scene == null:
			push_error('default spawn item cannot be null')
			item_scene= load("res://scenes/items/Item.tscn")
		
	if random_spawn == true:
		#_spawn.shuffle()
		item_scene = Music.shuffle_array(spawn_)#_spawn.pop_back()
	
	# instance the item scene
	var _item = item_scene.instance() 
	
	owner.get_parent().call_deferred("add_child", _item)
	_item.global_position = global_position
	#_item.item_type = _item
	
	'Exempts Coin from Amount changes'
	if not _item.name == 'coins':
		_item.amount = amount
	return 0
