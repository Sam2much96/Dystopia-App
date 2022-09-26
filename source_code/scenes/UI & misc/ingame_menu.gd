# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Ingame Menu
# 
# To Do:
#(1) Impement State Machine
#Bugs

#(1) Emitting signals fail
#(2) Broken functions
#(3) Spagetti code
#(4) change_scenes_via_global_scripts() breaks scene continuity
# *************************************************

extends Control

var selector = 0
signal menu_hidden
signal menu_showing
signal loading_game
export (bool) var enabled 

var shop = load('res://scenes/UI & misc/Shop.tscn')

"""
The game menu script. 
"""
#update code to arrange well in UI and on the game title screen

onready var continue_game = get_node("MarginContainer/ScrollContainer/HSeparator/continue") 
onready var game_menu = get_node("MarginContainer")

onready var _multiplayer = $MarginContainer/ScrollContainer/HSeparator/multiplayer

enum { SHOWING, HIDDEN, LOADING}
#func _enter_tree():
	#hide()
export (String) var menu_state

func _ready():
	'Hides the Menu once the scene tree is ready'
	#hide()
	menu_state =  HIDDEN
	
	if Globals.load_game(true) and continue_game != null:
		continue_game.disabled = false 
	else:
		continue_game.disabled = true

func _process(_delta):
	#_hide_some_menu_options() #turning this off temporarily to debug the debug singleton
	"Visibility State Machine"
	match menu_state:
		SHOWING:
			return _menu_showing()
		HIDDEN:
			return _menu_not_showing()
		LOADING:
			'simply emits a signal in this state'
			print ("Emitting Signa--Loading game")
			return emit_signal("loading_game")
	pass
func _input(event): #Toggles menu visibility on/off
	if event.is_action_pressed("menu") == true :# 
		if menu_state == HIDDEN:
			menu_state = SHOWING
			Music.play_track(Music.ui_sfx[0])
			#print ("Menu State: ",menu_state) #For debug purposes only
			return menu_state
		if menu_state== SHOWING:
			menu_state = HIDDEN
			Music.play_track(Music.ui_sfx[1])
			#print ("Menu State: ",menu_state) #For debug purposes only
			return menu_state
		else:
			return

#input functions for gamepad


		if event.is_action_pressed("ui_cancel") && visible == true:
			Globals._go_to_title()
	 
	


func _on_continue_pressed(): #breaks the Globals.current_level script
	print (" --loading game--")
	
	Music.play_track(Music.ui_sfx[0])
	Globals.load_game()
	if Globals.current_level != null:
		
		change_scenes_via_globals_script()
		
		#if Globals.change_scene_to(Globals.current_level) != OK:
		#	push_error("Error changing scenes")
	else:
		$MarginContainer/ScrollContainer/HSeparator/continue.hide()
		push_error("Error: current_level shouldn't be empty")
	pass # Replace with function body.


func _on_new_game_pressed(): #breaks the Globals.current_level script
	if Globals.initial_level != "":
		Globals.current_level = Globals.initial_level
		print (" Emitting signal--loading game--")
		Music.play_track(Music.ui_sfx[0]) #plays ui sfx in a loop
		

		
		if Globals.save_game() == false:
			push_error("Error saving game")
		
		'Auto Scene Changer Shorthand'
		change_scenes_via_globals_script()
		#var err =Globals.change_scene_to(Globals.initial_level) # Loads the initial scene 
		#print (" Menu Error: "+str(err))
		#if err != OK:
		#	push_error("Error changing scene from menu: %s" % err)
	else:
		push_error("Error: initial_level shouldn't be empty")
		
	pass # Replace with function body.



func _on_Menu_button_toggled(button_pressed): # Broken Function #rewriting with State_Machine
	if button_pressed :
		print (' Showing Game Menu ') # For Debug purposes only
		game_menu.show()
		# new animation
		emit_signal('menu_showing')
	else: 
		print (' Hiding Game Menu') # For Debug purposes only
		game_menu.hide() 
		emit_signal('menu_hidden')


#Handles Displaying the menu
func _menu_showing(): #Broken funtions #rewrite with state machine
	enabled = true 
	
	show()

	set_focus_mode(2)
	emit_signal("menu_showing")
	return

#Handles Hiding the menu
func _menu_not_showing():
	enabled = false
	hide()
	
	#Music.play_track(Music.ui_sfx[1]) #introduces a sound bug
	#Music._notification(NOTIFICATION_UNPAUSED) #introduces a sound bug
	
	set_focus_mode(0)
	emit_signal("menu_hidden")
	
	return
#Handles Pausing the Menu
func _menu_pause_and_play(boolean): #pass it a boolean to custom pause and play
	get_tree().set_pause(boolean)


func _on_comics_pressed():
	print_debug ('comics pressed')
	Music.play_track(Music.ui_sfx[0])
	Globals.change_scene_to(Globals.comics___2)
func _on_controls_pressed():
	Music.play_track(Music.ui_sfx[0])
	Globals.change_scene_to(Globals.controls)


func _on_quit_Button_pressed():
	if get_tree().get_current_scene().get_name() == 'Menu':
		Music.play_track(Music.ui_sfx[1])
		get_tree().quit()
	else:
		Music.play_track(Music.ui_sfx[1])
		#Globals.memory_leak_management()
		Globals.change_scene_to(Globals.title_screen)



func _on_multiplayer_pressed(): # Experimental feature
	Music.play_track(Music.ui_sfx[0])
	return get_tree().change_scene_to(load ('res://New game code and features/multiplayer/scenes/login.tscn'))

func _exit_tree():
	Music._notification(NOTIFICATION_UNPAUSED) #resets music when exiting scene tree


func _on_Shop_pressed():
	Music.play_track(Music.ui_sfx[0])
	Globals.change_scene_to(shop)

func _hide_some_menu_options():
	if Engine.has_singleton ('Debug'):
		var Debug = Engine.get_singleton('Debug')
		if Debug.debug_panel != null: #turns multiplayer on when debugging000
			_multiplayer.show()
		if Debug.debug_panel == null:
			_multiplayer.hide()
		pass

func change_scenes_via_globals_script(): #breaks the Globals.current_level script
	'Auto Scene Changer Shorthand' 
	if Globals._q == null:
		Globals._r =Globals.current_level # triggers an auto scene loader.changer from globals script
	if Globals._q != null:
		return (Globals.change_scene_to(Globals._q))

func _on_Anime_pressed():
	Music.play_track(Music.ui_sfx[0])
	return get_tree().change_scene_to((load('res://scenes/UI & misc/Shop.tscn')))


func _on_wallet_pressed():
	Music.play_track(Music.ui_sfx[0])
	return get_tree().change_scene_to((load('res://New game code and features/Wallet.tscn')))


func _on_Testing_Scene_pressed(): # turn off in release build
	Globals.current_level = 'res://scenes/levels/Testing Scene.tscn' #breaks the Globals.current_level script
	change_scenes_via_globals_script() 

func _on_City_scape_pressed(): #turn off in release build
	Globals.current_level = "res://scenes/levels/Cityscape Exterior.tscn"
	change_scenes_via_globals_script()
