# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Game Control settings
# 
# To-Do:
# (1) Finish D-pad to Joystick button change illustration 
# (2) Add Swipe Gestures on/off controls
#(3) Include a GitHub Login, to encourage Players to Inspect the Code Base

extends Control

class_name GameControls


"""
Game Control settings
"""
#map game settings to save file
var selector #for the menu cycle selector

onready var back : Button = $ScrollContainer/VBoxContainer/back
onready var music : Button = $ScrollContainer/VBoxContainer/music
onready var _debug : Button = $ScrollContainer/VBoxContainer/debug
onready var Shuffle : Button =$ScrollContainer/VBoxContainer/shuffle
onready var Change_Controller_type : Button = get_node("ScrollContainer/VBoxContainer/change controller")

onready var github : Button = $ScrollContainer/VBoxContainer/github
onready var languague : Button = $ScrollContainer/VBoxContainer/languague
onready var help : Button = $ScrollContainer/VBoxContainer/help

# Auto Scroll with Swipe Gestures 
onready var scroller : ScrollContainer= get_node("ScrollContainer")

onready var ControlButtons : Array =  [back, music,_debug,Shuffle,Change_Controller_type, github, languague, help]

onready var _Help_hint : hint = get_node("Help popup")

func _ready():
	if get_tree().get_root().has_node("/root/Debug") == true:
		
		# OK bloc
		var debug__ = get_tree().get_root().get_node("/root/Debug")

	$ScrollContainer/VBoxContainer/back.grab_focus() #Back button grabs focus

	$TextureRect.hide()


	if Globals.screenOrientation == 1 && Globals.os == "Android":
		upscale_ui()

	manual_translate()


func _input(event):
	
	"Auto Scroller"
	# Connects to Global Comics Swipe Feature and Game Menu Scroller function
	#'AutoScroller'
	# Implemented but Requires Proper Swipe Gesture Callibration
	# 

	if Comics_v6._state == Comics_v6.SWIPE_RIGHT:
		
		
		# Scroll Down
		Game_Menu.scroll(false, true,scroller)
	elif Comics_v6._state == Comics_v6.SWIPE_DOWN:
		
		# Scroll Up
		Game_Menu.scroll(true, true,scroller)
		
	else: pass


func _on_Button_pressed():
	return get_tree().change_scene_to(Globals.title_screen) #changes scene to main title


"""
Turns Music on and off & shuffles current track. Fix code later
"""


"""

"""
#toggles Debug panel on and off
func _on_Debug_toggled(button_pressed): 
	if get_tree().get_root().get_node("/root/Debug") != null:
		if button_pressed:
		
			var a = InputEventAction.new()
			a.action = "Debug"
			a.pressed = true
			Input.parse_input_event(a)

			#debug__.stop_debug()
			$TextureRect2.show() #Shows Debug hint when in debug mode
			$TextureRect.hide()

'Changes Button Sizes for mobile UI'
# Scales UI up for Android Mobile Devices

func upscale_ui():
	#print (cinematic.calculateViewportSize(self))
	var newScale = Vector2(1.5,1.5)
	scroller.set_scale(newScale)
	scroller.margin_bottom = 850

func _on_Shuffle_pressed():
	#var _o =Music.playlist_one
	#Music.shuffle( )
	print ('shuffle pressed')








func _on_Networking_toggled(button_pressed):
	#if Networking.ads != null:
	#	if button_pressed:
	#		Networking.ads.hide_ads()
	#	else:
	#		Networking.ads.show_ads()
	print ('Place Holder Button, it does Nothing yet')

func _on_music_toggled(button_pressed): #Music on and off settings
	if button_pressed :
		Music.sound('off')
	else  :
		Music._notification(NOTIFICATION_APP_RESUMED)


func _on_Help_pressed():
	_Help_hint._ready()


func _on_Direction_controls_toggled(button_pressed):
	if button_pressed:
		#'direction'
		Globals.direction_control = Globals._controller_type[1]
		$ScrollContainer/VBoxContainer/Direction_controls.set_text(Globals.direction_control)
	else:
		#'analogue'
		Globals.direction_control = Globals._controller_type[2]
		$ScrollContainer/VBoxContainer/Direction_controls.set_text(Globals.direction_control)




func manual_translate()-> void:
	if Dialogs.language != "" or null:
		
		print(ControlButtons)
		Dialogs.set_font(ControlButtons)
		
		for i in ControlButtons:
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			i.set_text(Dialogs.translate_to(i.name, Dialogs.language))


"Memory Leak Management"
func _exit_tree():
	
	"Saves Player's Configuration"
	Globals.Functions.save_game([], 0, null, null, Globals.current_level, Globals.os, 0, null, null, Globals.direction_control, null)
	
	# FOr Memorey Management ( Garbage Collector)
	for i in ControlButtons:
		i.queue_free()
		


"Triggers Translation subsystem by changing scene to Form"
func _on_languague_pressed():
	Dialogs.reset()
	get_tree().change_scene("res://scenes/UI & misc/form/form.tscn")


func _on_Github_pressed():
	get_tree().change_scene("res://addons/github-integration/scenes/GitHub.tscn")
