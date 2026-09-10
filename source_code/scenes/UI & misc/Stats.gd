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
#
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
# (7) Item Button should ideally be low poly texture buttons
# (8) Add steam achievements for using items
#
# *************************************************
# Bugs:
# (1) Regex For Inventroy Update is buggy
# 
# *************************************************

extends PanelContainer

class_name Stats

@export var enabled_ : bool
signal not_enabled
signal enabled

# Signals TO Connect To Android SIngleton For Controulling Touch HUD
signal status_hidden
signal status_showing

# Pointers to Tab Containers for icon implementation
@onready var tab_container : TabContainer = $TabContainer

#onready var scroller : ScrollContainer = $ScrollContainer # Depreciated

# Quest Parent Node Pointer
# Vbox Containter Containing all Inventory Items as children
@onready var _inventory_parent : VBoxContainer = $"TabContainer/3/ScrollContainer3/VBoxContainer" 

# Inventory Parent Node
@onready var _inventory_parent_label : Label = $"TabContainer/3/ScrollContainer3/VBoxContainer/Title3"

# Inventroy Parent Button
@onready var _inventory_button : Button = $"TabContainer/3/ScrollContainer3/VBoxContainer/Inventory"


@onready var _coin_label : Label = $"TabContainer/1/VBoxContainer/HBoxContainer/Sud"
@onready var _price_label : Label = $"TabContainer/1/VBoxContainer/HBoxContainer/price"
@onready var _quest_label : Label = $"TabContainer/2/ScrollContainer2/VBoxContainer/Quests"

# Backup Pointer to Inventory Singleton
@onready var _inventory : Storage = get_node("/root/Inventory")

# ( issue #145 ) icon-based inventory grid. Built in code and parented under the
# existing VBoxContainer so the scene file does not need restructuring.
const INVENTORY_SLOT : PackedScene = preload("res://scenes/UI & misc/InventorySlot.tscn")
var _inventory_grid : GridContainer

# pointer to Music singleton
@onready var safeMusic = get_node("/root/Music")

# Pointer to GLobal Touch HUD

# Array  pointer containing all QUest parent childeren
# Should be a dictionary
@onready var _stats_buttons : Array = []

# For Inventory Update
var regex : RegEx = RegEx.new()

enum {ENABLED, DISABLED, NULL}

@export var _state : int = DISABLED

func _ready():
	# Connect signals to self?
	
	self.connect("not_enabled", Callable(self, '_on_status_hidden'))
	self.connect('enabled', Callable(self, '_on_status_showing'))
	
	
	
	#self.get_child(0)
	
	#Globals.save_game() # Depreciated
	#get_tree().set_auto_accept_quit(false)
	hide()
	
	# Make self global 
	Inventory._stats_ui = self
	#GlobalInput._Stats = self
	
	#Regex for Inventory Update
	regex.compile("(\\d+)")

	# ( issue #145 ) swap the text button list for an icon grid
	_inventory_button.hide()
	_inventory_grid = GridContainer.new()
	_inventory_grid.name = "InventoryGrid"
	_inventory_grid.columns = 4
	_inventory_parent.add_child(_inventory_grid)
	_inventory.item_changed.connect(_on_inventory_changed)
	
	# Set Tab Icons via SUbclass Script
	tab_container.set_script(TabIcons)
	
	# Debug Signal Connections
	
	#print_debug(
	#	self.is_connected("not_enabled",self, '_on_status_hidden'), 
	#	self.is_connected('enabled',self,'_on_status_showing')
	#	)
	


func _input(event):
	
	# Enable / DIsable Logic is Buggy
	if event.is_action_pressed("stats")  && enabled_ == false:
		#print_debug("enable")
		enabled_ = true
		_enable()
	#	#_state = ENABLED
		safeMusic.play_track(safeMusic.MusicConfig.ui_sfx.get(0))
		return  # _input is void in Godot 4; the returned value was never used
	if event.is_action_pressed("stats") && enabled_ == true:
		enabled_ = false
		_disable()
	#	#_state = DISABLED
		#print_debug("disable")
		safeMusic.play_track(safeMusic.MusicConfig.ui_sfx.get(1))
		return




# to do: 
# (1) move wallet script, api calls and api return data type to a new script and reference that resource
func _update_wallet_stats(): #Updates killcount and Algos
	_coin_label.text = 'mAlgos: ' + str (Globals.algos)


func _update_quest_listing():
	
	
	var text = ""
	text += "Started:\n"
	for quest in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % quest
	text += "Failed:\n"
	for quest in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % quest
	
	_quest_label.text = text
	#pass

# ( issue #145 ) The inventory UI is now an icon grid. These two entry points are
# kept because they are called from elsewhere (Inventory.remove_item and _enable);
# both just re-render the grid from the current inventory dictionary.

# Called from Inventory.remove_item() after an item is consumed.
func _update_inventory_button_cache(_item : String, _amount : int) -> void:
	_render_inventory_grid()

func _update_inventory_listing() -> void:
	_render_inventory_grid()

func _on_inventory_changed(_action, _type, _amount) -> void:
	_render_inventory_grid()

# Rebuilds the icon grid from Inventory.list(). Cheap enough for the item counts
# this game deals with; called on open and on every inventory change.
func _render_inventory_grid() -> void:
	if not is_instance_valid(_inventory_grid):
		return

	for child in _inventory_grid.get_children():
		child.queue_free()
	_stats_buttons.clear()

	var items : Dictionary = _inventory.list()

	if items.is_empty():
		var empty := Label.new()
		empty.text = "[ Empty ]"
		_inventory_grid.add_child(empty)
		return

	for item in items:
		var count : int = int(items[item])
		if count <= 0:
			continue
		var slot := INVENTORY_SLOT.instantiate()
		_inventory_grid.add_child(slot)
		slot.set_item(str(item), count)
		slot.used.connect(_on_slot_used)
		_stats_buttons.append(str(item))

func _on_slot_used(item_type : String) -> void:
	_inventory.remove_item(item_type, 1)


func _notification(what):  #Triggered when the Min Game Loop is exited
	#if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
	#	print_debug("STATUS NOTIFICATION")
		pass


func _on_status_showing():
	# upadate inventory button lising
	#_update_inventory_button_cache() #  Depreciated Buggy NFT?
	
	
	#resets Mobile Touch HUD
	emit_signal("status_hidden")
	#GlobalInput.TouchInterface.reset()
	
	#print_debug("TC Status:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status hidden') #for debug purposes

func _on_status_hidden():
	# shows status UI only
	# Buggy Method Triggers Status state on Mobile Devices
	# TO DO: Implement In Android SIngleton
	#GlobalInput.TouchInterface.status()
	emit_signal("status_showing")
	#print_debug("TC hidden:",GlobalInput.TouchInterface._Hide_touch_interface, " SC: ", GlobalInput.TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status showing')



func equip(_item):
	# Placeholder method for Triggering an Equip method on the Player Script of an Inventroy Oject 
	pass


func _enable():
	enabled_ = true
	visible = enabled_
	emit_signal('enabled')
	safeMusic.play_track(safeMusic.MusicConfig.ui_sfx.get(0))
	get_tree().paused = enabled_

	_update_quest_listing()
	_update_inventory_listing() # Refactor
	_update_wallet_stats()
	print_debug(self.name, "disabled") 

func _disable():
	enabled_ = false
	visible = enabled_
	emit_signal("not_enabled")
	safeMusic.play_track(safeMusic.MusicConfig.ui_sfx.get(1))
	hide()
	get_tree().paused = false
	print (self.name, "enabled") # For debug purposes only
