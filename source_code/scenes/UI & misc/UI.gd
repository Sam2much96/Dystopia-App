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
#Bugs
#(1) Ingame menu bug
# (2) UI connects to depreciated state machine (fixed)
# (3) UI joystick and D pad changes 
# (4) 
# *************************************************


extends CanvasLayer

onready var menu = $"Menu "
onready var TouchInterface= $TouchInterface
onready var _Comics = $Comics

func _ready():
	
	connect_signals()
	
func _on_dialog_started():
	TouchInterface.interract()

func _on_dialog_ended():
	TouchInterface.reset()


func _input(_event):
	" UI logic" # rewrite to use new state machine instead
	# Controls the Touch interface state machine from the player's input 
	if Input.is_action_just_pressed("comics"):
		if _Comics.enabled == true:
			if TouchInterface._state_controller != 4  and _Comics.loaded_comics == true:
				TouchInterface.comics()
		elif _Comics.enabled == false or _Comics.loaded_comics == false:
			TouchInterface.reset()
	if Input.is_action_just_pressed("pause"):
		if $Stats.enabled == true :
			TouchInterface.status() #calls a display function int the touch interface scene
			
	if Input.is_action_just_pressed('menu'):
		if menu.enabled == true:
			TouchInterface.menu()
		elif menu.enabled == false:
			TouchInterface.reset()
	if Input.is_action_just_pressed('attack'):
		if TouchInterface._state_controller != 2: #2 is attack state  #uses old state_machine?
			TouchInterface.attack()
			
			#bug happens whenever player is killed
			#Implement timer with deltaTime and pass a boolean variable to fix this bug
			yield(get_tree().create_timer(3.0), "timeout") #Bad Code Implementation. Use a timer node instead
			TouchInterface.reset()
	
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

func on_menu_showing(): # connects from the ingame menu signal
	if menu.menu_state == 0: #uses the menu state in it's logic where 0 is showing and 1 is hidden
		TouchInterface.menu()
func on_menu_hidden(): # connects from the ingame menu signal
	if menu.menu_state == 1: #uses the menu state in it's logic where 0 is showing and 1 is hidden
		TouchInterface.reset() #buggy function
		print ("menu hidden --fix menu hidden bug")

func connect_signals():
	# Use for loop
	# Connects from singleton?
	return Dialogs.connect("dialog_started", self, "_on_dialog_started")
	return Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	return $Stats.connect("not_enabled",self, '_on_status_hidden')
	return $Stats.connect('enabled',self,'_on_status_showing')
	return _Comics.connect( 'freed_comics', self, '_on_comics_freed'  )

	#uses state machines instead #broken signals bug
	return menu.connect("menu_hidden",self,'on_menu_hidden')
	return menu.connect("menu_showing",self,'on_menu_showing')
