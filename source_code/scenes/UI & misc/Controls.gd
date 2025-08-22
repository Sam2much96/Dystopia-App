# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Game Control settings
#
# It controls gameplay global settings and stores those values to
# local device as user's preferred settings, preloaded on runtime
# ************************************************* 
# To-Do:

# (1) Serialise input states to controll ui
# 
# *************************************************
#
# Bugs:
# (1) This scene resets presaved player settings
# (2) Fix Help UI
# (3) Connect controls UI to menu enable and disable signals
# *************************************************

extends Control

class_name GameControls


"""
Game Control settings
"""
#map game settings to save file
var selector #for the menu cycle selector

onready var back : Button = $ScrollContainer/VBoxContainer/back
onready var music : Button = $ScrollContainer/VBoxContainer/HBoxContainer2/music
onready var music_checkbox : CheckBox = $ScrollContainer/VBoxContainer/HBoxContainer2/musicCheckBox
onready var _debug : Button = $ScrollContainer/VBoxContainer/HBoxContainer4/debug
onready var debugCheckbox : CheckBox = $ScrollContainer/VBoxContainer/HBoxContainer4/debugCheckbox
onready var Shuffle : Button =$ScrollContainer/VBoxContainer/shuffle

onready var languague : Button = $ScrollContainer/VBoxContainer/languague
onready var help : Button = $ScrollContainer/VBoxContainer/help

# Auto Scroll with Swipe Gestures 
onready var scroller : ScrollContainer= get_node("ScrollContainer")
#onready var _Help_hint : hint = get_node("Help popup")

# vibration
onready var vibration : Button = $ScrollContainer/VBoxContainer/HBoxContainer/vibration
onready var vibration_Checkbox : CheckBox = $ScrollContainer/VBoxContainer/HBoxContainer/CheckBox

# multiplayer
onready var _multiplayer : Button = $ScrollContainer/VBoxContainer/HBoxContainer3/multiplayer

onready var ControlButtons : Array =  [
	back, 
	music,
	_debug,
	Shuffle,
	languague, 
	help, 
	vibration,
	_multiplayer
	]



# COntroller Help
#onready var _controller_help : Help = $"Help popup/Control"

# safe pointers to global singletons
onready var safe_Globals = get_node("/root/Globals")
onready var safe_Utils = get_node("/root/Utils")
onready var safe_Debug = get_node("/root/Debug")
onready var safe_Music = get_node("/root/Music")
onready var safe_GameHUD = get_node("/root/GameHud")
onready var touchInterface = safe_GameHUD.get_TouchInterface() # use set get functions for this logic
onready var menuUI = safe_GameHUD.getMenu()
onready var safe_Simulation = get_node("/root/Simulation")

func _ready():
	
	safe_Utils.UI.check_for_broken_links(ControlButtons)
	
	# hide Menu UI
	menuUI.hidden()
	
	safe_Utils.Functions.load_user_data("music", get_tree()) # works
	

	if safe_Globals.screenOrientation == 1 && safe_Globals.os == "Android":
		upscale_ui()

	manual_translate()

	music_checkbox.toggle_mode = true
	vibration_Checkbox.toggle_mode = true
	
	music_checkbox.pressed = Music.enable


func _on_back_pressed():
	safe_Globals._go_to_title() #changes scene to main title


"""
Turns Music on and off & shuffles current track. Fix code later
"""


"""

"""
#toggles Debug panel on and off
func _on_Debug_toggled(button_pressed): 
	if safe_Debug != null:
		if button_pressed:
			safe_Debug.start_debug_v1()
		else:
			safe_Debug.stop_debug()
		debugCheckbox.pressed = safe_Debug.enabled

func _on_debugCheckbox_toggled(button_pressed):
	if safe_Debug != null:
		if button_pressed:
			safe_Debug.start_debug_v1()
		else:
			safe_Debug.stop_debug()

'Changes Button Sizes for mobile UI'
# Scales UI up for Android Mobile Devices

func upscale_ui():
	print_debug("Upscaling controls UI")
	#print (cinematic.calculateViewportSize(self))
	var newScale = Vector2(1.5,1.5)
	scroller.set_scale(newScale)
	scroller.margin_bottom = 850

func _on_Shuffle_pressed():
	#var _o =Music.playlist_one
	#Music.shuffle( )
	print ('shuffle pressed')


func _on_music_toggled(button_pressed): #Music on and off settings
	if button_pressed :
		safe_Music._notification(NOTIFICATION_APP_PAUSED)
		music_checkbox.pressed = false
	if not button_pressed  :
		safe_Music._notification(NOTIFICATION_APP_RESUMED)
		music_checkbox.pressed = true

func _on_musicCheckBox_toggled(button_pressed):
	if button_pressed :
		safe_Music._notification(NOTIFICATION_APP_RESUMED)
		#music_checkbox.pressed = true
	else  :
		safe_Music._notification(NOTIFICATION_APP_PAUSED)
		#music_checkbox.pressed = false
		
func _on_Help_pressed():
	# uses a pop up node to show the help scene
	# help scene requires graphics refactoring
	#_Help_hint.state = 0 # popup
	pass




func manual_translate()-> void:
	if Dialogs.language != "" or null:
		
		#print(ControlButtons) # for debug purposes only
		Dialogs.set_font(ControlButtons, 44, "",3)
		
		for i in ControlButtons:
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			i.set_text(Dialogs.translate_to(i.name, Dialogs.language))


"Memory Leak Management"
func _exit_tree():
	
	"Saves Player's PreferedConfiguration"
	#temporarily disabled for refactor
	#Utils.Functions.save_game(
	#	[],
	#	0,
	#	0, 
	#	0, 
	#	Globals.current_level, 
	#	Globals.os, 
	#	0, 
	#	"", 
	#	null, 
	#	Globals.direction_control)
	
	# FOr Memorey Management ( Garbage Collector)
	Utils.MemoryManagement.queue_free_array(ControlButtons)



"Triggers Translation subsystem by changing scene to Form"
func _on_languague_pressed():
	Dialogs.reset()
	Utils.Functions.change_scene_to(load("res://scenes/UI & misc/form/form.tscn"), get_tree())


#func _on_Github_pressed():
#	get_tree().change_scene("res://addons/github-integration/scenes/GitHub.tscn")


func _on_vibration_toggled(button_pressed):
	# Toggle Vibrations on/off for mobile devices
	# TO Do: Implement Saving Vibration settings (Done)
	if button_pressed:
		# bug: (1) vibrate is not available on touch interface 
		touchInterface.vibrate_ = !touchInterface.vibrate_
		vibration_Checkbox.pressed = touchInterface.vibrate_
		
		
		# to do : set vibration checkbox to touch interface vibrate state
	else: pass


func _on_multiplayer_toggled(button_pressed):
	# Toggles between Online MMO and Local Coop
	# Uses a Networking Enumerator to Setup 
	# Should Connect to A Global Signleton that's saved locally
	# Bugs: 
	# (1) Might Break Player Logic in overworld scenes
	if button_pressed:
		if _multiplayer.text == "online mmo":
			Networking.GamePlay = Networking.LOCAL_COOP
			return _multiplayer.set_text("local coop")
		else:
			_multiplayer.set_text("online mmo")
			Networking.GamePlay = Networking.MMO_SERVER


"""
THIRD PARTY SOFTWARE
"""






