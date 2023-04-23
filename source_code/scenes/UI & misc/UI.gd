# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
# The touch interface functions control it's state machine
# On the 16/04/22 , i started an update to the dialogue button.
# Features
# To DO
#(1) Implement State Machine to goggle between different Screen orientations using global orientation state
#(2) Implement Mobile Gyroscope 
# (3) Fix UI misalignment
#Bugs
#(1) Ingame menu bug (fixed)
# (2) UI connects to depreciated state machine (fixed)
# (3) UI joystick and D pad changes (fixed)
# (4) Status UI misalgnment
# (5) Doesn't implement Mobile Gyroscope
# *************************************************


extends CanvasLayer

class_name GameHUD


onready var menu = $"Menu "
onready var TouchInterface= $TouchInterface
onready var _Comics = Comics_v6 #$Comics
onready var _Stats = $Stats


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
			
	#'Sets Interract UI'
	# Hard connects to all interractible objects connected via the global variable
	if Globals.near_interractible_objects == true : #&& Input.is_action_just_pressed("interact"):
		TouchInterface.status()
	elif Globals.near_interractible_objects == null or false:
		# if Input.is_action_just_pressed("interact") : return TouchInterface.reset()
		return TouchInterface.reset()

func _on_comics_freed():
	TouchInterface.reset()

func _on_status_showing():
	TouchInterface.reset()
	print('status hidden') #for debug purposes

func _on_status_hidden():
	#$Stats.enabled = false
	TouchInterface.status()
	print('status showing')

func on_comics_showing():
	TouchInterface.comics()



#doesn't work
#should hide all UI items once menu is showing
#s
#connect TouchInterface to Menu Visibility
func on_menu_showing(): # connects from the ingame menu signal
	if menu.menu_state == 0: #uses the menu state in it's logic where 0 is showing and 1 is hidden
		TouchInterface.menu()
func on_menu_hidden(): # connects from the ingame menu signal
	if menu.menu_state == 1: #uses the menu state in it's logic where 0 is showing and 1 is hidden
		TouchInterface.reset() #buggy function
		print ("menu hidden --fix menu hidden bug")

func connect_signals()-> bool:
	# 
	# Connects from singleton?
	if not Dialogs.is_connected("dialog_started", self, "_on_dialog_started"):
		Dialogs.connect("dialog_started", self, "_on_dialog_started")
		
	if not Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended"):
		Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	if not _Stats.is_connected("not_enabled",self, '_on_status_hidden'):
		_Stats.connect("not_enabled",self, '_on_status_hidden')
	
	if not _Stats.connect('enabled',self,'_on_status_showing'):
		_Stats.connect('enabled',self,'_on_status_showing')
	
	if not _Comics.connect( 'freed_comics', self, '_on_comics_freed'  ):
		 _Comics.connect( 'freed_comics', self, '_on_comics_freed'  )
	
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
	
	if _Comics.connect( 'freed_comics', self, '_on_comics_freed'  ):
		 _Comics.disconnect( 'freed_comics', self, '_on_comics_freed'  )
	
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
