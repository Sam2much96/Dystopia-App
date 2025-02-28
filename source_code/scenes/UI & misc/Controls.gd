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
# (1) Finish D-pad to Joystick button change illustration 
# (2) Add Swipe Gestures on/off controls
# (3) Include a GitHub Login, to encourage Players to Inspect the Code Base ( Done in Game HUD)
# (4) Implement Keyboard Layout for  player's help
# (5) Show Player's Gameplay stats
# *************************************************
#
# Bugs:
# (1) This scene resets presaved player settings
# (2) Fix Help UI
# 
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
onready var _debug : Button = $ScrollContainer/VBoxContainer/debug
onready var Shuffle : Button =$ScrollContainer/VBoxContainer/shuffle
onready var Change_Controller_type : Button = get_node("ScrollContainer/VBoxContainer/change controller")

onready var languague : Button = $ScrollContainer/VBoxContainer/languague
onready var help : Button = $ScrollContainer/VBoxContainer/help

# Auto Scroll with Swipe Gestures 
onready var scroller : ScrollContainer= get_node("ScrollContainer")
onready var _Help_hint : hint = get_node("Help popup")

# vibration
onready var vibration : Button = $ScrollContainer/VBoxContainer/HBoxContainer/vibration

# multiplayer
onready var _multiplayer : Button = $ScrollContainer/VBoxContainer/HBoxContainer3/multiplayer

onready var ControlButtons : Array =  [
	back, 
	music,
	_debug,
	Shuffle,
	Change_Controller_type, 
	languague, 
	help, 
	vibration,
	_multiplayer
	]



# COntroller Help
onready var _controller_help : Help = $"Help popup/Control"

onready var debug__ = get_tree().get_root().get_node("/root/Debug")
onready var music_ = get_tree().get_root().get_node("/root/Music")
onready var GInput_ = get_tree().get_root().get_node("/root/GlobalInput") # use set get functions for this logic

func _ready():
	#if get_tree().get_root().has_node("/root/Debug") == true:
	#	
	#	# OK bloc
	#	

	$ScrollContainer/VBoxContainer/back.grab_focus() #Back button grabs focus

	#$TextureRect.hide()
	#hide ingame menu
	Android.show_only_menu()
	

	if Globals.screenOrientation == 1 && Globals.os == "Android":
		upscale_ui()

	manual_translate()



func _on_Button_pressed():
	Globals._go_to_title() #changes scene to main title


"""
Turns Music on and off & shuffles current track. Fix code later
"""


"""

"""
#toggles Debug panel on and off
func _on_Debug_toggled(button_pressed): 
	if get_tree().get_root().get_node("/root/Debug") != null:
		if button_pressed:
			# Gets the Input node from the Touch Interface and uses that to parse input programmatically
			
			# node_input : Input ,tree: SceneTree, action : String, _pressed : bool
			GInput_.parse_input(GInput_.get_gameHUD().get_TouchInterface().TouchInput, get_tree(),"Debug", true)

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
		Music._notification(NOTIFICATION_APP_PAUSED)
	if not button_pressed  :
		Music._notification(NOTIFICATION_APP_RESUMED)


func _on_Help_pressed():
	_Help_hint.state = 0 # popup
	pass


func _on_Direction_controls_toggled(button_pressed):
	if button_pressed:
		#'direction'
		# To Do : Should Connect To TOuchScreenHUD Directly for changing controller values
		Globals.direction_control = Globals._controller_type[1]
		Change_Controller_type.set_text(Globals.direction_control)
	else:
		#'analogue'
		Globals.direction_control = Globals._controller_type[2]
		Change_Controller_type.set_text(Globals.direction_control)




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
	Utils.Functions.save_game(
		[],
		0,
		0, 
		0, 
		Globals.current_level, 
		Globals.os, 
		0, 
		"", 
		null, 
		Globals.direction_control)
	
	# FOr Memorey Management ( Garbage Collector)
	Utils.MemoryManagement.queue_free_array(ControlButtons)
#	for i in ControlButtons:
#		i.queue_free()
		


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
		GlobalInput.vibrate = !GlobalInput.vibrate
		vibration.set_text(str(GlobalInput.vibrate))
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


func _on_CRT_toggled(button_pressed):
	"""
	Turn Filter on/ off and save config settings
	"""
	
	pass

"""
THIRD PARTY SOFTWARE
"""

func _on_github_pressed():
	Utils.Functions.change_scene_to(Globals.github, get_tree())


func _on_wallet_pressed():
	Utils.Functions.change_scene_to(Globals._wallet, get_tree())


func _on_notifications_pressed():
	Android.Notifications.schedule("dkjfskjdf","sadfjshdfsdhf")
