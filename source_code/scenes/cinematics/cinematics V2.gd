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
# *************************************************

class_name cinematic

export(String, FILE, "*.ogv") var vid_stream = ""

onready var animation : AnimationPlayer = $"animation player"
onready var position2d : Position2D = $Position2D
onready var node : Control = get_node("Node2D") #popup node for centering cinematics

#export (String) var anime_pilot : String = "https://github.com/Sam2much96/RenderChan/actions/runs/"
#export (String) var animatic : String = "https://youtu.be/uzDzAuJVHcI"

onready var videoplayer : VideoPlayer = $VideoPlayer


const Mobile_Platforms : Array = ["Android", "iOS"]
const Pc_Platforms : Array = ["X11", "Windows", "macOS"]
const Console_Platforms : Array = [""]

"""
CINEMATICS
"""
###export your video as ogv format
#update code to reference all in game animations

func _ready(): #create a video player function



	#use current scene to trigger cinematic
	Globals.update_curr_scene()
	
	'Screen Display Calculations'
	# Get Viewport Size, Make it Globally accessible
	# Calculations are now being run in GLobal Screen Class
	# Display calculations are now being run in Global Screen Class

	'Cinematics scene'
	if Globals.curr_scene == 'Cinematics':
		videoplayer  = get_node('VideoPlayer') #video player node
		videoplayer._set_size((get_viewport_rect().size))
		
		
		
		
		
		play_opening_cinematic() #Plays this video only on cinematics node
	
	" Anime Shop Scene "
	if Globals.curr_scene == "Shop":
		# Get the Parent
		var animationplayer : Control = $AnimationPlayer#get_node("AnimationPlayer")
		videoplayer = $AnimationPlayer/VideoPlayer
		print ("video player: ", videoplayer)# For Debug puroses only
		
		var episode1 : Button = $"africa icon/VBoxContainer/episode"
		var bts : Button = $"africa icon/VBoxContainer/behind the scenes"
		var animatic : Button = $"africa icon/VBoxContainer/animatic"
		var merch : Button = $"africa icon/VBoxContainer/merchandise"
		var guidebook : Button = $"africa icon/VBoxContainer/guide book"
		var back : Button = $back
		var UI_buttons_2 : Array = [episode1, bts,animatic, merch,guidebook, back]
		
		#print_debug("UI buttons: ",UI_buttons_2) #For Debug purposes only
		
		Dialogs.set_font(UI_buttons_2, 44, "",2)
		
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

	Globals._go_to_title()
	#get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
			Function._free_memory(Globals.cinematics)




static func Video_Stream(stream : VideoStreamTheora , os: String, video_parent : Control, videoplayer : VideoPlayer): #This code works
	#Use Position 2d node for Viewport Calibrations
	if os == "Android":
		videoplayer.expand = false
		
		#True Center of Screen
		video_parent.set_position(Vector2(0,0))
		
		print_debug("Video Player Position: ",videoplayer.get_position()) # For Debug Purposes only

	if os == "X11" or "Windows":
		
		#True Center of Screen
		videoplayer.set_position(Vector2((Globals.center_of_viewport.x/20),100)) # Globals.ceter_of_viewport calculation is off
	
	
	if stream != null: 
		videoplayer.visible = true
		videoplayer.set_stream(stream) 
		videoplayer.play() 
		



"Exhibits diffenent behaviours depending on a  'One shot ' option"
func _on_VideoPlayer_finished():
	_go_to_title()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
		Function._free_memory(Globals.cinematics)
	
	#self.queue_free() #autodelete


func _go_to_title():
	
	if Globals.curr_scene == 'Cinematics': #I use this bool to define two states
		
		
		
		#get_tree().change_scene_to(Globals.title_screen)
		Globals._go_to_title()
	if is_instance_valid(Globals.cinematics):
		# Free the Cinematics file from the Stack if loaded
		
		Function._free_memory(Globals.cinematics)

func play_opening_cinematic():
	#Plays the opening cinematic 
	#loads resource into memory 
	animation.play("opening_cinematic")
	# Playes a video stream to the video player in the scenetree
	
	return Music.play_track(Music.wind_sfx[0])



func load_OverworldMap():
	
	print (" Emitting signal--loading game--", Globals.current_level)
	"Load Overworld Map TO Memory"
	Globals.OverWorld = Utils.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress
		) 





# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Description:
# Anime Streamer Code
# Features
# (1) It Plays video through a global variable
# (2)It triggers an error splash page in the debug script if user is offline
# (3) It aids monetization through online advertising on Mobile
# *************************************************
# 
"""
THIS IS THE LOGIC FOR THE ANIME VIDEO STREAMER. iT WILL RENDER THE PILOT AND THE OPENING IN GODOT GAME ENGINE
"""

class Function :
	
	static func store_video_files(_body : PoolByteArray):
		var video_file : File = Utils.file #= File.new()
		video_file.open('user://video.ogv',File.WRITE)
		var _err = (video_file.open('user://video.ogv', File.WRITE_READ))
		if _err != OK:
			push_error(_err)
		video_file.store_buffer(_body) #store pool byte array as video buffer
		var video_file_path = video_file.get_path_absolute() #gets the file path
		print ('Video File path: ', video_file_path)
		Globals.VIDEO = video_file_path
		video_file.close()

	
	static func _free_memory(_items): # A Generic function to clear global variables once they've been used
		_items = null

	
	static func _check_download_size(loaded,total, downloading_video: bool, download_video_size : float): #Kinda works. Sort this code out first
		if downloading_video == true:
			if download_video_size == 0 or loaded == 0 or total == 0: #Error catcher 2
				#print ('Download video size:/', download_video_size, 'Loaded:/',loaded,'Total:/',total) #for debug purposes
				total = 1
			if download_video_size != null && total != 0 : # Error catcher 1
				var percent = (loaded)/total
				#while percent != 100:
				print('Downloading.../ ', percent, '%')

			if loaded == total and Globals.VIDEO != null:
				print (' Download Completed') 
		if downloading_video == false:
			pass



	static func cinematic_debug(videoplayer: VideoPlayer, vid_stream)-> void:
		Debug.misc_debug = str(int(videoplayer.stream_position)) + Globals.os + str(videoplayer.is_playing(),
		str(vid_stream) + videoplayer.get_stream_name()
		)

		
	"""
	CREATES AN VideoStreamTheora  .OGV  VIDEO FILE FROM A POOLBYE ARRAY
	"""

	# It needs a video file size and it will run as a loop as long as both aren't equal
	func _store_video_files(_body, size) -> VideoStreamTheora: # FUnvtion breaks here
		var video_file = Utils.file #File.new()
		var error_checker = Utils.file #File.new()
		
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








# Changes Scene Tree to Title Screen After Intro Finished Playing
func _on_animation_player_animation_finished(anim_name):
	if anim_name ==  "opening_cinematic":
		_go_to_title()




func _on_back_pressed():
	Globals._go_to_title()
