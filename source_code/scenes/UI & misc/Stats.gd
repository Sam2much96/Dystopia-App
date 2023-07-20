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
#
# TO-DO:
# 
# (1) Scrolling Inbentory Menu (Done)
# (2) Should AutoScale to Screen Display size using Global screen calculation functions
# (3) Inventory Items Should be more Accessible
# (4) Implement Character Customization UI
# (5) Implement Tabbed VIew

# *************************************************

extends PanelContainer

class_name Stats

export (bool) var enabled = false
signal not_enabled
signal enabled

onready var scroller : ScrollContainer = $ScrollContainer # Depreciated

#Quest Parent Node Pointer
onready var _quest_parent : VBoxContainer = $TabContainer/Inventory/ScrollContainer3/VBoxContainer

# Inventory Parent Node
onready var _inventory_parent : Label = $TabContainer/Inventory/ScrollContainer3/VBoxContainer/Title2

# Inventroy Parent Button
onready var _inventory_button : Button = $TabContainer/Inventory/ScrollContainer3/VBoxContainer/Inventory


# Array  pointer containing all QUest parent childeren
onready var _stats_buttons : Array = []

func _ready():
	self.get_child(0)
	
	#Globals.save_game() # Depreciated
	get_tree().set_auto_accept_quit(false)
	hide()


func _input(event):
	"""
	UPDATES STATUS HUD ON PAUSE 
	"""
	if event.is_action_pressed("pause")  && enabled == false: #
		emit_signal("not_enabled")
		enabled = true
		visible = enabled
		
		# _update_inventory_button_cache()
		
		Music.play_track(Music.ui_sfx[0])
		get_tree().paused = enabled
		
		
		
		#TouchScreenHUD.status(Globals._TouchScreenHUD) #GameHUD already calls this method
		

		return enabled
		pass
	if event.is_action_pressed("pause") && enabled == true:
		enabled = false
		emit_signal('enabled')
		visible = enabled
		Music.play_track(Music.ui_sfx[1])
		hide()
		get_tree().paused = false
		#print (enabled)
		return enabled

	"Mobile HUD Controller"
	if enabled && is_instance_valid(Globals._TouchScreenHUD):
		Globals._TouchScreenHUD.status()
		"Grab Focus ?"
		#grab_focus()
		_update_quest_listing()
		_update_inventory_listing()
		_update_wallet_stats()



func _update_wallet_stats(): #Updates killcount and Algos
	$TabContainer/Wallet/Algos.text = 'mAlgos: ' + str (Globals.algos)


func _update_quest_listing():
	var text = ""
	text += "Started:\n"
	for quest in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % quest
	text += "Failed:\n"
	for quest in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % quest
	
	$TabContainer/Quests/ScrollContainer2/VBoxContainer/Quests.text = text
	pass

func _update_inventory_button_cache() -> bool:
	# save all UI stats Nodes to Array pointer
	for nodes in _quest_parent:
		if not _stats_buttons.has(nodes):
			_stats_buttons.append(nodes)
			return true
		else: 
			return false
	return false


func _update_inventory_listing():
	# Updates the Inventroy Button with the Items the Player holds
	# Note: As the Number of Items grow, inventory might require a more encompassing method && UI
	var text : String = ""
	var inventory : Dictionary = Inventory.list()
	var _inventory_size : int = inventory.size()
	
	#  _update_inventory_button_cache() # Bugg Functions
	
	# add COnditional for if quest parent has inventory item to avoid dupliucation bug
	# it'll compate an array of the button names to check if it is already created
	# if created pass, if not , update inventory listing
	
	if inventory.empty():
		text += "[Empty]"
		_inventory_button.text = text
	
	elif not inventory.empty() && _inventory_size >= 1 :
		
		if inventory.size() == 1:
			for item in inventory:
				if not _stats_buttons.has(str(item)):
					text = "%s x %s\n" % [item, inventory[item]]
					_inventory_button.text = text
					pass
		
		if _inventory_size > 1 :
			
			for item in inventory:
				# Bugs: 
				# (1) Only Uses the first item in t he inventory dictionary sometimes
				# (2) Duplicates the number of items everytime (1/2)
				# (3) REGEX code concatonates Inventory item names together (fixed)
				
				# Add Conditionals
				 
				if not _stats_buttons.has(str(item)):
					# DUplicates button using instancing
					# Item Button should ideally be low poly texture buttons
					var new_item_button : Button = _inventory_button.duplicate(8) 
					
					new_item_button.name = str(item)
					
					#create new button object anbd or remove exisiting buttons if they exist
					_quest_parent.add_child_below_node(_inventory_button, new_item_button)
					
					# connect signal
					
					# Sorts Items and the amount Into Individual Lines using REGEX
					text = "%s x %s\n" % [item, inventory[item]]
					
					# set each item button Text to their corresponding item 
					new_item_button.text = text
				else : pass



func _notification(what):  #Triggered when the Min Game Loop is exited
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print_debug("STATUS NOTIFICATION")



func _on_status_showing():
	# upadate inventory button lising
	#_update_inventory_button_cache() #  Depreciated Buggy NFT
	
	#resets Mobile Touch HUD
	Globals._TouchScreenHUD.reset()
	
	#print_debug("TC hidden:",TouchInterface._Hide_touch_interface, " SC: ", TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status hidden') #for debug purposes

func _on_status_hidden():
	# shows status UI only
	Globals._TouchScreenHUD.status()
	#print_debug("TC hidden:",TouchInterface._Hide_touch_interface, " SC: ", TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status showing')



func equip():
	# Placeholder method for Triggering an Equip method on the Player Script of an Inventroy Oject 
	pass
