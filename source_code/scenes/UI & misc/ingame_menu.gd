# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Ingame Menu for Android
# 
# Features:
# (1) State Machine
# (2) Object listens for the menu button propagated
# (3) Auto scalling on mobile screens
#
# To Do:
#
#(1) Impement State Machine (done)
# (2) Scales for mobile UI (done)
# (3) Translations
# (4) Sets Global Screen Orientation
# (5) Ingame Menu Has 2 behaviours depending on the current scene
#		# (a) Trigger Touch HUD menu state when not in overworld
#		# (b) Triggers Touch menu visible state when in overworld
#	The signal emitting function should account for this
# *************************************************

# To-Do
# (1) Implement Different States (Portrait & LandScape) Using Global Screen Orientation
# (2) Connect Menu Object to Menu Singleton to trigger Menu States


#Bugs 
# (1) Buggy on Screen Orientation Rotation
# (2) Implements Swipe Gestures for Auto Scroll using refactores swipe detection
# (3) Should implement Touch Input without emulation, maybe by morhing the button type or autogenerating /duplicating body
# *************************************************

extends Control


class_name Game_Menu

#signal menu_hidden_in_ui
#signal menu_hidden_in_game
signal menu_showing
signal menu_hidden

export (bool) var enabled 
var showingObject : bool = false
"""
The game menu script. 
"""

enum { SHOWING, HIDDEN}

export (String) var menu_state


#export (bool) var ENABLE  : bool 

# Stops ooverflow of Upscaling Method
# stops signal spamming

#var counter : int = 0 

var comics : Button 
var new_game : Button 

var continue_game : Button  

var _multiplayer : Button 

#var anime : Button 
var practice : Button 
var controls : Button 
var quit : Button 


# Auto Scroll with Swipe Gestures
var scroller : ScrollContainer

var MenuButtons : Array = []

"Safe Pointers To global Singletons"
onready var safe_Music = get_node("/root/Music")
onready var safe_Android = get_node("/root/Android")
onready var safe_Globals = get_node("/root/Globals")
onready var safe_Utils = get_node("/root/Utils")
onready var safe_Dialogs = get_node("/root/Dialogs")
onready var safe_Networking = get_node("/root/Networking")

"safe Pointers to the Menu UI elemt"
onready var safe_UI = get_parent().get_node("TouchInterface")

onready var _ui_sfx : String = safe_Music.ui_sfx.get(0)
onready var _ui_sfx_1 : String = safe_Music.ui_sfx.get(1)

const newScale = Vector2 (2,2)
const initialScale = Vector2(1,1)

func _ready():
	# set pointer to the touch interface which has the touch screen UI buttons
	safe_UI.menuObj = self
	
	# Make Globalm but don't overwrite memory address
	if safe_Android.ingameMenu == null:
		safe_Android.ingameMenu = self
	
	print_debug("todo: Connect Menu Object to UI button using signals", self.name, safe_UI.menuObj)
	#GlobalInput.menu = self
	
	#Buttons
	comics  = $ScrollContainer/HSeparator/lore
	new_game  = $"ScrollContainer/HSeparator/new game"
	continue_game = get_node("ScrollContainer/HSeparator/continue") 
	_multiplayer = $ScrollContainer/HSeparator/multiplayer
	practice = $ScrollContainer/HSeparator/practice
	controls = $ScrollContainer/HSeparator/controls
	quit  = $"ScrollContainer/HSeparator/quit"


	# Auto Scroll with Swipe Gestures
	scroller= get_node("ScrollContainer")

	MenuButtons = [comics,new_game, continue_game, _multiplayer, practice,controls, quit]

	" Translation"
	
	manually_translate()
	
	"Scales for Mobile UI"
	# Disabling for debuggin
	
	
	'Hides the Menu once the scene tree is ready'
	
	showingObject = false
	hidden()
	

"""
Menu State As Functions
Features:
	(1) Manipulates state machine of Menu object 
	(2) Exports state machine via function to Touch Screen HUD UI menu button presses
"""

func showing():
	
	#print_debug("Showing Menu")
	set_focus_mode(Control.FOCUS_CLICK)
	set_mouse_filter(Control.MOUSE_FILTER_STOP)
	safe_Music.play_track(_ui_sfx)
	show()
	emit_signal("menu_showing")


func hidden():
	#print_debug("Hiding Menu")
	hide()
	emit_signal("menu_hidden")
	safe_Music.play_track(_ui_sfx_1)
	set_focus_mode(Control.FOCUS_NONE)
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

		
		
		
		
		
		#depreciated signals
		# duplicated signals?
		# check if current scene is a global scene or a game scene
		#if !safe_Globals.global_scenes.has(safe_Globals.curr_scene):
		#	emit_signal("menu_hidden_in_game")
		
		# menu hidden outside main game loop
		#if safe_Globals.global_scenes.has(safe_Globals.curr_scene):
			#print_debug("Current Level Debug 2: ", Globals.current_level)
		#	emit_signal("menu_hidden_in_ui")
		
		#return menu_state
		
	
	#get_tree().set_input_as_handled()


func _on_new_game_pressed(): #breaks the Globals.current_level script
	print_debug("new game pressed")
	if safe_Globals.initial_level != "":
		
		# current way to load game
		
		# Sets the Current Level to the defauult initial level
		safe_Globals.current_level = safe_Globals.initial_level
		
		

		# shance scene to loading scene with nspecialized logic for device loadi handling
		safe_Utils.Functions.change_scene_to(safe_Globals.loading_scene,get_tree() )
		
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
		
		safe_Utils.Functions.save_game(get_tree())

		safe_Music.play_track(_ui_sfx) #plays ui sfx in a loop
		
		
		menu_state = HIDDEN
		
		return 0

#Handles Displaying the menu

""" Menu Function Connected To Touch interface HUD"""
func _menu_button_pressed() -> bool: 
	"All Menu Visibility Logic"
	
	print_debug("Menu Button Pressed/ ", self.name, "/", showingObject)
	#menu_state = SHOWING
	if !showingObject: 
		showing()
		#hidden()
		showingObject = true
		return showingObject
	
	if showingObject : 
		hidden()
		showingObject = false
		return showingObject
	return showingObject
	
	
	#return show() if visible else hide()

#Handles Hiding the menu
func _menu_not_showing():
	
	enabled = false
	hide()



#Handles Pausing the Menu
func _menu_pause_and_play(boolean): #pass it a boolean to custom pause and play
	get_tree().set_pause(boolean)


func _on_lore_pressed():
	print_debug ('comics pressed')
	safe_Music.play_track(_ui_sfx)
	#Utils.Functions.change_scene_to(Globals.comics___2, get_tree())
	
	# Open URL to My Website
	safe_Networking.open_browser("https://dystopia-app.site")


func _on_controls_pressed():
	safe_Music.play_track(_ui_sfx)
	safe_Utils.Functions.change_scene_to(load(safe_Globals.global_scenes["Controls"]), get_tree())
	
	menu_state = HIDDEN
	
	return 0

func _on_quit_pressed():
	if safe_Globals.curr_scene == 'Title screen': # Title Screen Custom Quit
		safe_Music.play_track(_ui_sfx_1)
		get_tree().quit()
	
	if safe_Globals.curr_scene == 'form': # Mutiplayer Login Custom Quit
		safe_Music.play_track(_ui_sfx_1)
		get_tree().quit()
	else:
		safe_Music.play_track(_ui_sfx_1)
		#Globals.memory_leak_management()
		#Utils.Functions.change_scene_to(Globals.title_screen, get_tree())
		safe_Globals._go_to_title()


func _on_multiplayer_pressed(): # Experimental feature
	safe_Music.play_track(_ui_sfx)
	
	return safe_Utils.Functions.change_scene_to(load(Globals.global_scenes.get("login")), get_tree())



func _exit_tree():
	# Memory Leak Management
	#
	# Clears all ui buttons
	
	safe_Utils.MemoryManagement.queue_free_array(MenuButtons)
	safe_Music._notification(NOTIFICATION_UNPAUSED) #resets music when exiting scene tree
	self.queue_free()

func _on_practice_pressed(): # turn off in release build
	# To DO:
	# (1) refactor practice scene to forced tutorial scene for new players
	# (2) Fix audo delete save file bug in form.tscn
	safe_Globals.current_level = safe_Globals.global_scenes["practice"] #'res://scenes/levels/Testing Scene 2.tscn' #breaks the Globals.current_level script
	safe_Utils.Functions.change_scene_to(safe_Globals.loading_scene,get_tree() )


func manually_translate()-> void:
	#print_debug ("Selected Language: ",Dialogs.language)
	#SHould Ideally Use Hashmap tuple + for loops  for translations
	#print_debug(MenuButtons)
	
	if safe_Dialogs.language != "" or null:
		#print_debug(Dialogs.language)
		
		#UI Array & Font Size
		safe_Dialogs.set_font(MenuButtons, 44, "", 2)
		
		# Set UI Text to Translated Names
		for i in MenuButtons:
			
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			
			i.set_text(safe_Dialogs.translate_to(i.name, safe_Dialogs.language))



