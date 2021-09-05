extends Control

export(String, FILE, "*.webm") var vid_file = ""

var downloading_video = false

var dicL1 = {}
onready var video_file = File.new()
onready var dir = Directory.new()
var download_video_size = 1
var percent
onready var error_code = 0
onready var videoplayer = get_node("VideoPlayer")

func _on_Button_pressed():
	get_tree().change_scene_to((Globals.title_screen))





func _on_watch_anime_pressed():
#use URL: https://youtu.be/ETtpGXDwe08 to test video streaming.
#Original youtube amv url: https://youtu.be/sh0ygItcpBg
	#video_file = File.new()

	######The Streaming Site passed as a global string variable#########
	if Globals.os != str ('Android'): #Webm doesn't play on Godot v3.2.3 Videoplayer yet
		#Networking.url = 'https://animationvideosondemand.s3.af-south-1.amazonaws.com/shots_1-8+pencil+test.webm' #for debuging video streaming
		Networking.url = 'https://animationvideosondemand.s3.af-south-1.amazonaws.com/AMV_3.webm'
	if Globals.os == str ('Android'):
		#Networking.url ='https://animationvideosondemand.s3.af-south-1.amazonaws.com/shots_1-8+pencil+test.ogv' #OGV TEST
		Networking.url ='https://animationvideosondemand.s3.af-south-1.amazonaws.com/AMV_5.ogv' #OGV
	
	
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
		play_loading_cinematic() #Plays the Loading cinematic while the video file downloads
		downloading_video = true
		Networking.connect("request_completed", self, "_http_request_completed")
		print ('download completed')
	if not file_exists && downloading_video == true:
		print('Already Downloading video, Please Wait or Quit and Restart')

	if file_exists: 
		print ('Video File Exists')
		stop_playing_laoding_cinematic()
		downloading_video = false
		var err
		if Globals.os != str ('Android'):
			video_file.open("user://video.webm", File.READ_WRITE)
			err = (video_file.open('user://video.webm', File.READ))
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
		if Globals.os == str('Android'):
			video_file.open("user://video.ogv", File.READ_WRITE)
			err = (video_file.open('user://video.ogv', File.READ))
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
		
		var video_file_path = video_file.get_path_absolute()
		print ('Video File Path: ',video_file_path)
		print('Video file size : ', video_file.get_len())
		
		
		if video_file.get_len() ==0 :
			push_error('Video file is corrupted')
		
		if video_file.is_open() && err == 0: #error catcher 2
			if Globals.os != str('Android'):
				Globals.AMV = ResourceLoader.load(video_file_path, "VideoStreamWebm", false)
			if Globals.os == str ('Android'):
				Globals.AMV = ResourceLoader.load(video_file_path, 'VideoStreamTheora', false)
			Music.notification(NOTIFICATION_PREDELETE) #. Fix Music off function
			print ('Playing Global video File: ', Globals.AMV )
			Video_Stream((Globals.AMV), Music.playlist_one[4]) #Play the video with Shootback


func _check_download_size(loaded,total): #Kinda works. Sort this code out first
	if downloading_video == true:
		if download_video_size == 0 or loaded == 0 or total == 0: #Error catcher 2
			#print ('Download video size:/', download_video_size, 'Loaded:/',loaded,'Total:/',total) #for debug purposes
			total = 1
		if download_video_size != null && total != 0 : # Error catcher 1
			percent = (loaded)/total
			#while percent != 100:
			print('Downloading.../ ', percent, '%')

		if loaded == total and Globals.AMV != null:
			print (' Download Completed') 
	if downloading_video == false:
		pass


func _process(_delta):
	#for debug purposes only
	if downloading_video == true:
	#	yield(get_tree().create_timer(5), "timeout")
	#	print (_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes())) #shows a progress report on video being downloaded)
		debug_stream()
	pass

###########my codes###############parsing the poopbyte array as a video stream########
func _http_request_completed(result, response_code, headers, body):
	#Sets the video stream to the videoplayer
	#video_file = File.new()
	
	if body.empty() != true: #Executes once a Connection is established 
		
		
		
		dir.open ("user://")
		var file_exists = dir.file_exists('user://video.webm')
		print ('Video File Exists: ', file_exists)
		
		#Checks if video file exits
		if not file_exists : #executes if videofile doesnt exit
			#video_file = File.new()
			
			#dir = Directory.new()
			dir.open("user://")
			var _absolute_path = dir.get_current_dir ( )
			
			print ('Directory //', _absolute_path)
			var err
			if Globals.os != str ('Android'):
				video_file.open('user://video.webm',File.WRITE)
			#OS.execute (str(_absolute_path), 'chmod + x str(_absolute_paths)', false, 'making folder executable', false)
				err = (video_file.open('user://video.webm', File.WRITE_READ))
			if Globals.os == str ('Android'):
				video_file.open('user://video.ogv',File.WRITE)
				err = (video_file.open('user://video.ogv', File.WRITE_READ))
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
			if video_file.is_open() && err == 0: #error catcher 2
				#var _body = body
				
				
				download_video_size = Networking.get_body_size()#8gets video size from servers
				_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes())
				#var parser = _body.decompress(download_video_size) #decompresses the poolbyte
				video_file.store_buffer(body) #store pool byte array as video buffer
				var video_file_path = video_file.get_path_absolute() #gets the file path
				Globals.AMV = video_file_path
				video_file.close()

				downloading_video = false
			#return Globals.video_stream
		if file_exists:
			print ('File Exists', file_exists)
	if body.empty() == true:
		print ('Streaming Site '+ Networking.url+ ' is unavailable ')
		print ('It could be a myriad of problems. Please debug carefully')


#to use: video_html('video', body)

func Video_Stream(stream, audio): #Video Streamer
	videoplayer._set_size((get_viewport_rect().size))
	if stream!= null or '':
		print('Playing Video Stream:/',stream)
		videoplayer.set_stream(stream) 
		videoplayer.play() 
		print ('Video player is playing: ',videoplayer.is_playing())
		
		#Sets the Audio track to play
		get_node("AudioStreamPlayer").set_stream(load(audio)) #plays the audio
		get_node("AudioStreamPlayer").play(0.0)
		#print ('analysis:' + "It works")

func play_loading_cinematic(): #A simple loading loop
	_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes()) #shows a progress report on video being downloaded
	var _z = str( 'Downloading Remaining.../ ', percent ,'%') #formats the data
	Dialogs.show_dialog( _z, 'Admin') #displays the download percent to the users

	Video_Stream(Globals.cinematics, Music.wind_sfx[0])
	
	print ('Playing loading Cinematic ')
	yield(get_tree().create_timer(5), "timeout") #Runs this loop every 5 secs
	
	if Globals.os != str ("Android") && Globals.AMV == null:
		if not dir.file_exists("user://video.webm"): #breaks loop
			play_loading_cinematic()
			print ('looping loading cinematic')
		if dir.file_exists("user://video.webm"):
			stop_playing_laoding_cinematic()


	if Globals.os == str ('Android'):
		if not dir.file_exists("user://video.ogv") && Globals.AMV == null: #breaks loop
			play_loading_cinematic()
		print ('looping loading cinematic')
		if dir.file_exists("user://video.ogv"):
			stop_playing_laoding_cinematic()

func stop_playing_laoding_cinematic():
	Dialogs.hide_dialogue() #Error catcher 1 

func debug_stream():
	Networking.debug += str (percent)
	




func exit(error) -> void:
	print ('Error code: ', error)
	get_tree().quit()


func _on_VideoPlayer_finished(): #Stops Music Once Video Finishes
	get_node("AudioStreamPlayer").stop()
