# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Tab Icons
# 
#
# Features:
# (1) sets the tab icons in stats UI
# (2)
#
# *************************************************

extends TabContainer
class_name TabIcons 
# Code Called in the Tab conttainer child class
func _ready():
	# Should recursively set tab icons for Tab container child node
	print_debug("Setting Tab Icons")
	
	
	"Load IStats Icons"
	
	self.set_tab_icon(0,load("res://resources/misc/shield.webp")) # Sets index 0 tab icon to a shield texture
	self.set_tab_icon(1,load("res://resources/misc/wallet.webp")) # Sets index 0 tab icon to a wallet texture
	self.set_tab_icon(2,load("res://resources/misc/quest.webp")) # Sets index 0 tab icon to a quest texture
	self.set_tab_icon(3,load("res://resources/misc/inventory.webp")) # Sets index 0 tab icon to a quest texture
	self.set_tab_icon(4,load("res://resources/misc/char.webp")) # Sets index 0 tab icon to a quest texture
	
	
