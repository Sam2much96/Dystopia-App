# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
#
# Features
# To DO
#(1) Implement State Machine to goggle between different Screen orientations using global orientation state
#(2) Implement Mobile Gyroscope 
# (3) Fix UI misalignment
#Bugs
#(1) Ingame menu bug (fixed)
# (2) UI connects to depreciated state machine (fixed)
# (3) UI joystick and D pad changes (fixed)
# (4) Status UI misalgnment (fixed)
# (5) Doesn't implement Mobile Gyroscope (f1/2 fixed)
# (6) TouchInterface State Machine is buggy
# (7) Dialogue State is Buggy
#		#-Icons Do not hide when dialogue ia triggered
# *************************************************


extends CanvasLayer

class_name GameHUD


onready var menu : Container = $"Menu "
onready var TouchInterface : Node2D =  $TouchInterface
onready var _Comics = Comics_v6 #$Comics
onready var _Stats : PanelContainer = $Stats


func _ready():
	
	connect_signals()

func _on_dialog_started():
	TouchInterface.interract()

func _on_dialog_ended():
	TouchInterface.reset()


func _input(_event):
	" UI logic" # 
	
	


	" UI Animation"
	# Controls the Touch interface state machine from the player's input 
	# Buggy and Broken
	
	
	# nested If Statements?
	if Input.is_action_just_pressed("comics"):
		if _Comics.enabled == true:
			if TouchInterface._state_controller != 4 : # and _Comics.loaded_comics == true:
				TouchInterface.comics()
		elif _Comics.enabled == false : #or _Comics.loaded_comics == false:
			TouchInterface.reset()
	if Input.is_action_just_pressed("pause"):
		if _Stats.enabled == true :
			TouchInterface.status() #calls a display function int the touch interface scene
			
	if Input.is_action_just_pressed('menu'):
		if menu.enabled == true:
			TouchInterface.menu()
		elif menu.enabled == false:
			TouchInterface.reset()
	if Input.is_action_just_pressed('attack'):
		if TouchInterface._state_controller != 2: #2 is attack state  #uses old state_machine?
			TouchInterface.attack()
			
			# Uses Networking Timer to Reset Touch Interface
			Networking.start_check(3)
	#if Input.is_action_just_pressed('comics'):
	#	if _Comics.enabled :
	#		TouchInterface.comics()
	else : pass #TouchInterface.reset()
	
	#'Sets Interract UI'
	# Disabled for Debugging
	#
	# Hard connects to all interractible objects connected via the global variable
	#if Globals.near_interractible_objects == true : #&& Input.is_action_just_pressed("interact"):
		#TouchInterface.status()
	#	print_debug("Player near Interractible Object", Globals.near_interractible_objects)
	#elif Globals.near_interractible_objects == null or false:
	#	# if Input.is_action_just_pressed("interact") : return TouchInterface.reset()
	#	#return TouchInterface.reset()
	#	print_debug("PLayer Left Interactibe object")



func connect_signals()-> bool:
	# 
	# Connects from singleton?
	if not Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.connect("dialog_started", self, "_on_dialog_started")
		
	if not Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	if not _Stats.is_connected("not_enabled",_Stats, '_on_status_hidden'):
		_Stats.connect("not_enabled",_Stats, '_on_status_hidden')
	
	if not _Stats.connect('enabled',_Stats,'_on_status_showing'):
		_Stats.connect('enabled',_Stats,'_on_status_showing')
	
	if not _Comics.connect( 'comics_showing', TouchInterface, '_on_comics_showing'  ):
		 _Comics.connect( 'comics_showing', TouchInterface, '_on_comics_showing'  )
	
	if not _Comics.connect( 'comics_hidden', TouchInterface, '_on_comics_hidden'  ):
		 _Comics.connect( 'comics_hidden', TouchInterface, '_on_comics_hidden'  )
	
	if not menu.is_connected("menu_showing", TouchInterface, "menu"): #works
		menu.connect("menu_showing", TouchInterface, "menu")
	
	if not menu.is_connected("menu_hidden", TouchInterface, 'reset'):
		menu.connect("menu_hidden", TouchInterface, "reset")
	
	
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
