extends Control
"""
Game Control settings
"""
#map game settings to save file
var selector #for the menu cycle selector

onready var debug__ = get_tree().get_root().get_node("/root/Debug")

func _ready():
	$VBoxContainer/back.grab_focus() #Back button grabs focus

	$TextureRect.hide()


	if Globals.screenOrientation == 1:
		upscale_ui()



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
func upscale_ui():
	var newScale = Vector2(3,3)
	$VBoxContainer.set_scale(newScale)


func _on_Shuffle_pressed():
	#var _o =Music.playlist_one
	#Music.shuffle( )
	print ('shuffle pressed')








func _on_Networking_toggled(button_pressed):
	if Networking.ads != null:
		if button_pressed:
			Networking.ads.hide_ads()
		else:
			Networking.ads.show_ads()
	print ('Place Holder Button, it does Nothing yet')

func _on_music_toggled(button_pressed): #Music on and off settings
	if button_pressed :
		#toggles music on and off
		#Music.music_on = false
		#Globals.Music_on_settings = false
		Music.sound('off')
	else  :
		#Music.notification(NOTIFICATION_UNPAUSED)
		
		#get_tree().get_root().add_child(Music) #doesnt work
		#Music.music_on = true
		Music._notification(NOTIFICATION_APP_RESUMED)
		#Globals.Music_on_settings = true

func _on_Help_pressed():
	$"Help popup"._ready()


func _on_Direction_controls_toggled(button_pressed):
	if button_pressed:
		Globals.direction_control = 'analogue'
		$VBoxContainer/Direction_controls.set_text(Globals.direction_control)
	else:
		Globals.direction_control = 'direction'
		$VBoxContainer/Direction_controls.set_text(Globals.direction_control)
