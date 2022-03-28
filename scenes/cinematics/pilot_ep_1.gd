extends Control

#This code should run a global function to unzip the video files to 'user://' when the user first funs the app

export (bool) var enabled 

# Preload for fast loading. Also used Global functions as well

onready var Pilot_a = load ('res://scenes/cinematics/Pilot_a.ogv') # Ogv works best for mobile phones
onready var Pilot_b = load ('res://scenes/cinematics/Pilot_b.ogv')

onready var AMV = load ('res://scenes/cinematics/AMV.ogv')

onready var Pilot_a_sound =  ('res://scenes/cinematics/Pilot_a.ogg')
onready var Pilot_b_sound =('res://scenes/cinematics/Pilot_b.ogg')

onready var _video_player = $VideoPlayer
onready var aspect_ratio = $ColorRect
onready var audio = $AudioStreamPlayer

onready var ads_manager = $Ads_Manager
var viewport = get_rect().size

var counter = 0# An integer Used as a trigger aid for the video changer

var error_code
export (bool )var new_feature  # A switch for the zip folder new function.
# The Video Code is broken, Fix it.

var path_to_zip_file = 'res://scenes/cinematics/Pilot_a.zip' # Used in a 
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

func _ready():
	ads_manager.enabled = false # Disables the ads manager initially

func _process(_delta):
	#Globals.unzip_file_to_video(path_to_zip_file) # Disable after debugging #Unzip function breaks 
	# AUto hides and deletes if enabled is false
	if enabled == false:
		self.hide()
		self.queue_free()


	# Checks if the Video Ads load
	
	if ads_manager.Admob.emit_signal("rewarded_video_loaded"):
		print (' Video Ads loaded')
	if ads_manager.Admob.emit_signal("rewarded_video_failed_to_load", error_code) :
		print ("rewarded_video_failed_to_load")
		counter = 4 # Triggers a quit action through the counter function
		check_counter()
	else:
		pass

func _play_pilot_a():
	if enabled == true && Pilot_a != null:
		_video_player.show()
		
		#It uses a global videostream function
		
		Globals._Video_Stream(_video_player , Pilot_a, Pilot_a_sound, viewport)
		audio.set_stream(load(Pilot_a_sound))
		audio.play(0.0)

func _play_pilot_b():
	if enabled == true && Pilot_b != null:
		_video_player.show()
		#It uses a global videostream function
		
		Globals._Video_Stream(_video_player , Pilot_b, Pilot_b_sound, viewport)
		audio.set_stream(load(Pilot_b_sound))
		audio.play(0.0)

func _play_AMV():
	if enabled == true && Pilot_b != null:
		_video_player.show()
		#It uses a global videostream function
		
		Globals._Video_Stream(_video_player , AMV, '', viewport)
		audio.set_stream(load('res://music/chuks-dane_chuks-dane-shoot-back.ogg'))
		audio.play(0.0)

func stop_playing():
	_video_player.hide()
	Music.sound('off')

# Video Monetization code
func _show_video_ads():
	# Initialises the Admob singleton through the ads manager for video ads
	if (OS.get_name()) == "Android"or  "iOS": # Activates the ads only on mobiles
		ads_manager.singleton = "GodotYodo1Mas"
		ads_manager.enabled = true
		ads_manager._ad_type = "video_ad"
		ads_manager.init()
		ads_manager.yodo1mas()
	else:
		counter == 4
		check_counter()
		return


func _exit_tree():
	print ('Deleting Videoplayer from scene')




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
		queue_free()
	else:
		return
