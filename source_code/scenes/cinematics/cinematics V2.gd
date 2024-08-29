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
# (5) 
# *************************************************
export(String, FILE, "*.ogv") var vid_stream = ""

onready var animation = get_node("animation player") # AnimationPlayer 
onready var position2d = get_node("Position2D")
onready var node = get_node("Node2D") #popup node for centering cinematics

#export (String) var anime_pilot : String = "https://github.com/Sam2much96/RenderChan/actions/runs/"
#export (String) var animatic : String = "https://youtu.be/uzDzAuJVHcI"

onready var videoplayer = get_node("VideoPlayer")

#"""
#CINEMATICS
#"""
###export your video as ogv format
#update code to reference all in game animations

onready var local_globals = get_node("/root/Globals") #: GlobalsVar 
onready var local_dialogs = get_node("/root/Dialogs") #: DialogsVar 

onready var local_music = get_node("/root/Music") #: music_singleton 
onready var wind_sfx = local_music.wind_sfx.get(0) #: String 



func _ready(): #create a video player function
	
	
	
	#use current scene to trigger cinematic
	local_globals.update_curr_scene()
	
	'Screen Display Calculations'
	# Get Viewport Size, Make it Globally accessible
	# Calculations are now being run in GLobal Screen Class
	# Display calculations are now being run in Global Screen Class

	'Cinematics scene'
	if local_globals.curr_scene == 'Cinematics':
		videoplayer  = get_node('VideoPlayer') #video player node
		videoplayer._set_size((get_viewport_rect().size))
		
		
		
		
		
		play_opening_cinematic() #Plays this video only on cinematics node
	
	" Anime Shop Scene "
	if local_globals.curr_scene == "Shop":
		# Get the Parent
		var animationplayer = get_node("AnimationPlayer")# : Control #get_node("AnimationPlayer")
		videoplayer = get_node("AnimationPlayer/VideoPlayer")
		print ("video player: ", videoplayer)# For Debug puroses only
		
		var episode1 = get_node("africa icon/VBoxContainer/episode") #: Button
		var bts = get_node("africa icon/VBoxContainer/behind the scenes") # : Button
		var animatic = get_node("africa icon/VBoxContainer/animatic") # : Button 
		var merch = get_node("africa icon/VBoxContainer/merchandise") # : Button 
		var guidebook = get_node("africa icon/VBoxContainer/guide book") # : Button 
		var back = get_node("back") # : Button 
		var UI_buttons_2  = [episode1, bts,animatic, merch,guidebook, back] # : Array
		
		#print_debug("UI buttons: ",UI_buttons_2) #For Debug purposes only
		
		local_dialogs.set_font(UI_buttons_2, 44, "",2)
		
		# Manually Translate UI
		# Disabled for testing 
		#for i in UI_buttons_2:
		#	# Note: If it breaks with a null object error, it means that the scene layout has been changed
		#	# Update the button links then
		#	i.set_text(Dialogs.translate_to(i.name, Dialogs.language))
		
	
	
	
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
	videoplayer.stop()
	local_globals._go_to_title()
	if local_globals.curr_scene == 'Cinematics':
			Function._free_memory(local_globals.cinematics) # Self




#"Exhibits diffenent behaviours depending on a  'One shot ' option"
func _on_VideoPlayer_finished():
	_go_to_title()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	_go_to_title()
	if local_globals.curr_scene == 'Cinematics':
		Function._free_memory(local_globals.cinematics)
	
	#self.queue_free() #autodelete


func _go_to_title(): # -> void: 
	
	if local_globals.curr_scene == 'Cinematics': #I use this bool to define two states
		
		
		
		#get_tree().change_scene_to(Globals.title_screen)
		local_globals._go_to_title()
	if is_instance_valid(local_globals.cinematics):
		# Free the Cinematics file from the Stack if loaded
		
		Function._free_memory(local_globals.cinematics)

func play_opening_cinematic() : #-> int :
	#Plays the opening cinematic 
	animation.play("opening_cinematic")
	
	local_music.play_track(wind_sfx)
	return 0


