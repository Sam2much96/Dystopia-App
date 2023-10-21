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
# Bugs:
#(1) Breaks on Mobile devices. Debug 
#(2) Lack of Documentation.
#(3)  
# TO DO:
#(1) Update Documentation
# (2) Reorganise code into classes (Done)
# (3) Fix video Positionig on multiple devices
# (4) Guidebook SHould Use HTML Parser

class_name cinematic

#hvjhvjhv

export (bool) var cinematic_on = true
export(String, FILE, "*.ogv") var vid_stream = ""

# Cread Object
var yt_dlp = null # Depreciated Code #YtDlp.new()
onready var dialgue_box = $Dialog_box
onready var animation : AnimationPlayer = $"animation player"
onready var position2d : Position2D = $Position2D
onready var os 
onready var node = get_node("Node2D") #popup node for centering cinematics

"Cinematics DIctionary"
# Modify Dictionary to Account for .ogv files
# While .webm works well on PC, .ogv works best on Mobiles
# Implement Global.os to togle btw .ogv and .webm
const cinematic : Dictionary = {
	0:'res://resources/title animation/title..ogv',
	"Test": "user://Test.webm", #convert video to ogv
	"Ep1": "user://Ep1.webm",
	"FightScene": "user://Fightscene.webm",
	"Animatic" : "user://Animatic.webm"
	}


"Youtube Urls as a Dictionary Parameters"
const youtube : Dictionary = {
	"Test":'https://youtube.com/shorts/YCwou4oX12I?feature=share', # Testing
	"Ep1":'https://youtu.be/oJY1rIxC4kk', # Ep 1
	"FightScene": 'https://youtu.be/uzDzAuJVHcI', # Behind the Scenes
	"Animatic": 'https://youtu.be/EAL8Mu2-f7Q' # Animatic
	}

var videoplayer : VideoPlayer


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
		
		print_debug("UI buttons: ",UI_buttons_2) #For Debug purposes only
		
		Dialogs.set_font(UI_buttons_2)
		
		# Manually Translate UI
		for i in UI_buttons_2:
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			i.set_text(Dialogs.translate_to(i.name, Dialogs.language))

		
		# File Doesn't Exist but user has good internet
		if not Utils.check_files(Globals.user_data_dir, cinematic["Test"]) && Globals.os != "Android": 
			pass
		
		
		# Checks if Video File is locally available
		# File Exists
		if Utils.check_files(Globals.user_data_dir, "user://Test.webm") :
			pass
	
	if vid_stream == null:
		push_error('vid_stream is null')
	
	
	
	pass

func _input(_event):
	if is_instance_valid(dialgue_box): # Hides Dialgue
		dialgue_box.hide_dialogue()

func _on_skip_pressed():
	videoplayer.stop()

	Globals._go_to_title()
	#get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
			Function._free_memory(Globals.cinematics)




func Video_Stream(stream, os: String): #This code works
	#Use Position 2d node for Viewport Calibrations
	
	if os == "Android":
		videoplayer.expand = false
		
		#True Center of Screen
		self.set_position(Vector2(-(Globals.center_of_viewport.x),300))
		#videoplayer.set_position($Position2D.position) #Video Player Position: (-1334.26001, 412.127014)

		
		print("Video Player Position: ",videoplayer.get_position()) # For Debug Purposes only

	if os == "X11" or "Windows":
		
		#print (Globals.center_of_viewport) # for debug purposes only
		#True Center of Screen
		videoplayer.set_position(Vector2((Globals.center_of_viewport.x/20),100)) # Globals.ceter_of_viewport calculation is off
		#videoplayer.set_position($Position2D.position) 

	
	
	if stream != null: 
		videoplayer.visible = true
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
		
		
		
		Function._free_memory(Globals.cinematics)
		#get_tree().change_scene_to(Globals.title_screen)
		Globals._go_to_title()

func _on_Timer_timeout():
	push_error('Cinematic scene broken')
	get_tree().change_scene_to(Globals.title_screen)
	if Globals.curr_scene == 'Cinematics':
		Function._free_memory(Globals.cinematics)
	#self.queue_free() #autodelete


func play_opening_cinematic():
	#Plays the opening cinematic 
	#loads resource into memory 
	#vid_stream = Globals.cinematics #ResourceLoader.load_interactive(cinematic [0])
	
	#videoplayer.expand = true
	
	Video_Stream(Globals.cinematics, Globals.os)
	
	return Music.play_track(Music.wind_sfx[0])



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
# To DO:
#(1) integrade youtube download through networking singleton
# (2) Integrate video stream with proper documentation
# (3) Integrate youtube links
#extends Control
"""
THIS IS THE LOGIC FOR THE ANIME VIDEO STREAMER. iT WILL RENDER THE PILOT AND THE OPENING IN GODOT GAME ENGINE
"""
##### IF IT BREAKS, IT BREAKS
# The optimized code would unzip a video file zip to the user's directory
export (VideoStreamTheora )var video_file
export (String)var err

var downloading_video = false


# Feature is broken
#var vid_file_mob = Globals.pilot_ep
var dicL1 : Dictionary = {}

onready var dir = Directory.new()



var download_video_size = 1
var percent
onready var error_code = 0


var pilot_ep_scene = load ('res://scenes/cinematics/pilot_ep_1.tscn')

#Declare some animation variables
#var animmation_frames
#var NFT

func _on_Button_pressed():
	return Globals._go_to_title()

func download_yt_video():
	# It should take a parameter to download different videos 
	# without affecting it's signals.
	# How to pass parameters through signls
	
	#dialgue_box.show_dialog( ("Downloading YT video: " + youtube[0]),  "admin")
	print ("Downloading YT video: " + youtube.get(1, "") + "Depreciated code") 
	#Download video using url to local storage
	#yt_dlp.download(youtube[1],OS.get_user_data_dir(),cinematic["user://Test.webm"] ) # The cinematics dictionary returns the key as the File Save name
	

func stream_yt_video():
	
	dialgue_box.show_dialog("Playing YT Video", "admin ")
	print("Playing YT Video")
	
	# Play Downloaded Video file
	var stream := VideoStreamWebm.new()
	stream.set_file(cinematic["Test"])
	Video_Stream(stream, Globals.os)

func _on_watch_anime_pressed():
	# Get Animated Pilot Ep
	
	cinematics_get("Ep1")
	
	Music._notification(NOTIFICATION_APP_PAUSED)#Shuts off music
	
	$Label.hide()
	#videoplayer._play_pilot_a() #depreciated in v1.1.9 for size problems
	#


func cinematics_get(parameters : String) :
	
	return OS.shell_open(youtube[parameters])
	
	
	# Enables Polymorphism of Cinematics Yt Downloader & Streamer
	# Disabled for Refactoring and Debugging
	"""
	for i in Mobile_Platforms:
		# PC Platforms
		if Globals.os != i && Globals.check_files(Globals.user_data_dir, cinematic[parameters]):  
			
			if Networking.good_internet:
				
				# PC platforms
				var stream := VideoStreamWebm.new()
				stream.set_file(cinematic[parameters])
				dialgue_box.show_dialog("Playing " + parameters + ".webm" , "admin" )
				Video_Stream(stream, Globals.os)
				
				
			elif !Networking.good_internet:
				return OS.shell_open(youtube[parameters])
		
		if Globals.os == i: # Mobile Platforms
			return OS.shell_open(youtube[parameters])
	"""


# Rewrite this code
func _verify_Online_downloaded_video():
	# Verifies if the downloaded video is valid
	dir.open ("user://")
	var file_exists
	if Globals.os != str ('Android'):
		file_exists = dir.file_exists('user://video.webm')
	if Globals.os == str ('Android'):
		file_exists = dir.file_exists('user://video.ogv')
	
	print ('Video File Exists: ', file_exists)
	if not file_exists && downloading_video != true:
		print ('Video File Doesn.t exist,downloading' )#;_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes())
		return Networking.request(Networking.url)
		#play_loading_cinematic() #Plays the Loading cinematic while the video file downloads
		downloading_video = true
		Networking.connect("request_completed", self, "_http_request_completed")
		print ('download completed')
	if not file_exists && downloading_video == true:
		print('Already Downloading video, Please Wait or Quit and Restart')

#Checks if the file exists

	if file_exists: 
		print ('Video File Exists')
		#stop_playing_laoding_cinematic()
		downloading_video = false
		var err
		var video_file : File = File.new()
		var video_file_path = "user://video.ogv"
		video_file.open(video_file_path, File.READ_WRITE)
		err = (video_file.open(video_file_path, File.READ))
		print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
		
		var video_file_absolute_path = video_file.get_path_absolute()
		print ('Video File Path: ',video_file_path)
		print('Video file size : ', video_file.get_len())
		
		# Chhecks if the video is an 0 byte error
		if video_file.get_len() ==0 :
			push_error('Video file is corrupted /'+ str(video_file.get_len()))
		
		if video_file.is_open() && err == 0: #error catcher 2
			Globals.VIDEO = ResourceLoader.load(video_file_path, 'VideoStreamTheora', false) #Don't make the video a global file
			#Music.notification(NOTIFICATION_PREDELETE) #. Fix Music off function #not needed
			print ('Playing Global video File: ', Globals.VIDEO )
			#_Video_Stream((Globals.AMV)) #Plays the AMV video with Shootback




"""
parses the poopbyte array as a video stream
"""
func _http_request_completed(result, response_code, _headers, body): # dOWNLOADS A VIDEO FROM A SERVER
	if body.empty() != true: #Executes once a Connection is established 

		dir.open ("user://")
		var file_exists = dir.file_exists('user://video.webm')
		print ('Video File Exists: ', file_exists)
		
		#Checks if video file exits
		if not file_exists : #executes if videofile doesnt exit
			dir.open("user://")
			var _absolute_path = dir.get_current_dir ( )
			
			print ('Directory //', _absolute_path)
			var err : int
			Function.store_video_files(body)
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
			if video_file.is_open() && err == 0: #error catcher 2
				
				download_video_size = Networking.get_body_size()#8gets video size from servers
				
				
				#downloading_video: bool, download_video_size : int
				Function._check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes(), downloading_video, download_video_size)
				#var parser = _body.decompress(download_video_size) #decompresses the poolbyte
				


				downloading_video = false
			#return Globals.video_stream
		if file_exists:
			print ('File Exists', file_exists)
	if body.empty() == true:
		print ('Streaming Site '+ Networking.url+ ' is unavailable ')
		print ('It could be a myriad of problems. Please debug carefully')


#to use: video_html('video', body)


class Pilot extends Reference:
	
	
	export (bool) var enabled 

	# Preload for fast loading. Also used Global functions as well
	# use Globals.cinematics for video files
	onready var Pilot_a #= load ('res://scenes/cinematics/Pilot_a.ogv') # Ogv works best for mobile phones #depreciated in v1.1.9
	onready var Pilot_b #= load ('res://scenes/cinematics/Pilot_b.ogv') # it decodes webm as well #depreciated in v1.1.9

	onready var AMV #= load ('res://scenes/cinematics/AMV.ogv')

	onready var Pilot_a_sound# =  ('res://scenes/cinematics/Pilot_a.ogg')
	onready var Pilot_b_sound# =('res://scenes/cinematics/Pilot_b.ogg')

	onready var _video_player : VideoPlayer #= $VideoPlayer
	onready var aspect_ratio : ColorRect#= $ColorRect
	onready var audio : AudioStreamPlayer#= $AudioStreamPlayer

	#onready var ads_manager = $Ads_Manager
	
	var viewport : float = Globals.get_viewport().get_rect().size

	var counter : int = 0# An integer Used as a trigger aid for the video changer

	#var error_code
	export (bool )var new_feature  # A switch for the zip folder new function.
	# The Video Code is broken, Fix it.

	#var path_to_zip_file = 'res://scenes/cinematics/Pilot_a.zip' # Used in a #doesn't work
	func _init()-> void:
		#Check if the uncompressed videos are available in the directory
		var file2Check = File.new()
		#var doFileExists = file2Check.file_exists('user://video.ogv')
		#var doFileExists2 = file2Check.file_exists('user://video2.ogv') # this video does not exist
		var doFileExists = file2Check.file_exists('res://scenes/cinematics/Pilot_a.ogv')
		var doFileExists2 = file2Check.file_exists('res://scenes/cinematics/Pilot_b.ogv') # this video does not exist
		
		# Incase it's a broken build
		var doFileExists3 = file2Check.file_exists('res://scenes/cinematics/Pilot_a.ogg')
		var doFileExists4 = file2Check.file_exists('res://scenes/cinematics/Pilot_b.ogg')
		
		print ('Video File Check:', doFileExists,'/', doFileExists2, '/',doFileExists3, '/',doFileExists4) #For debug purposes only
		
		


		"""
		CHECKS IF THE AUDIO & VIDEO FILES DO NOT EXIST, EXECUTE THE FOLLOWING LINES OF CODE
		"""

	#Unzips the video if the User library's video file is none existent
	# I turned this code bloc off because it is buggy 
		if doFileExists == false && new_feature == true:
			push_warning ('Video file: '+str(doFileExists2) + 'does not exist. Check it') # Checks if the video file exists in the project
			# Unzips video file
			#Globals.unzip_file_to_video(path_to_zip_file) # Disable after debugging #Unzip function break
		# save the file to a web theora file
		if doFileExists2 == false:
			push_warning ('Video file: '+ str(doFileExists2) + 'does not exist. Check it')
			pass
		if doFileExists3 == false:
			push_warning ('Sound file1: ' +str(doFileExists3) + 'does not exist. Check it')
			pass
		if doFileExists4 == false:
			push_warning ('Sound file2: ' +str(doFileExists4) + 'does not exist. Check it')
			pass
		"""
		IF VIDEO FILEs  EXISTS, Execute these blocs
		"""
		if doFileExists == true:
			
			return
		if doFileExists2 == true:
			return




	func _play_pilot_a():
		if enabled == true && Pilot_a != null:
			_video_player.show()
			
			#It uses a global videostream function
			Globals.cinematics = Pilot_a
			audio.set_stream(load(Pilot_a_sound))
			audio.play(0.0)
			
			
			# Makes a Call to the Parent Script
			return Globals._Video_Stream(_video_player , Globals.cinematics, Pilot_a_sound, viewport)# Rewrite function to root script
			

	func _play_pilot_b():
		if enabled == true && Pilot_b != null:
			_video_player.show()
			#It uses a global videostream function
			Globals.cinematics = Pilot_b
			
			audio.set_stream(load(Pilot_b_sound))
			audio.play(0.0)
			
			Globals._Video_Stream(_video_player , Globals.cinematics, Pilot_b_sound, viewport)


	func _play_AMV():
		if enabled == true && Pilot_b != null:
			_video_player.show()
			#It uses a global videostream function
			Globals.cinematics = AMV #makes the video file a global for improved playspeed
			
			audio.set_stream(load('res://music/chuks-dane_chuks-dane-shoot-back.ogg'))
			audio.play(0.0)

			
			Globals._Video_Stream(_video_player , Globals.cinematics, '', viewport)
			
	func stop_playing():
		_video_player.hide()
		Music.sound('off') # Check THe GLobal Music settings and adjust accordingly

	'should connect to ADS mANAGER'
	# Video Monetization code
	func _show_video_ads(): # Not properly tested, disabling this until it is.
		# Initialises the Admob singleton through the ads manager for video ads
		print ('showing video ads by connecting to Ads manager function')
		if (OS.get_name()) == "Android"or  "iOS": # Activates the ads only on mobiles
		#	ads_manager.singleton = "GodotYodo1Mas"
		#	ads_manager.enabled = true
		#	ads_manager._ad_type = "video_ad"
		#	ads_manager.init()
		#	ads_manager.yodo1mas()
			counter = 4 # stops everything
			check_counter()
			return


	func _exit_tree():
		print ('Deleting All Videoplayer items from scene')
		Function._free_memory(Globals.cinematics)
		Function._free_memory(Pilot_a_sound)
		Function._free_memory(Pilot_b_sound)
		Function._free_memory(Pilot_a)
		Function._free_memory(Pilot_b)
		
		_video_player.queue_free()





	func _on_VideoPlayer_finished():
		"""
		THIS IS BAD CODE, PLEASE IMPROVE IT
		"""
		# A 3 POINT COUNTER FOR SEQUENTIALLY PLAYING THE VIDEO THROUGH TO THE ADS
		counter += 1
		check_counter()

	func check_counter():
		if counter == 1 :
			_play_pilot_b()
		if counter == 2:
			_play_AMV()
			#counter = 3
		if counter == 3:
			_show_video_ads()
		if counter == 4 :
		# Auto deletes once the pilot episode has finished playing
			stop_playing()
			#queue_free()
		else:
			return


	func _input(_event):
		if Input.is_action_pressed("ui_cancel") :#Press escape to quit
			Globals._go_to_title()


"""
STORES A POOL BYTE ARRAY TO A VIDEO FILE AND PUBLISHES IT AS A GLOBAL VARIABLE
"""


class Function extends Reference:
	
	func store_video_files(_body : PoolByteArray):
		var video_file : File = File.new()
		video_file.open('user://video.ogv',File.WRITE)
		var err = (video_file.open('user://video.ogv', File.WRITE_READ))
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



	func cinematic_debug(videoplayer: VideoPlayer, vid_stream)-> void:
		Debug.misc_debug = str(int(videoplayer.stream_position)) + Globals.os + str(videoplayer.is_playing(),
		str(vid_stream) + videoplayer.get_stream_name()
		)

		#streamer for android and ios
	func OS_play(_stream): #buggy
		if Globals.os == str('Android'):
			print ('playing ', _stream, "on", Globals.os)
		else:
			pass



func play_loading_cinematic(): #A simple loading loop
	#downloading_video: bool, download_video_size : int
	Function._check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes(), downloading_video, download_video_size) #shows a progress report on video being downloaded
	var _z = str( 'Downloading Remaining.../ ', percent ,'%') #formats the data
	Dialogs.show_dialog( _z, 'Admin') #displays the download percent to the users

	#_Video_Stream(Globals.cinematics) broken function. Video stream function is a global function now
	
	print_debug('Playing loading Cinematic ')
	yield(get_tree().create_timer(5), "timeout") #Runs this loop every 5 secs



func exit(error) -> void:
	print ('Error code: ', error)
	get_tree().quit()




func _on_watch_anime2_pressed():
	cinematics_get("FightScene")
	Music._notification(NOTIFICATION_APP_PAUSED)#Shuts off music
	#videoplayer._play_pilot_a() #depreciated in v1.1.9 for size problems
	$Label.hide()
	#return OS.shell_open(youtube[2])
	
	

func _on_watch_merch_pressed():
	var merch_link = 'https://inhumanity-merch.creator-spring.com/listing/dystopia-merch'
	print ('opening merch link at ',merch_link )
	return OS.shell_open(merch_link)


func _on_watch_anime3_pressed():
	cinematics_get("Animatic")
	
	Music._notification(NOTIFICATION_APP_PAUSED)#Shuts off music
	#return OS.shell_open(youtube[3])


func _on_watch_guidebook_pressed():
	Music._notification(NOTIFICATION_APP_PAUSED)#Shuts off music
	return OS.shell_open("https://github.com/Sam2much96/Dystopia-App/wiki")



