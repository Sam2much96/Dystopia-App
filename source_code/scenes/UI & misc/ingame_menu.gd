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
#Bugs
# (2) Implements Swipe Gestures for Auto Scroll
#(3) Spagetti code 
# (5) Should implemente Touch Input without emulation
# *************************************************

extends Control


class_name Game_Menu

var selector = 0
signal menu_hidden
signal menu_showing
signal loading_game
@export var enabled : bool = true

var shop : PackedScene = load('res://scenes/UI & misc/Shop.tscn')

"""
The game menu script. 
"""

enum { SHOWING, HIDDEN, LOADING}
@export var menu_state = SHOWING


#Buttons
@onready var comics : Button = $MarginContainer/ScrollContainer/HSeparator/comics
@onready var new_game : Button =  $"MarginContainer/ScrollContainer/HSeparator/new game"
@onready var continue_game : Button = get_node("MarginContainer/ScrollContainer/HSeparator/continue") 
@onready var game_menu : MarginContainer = get_node("MarginContainer")
@onready var _multiplayer : Button = $MarginContainer/ScrollContainer/HSeparator/multiplayer
@onready var anime : Button = $MarginContainer/ScrollContainer/HSeparator/Anime
@onready var practice : Button = $MarginContainer/ScrollContainer/HSeparator/Testing_Scene
@onready var City_scape : Button = $MarginContainer/ScrollContainer/HSeparator/City_scape
@onready var wallet_ : Button = $MarginContainer/ScrollContainer/HSeparator/wallet
@onready var controls : Button = $MarginContainer/ScrollContainer/HSeparator/controls
@onready var quit : Button = $"MarginContainer/ScrollContainer/HSeparator/quit Button"


# Auto Scroll with Swipe Gestures
@onready var scroller : ScrollContainer = get_node("MarginContainer/ScrollContainer")

const scroll_constant: int = 4


@onready var MenuButtons : Array = [
	comics, new_game, continue_game, game_menu,
	_multiplayer, anime, practice, City_scape, 
	wallet_, controls, quit
]

func _ready():
	
	" Translation"
	manually_translate()
	
	"Scales for Mobile UI"
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		upscale()
	
	
	'Hides the Menu once the scene tree is ready'
	#hide()
	menu_state =  SHOWING
	
	if Globals.load_game(true) and continue_game != null:
		continue_game.disabled = false 
	else:
		continue_game.disabled = true



func _process(delta):
	
	
	
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


static func scroll(direction : bool , visible : bool, _scroller : ScrollContainer)-> void:
	# DOCS : https://godotengine.org/qa/92054/how-programmatically-scroll-horizontal-list-texturerects
	# using a boolean because it allows for only two options in it's data structure
	# True is up, false is down
	# Max is 449
	
	# Requires Delta Parameter for smooth scrolling 
	# but running this function as a static function means
	# it scrolls choppily
	
	
	if visible && direction:
		_scroller.scroll_vertical += 20 * scroll_constant  #* delta
	elif visible && !direction:
		_scroller.scroll_vertical -= 20 * scroll_constant  #* delta

		#print (scroller.scroll_vertical )#= scroll_constant  * delta

func _input(event): #Toggles menu visibility on/off
	if event.is_action_pressed("menu") == true :# 
		if menu_state == HIDDEN:
			menu_state = SHOWING
			set_focus_mode(Control.FOCUS_CLICK)
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
	
	"Auto Scroller"
	# Connects to Global Comics Swipe Feature
	#'AutoScroller'
	# Implemented but Requires Proper Swipe Gesture Callibration
	# 

	if Comics_v5._state == Comics_v5.SWIPE_RIGHT:
		
		
		# Scroll Down
		scroll(false, true,scroller)
	elif Comics_v5._state == Comics_v5.SWIPE_DOWN:
		
		# Scroll Up
		scroll(true, true,scroller)
		
	else: pass


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

	else:
		push_error("Error: initial_level shouldn't be empty")
		
	pass # Replace with function body.




#Handles Displaying the menu
func _menu_showing(): #Broken funtions #rewrite with state machine
	enabled = true 
	
	show()

	#set_focus_mode(2)
	
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
	# Memory Leak Management
	#
	# Clears all ui buttons
	Globals.MemoryManagement.queue_free_array(MenuButtons)
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
	return get_tree().change_scene_to((load('res://scenes/Wallet/Wallet main.tscn')))


func _on_Testing_Scene_pressed(): # turn off in release build
	Globals.current_level = 'res://scenes/levels/Testing Scene.tscn' #breaks the Globals.current_level script
	change_scenes_via_globals_script() 

func _on_City_scape_pressed(): #turn off in release build
	Globals.current_level = "res://scenes/levels/Cityscape Exterior.tscn"
	change_scenes_via_globals_script()

func upscale()-> void:
	# This is a quick fix. It should ideally find the center of the screen and 
	#position by an offset
	var newScale = Vector2(2,2)
	var newPosition = Vector2(-650,250)
	self.set_scale(newScale)
	self.set_position(newPosition)


func manually_translate()-> void:
	print ("Selected Language: ",Dialogs.language)
	#SHould Ideally Use Hashmap tuple + for loops  for translations
	if Dialogs.language != "" or null:
		#jggugu
		comics.set_text(Dialogs.translate_to("comics", Dialogs.language))
		new_game.set_text(Dialogs.translate_to("new game", Dialogs.language))
		continue_game.set_text(Dialogs.translate_to("continue", Dialogs.language))
		#game_menu.set_text(Dialogs.translate_to("comics", Dialogs.language))
		_multiplayer.set_text(Dialogs.translate_to("multiplayer", Dialogs.language))
		anime.set_text(Dialogs.translate_to("anime", Dialogs.language))
		practice.set_text(Dialogs.translate_to("practice", Dialogs.language))
		City_scape.set_text(Dialogs.translate_to("cityscape", Dialogs.language))
		wallet_ .set_text(Dialogs.translate_to("wallet", Dialogs.language))
		controls.set_text(Dialogs.translate_to("controls", Dialogs.language))
		quit.set_text(Dialogs.translate_to("quit", Dialogs.language))
