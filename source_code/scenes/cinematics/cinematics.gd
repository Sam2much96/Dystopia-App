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
# Bugs:
#(1) Breaks on Mobile devices. Debug 
#(2) Lack of Documentation.
#(3)  
# TO DO:
#(1) Update Documentation
# (2) Use center y center of screen calculation to position video player

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
	#use current scene to trigger cinematic
	Globals.update_curr_scene()
	
	print('Cinematic Debug: /current scene/',  Globals.curr_scene) #for debug purposes
	'Plays only when the Scene is the cinematics scene'
	if Globals.curr_scene == 'Cinematics':
		play_opening_cinematic() #Plays this video only on cinematics node
		#set videoplayer rect size to viewport size
		videoplayer._set_size((get_viewport_rect().size))
	
	if vid_stream == null:
		push_error('vid_stream is null')
	
	
	
	pass
func _on_skip_pressed():
	videoplayer.stop()

	get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
			_free_memory(Globals.cinematics)



# Try Using Global Functions
func Video_Stream(stream): #This code works
	
	if stream != null: 
		#stream = stream.get_resource()
		videoplayer.set_stream(stream) 
		videoplayer.play() 
		cinematic_on= true
		


# warning-ignore:unused_argument
func _on_Intro_animation_animation_finished(anim_name): #unused animation code
	#get_tree().change_scene(Globals.title_screen)
	#Music.clear()
	pass





"Exkibits diffenent behaviours depending on a  'One shot ' option"
func _on_VideoPlayer_finished():
	cinematic_on= false
	
	if Globals.curr_scene == 'Cinematics': #I use this bool to define two states
		one_shot == true
		
		
		_free_memory(Globals.cinematics)
		get_tree().change_scene_to(Globals.title_screen)
		
	if one_shot == true:
		self.hide()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
		_free_memory(Globals.cinematics)
	#self.queue_free() #autodelete


func play_opening_cinematic():
	#Plays the opening cinematic 
	#loads resource into memory 
	vid_stream = Globals.cinematics #ResourceLoader.load_interactive(cinematic [0])
	Video_Stream(vid_stream)
	$Node2D/AudioStreamPlayer.play(0.0)
	#opening_cinematic_playing = false
	pass
'Rewrite function to be used via Extensions'
func _free_memory(items): # A Generic function to clear global variables once they've been used
	items = null




"""
CREATES AN VideoStreamTheora  .OGV  VIDEO FILE FROM A POOLBYE ARRAY
"""

# It needs a video file size and it will run as a loop as long as both aren't equal
func store_video_files(_body, size) -> VideoStreamTheora: # FUnvtion breaks here
	var video_file = File.new()
	var error_checker = File.new()
	
	if _body != null:
		# Add more error File error checkers
		
		#Writes a video file to the godot user's directory from a pool byte array
		video_file.open('user://video.ogv',File.WRITE)
		
		# Checks the Video file
		var err = (error_checker.open('user://video.ogv', File.READ))
		#Debug.misc_debug = str('VIdeo buffer: ' ,_body) # Debugs the video file
		 #store pool byte array as video buffer
		var video_file_path = video_file.get_path_absolute() #gets the file path
		print ('Video File path: ', video_file_path)
		var VIDEO = load(video_file_path)
		
		#return print ('Video FIle Path',video_file_path)
		#Comvert size to MB usingConvertfunctiion
		
		 # Gets VIdeo file length in bytes, converts it to MB
		var __video_file_size_mb = Globals._ram_convert(video_file.get_len())

		print ('Video file size: ',__video_file_size_mb, '/',' Est file size: ', size)# For debug purposes only
		#Stores PoolbyteArray into video file while the video file size is not the user's inputed video size
		if not error_checker.eof_reached() : # Original code uses a while loop. CHanging it because code breaks
			if _body != null:
				print ('Storing video buffer')
				video_file.store_buffer(_body.get_buffer())
		# Error checkers
			if __video_file_size_mb != size :
				print ('Video File size is not equal or greater than the inputed video file size 1')
				print ('Body (poolbytearray)',_body)
			if error_checker.get_len() != size:
				print('Video File size is not equal or greater than the inputed video file size 2')
			

			if error_checker.eof_reached(): # If the error checker has read through the body
				#break
				return video_file
			if __video_file_size_mb != null :
				if __video_file_size_mb >= size: 
					print ('STORAGE SUCCESS')
		video_file.close()
		return video_file
	return video_file
