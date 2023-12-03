# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
#
# Features: 
# (1) SHows All Game Data from Different Singletons to player
# (2) Creates Global Pointer to Children Nodes from Global Input Singleton
# (3) Connects Signals Between CHildren Nodes
# *************************************************
# To DO
# (1) Implement State Machine to goggle between different Screen orientations using global orientation state
# (2) Implement Mobile Gyroscope in a process method
# (3) Fix UI misalignment
# (4) Refactor into state machines
# *************************************************
# Bugs :
#(1) Ingame menu bug (fixed)
# (2) Multiple State can be active at the same time Bug
# (4) Fix Intteract UI
# (5) Doesn't implement Mobile Gyroscope (f1/2 fixed)
# (6) TouchInterface State Machine is buggy
# (7) Touch Interface INterract State  State is Buggy
#		#-Icons Do not hide when dialogue ia triggered
# (8) Breaks when in scene with player networking v2
# *************************************************


extends CanvasLayer

class_name GameHUD


#onready var menu : Game_Menu = $"Menu "
#onready var TouchInterface : TouchScreenHUD =  $TouchInterface
#onready var _Comics = Comics_v6 #$Comics
#onready var _Stats : PanelContainer = $Stats
#onready var _Status_text : StatusText = $Status_text

#enum {RESET, INTERRACT, STATUS, COMICS}

#func _enter_tree():
	

#func _process(delta):
#	pass

func _ready():
	
	connect_signals()
	
	"Update Global Input SIngletons Pointers"
	# Global Pointers
#	GlobalInput.menu = menu
#	GlobalInput.TouchInterface  = TouchInterface
#	GlobalInput._Comics = _Comics
#	GlobalInput._Stats = _Stats
#


func _on_dialog_started():
	GlobalInput.TouchInterface.interract()

func _on_dialog_ended():
	GlobalInput.TouchInterface.reset()




func connect_signals()-> bool:
	# Connects signals from to State Methods on Different Paths
	# # Require Debugging`and More Documentation (Done)
	# 

	# Dialogues to GameHUD
	if not Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.connect("dialog_started", self, "_on_dialog_started")
		
	if not Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	# Status Text to Quest
	
	# Connects to Both Quest and Item Singleton
	if not Quest.is_connected("quest_changed", StatusText, "_questlog_updated"):
		Quest.connect("quest_changed", StatusText, "_questlog_updated")
	
	# Inventory to Status Text
	if not Inventory.is_connected("item_changed", StatusText, "_inventory_updated"):
		Inventory.connect("item_changed", StatusText, "_inventory_updated")

	
	
	# Stats
	if not GlobalInput._Stats.is_connected("not_enabled",GlobalInput._Stats, '_on_status_hidden'):
		GlobalInput._Stats.connect("not_enabled",GlobalInput._Stats, '_on_status_hidden')
	
	# Stats to Stats
	if not GlobalInput._Stats.is_connected('enabled',GlobalInput._Stats,'_on_status_showing'):
		GlobalInput._Stats.connect('enabled',GlobalInput._Stats,'_on_status_showing')
	
	# Comics to Touch Interface
	if not GlobalInput._Comics.is_connected( 'comics_showing', GlobalInput.TouchInterface, '_on_comics_showing'  ):
		 GlobalInput._Comics.connect( 'comics_showing', GlobalInput.TouchInterface, '_on_comics_showing'  )
	
	# COmics to Touch Interface
	if not GlobalInput._Comics.is_connected( 'comics_hidden', GlobalInput.TouchInterface, '_on_comics_hidden'  ):
		 GlobalInput._Comics.connect( 'comics_hidden', GlobalInput.TouchInterface, '_on_comics_hidden'  )
	
	# Menu to Touch Interface
	if not GlobalInput.menu.is_connected("menu_showing", GlobalInput.TouchInterface, "menu"): #works
		GlobalInput.menu.connect("menu_showing", GlobalInput.TouchInterface, "menu")
	
	if not GlobalInput.menu.is_connected("menu_hidden", GlobalInput.TouchInterface, 'reset'):
		GlobalInput.menu.connect("menu_hidden", GlobalInput.TouchInterface, "reset")
	
	
	# Networking TImer to Touch Interface
	# Resets Using Networking timer
	if not Networking.timer.is_connected("timeout", GlobalInput.TouchInterface, "reset") :
		Networking.timer.connect("timeout", GlobalInput.TouchInterface, "reset")
	
	
	if not (Dialogs.is_connected("dialog_started", self, "_on_dialog_started") and
	Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended") and
	Quest.is_connected("quest_changed", GlobalInput.StatusText, "_questlog_updated") and
	Inventory.is_connected("item_changed", GlobalInput.StatusText, "_inventory_updated") and
	GlobalInput._Stats.is_connected("not_enabled",GlobalInput._Stats, '_on_status_hidden') and
	GlobalInput._Stats.is_connected('enabled',GlobalInput._Stats,'_on_status_showing') and
	GlobalInput._Comics.is_connected( 'comics_showing', GlobalInput.TouchInterface, '_on_comics_showing'  ) and
	GlobalInput._Comics.is_connected( 'comics_hidden', GlobalInput.TouchInterface, '_on_comics_hidden'  ) and
	GlobalInput.menu.is_connected("menu_showing", GlobalInput.TouchInterface, "menu") and
	Networking.timer.is_connected("timeout", GlobalInput.TouchInterface, "reset")
	):
		print("Debug Game HUD Signals")
	
	
	#print("sgjoaopfgias0giawerg0ihjsgfokafghio")
	
	
	return true

func disconnect_signals()-> bool:
	# 
	# Connects from singleton?
	if Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.disconnect("dialog_started", self, "_on_dialog_started")
		
	if Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.disconnect("dialog_ended", self, "_on_dialog_ended")
	
	if GlobalInput._Stats.is_connected("not_enabled",self, '_on_status_hidden'):
		GlobalInput._Stats.disconnect("not_enabled",self, '_on_status_hidden')
	
	if GlobalInput._Stats.connect('enabled',self,'_on_status_showing'):
		GlobalInput._Stats.disconnect('enabled',self,'_on_status_showing')
	
	if GlobalInput._Comics.connect( 'freed_comics', GlobalInput.TouchInterface, '_on_comics_hidden'  ):
		 GlobalInput._Comics.disconnect( 'freed_comics', GlobalInput.TouchInterface, '_on_comics_hidden'  )

	if GlobalInput._Comics.connect( 'freed_comics', GlobalInput.TouchInterface, '_on_comics_showing'  ):
		 GlobalInput._Comics.disconnect( 'freed_comics', GlobalInput.TouchInterface, '_on_comics_showing'  )
	
	if GlobalInput.menu.is_connected("menu_showing", GlobalInput.TouchInterface, "menu"): #works
		GlobalInput.menu.disconnect("menu_showing", GlobalInput.TouchInterface, "menu")
	
	if GlobalInput.menu.is_connected("menu_hidden", GlobalInput.TouchInterface, 'reset'):
		GlobalInput.menu.disconnect("menu_hidden", GlobalInput.TouchInterface, "reset")
	
	
	# Resets Using Networking timer
	if Networking.timer.is_connected("timeout", GlobalInput.TouchInterface, "reset") :
		Networking.timer.disconnect("timeout", GlobalInput.TouchInterface, "reset")
	return true




func _exit_tree():
	disconnect_signals()
