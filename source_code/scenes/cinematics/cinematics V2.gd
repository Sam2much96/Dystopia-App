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
#(1) Breaks on Mobile devices. Debug 
#(2) Lack of Documentation.
#(3)  
# *************************************************
# TO DO:
#(1) Update Documentation
# (2) Reorganise code into classes (Done)
# (3) Fix video Positionig on multiple devices
# (4) Guidebook SHould Use HTML Parser
###export your video as ogv format
#update code to reference all in game animations

# *************************************************

class_name cinematic

@export var vid_stream = "" # (String, FILE, "*.ogv")

@onready var animation : AnimationPlayer = $"animation player"
@onready var position2d : Marker2D = $Marker2D
@onready var node : Control = get_node("Node2D") #popup node for centering cinematics

#export (String) var anime_pilot : String = "https://github.com/Sam2much96/RenderChan/actions/runs/"
#export (String) var animatic : String = "https://youtu.be/uzDzAuJVHcI"

@onready var videoplayer : VideoStreamPlayer = $VideoStreamPlayer

@onready var local_globals : GlobalsVar = get_node("/root/Globals")
@onready var local_dialoges : DialogsVar = get_node("/root/Dialogs")

@onready var local_music : music_singleton = get_node("/root/Music")
@onready var wind_sfx : String = local_music.wind_sfx.get(0)

"""
CINEMATICS
"""

func _ready(): #create a video player function



	#use current scene to trigger cinematic
	local_globals.update_curr_scene()
	
	'Screen Display Calculations'
	# Get Viewport Size, Make it Globally accessible
	# Calculations are now being run in GLobal Screen Class
	# Display calculations are now being run in Global Screen Class

	'Cinematics scene'
	if local_globals.curr_scene == 'Cinematics':
		videoplayer  = get_node('VideoStreamPlayer') #video player node
		videoplayer._set_size((get_viewport_rect().size))
		
		
		
		
		
		play_opening_cinematic() #Plays this video only on cinematics node
	
	" Anime Shop Scene "
	if local_globals.curr_scene == "Shop":
		# Get the Parent
		var animationplayer : Control = $AnimationPlayer#get_node("AnimationPlayer")
		videoplayer = $AnimationPlayer/VideoStreamPlayer
		print ("video player: ", videoplayer)# For Debug puroses only
		
		var episode1 : Button = $"africa icon/VBoxContainer/episode"
		var bts : Button = $"africa icon/VBoxContainer/behind the scenes"
		var animatic : Button = $"africa icon/VBoxContainer/animatic"
		var merch : Button = $"africa icon/VBoxContainer/merchandise"
		var guidebook : Button = $"africa icon/VBoxContainer/guide book"
		var back : Button = $back
		var UI_buttons_2 : Array = [episode1, bts,animatic, merch,guidebook, back]
		
		#print_debug("UI buttons: ",UI_buttons_2) #For Debug purposes only
		
		local_dialoges.set_font(UI_buttons_2, 44, "",2)
		
		# Manually Translate UI
		# Disabled for testing 
		#for i in UI_buttons_2:
		#	# Note: If it breaks with a null object error, it means that the scene layout has been changed
		#	# Update the button links then
		#	i.set_text(Dialogs.translate_to(i.name, Dialogs.language))
		
	
	
	
	if vid_stream == null:
		push_error('vid_stream is null')
	
	
	
	pass
	
	
	

func _on_skip_pressed():
	videoplayer.stop()

	local_globals._go_to_title()
	#get_tree().change_scene_to(Globals.title_screen)
	if local_globals.curr_scene == 'Cinematics':
		pass



"Exhibits diffenent behaviours depending on a  'One shot ' option"
func _on_VideoPlayer_finished():
	_go_to_title()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	_go_to_title()
	if Globals.curr_scene == 'Cinematics':
		pass
	
	#self.queue_free() #autodelete


func _go_to_title() -> void:
	
	if local_globals.curr_scene == 'Cinematics': #I use this bool to define two states
		
		
		
		#get_tree().change_scene_to(Globals.title_screen)
		local_globals._go_to_title()
	if is_instance_valid(local_globals.cinematics):
		# Free the Cinematics file from the Stack if loaded
		
		pass

func play_opening_cinematic() -> int:
	#Plays the opening cinematic 
	#loads resource into memory 
	animation.play("opening_cinematic")
	# Playes a video stream to the video player in the scenetree
	
	await local_music.play_track(wind_sfx)
	return 0


func _exit_tree():
	# Clear The Memory
	local_globals.cinematics = null
	self.queue_free()




# Changes Scene Tree to Title Screen After Intro Finished Playing
func _on_animation_player_animation_finished(anim_name):
	if anim_name ==  "opening_cinematic":
		_go_to_title()




func _on_back_pressed():
	Globals._go_to_title()
