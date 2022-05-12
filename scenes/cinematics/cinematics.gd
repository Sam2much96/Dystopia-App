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
#It Plays an 'Opening Cinematic' which is also used as a loading progress.
# Bugs:
#(1) Breaks on Mobile devices. Debug 
#(2) Lack of Documentation.
#(3)  

class_name cinematic


#save resource to a .tres file
#update code to use as videoplayer's base node to play all videos in the scene
export (bool) var one_shot 
export (bool) var cinematic_on = true
#it only works with ogv files
export(String, FILE, "*.ogv") var vid_stream = ""
   
enum  {SINGLE_PLAY,LOOP, NO_PLAY}

export var state = SINGLE_PLAY
#Ref<ResourceInteractiveLoader> ResourceLoader::load_interactive(String p_path)#experimental code to load resource
onready var animation = $"animation player"
onready var videoplayer = get_node('Node2D/VideoPlayer') #video player node
onready var os 
var cinematic = {
	0:'res://resources/title animation/title..ogv',
	1:'', #convert video to ogv
	}

"""
CINEMATICS
"""
###export your video as ogv format
#update code to reference all in game animations


func _ready(): #create a video player function
	play_opening_cinematic() #Plays this video on a loop
	if vid_stream == null:
		push_error('vid_stream is null')
	
	#set videoplayer rect size to viewport size
	videoplayer._set_size((get_viewport_rect().size))
	
	
	pass
func _on_skip_pressed():
	videoplayer.stop()
	get_tree().change_scene_to(Globals.title_screen)



# Try Using Global Functions
func Video_Stream(stream): #This code works
	if stream!= null:
		#stream = stream.get_resource()
		videoplayer.set_stream(stream) 
		videoplayer.play() 
		cinematic_on= true
		


# warning-ignore:unused_argument
func _on_Intro_animation_animation_finished(anim_name): #unused animation code
	#get_tree().change_scene(Globals.title_screen)
	#Music.clear()
	pass


# Write youtube Download function

func yt_download(): #downloads videos from the yt channel. streams it in app
	var yt =load('res://New game code and features/youtube streamer/Youtube-DL.gd')
	#improve the cinematic playing function. Pass the youtube video to it for streaming anime
	yt._init()
	pass



func _on_VideoPlayer_finished():
	cinematic_on= false
	
	if one_shot == false: #I use this bool to define two states
		one_shot == true
		get_tree().change_scene_to(Globals.title_screen)
		
	if one_shot == true:
		self.hide()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	get_tree().change_scene_to(Globals.title_screen)
	self.queue_free() #autodelete


func play_opening_cinematic():
	#Plays the opening cinematic 
	#loads resource into memory 
	vid_stream = Globals.cinematics #ResourceLoader.load_interactive(cinematic [0])
	Video_Stream(vid_stream)
	$Node2D/AudioStreamPlayer.play(0.0)
	#opening_cinematic_playing = false
	pass


