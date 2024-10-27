# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Status Text
# Shows Updats on the Player's Status Changes
# Features:
# (1) Connects to methods on the Quest and Inventory singletons

# Bugs:
# (1) Doesn't Display Text
# (2) Display Doesn't Adapt for Mobile Screens and PC Screen s
# 

# To Do:
#(1) Fix Bugs
# *************************************************


extends Label


class_name StatusText

"""
Connects to the inventory and quest systems and will show a message on screen
for every change in either
"""

var messages : Array = []

#var nodes : Array = [self]

onready var anims : AnimationPlayer = $anims
func _enter_tree():
	# Make GLobal
	GlobalInput._Status_text = self


func _ready():
	
	# connect Signals
	# Connects to Both Quest and Item Singleton
	Quest.connect("quest_changed", self, "_questlog_updated")
	
	# Inventory to Status Text
	# Item changed signals contain parameters
	Inventory.connect("item_changed", self, "_inventory_updated")
	
	#Debug Signals
	print_debug(
		Inventory.is_connected("item_changed", self, "_inventory_updated"), 
		Quest.is_connected("quest_changed", self, "_questlog_updated")
		)
	
	
	#Dialogs.set_font(nodes, 42, "", 4)
	hide()
	
	
	# Connects to Both Quest and Item Singleton
	# Refactored to Game HUD Parent
	#Quest.connect("quest_changed", self, "_questlog_updated")
	#Inventory.connect("item_changed", self, "_inventory_updated")


# Quests
func _questlog_updated(quest_name, status):
	var txt : String
	match status:
		Quest.STATUS.STARTED:
			txt = "Quest aquired: %s." % quest_name
		Quest.STATUS.COMPLETE:
			txt = "Quest complete! %s." % quest_name
	
	# Print a translated version of this text for debugging
	_queue_message(txt)
	pass

# Inventory
func _inventory_updated(action : String, type: String, amount : int):
	# Change status text font
	
	var txt : String

	var _type : String = Dialogs.translate_to(type , Dialogs.language)
	
	
	match action:
		"added":
			var obtained : String = Dialogs.translate_to("Obtained", Dialogs.language)
			
			txt = "%s  %s x %s" % [obtained,_type, amount]
		"removed":
			
			var lost : String = Dialogs.translate_to("Lost", Dialogs.language)
			txt =  "%s %s x %s" % [lost,_type, amount]
	# Print a translated version of this text for debugging 
	
	#++Dialogs.translate_to(i.name, Dialogs.language)
	_queue_message(txt)


func _queue_message(text):
	messages.push_back(text)
	if not anims.is_playing():
		_play_next()


func _play_next():
	if messages.empty():
		return
	else:
		text = messages.pop_front()
		anims.queue("update")
