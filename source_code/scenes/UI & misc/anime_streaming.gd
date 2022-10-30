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
extends Control
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
var dicL1 = {}

onready var dir = Directory.new()



var download_video_size = 1
var percent
onready var error_code = 0
onready var videoplayer = get_node("AnimationPlayer")

var pilot_ep_scene = load ('res://scenes/cinematics/pilot_ep_1.tscn')

#Declare some animation variables
#var animmation_frames
#var NFT

func _on_Button_pressed():
	return get_tree().change_scene_to((Globals.title_screen))



func _download_video(): #(depreciated)

	pass


func _on_watch_anime_pressed():

	#if Globals.os == str ('Android'):
	
	
	
	#_Video_Stream((Globals.pilot_ep))
	
	Music._notification(NOTIFICATION_APP_PAUSED)#Shuts off music
	#videoplayer._play_pilot_a() #depreciated in v1.1.9 for size problems
	$Label.hide()
	return OS.shell_open("https://youtu.be/oJY1rIxC4kk")
	
	
	#print ('Video Stream: ' , str(videoplayer.stream)) # For debug purposes only
		

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
		Networking.request(Networking.url)
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
		var video_file = File.new()
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


func _check_download_size(loaded,total): #Kinda works. Sort this code out first
	if downloading_video == true:
		if download_video_size == 0 or loaded == 0 or total == 0: #Error catcher 2
			#print ('Download video size:/', download_video_size, 'Loaded:/',loaded,'Total:/',total) #for debug purposes
			total = 1
		if download_video_size != null && total != 0 : # Error catcher 1
			percent = (loaded)/total
			#while percent != 100:
			print('Downloading.../ ', percent, '%')

		if loaded == total and Globals.VIDEO != null:
			print (' Download Completed') 
	if downloading_video == false:
		pass


"""
parses the poopbyte array as a video stream
"""
func _http_request_completed(result, response_code, headers, body): # dOWNLOADS A VIDEO FROM A SERVER
	if body.empty() != true: #Executes once a Connection is established 

		dir.open ("user://")
		var file_exists = dir.file_exists('user://video.webm')
		print ('Video File Exists: ', file_exists)
		
		#Checks if video file exits
		if not file_exists : #executes if videofile doesnt exit
			dir.open("user://")
			var _absolute_path = dir.get_current_dir ( )
			
			print ('Directory //', _absolute_path)
			var err
			store_video_files(body)
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
			if video_file.is_open() && err == 0: #error catcher 2
				
				download_video_size = Networking.get_body_size()#8gets video size from servers
				_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes())
				#var parser = _body.decompress(download_video_size) #decompresses the poolbyte
				


				downloading_video = false
			#return Globals.video_stream
		if file_exists:
			print ('File Exists', file_exists)
	if body.empty() == true:
		print ('Streaming Site '+ Networking.url+ ' is unavailable ')
		print ('It could be a myriad of problems. Please debug carefully')


#to use: video_html('video', body)

"""
STORES A POOL BYTE ARRAY TO A VIDEO FILE AND PUBLISHES IT AS A GLOBAL VARIABLE
"""
"""
Duplicate COde. Delete Eventually.
				"""
func store_video_files(_body):
	video_file = File.new()
	video_file.open('user://video.ogv',File.WRITE)
	err = (video_file.open('user://video.ogv', File.WRITE_READ))
	video_file.store_buffer(_body) #store pool byte array as video buffer
	var video_file_path = video_file.get_path_absolute() #gets the file path
	print ('Video File path: ', video_file_path)
	Globals.VIDEO = video_file_path
	video_file.close()





func play_loading_cinematic(): #A simple loading loop
	_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes()) #shows a progress report on video being downloaded
	var _z = str( 'Downloading Remaining.../ ', percent ,'%') #formats the data
	Dialogs.show_dialog( _z, 'Admin') #displays the download percent to the users

	#_Video_Stream(Globals.cinematics) broken function. Video stream function is a global function now
	
	print ('Playing loading Cinematic ')
	yield(get_tree().create_timer(5), "timeout") #Runs this loop every 5 secs
	

func _exit_tree():
#	#Turns on music when exiting scene
#	Music._notification(NOTIFICATION_APP_RESUMED) #Buggy
	pass


func exit(error) -> void:
	print ('Error code: ', error)
	get_tree().quit()

func open_merch_link(): #triggers a merch link link download
	var merch_link = 'https://inhumanity-merch.creator-spring.com/listing/dystopia-merch'
	print ('opening merch link at ',merch_link )
	return OS.shell_open(merch_link)
