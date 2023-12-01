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
# TO-DO:
# 
# (1) Scrolling Inbentory Menu refactor (Utils.gd)
# (2) Should AutoScale to Screen Display size using Global screen calculation functions
# (3) Inventory Items Should be more Accessible
# (4) Implement Character Customization UI (1/2)
# (5) 
# (6) Implement Tab Icons
# (7) Item Button should ideally be low poly texture buttons

# *************************************************

extends PanelContainer

class_name Stats

export (bool) var enabled
signal not_enabled
signal enabled

onready var scroller : ScrollContainer = $ScrollContainer # Depreciated

#Quest Parent Node Pointer
onready var _inventory_parent : VBoxContainer = $TabContainer/Inventory/ScrollContainer3/VBoxContainer

# Inventory Parent Node
onready var _inventory_parent_label : Label = $TabContainer/Inventory/ScrollContainer3/VBoxContainer/Title2

# Inventroy Parent Button
onready var _inventory_button : Button = $TabContainer/Inventory/ScrollContainer3/VBoxContainer/Inventory


onready var _coin_label : Label = $TabContainer/Wallet/Algos
onready var _quest_label : Label = $TabContainer/Quests/ScrollContainer2/VBoxContainer/Quests

# Pointer to Inventory Singleton
onready var _inventory : Storage = get_tree().get_root().get_node("/root/Inventory")

# Pointer to GLobal Touch HUD

# Array  pointer containing all QUest parent childeren
# Should be a dictionary
onready var _stats_buttons : Array = []



enum {ENABLED, DISABLED, NULL}

export (int) var _state = DISABLED

func _ready():
	self.get_child(0)
	
	#Globals.save_game() # Depreciated
	get_tree().set_auto_accept_quit(false)
	hide()
	
	# Make self global 
	_inventory._stats_ui = self



func _input(event):
	
	 #Toggles menu visibility on/off
	#if !enabled && event.is_action_pressed("pause") or GlobalInput._state == GlobalInput.PAUSE :# 
	#	print("dfhhsghsdgh") # works
	#	if _state == DISABLED:
	#		#print ("sjnsoni0ij")
	#		_state = ENABLED
	#		#set_focus_mode(Control.FOCUS_CLICK)
	#		Music.play_track(Music.ui_sfx[0])
	#		print ("Stats State: ", _state) #For debug purposes only
	#		
	#		return _state
	#if enabled && event.is_action_pressed("pause") or GlobalInput._state == GlobalInput.PAUSE :
	#	print("skgn[gfi[0ij[i]]]")
	#	if _state == ENABLED:
	#		_state = DISABLED
	#		Music.play_track(Music.ui_sfx[1])
	#		print ("Stats State: ", _state) #For debug purposes only
	#		#Globals.Screen.debug_screen_properties()# Debug Screen Settingd
	#		
	
	# Enable / DIsable Logic is Buggy
	if event.is_action_pressed("pause")  && enabled == false:
		print("enable")
		enabled = true
		_enable()
	#	#_state = ENABLED
		Music.play_track(Music.ui_sfx[0])
		return enabled # _state
	if event.is_action_pressed("pause") && enabled == true:
		enabled = false
		_disable()
	#	#_state = DISABLED
		print("disable")
		Music.play_track(Music.ui_sfx[1])
		return enabled #_state
#

# Depreciated State Machine
#func _process(delta):
#	pass



func _update_wallet_stats(): #Updates killcount and Algos
	_coin_label.text = 'mAlgos: ' + str (Globals.algos)


func _update_quest_listing():
	# DOcument and refactor
	
	var text = ""
	text += "Started:\n"
	for quest in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % quest
	text += "Failed:\n"
	for quest in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % quest
	
	_quest_label.text = text
	#pass

func _update_inventory_button_cache() -> bool: # REmove this code bloc
	# 
	# What does this code bloc do?
	# Code Bloc is meant to update a pointer containing all Inventory items buttons and their related ammount
	# This pointer is used to optimize a psudo-sorting algorithm needed for the Stats UI 
	# To create inventroy items as buttons
	# Ideally these buttons should be a texture reat with a number ount labeel, but that'll be for a later refactor
	for _nodes in _inventory_parent.get_children():
		if not _stats_buttons.has(_nodes):
			_stats_buttons.append(_nodes)
			print_debug(_stats_buttons)
			print_debug(_inventory_parent)
			return true
		else: 
			return false
	return false


func _update_inventory_listing():
	"Inventory UI Logic"
	# Refactoring?
	
	# Updates the Inventroy Button with the Items the Player holds
	# Note: As the Number of Items grow, inventory might require a more encompassing method && UI
	var text : String = ""
	var inventory : Dictionary = _inventory.list()
	var _inventory_size : int = inventory.size()
	
	#print_debug("Inventory Size Debug : ", _inventory_size) # For Debug Purposes only
	
	_update_inventory_button_cache() # Buggy Functions
	
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
					new_item_button.connect("pressed", _inventory, "placeholder",[item]) # button presses 
					
					# Create a pointer to Inventory ui buttons
					_stats_buttons.append(new_item_button)
					#print_debug("Inventory Stats Debug: ", _stats_buttons) # For Debug Purposes only
			else : pass


func _notification(what):  #Triggered when the Min Game Loop is exited
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print_debug("STATUS NOTIFICATION")



func _on_status_showing():
	# upadate inventory button lising
	#_update_inventory_button_cache() #  Depreciated Buggy NFT
	
	#resets Mobile Touch HUD
	GlobalInput.TouchInterface.status()
	
	print_debug("TC Status:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status hidden') #for debug purposes

func _on_status_hidden():
	# shows status UI only
	GlobalInput.TouchInterface.status()
	print_debug("TC hidden:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status showing')



func equip(_item):
	# Placeholder method for Triggering an Equip method on the Player Script of an Inventroy Oject 
	pass


func _enable():
	enabled = true
	visible = enabled
	emit_signal('enabled')
	Music.play_track(Music.ui_sfx[0])
	get_tree().paused = enabled
	
	"Mobile HUD Controller"
	if is_instance_valid(GlobalInput.TouchInterface):
		print_debug("Touch HUD Instance valid")
		GlobalInput.TouchInterface.status()
		#"Grab Focus ?"
		#grab_focus()
		#asasfghafhd
		_update_quest_listing()
		_update_inventory_listing() # Refactor
		_update_wallet_stats()
	print(self.name, "disabled") # For debug purposes only

func _disable():
	enabled = false
	visible = enabled
	emit_signal("not_enabled")
	Music.play_track(Music.ui_sfx[1])
	hide()
	get_tree().paused = false
	print (self.name, "enabled") # For debug purposes only
