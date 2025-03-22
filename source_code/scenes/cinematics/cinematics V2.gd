extends Control

# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is the cinematics script
# information used by the ciematic scenes .
# organize this code 
# *************************************************
#Features:
#(1) It Plays an 'Opening Cinematic' which is also used as a loading progress.
#(2) Can download and locally store video streams off the internet
	#- Feature is implemented on PC, partially implemented on mobiles
# (3) Sets Global Screen Orientation
# ********************************************************************
# Bugs:
#(1) Redraw animation video assets to scale to mobile 
#(2) 
#(3)  
# *************************************************
# 
# 
# *************************************************

class_name cinematic

export(String, FILE, "*.ogv") var vid_stream = ""

onready var animation : AnimationPlayer = $"animation player"

#onready var videoplayer : VideoPlayer = $VideoPlayer

"""
CINEMATICS
"""

onready var local_globals : GlobalsVar = get_node("/root/Globals")
#onready var local_dialogs : DialogsVar = get_node("/root/Dialogs")
onready var local_android  : android = get_node("/root/Android")
onready var local_music : music_singleton = get_node("/root/Music")
onready var wind_sfx : String = Music.wind_sfx.get(0)

func _ready(): 
	
	#local_android.hide_touch_interface()
	

	
	#use current scene to trigger cinematic
	local_globals.update_curr_scene()
	
	'Screen Display Calculations'
	# Get Viewport Size, Make it Globally accessible
	# Calculations are now being run in GLobal Screen Class
	# Display calculations are now being run in Global Screen Class

	'Cinematics scene'
	if local_globals.curr_scene == 'Cinematics':
		#videoplayer  = get_node('VideoPlayer') #video player node
		#videoplayer._set_size((get_viewport_rect().size))
		
		
		play_opening_cinematic() #Plays this video only on cinematics node
	
	
	
	if vid_stream == null:
		push_error('vid_stream is null')
	
	
	
	pass


# Changes Scene Tree to Title Screen After Intro Finished Playing
func _on_animation_player_animation_finished(anim_name):
	if anim_name ==  "opening_cinematic":
		_go_to_title()




func _on_back_pressed():
	_go_to_title()



func _on_skip_pressed():
	print_debug("Skip Button Pressed")
	#videoplayer.stop()
	local_globals._go_to_title()




"Exhibits diffenent behaviours depending on a  'One shot ' option"
#func _on_VideoPlayer_finished():
#	_go_to_title()

#func _on_Timer_timeout():
#	push_error('Cinematic scene broken')
#	_go_to_title()
#	if local_globals.curr_scene == 'Cinematics':
#		pass


func _go_to_title() -> void: 
	
	if local_globals.curr_scene == 'Cinematics': #I use this bool to define two states
		local_globals._go_to_title()
		#animation.play("titlescreen")

func play_opening_cinematic() -> int :
	#Plays the opening cinematic 
	animation.play("opening_cinematic")
	
	local_music.play_track(wind_sfx)
	
	#fetch asset price
	return 0

func _exit_tree():
	# Free Memory
	local_globals.cinematics = null
	self.queue_free()

