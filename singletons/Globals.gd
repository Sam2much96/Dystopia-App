# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a auto-included singleton containing
# information used by the Game 
#
# *************************************************

extends Node

#use variables to code ux +add a scene tree calculator
var cinematics = preload ('res://resources/title animation/title..ogv')
#var Pilot_ep

#var AMV 
var pilot_ep 
var VIDEO

var form = load ('res://New game code and features/multiplayer/scenes/form.tscn')
var title_screen = preload( 'res://scenes/Title screen.tscn')
#var shop = load('res://scenes/UI & misc/Shop.tscn')
var controls = load ('res://scenes/UI & misc/Controls.tscn')

#Comics  Book Module variables
var comics = load ('res://scenes/UI & misc/Comics.tscn')
var comics___2 = load ('res://scenes/UI & misc/Comics____2.tscn')
var comics_chapter 
var comics_page 


var game_loop

var prev_scene
var prev_scene_spawnpoint
var next_scene = null
onready var curr_scene #= get_tree().get_current_scene().get_name()
onready var os = str(OS.get_name())
onready var kill_count = 0 #update to load from savefile
export var player  = []
var player_hitpoints
var enemy = null
var enemy_debug
export(String, FILE, "*.tscn") var initial_level  = "res://scenes/levels/Outside.tscn" 
var Debug = null
var _player_state # gets state data from the player state machine
var video_stream #for the video streamers

var metamask_wallet #Stores your wallet for the nft transactions
var languague #Stores the user's lingua franca

export (int) var Suds #currency system
# warning-ignore:unused_class_variable
export (Vector2) var spawnpoint 
var spawn_x
var spawn_y
var current_level 

var blood_fx = load ('res://scenes/UI & misc/Blood_Splatter_FX.tscn')

export (bool) var Music_on_settings
var direction_control = '' #toggles btw analogue and d-pad

var uncompressed # Varible holds uncompressed zip files
func _ready():
	print('Blood fx:',blood_fx)
	

	
	player.append( get_tree().get_nodes_in_group('player') )#gets all player nodes in the scene
	if player.empty() == true: #error catcher 1             #it shows deleted object once player is despawns. Fix pls
		player = null
	
	
	
	VisualServer.set_default_clear_color(ColorN("white"))


func _process(_delta):
	if spawn_x and spawn_y != null:
		spawnpoint =Vector2(spawn_x,spawn_y)
	if player_hitpoints == int (0):
		player_hitpoints = 1 #stops the game from saving zero lives



"""
Really simple save file implementation. Just saving some variables to a dictionary
"""
func save_game(): #modify code to include current scene and player position. also enemy spawner postions and info
	var save_game = File.new()
	save_game.open("user://savegeme.save", File.WRITE)
	var save_dict = {}
	save_dict.player = player #saves the player node 
	#save_dict.spawnpoint = spawnpoint
	save_dict.spawn_x = spawn_x
	save_dict.spawn_y =spawn_y
	save_dict.current_level = current_level
	save_dict.inventory = Inventory.list()
	save_dict.quests = Quest.get_quest_list()
	#my code
	save_dict.os = os
	save_dict.kill_count = kill_count
	save_dict.currency = Suds
	save_dict.prev_scene = prev_scene
	save_dict.prev_scene_spawnpoint = prev_scene_spawnpoint
	save_dict.player_hitpoints = player_hitpoints
	save_dict.direction_control = direction_control
	save_dict.Music_on_settings = Music_on_settings #add other variables to save
	
	#Comics Variables
	#save_dict.comics_chapter
	#save_dict.comics_page
	
	save_game.store_line(to_json(save_dict))
	save_game.close()
	pass

"""
If check_only is true it will only check for a valid save file and return true or false without
restoring any data
"""
func load_game(check_only=false):
	var save_game = File.new()
	
	if not save_game.file_exists("user://savegeme.save"):
		return false
	
	save_game.open("user://savegeme.save", File.READ)
	
	var save_dict = parse_json(save_game.get_line())
	if typeof(save_dict) != TYPE_DICTIONARY:
		return false
	if not check_only:
		_restore_data(save_dict)
	
	save_game.close()
	return true

"""
Restores data from the JSON dictionary inside the save files
"""
func _restore_data(save_dict):
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	for key in save_dict.quests:
		save_dict.quests[key] = int(save_dict.quests[key])
	Quest.quest_list = save_dict.quests
	
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	for key in save_dict.inventory:
		save_dict.inventory[key] = int(save_dict.inventory[key])
	Inventory.inventory = save_dict.inventory
	
	spawn_x = save_dict.spawn_x 
	spawn_y = save_dict.spawn_y
	current_level = save_dict.current_level
	
	player = save_dict.player
	
	os = save_dict.os 
	kill_count = save_dict.kill_count 
	Suds = save_dict.currency 
	player_hitpoints = save_dict.player_hitpoints
	prev_scene =save_dict.prev_scene 
	prev_scene_spawnpoint = save_dict.prev_scene_spawnpoint 
	direction_control = save_dict.direction_control
	
	#Music_on_settings = save_dict.Music_on_settings 
		#Comics Variables
	#comics_chapter = save_dict.comics_chapter
	#comics_page = save_dict.comics_page
	
	
func update_curr_scene(): 
	curr_scene= get_tree().get_current_scene().get_name() 
	
func _go_to_title():
	if get_tree().get_current_scene().get_name() == 'Menu':
		get_tree().quit()
	Music.play_track(Music.ui_sfx[1])
	return get_tree().change_scene_to(title_screen)

func _go_to_cinematics():
	return get_tree().change_scene('res://scenes/cinematics/cinematics.tscn') 


"""
VIDEO STREAMER
"""
"""
It uses plays a video and music stream, and sets the videoplayer to the viewport's size
"""

func _Video_Stream(node , stream, _sound, viewport):
	if stream and node != null or '':
		print('Playing Video Stream:/',stream)
		#node._set_size((viewport))
		node.set_stream(stream) 
		node.play() 
		print ('Video player is playing: ',node.is_playing())
		
		# Plays the sound through the music singleton
		#get_tree().get_root().get_node("/root/Music").play(sound)
		return
	else:
		push_error('Video player uses the video player node, and music singleton')
		push_warning(str(node) +"/" +str(stream) + "/"+ str (_sound))


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
		VIDEO = load(video_file_path)
		
		#return print ('Video FIle Path',video_file_path)
		#Comvert size to MB usingConvertfunctiion
		
		 # Gets VIdeo file length in bytes, converts it to MB
		var __video_file_size_mb = _ram_convert(video_file.get_len())

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


func unzip_file_to_video(path_to_zip): # Unzips the pilot ep. #Rewrite to use globally
	print ('Path to zip: ', path_to_zip)
	var file2Check = File.new()
	var dir = Directory.new() # Testing some new code
	var doZipFileExists = file2Check.file_exists(path_to_zip) # Path to Zip file
	if doZipFileExists == true :
		print ('Video file: '+str(doZipFileExists) + 'does  exist. ')
		
		var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
# - load a zip file:
		var loaded = gdunzip.load('res://scenes/cinematics/Pilot_a.zip')
# - if loaded is true you can try to uncompress a file:
		var uncompressed = gdunzip.uncompress('res://scenes/cinematics/Pilot_a.zip/Pilot_a.ogv')
		#var uncompressed = gdunzip.uncompress('res://scenes/cinematics/Pilot_a.zip/')
# - now you have got a PoolByteArray named "uncompressed" with the
#   uncompressed data for the given file
		print ('Loaded zip : ',loaded) #for debug purposes only
		print ('Uncompressed file : ',uncompressed) #it fails to uncompress  # For debug purposes only
# You can iterate over the "files" variable from the gdunzip instance, to
# see all the available files:
		for f in gdunzip.files:
			 # Works
			#pilot_ep = f
			print ('File in zip file: ',f, '  //  ', 'Pilot ep', pilot_ep )
			#print ()
			#print(f['file_name'])
			#dir.copy(f, 'user://video.ogv')

			#store_video_files(f,50.2)


			
	# - if loaded is true you can try to uncompress a file:
		#	uncompressed = _w.uncompress(_q) #Breaks, unzips a 0 file, write error checkers
	# - now you have got a PoolByteArray named "uncompressed" with the
	#   uncompressed data for the given file
		print ('The uncompression algorithm code fails to uncompress and breaks if pilot_a.ogv is moved')
		
		# Stores the uncompresed pool byte array to a video file
		#store_video_files(uncompressed,50.2) # Stores the video file with a global function, disabling for now
		# It creates a corrupted video file of 0 mb. Try running in a process() function


# Convert bytes to Megabytes
func _ram_convert(bytes) :
	if bytes >= int(1):
		var _mb = String(round(float(bytes) / 1_048_576))
		return _mb
