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

var inventory : Dictionary = {}

# Create Pointers to Stats and Quests HUD
var _stats_ui #: Stats 


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
func remove_item(type:String, amount:int) -> bool:
	if inventory.has(type) and inventory[type] >= amount:
		inventory[type] -= amount
		if inventory[type] == 0:
			inventory.erase(type)
		emit_signal("item_changed", "removed", type, amount)
		return true
	else:
		return false
	pass

"RETURNS A DUPLICATE OF THE INVENTORY DICTIONARY"
func list() -> Dictionary:
	return inventory.duplicate()


"""
STATS UI
"""
func  placeholder(item):
	print_debug("Inventory button pressed", item)
	# Testing Inventory UI
	remove_item(item,1)
