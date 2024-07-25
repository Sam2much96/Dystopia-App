# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Inventory Singleton
# Saves and Manipulates Item Objects Within the Scene Tree
# Features:
#(1) Saves Itself and it's count to a .json save file via the Globals save() and load() functions
#(2) Records all nodes in the Items group and stores a copy of them
#(3) Interracts with the Items node at res://scenes/items/Item.tscn
#(4) Interracts with the Quest singleton at res://singletons/Quest.gd
# *************************************************
# To do:
# (1) Update
# (2) Documents Functions 
# *************************************************



extends Node


class_name Storage

"""
Minimal inventory system implementation. 
It's just a dictionary where items are identified by a string key and hold an int amount
"""

# action can be 'added' some amount of some items is added and 'removed' when some amount
# of some item is removed
signal item_changed(action, type, amount)

@export var inventory : Dictionary = {}


# Inventory Buffer for Multuiplayer

var buffer : Dictionary = {
	Generic_Item : 0,
	Magic_Sword : 0,
	health_potion : 0,
	Bomb : 0,
	Arrow : 0,
	Bow : 0
}
# Create Pointers to Stats and Quests HUD
var _stats_ui #: Stats 


# Intanciable items
@onready var bullet : PackedScene = preload("res://scenes/items/Bullet.tscn")
@onready var bomb_explosion : PackedScene = preload("res://scenes/items/bombexplosion.tscn")

# Hard COding Items for 
# items
enum {Generic_Item, Magic_Sword, health_potion, Bow, Arrow, Bomb}


"""
CHECKS IF THE INVENTROY HAS AN ITEM
"""
func get_item(type:String) -> int:
	if inventory.has(type):
		return inventory[type]
	else:
		return 0
	pass


"""
ADDS ITEMS TO THE INVENTORY DICTIONARY
"""
# TO DO : Modify to store inventory items with enums rathewr than string keys() for multiplayer
func add_item(type:String, amount:int) -> bool:
	if inventory.has(type):
		inventory[type] += amount
		emit_signal("item_changed", "added", type, amount)
		return true
	else:
		inventory[type] = amount
		emit_signal("item_changed", "added", type, amount)
		return true

"""
REMOVES ITEMS FROM THE INVENTORY DICTIONARY
"""
# Logic : Uses INventory keys as a parameter
func remove_item(type:String, amount:int) -> bool:
	# Refactor remove item to connect to Stats amd Update properly
	#print_debug("Inventory button pressed", type, amount)
	
	
	
	Music.play_track("res://sounds/item_collected.ogg")
	var player = get_tree().get_nodes_in_group("player")[0] 
	
	if inventory.has(type) and inventory[type] >= amount:
		inventory[type] -= amount
		
		_stats_ui._update_inventory_button_cache(type, amount) # Testing Functions
		
		if inventory[type] == 0:
			inventory.erase(type)
		emit_signal("item_changed", "removed", type, amount)
		
		"Logic Implementation for Diffenent Item Types"
		# Item Implementation
		# There's 4 Inventory Items implemented
		# (1) health potion
		# (2) Generic Item
		# (3) Magic Sword
		# (4) Bomb
		# (5) Arrow
		# (6) Bow
		if type == "health potion":
		
			#print("aksdfjabnfo;giSHip")
			
			# Update player object body
			player.hitpoints += 1
			
			# emit signal
			player.emit_signal("health_changed", player.hitpoints)
		
		if type == "Generic Item":
			# increases player speed and attack power
			player.WALK_SPEED += 250
			player.ROLL_SPEED += 400
			player.ATTACK = 2
		
		if type == "Magic Sword":
			# increase pushback impact, increases chances of double attack
			player.pushback = 8000
		
		if type == "Bomb":
			var bomb_instance = bomb_explosion.instance()
			
			#if is_instance_valid(bomb_instance) : # Error Catcher 1
			
			# set bom instance position
			bomb_instance.position = player.position
			
			player.get_parent().call_deferred("add_child",bomb_instance)
			
			print_debug("bomb debug: ",bomb_instance)
			
		if type == "Arrow" and  inventory.has("Bow"):
			
			
			var bullet_instance = bullet.instance()
			
			
			# rotate the projectile instance to player's facing direction
			bullet_instance.position = player.position
			
			#player.add_child(bullet_instance)
			player.get_parent().call_deferred("add_child",bullet_instance)
			
			bullet_instance.facing = player._facing 
			print_debug("arrow instance : ", bullet_instance)
			
			#return
		return true
	else:
		return false
	pass

"RETURNS A DUPLICATE OF THE INVENTORY DICTIONARY"
func list() -> Dictionary:
	return inventory.duplicate()

"RETURNS A DUPLICATE OF THE INVENTORY DICTIONARY AS A JSON STRING"
func jsonify() -> String:
	#
	var inv : String = JSON.stringify(inventory.duplicate())
	return inv


func _get_inventory_buffer() -> String:
	# Converts String Dictionary to Integer DIctionary as Data Optimization
	
	for i in inventory.keys(): 
		if i == "Generic Item":
			buffer[Generic_Item] = inventory["Generic Item"]
		if i == "health potion":
			buffer[health_potion] = inventory["health potion"]
		if i == "Magic Sword":
			buffer[Magic_Sword] = inventory["Magic Sword"]
		if i == "Bomb":
			buffer[Bomb] = inventory["Bomb"]
		if i =="Arrow":
			buffer[Arrow] = inventory["Arrow"]
		if i == "Bow":
			buffer[Bow] = inventory["Bow"]
	
	var inv : String = JSON.stringify(buffer.duplicate())
	return inv

	
