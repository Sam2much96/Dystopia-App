# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Game Control settings
# 
# To-Do:
# (1) Finish D-pad to Joystick button change illustration 
# (2) Add Swipe Gestures on/off controls
#(3) Include a GitHub Login

extends Control

class_name GameControls


"""
Game Control settings
"""
#map game settings to save file
var selector #for the menu cycle selector

onready var back : Button = $ScrollContainer/VBoxContainer/back
onready var music : Button = $ScrollContainer/VBoxContainer/music
onready var debug : Button = $ScrollContainer/VBoxContainer/Debug
onready var Shuffle : Button =$ScrollContainer/VBoxContainer/Shuffle
onready var Change_Controller_type : Button = $ScrollContainer/VBoxContainer/Direction_controls

# Auto Scroll with Swipe Gestures 
onready var scroller : ScrollContainer= get_node("ScrollContainer")

onready var ControlButtons : Array =  [back, music,debug,Shuffle,Change_Controller_type]

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
	$"Help popup"._ready()


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
		
		back .set_text(Dialogs.translate_to("back", Dialogs.language))
		music .set_text(Dialogs.translate_to("music", Dialogs.language))
		debug .set_text(Dialogs.translate_to("debug", Dialogs.language))
		Shuffle.set_text(Dialogs.translate_to("shuffle", Dialogs.language))
		Change_Controller_type.set_text(Dialogs.translate_to("change controller", Dialogs.language))



"Memory Leak Management"
func _exit_tree():
	for i in ControlButtons:
		i.queue_free()
