# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Pilot 1 episode run script
# Features
# 
#(1) Functions that Make the Playing the episode easier for mobiles to process
# (2) Extends Cinematics class
#
# To Do
#(1) Implement subtitle feature
# (2) Re-render animation  pilot ep
# (3) Compress video file as a zip and unzip before runtime
#  Bugs
# (1) There's a couple of seconds lag in between Pilot A and pilot b codes
# *************************************************


extends cinematic

##This code should run a global function to unzip the video files to 'user://' when the user first funs the app
# It extends cinematic class, and causes a bug break from the root cinematic node
#it also gives access to cinematic source funtions

export (bool) var enabled 

# Preload for fast loading. Also used Global functions as well
# use Globals.cinematics for video files
onready var Pilot_a #= load ('res://scenes/cinematics/Pilot_a.ogv') # Ogv works best for mobile phones #depreciated in v1.1.9
onready var Pilot_b #= load ('res://scenes/cinematics/Pilot_b.ogv') # it decodes webm as well #depreciated in v1.1.9

onready var AMV #= load ('res://scenes/cinematics/AMV.ogv')

onready var Pilot_a_sound# =  ('res://scenes/cinematics/Pilot_a.ogg')
onready var Pilot_b_sound# =('res://scenes/cinematics/Pilot_b.ogg')

onready var _video_player = $VideoPlayer
onready var aspect_ratio = $ColorRect
onready var audio = $AudioStreamPlayer

onready var ads_manager = $Ads_Manager
var viewport = get_rect().size

var counter = 0# An integer Used as a trigger aid for the video changer

var error_code
export (bool )var new_feature  # A switch for the zip folder new function.
# The Video Code is broken, Fix it.

var path_to_zip_file = 'res://scenes/cinematics/Pilot_a.zip' # Used in a #doesn't work
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
	#ads_manager.enabled = false # Disables the ads manager initially
	pass


func _process(_delta):
	#Globals.unzip_file_to_video(path_to_zip_file) # Disable after debugging #Unzip function breaks 
	# AUto hides and deletes if enabled is false
	if enabled == false:
		self.hide()
		self.queue_free()



func _play_pilot_a():
	if enabled == true && Pilot_a != null:
		_video_player.show()
		
		#It uses a global videostream function
		Globals.cinematics = Pilot_a
		_Video_Stream(_video_player , Globals.cinematics, Pilot_a_sound, viewport)# Rewrite function to root script
		audio.set_stream(load(Pilot_a_sound))
		audio.play(0.0)

func _play_pilot_b():
	if enabled == true && Pilot_b != null:
		_video_player.show()
		#It uses a global videostream function
		Globals.cinematics = Pilot_b
		_Video_Stream(_video_player , Globals.cinematics, Pilot_b_sound, viewport)
		audio.set_stream(load(Pilot_b_sound))
		audio.play(0.0)

func _play_AMV():
	if enabled == true && Pilot_b != null:
		_video_player.show()
		#It uses a global videostream function
		Globals.cinematics = AMV #makes the video file a global for improved playspeed
		_Video_Stream(_video_player , Globals.cinematics, '', viewport)
		audio.set_stream(load('res://music/chuks-dane_chuks-dane-shoot-back.ogg'))
		audio.play(0.0)

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
	_free_memory(Globals.cinematics)
	_free_memory(Pilot_a_sound)
	_free_memory(Pilot_b_sound)
	_free_memory(Pilot_a)
	_free_memory(Pilot_b)
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
		queue_free()
	else:
		return


func _input(_event):
	if Input.is_action_pressed("ui_cancel") :#Press escape to quit
		Globals._go_to_title()
