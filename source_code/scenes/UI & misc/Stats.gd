# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Stats
# Updates Game Stats to the UI.
# Displays Quest and Inventory INformation to the Player
# currenty updates quests, Killcount and Algos
# Features
# (1) Parses Quest Data from Singleton
# (2) Controls Touch HUD
# (3) Connects Inventory Buttons to inventory singleton on line 215
# (4) Serialised Quest Status to Users
# *************************************************
# TO-DO:
# 
# (1) Scrolling Inbentory Menu refactor (Utils.gd)
# (2) Should AutoScale to Screen Display size using Global screen calculation functions
# (3) Inventory Items Should be more Accessible
# (4) Implement Character Customization UI (1/2)
# (5) 
# (6) Implement Tab Icons with code (1/2)
#		-(a) Done with TabIcon Subclass
# (7) Item Button should ideally be low poly texture buttons (1/2)
#
# *************************************************
# Bugs:
# (1) Regex For Inventroy Update is buggy
# 
# *************************************************

extends PanelContainer

class_name Stats

export (bool) var enabled
signal _not_enabled
signal _enabled

# Signals TO Connect To Android SIngleton For Controulling Touch HUD (Done)
#signal status_hidden
#signal status_showing

# Pointers to Tab Containers for icon implementation
var tab_container : TabContainer

#onready var scroller : ScrollContainer = $ScrollContainer # Depreciated

# Quest Parent Node Pointer
# Vbox Containter Containing all Inventory Items as children
var _inventory_parent : VBoxContainer 

# Inventory Parent Node
var _inventory_parent_label : Label 

# Inventroy Parent Button
var _inventory_button : Button 


var _coin_label : Label 
var _quest_label : Label
var _price_label : Label
# Backup Pointer to Inventory Singleton
onready var _inventory = get_tree().get_root().get_node("/root/Inventory")

# Pointer to GLobal Touch HUD

# Array  pointer containing all QUest parent childeren
# Should be a dictionary
var _stats_buttons : Array = []

var _Stats_UI_Elements : Array = []

# Mini Map
var _Mini_map : minimap 


# For Inventory Update
var regex : RegEx = RegEx.new()

enum {ENABLED, DISABLED, NULL}

export (int) var _state = DISABLED

onready var local_networking : Internet = get_node("/root/Networking")




func _ready():
	
	# Get UI Node Pointer
	_Mini_map = $"%minimap"
	_quest_label = $"%Quests"
	_coin_label = $"%Sud"
	_price_label = $"%price"
	_inventory_button = $"%Inventory"
	_inventory_parent_label = $"%Title3"
	tab_container = $TabContainer
	_inventory_parent = $"TabContainer/3/MarginContainer/ScrollContainer3/VBoxContainer"
	
	# Check That THe UI Nodes are OK
	_Stats_UI_Elements = [
		_Mini_map, _quest_label, _coin_label,_price_label, 
		_inventory_button, _inventory_parent_label,
		tab_container, _inventory_parent
	]
	
	
	Utils.UI.check_for_broken_links(_Stats_UI_Elements)
	

	hide()
	
	# Make self global 
	# uses setter and getter functions for proper code handling 
	Inventory.stats_ui = self
	GlobalInput.Stats_ = self
	
	#Regex for Inventory Update
	regex.compile("(\\d+)")
	
	# Set Tab Icons via SUbclass Script
	tab_container.set_script(TabIcons)
	
	
	# Fetch price data once ready
	# 
	#local_networking._check_connection("https://free-api.vestige.fi/asset/2717482658/price" , local_networking) #
	Networking._check_connection("https://free-api.vestige.fi/asset/2717482658/price" , Networking) #

func _input(event):
	"Status UI Visibility Is Entirely Self Controlled From Here"
	
	# Satus UI Only Listens to The Pause Input
	if not event.is_action_pressed("pause"): # Guard Clause
		return 
		
	# Enable / DIsable Logic is Buggy
	if event.is_action_pressed("pause")  && enabled == false:
		print_debug("enable")
		enabled = true
		_enable()
		return enabled 
	if event.is_action_pressed("pause") && enabled == true:
		enabled = false
		_disable()

		print_debug("disable")
		return enabled





func _update_wallet_stats(): #Updates killcount and Algos
	"Update Price From Vestigefi API"
	

	
	if Networking.good_internet:
		_coin_label.text = 'Suds: ' + str (Globals.suds)
		_price_label.text =  str(Networking.Data) # fetchs price data from Sud token


func _update_quest_listing():
	# Prints Out the Quest Database from save game 
	# and serialises them based on their enumeration value
	# TO DO: serialise output to prettier UI
	
	var text = ""
	text += "Started:\n"
	for i in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % i #print as a string and create a new line
	text += "Failed:\n"
	for p in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % p #print as a string and create a new line
	text += "Finished:\n"
	for j in Quest.list(Quest.STATUS.COMPLETE):
		text += "%s\n" % j #print as a string and create a new line
	
	_quest_label.text = text


# Connects to Inventory.remove item -> Stats.gd
func _update_inventory_button_cache(item : String, amount : int) : # COde Bloc Called from inventroy singleton remove_item() method
	# 
	# 
	# Code Bloc is meant to update a pointer containing all Inventory items buttons and their related ammount
	# This Code Bloc is used to optimize a psudo-sorting algorithm needed for the Stats UI 
	# 
	# Ideally these buttons should be a texture reat with a number ount labeel, but that'll be for a later refactor
	
	var result
	
	for i in _inventory_parent.get_children(): # Nested Bloc?
		if i is Label:
			pass
		if i is Button:
			
			# look for the particular Inventory Button 
			if i.name == item:
			
				# Returns the item count for each Inventory Item
				result = regex.search(i.text)
			
				if result:
					#print_debug(i.text) # for debug purposes only
					
					i.set_text("%s x %s\n" % [i.name, int(result.get_string()) - amount])
				
				#print_debug("%s x %s\n" % [i.name, result.get_string()]) # for debug purposes only


func _update_inventory_listing():
	"Inventory UI Logic"
	# Refactoring?
	
	# Updates the Inventroy Button with the Items the Player holds
	# Note: As the Number of Items grow, inventory might require a more encompassing method && UI
	var text : String = ""
	var inventory : Dictionary = _inventory.list()
	var _inventory_size : int = inventory.size()
	
	#print_debug("Inventory Size Debug : ", _inventory_size) # For Debug Purposes only
	
	# add COnditional for if quest parent has inventory item to avoid dupliucation bug
	# it'll compate an array of the button names to check if it is already created
	# if created pass, if not , update inventory listing
	
	if inventory.empty():
		text += "[Empty]"
		_inventory_button.text = text
	
	elif not inventory.empty() && _inventory_size >= 1 :
		
		if inventory.size() == 1: # Works
			for item in inventory:
				if not _stats_buttons.has(str(item)):
					text = "%s x %s\n" % [item, inventory[item]]
					_inventory_button.text = text
					pass
		
		if _inventory_size > 1 :
			
			if not _stats_buttons.size() > _inventory_size : # Buggy Conditional
			
			
				# Bugs: 
				# (1) Only Uses the first item in t he inventory dictionary sometimes
				# (2) Duplicates the number of items everytime (2/3)
				# (4) Items of same type repeat themselves
				# (5) Doesnt Reflect Item Current Count
				
				
				# Add Conditionals
				#print_debug("Item Debug: ", item) # For Debug Purposes only
				for item in inventory:
				
					# DUplicates button using instancing
					# Item Button should ideally be low poly texture buttons
					var new_item_button : Button = _inventory_button.duplicate(8) 
					
					
					#create new button object anbd or remove exisiting buttons if they exist
					_inventory_parent.add_child_below_node(_inventory_button, new_item_button)
					
					# connect signal
					
					# Sorts Items and the amount Into Individual Lines using REGEX
					text = "%s x %s\n" % [item, inventory[item]]
					
					# set each item button Text to their corresponding item 
					new_item_button.text = text
					new_item_button.name = str(item)
					
					# connect button to inventory singleton method
					#
					new_item_button.connect("pressed", _inventory, "remove_item",[item, 1]) # button presses 
					
					# Create a pointer to Inventory ui buttons
					_stats_buttons.append(new_item_button)
					#print_debug("Inventory Stats Debug: ", _stats_buttons) # For Debug Purposes only
			else : pass


func _notification(what):  #Triggered when the Min Game Loop is exited
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print_debug("STATUS NOTIFICATION")


# Debugging Status Signals
# Depreicated Signals

#func _on_status_showing():
#	# upadate inventory button lising
#	#_update_inventory_button_cache() #  Depreciated Buggy NFT?
#	
#	# Grab Focus
#	print_debug("2222222222222222")
#	
#	#resets Mobile Touch HUD
#	emit_signal("status_hidden") # SIgnals trigger opposite effect
#	#GlobalInput.TouchInterface.reset()
#	
#	#print_debug("TC Status:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
#	print_debug('status hidden') #for debug purposes

#func _on_status_hidden():
#	
#	# Ignore Inp
#	print_debug("11111111111")
#	# shows status UI only
#	# Buggy Method Triggers Status state on Mobile Devices
#	# TO DO: Implement In Android SIngleton
#	#GlobalInput.TouchInterface.status()
#	emit_signal("status_showing")
#	#print_debug("TC hidden:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
#	print_debug('status showing')
#	#print_stack()


func equip(_item):
	# Placeholder method for Triggering an Equip method on the Player Script of an Inventroy Oject 
	pass

"""
Enable And Disable Stats UI & CHildern
"""

func _enable():
	enabled = true
	visible = enabled
	emit_signal('_enabled')
	Music.play_track(Music.ui_sfx[0])
	get_tree().paused = enabled
	
	_update_quest_listing() # Refactor
	_update_inventory_listing() # Refactor
	_update_wallet_stats()
	print_debug("Stats UI Enabled") 

func _disable():
	enabled = false
	visible = enabled
	emit_signal("_not_enabled")
	Music.play_track(Music.ui_sfx[1])
	hide()
	get_tree().paused = false
	print_debug ("Stats UI disabled") # For debug purposes only
	#print_stack()

	#set_focus_mode(Control.FOCUS_NONE)
	
	# Ignore All Mouse UI Inputs WHen Hidden
	#set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
