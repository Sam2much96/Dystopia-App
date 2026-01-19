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



signal menu_hidden
signal menu_showing
@export var enabled : bool

var showingObject : bool = false
"""
The game menu script. 
"""

enum { SHOWING, HIDDEN}

@export var menu_state : String




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

#safe Pointers to global singletons
@onready var safe_Music = get_node("/root/Music")
@onready var safe_Globals = get_node("/root/Globals")


#
@onready var _ui_sfx : String = safe_Music.MusicConfig.ui_sfx[0]
@onready var _ui_sfx_1 : String = safe_Music.MusicConfig.ui_sfx[1]


func _ready():
	
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
	
	showingObject = false
	hidden()
	


func _unhandled_input(event):
	# Keyboard Input
	if event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		toggled()


func toggled():
	#print_debug("Menu Button Triggered")
	showingObject = !showingObject
	if showingObject:
		showing()
	else:
		hidden()





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


func showing():
	show()
	manually_translate()
	enabled = true 
	set_focus_mode(Control.FOCUS_CLICK)
	set_mouse_filter(Control.MOUSE_FILTER_STOP)
	safe_Music.play_track(_ui_sfx)
	emit_signal("menu_showing")



#Handles Hiding the menu
func hidden():
	enabled = false
	hide()
	emit_signal("menu_hidden")
	
	
	return




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
	# temporarily disabled for refactoring Jan 19, 26
	pass
