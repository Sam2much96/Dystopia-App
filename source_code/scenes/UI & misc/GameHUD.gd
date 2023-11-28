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


onready var menu : Game_Menu = $"Menu "
onready var TouchInterface : TouchScreenHUD =  $TouchInterface
onready var _Comics = Comics_v6 #$Comics
onready var _Stats : PanelContainer = $Stats


enum {RESET, INTERRACT, STATUS, COMICS}

func _ready():
	
	"Update Global Input SIngletons Pointers"
	# Global Pointers
	GlobalInput.menu = menu
	GlobalInput.TouchInterface  = TouchInterface
	GlobalInput._Comics = _Comics
	GlobalInput._Stats = _Stats

	
	connect_signals()

func _on_dialog_started():
	GlobalInput.TouchInterface.interract()

func _on_dialog_ended():
	GlobalInput.TouchInterface.reset()




func connect_signals()-> bool:
	# Connects signals from to State Methods on Different Paths
	# # Require Debugging`and More Documentation
	# 
	# Dialogues to GameHUD
	if not Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.connect("dialog_started", self, "_on_dialog_started")
		
	if not Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	# Stats
	if not _Stats.is_connected("not_enabled",_Stats, '_on_status_hidden'):
		_Stats.connect("not_enabled",_Stats, '_on_status_hidden')
	
	# Stats to Stats
	if not _Stats.connect('enabled',_Stats,'_on_status_showing'):
		_Stats.connect('enabled',_Stats,'_on_status_showing')
	
	# Comics to Touch Interface
	if not _Comics.connect( 'comics_showing', TouchInterface, '_on_comics_showing'  ):
		 _Comics.connect( 'comics_showing', TouchInterface, '_on_comics_showing'  )
	
	# COmics to Touch Interface
	if not _Comics.connect( 'comics_hidden', TouchInterface, '_on_comics_hidden'  ):
		 _Comics.connect( 'comics_hidden', TouchInterface, '_on_comics_hidden'  )
	
	# Menu to Touch Interface
	if not menu.is_connected("menu_showing", TouchInterface, "menu"): #works
		menu.connect("menu_showing", TouchInterface, "menu")
	
	if not menu.is_connected("menu_hidden", TouchInterface, 'reset'):
		menu.connect("menu_hidden", TouchInterface, "reset")
	
	
	# Networking TImer to Touch Interface
	# Resets Using Networking timer
	if not Networking.timer.is_connected("timeout", TouchInterface, "reset") :
		Networking.timer.connect("timeout", TouchInterface, "reset")
	return true

func disconnect_signals()-> bool:
	# 
	# Connects from singleton?
	if Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.disconnect("dialog_started", self, "_on_dialog_started")
		
	if Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.disconnect("dialog_ended", self, "_on_dialog_ended")
	
	if _Stats.is_connected("not_enabled",self, '_on_status_hidden'):
		_Stats.disconnect("not_enabled",self, '_on_status_hidden')
	
	if _Stats.connect('enabled',self,'_on_status_showing'):
		_Stats.disconnect('enabled',self,'_on_status_showing')
	
	if _Comics.connect( 'freed_comics', TouchInterface, '_on_comics_hidden'  ):
		 _Comics.disconnect( 'freed_comics', TouchInterface, '_on_comics_hidden'  )

	if _Comics.connect( 'freed_comics', TouchInterface, '_on_comics_showing'  ):
		 _Comics.disconnect( 'freed_comics', TouchInterface, '_on_comics_showing'  )
	
	if menu.is_connected("menu_showing", TouchInterface, "menu"): #works
		menu.disconnect("menu_showing", TouchInterface, "menu")
	
	if menu.is_connected("menu_hidden", TouchInterface, 'reset'):
		menu.disconnect("menu_hidden", TouchInterface, "reset")
	
	
	# Resets Using Networking timer
	if Networking.timer.is_connected("timeout", TouchInterface, "reset") :
		Networking.timer.disconnect("timeout", TouchInterface, "reset")
	return true




func _exit_tree():
	disconnect_signals()
