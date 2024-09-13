# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Ingame Menu
# 
# Features:
#(1) Impement State Machine (done)
# (2) Scales for mobile UI (done)
# (3) Translations
# (4) Sets Global Screen Orientation
# *************************************************

# To-Do
# (1) Implement Different States (Portrait & LandScape) Using Global Screen Orientation

#Bugs 
# (1) Buggy on Screen Orientation Rotation
# (2) Implements Swipe Gestures for Auto Scroll using refactores swipe detection
# (3) Spagetti code 
# (5) Should implemente Touch Input without emulation
# *************************************************

extends Control


class_name Game_Menu

var selector = 0
signal menu_hidden
signal menu_showing
#signal loading_game
@export var enabled : bool

#var shop = load('res://scenes/UI & misc/Shop.tscn')

"""
The game menu script. 
"""

enum { SHOWING, HIDDEN}

@export var menu_state : int




var counter : int = 0 # Stopis ooverflow of Upscaling Method
var comics : Button 
var new_game : Button 

var continue_game : Button  
#onready var game_menu : ScrollContainer = self#get_node("MarginContainer")

var _multiplayer : Button 

var anime : Button 
var practice : Button 
var controls : Button 
var quit : Button 


# Auto Scroll with Swipe Gestures
var scroller : ScrollContainer

var MenuButtons : Array = []

#var initialScale : Vector2 =self.get_scale()
#@export var newScale : Vector2 = Vector2(2,2)

@onready var _ui_sfx : String = Music.ui_sfx[0]
@onready var _ui_sfx_1 : String = Music.ui_sfx[1]


func _ready():
	
	# Make Global
	Android.ingameMenu = self
	GlobalInput.menu = self
	
	#Buttons
	comics  = $ScrollContainer/HSeparator/comics
	new_game  = $"ScrollContainer/HSeparator/new game"

	continue_game = get_node("ScrollContainer/HSeparator/continue") 
	#onready var game_menu : ScrollContainer = self#get_node("MarginContainer")

	_multiplayer = $ScrollContainer/HSeparator/multiplayer

	anime = $ScrollContainer/HSeparator/anime
	practice = $ScrollContainer/HSeparator/practice
	controls = $ScrollContainer/HSeparator/controls
	quit  = $"ScrollContainer/HSeparator/quit"


	# Auto Scroll with Swipe Gestures
	scroller= get_node("ScrollContainer")

	MenuButtons = [comics,new_game, continue_game, _multiplayer, anime,practice,controls, quit]

	" Translation"
	
	#manually_translate()
	
	"Scales for Mobile UI"
	# Disabling for debuggin
	

	
	'Hides the Menu once the scene tree is ready'
	
	menu_state =  HIDDEN
	
	

	
	"Continue Button Disable"#?
	#if Utils.Functions.load_game(true, Globals) and continue_game != null:
	#	continue_game.disabled = false 
		
	#else:
	#	continue_game.disabled = true
	#print_debug("Continue Disabled",continue_game.disabled)


func _process(_delta):
	
	
	
	#_hide_some_menu_options() #turning this off temporarily to debug the debug singleton
	"Visibility State Machine"
	match menu_state:
		SHOWING:
			
			return _menu_showing()
		HIDDEN:
			return _menu_not_showing()




func _input(event): 
	#Toggles menu visibility on/off
	# Bug: 
	# (1) Causes Laggy Audio On Title Screen Loads
	if event.is_action_pressed("menu") == true :# 
		print_debug("Menu Is Pressed")
		if menu_state == HIDDEN:
			menu_state = SHOWING
			set_focus_mode(Control.FOCUS_CLICK)
			Music.play_track(_ui_sfx)
			
			return menu_state
		if menu_state== SHOWING:
			menu_state = HIDDEN
			#Music.play_track(Music.ui_sfx[1])
			return menu_state

#input functions for gamepad


		if event.is_action_pressed("ui_cancel") && visible == true:
			Globals._go_to_title()
	else : pass 
	


func _on_continue_pressed():
	print_debug("continue game pressed")
	Music.play_track(_ui_sfx)
	#Utils.Functions.load_game(false, Globals)
	if Globals.current_level != null:
		
		"Loads Large Scene"
		
		Utils.Functions.change_scene_to_packed(Utils.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress
		), get_tree())
		

	else:
		continue_game.hide()
		push_error("Error: current_level shouldn't be empty")
	pass # Replace with function body.


func _on_new_game_pressed(): #breaks the Globals.current_level script
	print_debug("new game pressed")
	if Globals.initial_level != "":
		
		# Sets the Current Level to the defauult initial level
		Globals.current_level = Globals.initial_level
		
		

		# shance scene to loading scene with nspecialized logic for device loadi handling
		Utils.Functions.change_scene_to_packed(Globals.loading_scene,get_tree() )
		
		# Required Variables
		#player: Array, 
		#player_hitpoints : int, 
		#spawn_x, spawn_y, 
		#current_level, 
		#os : String, 
		#kill_count : int, 
		#prev_scene, 
		#prev_scene_spawnpoint,
		#direction_control,
		#Music_on_settings
		if Utils.Functions.save_game(
			[], 
			0, 
			0, 
			0, 
			Globals.current_level, 
			Globals.os, 
			0, 
			"", 
			null, 
			Globals.direction_control 
			) == false: push_error("Error saving game")

		await Music.play_track(_ui_sfx) #plays ui sfx in a loop
		return 0

#Handles Displaying the menu
func _menu_showing(): #Broken funtions #rewrite with state machine
	"Menu Logic"
	
	
	enabled = true 
	

	
	
	if counter < 2: # Stops overflow of Menu Logic freeing up the main thread for oher core tasks
		
		"UI scaling moved to Android SIngleton"
		
		## Temp Disabling for debugging
		#print_debug("UI downslacling is unimplemented")# For Debug Purposes only
		
		
		emit_signal("menu_showing")
		counter += 1
	
	
	show()

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
	Music.play_track(_ui_sfx)
	Utils.Functions.change_scene_to_packed(Globals.comics___2, get_tree()) # breaks in v3.5 build

func _on_controls_pressed():
	Music.play_track(_ui_sfx)
	return Utils.Functions.change_scene_to_packed(Globals.controls, get_tree())


func _on_quit_pressed():
	if get_tree().get_current_scene().get_name() == 'Menu': # Title Screen Custom Quit
		Music.play_track(_ui_sfx_1)
		get_tree().quit()
	
	if get_tree().get_current_scene().get_name() == 'form': # Mutiplayer Login Custom Quit
		Music.play_track(_ui_sfx_1)
		get_tree().quit()
	else:
		Music.play_track(_ui_sfx_1)
		#Globals.memory_leak_management()
		#Utils.Functions.change_scene_to_packed(Globals.title_screen, get_tree())
		await Globals._go_to_title()


func _on_multiplayer_pressed(): # Experimental feature
	Music.play_track(_ui_sfx)
	return get_tree().change_scene_to_packed(load ('res://scenes/multiplayer/login.tscn'))

func _exit_tree():
	# Memory Leak Management
	#
	# Clears all ui buttons
	
	Utils.MemoryManagement.queue_free_array(MenuButtons)
	Music._notification(NOTIFICATION_UNPAUSED) #resets music when exiting scene tree
	








func _on_anime_pressed():
	Music.play_track(_ui_sfx)
	return get_tree().change_scene_to_packed((load('res://scenes/UI & misc/Shop.tscn')))


func _on_wallet_pressed():
	Music.play_track(_ui_sfx)
	return get_tree().change_scene_to_packed((load('res://scenes/Wallet/Wallet main.tscn')))


func _on_practice_pressed(): # turn off in release build
	# To DO:
	# (1) refactor practice scene to forced tutorial scene for new players
	# (2) Fix audo delete save file bug in form.tscn
	Globals.current_level = 'res://scenes/levels/Testing Scene 2.tscn' #breaks the Globals.current_level script
	Utils.Functions.change_scene_to_packed(Utils.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress
		), get_tree())




func manually_translate()-> void:
	#print_debug ("Selected Language: ",Dialogs.language)
	#SHould Ideally Use Hashmap tuple + for loops  for translations
	#print_debug(MenuButtons)
	
	if Dialogs.language != "" or null:
		#print_debug(Dialogs.language)
		
		#UI Array & Font Size
		Dialogs.set_font(MenuButtons, 44, "", 2)
		
		# Set UI Text to Translated Names
		for i in MenuButtons:
			
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			
			i.set_text(Dialogs.translate_to(i.name, Dialogs.language))
		
		#comics.set_text(Dialogs.translate_to("comics", Dialogs.language))


#func _on_github_pressed():
#	get_tree().change_scene("res://addons/github-integration/scenes/GitHub.tscn")
