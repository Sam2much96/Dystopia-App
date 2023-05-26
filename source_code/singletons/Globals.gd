# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a auto-included singleton containing
# information used by the Game 
# Features
# (1) Functions Class for Saving & Loading.
# (2) A Call to find the current scene
# (3) 
# (4) A video streaming function, which should originally have been a child of the video streamers, 
#     but it runs faster on a singleton script and so, was called from here
# (5) Store video files functions
# (6) It loads scenes for faster switiching between
# To Add
# (1) A working zip and unzip function through GDUnzip repurposed as an editor plugin #('insert GDUNzip github address')
# (2) ArrAnge code base, make it easier to read at a glance (1/2)
# (3) Use resource oader for video loading script
# Bugs
# (1) COnnect to GDUNZIP via editor script to zip and unzip 
# (2) Lacks proper documentation (fixed)
# (3) Lacks Performance Optimization and Proper variable mnaming conventions (fixed)
# (4) Causes a performance hog with process functions
# (5) Causes a ram hog with loaded and preloaded variables
# *************************************************

extends Node


var cinematics = preload ('res://resources/title animation/title..ogv') #I free memory once this is used
var title_screen = load( 'res://scenes/Title screen.tscn')
var pilot_ep 
var VIDEO

onready var form = load ('res://scenes/UI & misc/form/form.tscn')

#var shop = load('res://scenes/UI & misc/Shop.tscn')
var controls = load ('res://scenes/UI & misc/Controls.tscn')

"Comics  Book Module variables"
onready var comics = load ('res://scenes/UI & misc/Comics.tscn')
onready var comics___2 = load ('res://scenes/UI & misc/Comics____2.tscn')
var comics_chapter 
var comics_page 


var game_loop

var prev_scene
var prev_scene_spawnpoint
var next_scene = null
onready var curr_scene : String = ""
onready var os: String = OS.get_name()
onready var kill_count : int = 0 #update to load from savefile
var player : Array = []
#var _p # Player placeholder
var player_hitpoints : int
var enemy = null
var enemy_debug : String 
var initial_level : String = "res://scenes/levels/Outside.tscn"  # loading outside environment bug fixed
#var _Debug = null
var _player_state # gets state data from the player state machine
var video_stream #for the video streamers



# warning-ignore:unused_class_variable
var spawnpoint : Vector2
var spawn_x : int 
var spawn_y : int 
var current_level : String


var Music_on_settings # Depreciated
export (String, 'analogue', 'direction') var direction_control = ''  #toggles btw analogue and d-pad

var uncompressed # Varible holds uncompressed zip files


'ingame Environment Variables'
var near_interractible_objects #which objects use this?

'Scene Loading variables'
var scene_resource : PackedScene # Large Resouce Scene Placeholder
var _to_load : String  # Large Resource Placeholder Variable
var _o : ResourceInteractiveLoader#for polling resource loader
var err
var a : int # Loader progress variable (a/b) 
var b : int
var loading_resource : bool = false
onready var scene_loader= ResourceLoader
onready var progress : float

"Crypto Variables" 
var address : String
var mnemonic : String
var player_name : String

# Buggy
onready var algos : int  #=  Wallet.Wallet.load_account_info(false, Wallet.token_write_path, Wallet.FileCheck3, Wallet.UserData).get("_wallet_algos")
	#MicroAlgos 


"Device Variables"
var user_data_dir : String =OS.get_user_data_dir()

'Screen Size Resolution'
var screenSize : Vector2
enum { SCREEN_HORIZONTAL, SCREEN_VERTICAL} 
var screenOrientation : int
var viewport_size : Vector2
var center_of_viewport : Vector2 

"In Game FX"
var blood_fx: PackedScene = load ('res://scenes/UI & misc/Blood_Splatter_FX.tscn') #only load this once gameplay is on (optimization)
var despawn_fx: PackedScene = load ("res://scenes/UI & misc/DespawnFX.tscn")
var bullet_fx : PackedScene

'Temporary variants'
var temp

"Wallet Algo"
var NFT: TextureRect #should ideally be an array for multiple NFT's
var wallet_state  #wallet state global variabe


" File Checkers"
var FileCheck1=File.new() # checks wallet mnemonic
var FileDirectory=Directory.new() #deletes all theon reset

func _ready():
	print('Blood fx:',blood_fx) #optimize blood fx to only load during game runtimes
	
	# Resizes window the preselected sizes
	# Sets Default Screen Orientation
	if os == "Android":
		screenOrientation = SCREEN_VERTICAL
	else: screenOrientation = SCREEN_HORIZONTAL 
	print ("Screen orientation is: ", screenOrientation)



	player.append( get_tree().get_nodes_in_group('player') )#gets all player nodes in the scene
	 #it shows deleted object once player is despawns.
	if player.empty() == true: #error catcher 1            
		player.clear()
	
	
	#Set White Background
	VisualServer.set_default_clear_color(ColorN("white")) 


func _process(_delta): #Turn process off if not in use (optimiztion) turn_off_processing()

# Handles Screen Orientation
	screenOrientation = OS.get_screen_orientation() # Updates Global Screen Orientation


	if screenOrientation == SCREEN_VERTICAL :

		pass
	elif screenOrientation == SCREEN_HORIZONTAL:

		pass
	else: return 1;


func update_curr_scene() -> void:
	curr_scene= get_tree().get_current_scene().get_name() 
	print ("current scene is: ", curr_scene)


func _go_to_title():
	'Quits if already at title screen'
	if get_tree().get_current_scene().get_name() == 'Menu':
		get_tree().quit()
	Music.play_track(Music.ui_sfx[1])
	
	'changes scene to title_screen'
	
	return get_tree().change_scene("res://scenes/Title screen.tscn")

func _go_to_cinematics():
	return get_tree().change_scene('res://scenes/cinematics/cinematics.tscn') 


# Deprecoated
func resize_window(x,y): #resizes the game window
	screenSize = Vector2(x,y);
	return OS.set_window_size(Vector2(x,y));

# Convert bytes to Megabytes
func _ram_convert(bytes) :
	if bytes >= int(1):
		var _mb = String(round(float(bytes) / 1_048_576))
		return _mb


class Functions extends Reference:

	static func change_scene_to(scene : PackedScene, tree : SceneTree): #Loads scenes faster?
		
		#if scene is PackedScene: 
			if scene != null: 
				return tree.change_scene_to(scene)  

			else: return (print (typeof(scene) ,"is not supported in this function"))
	
	'Resource Loader FOr Large Scenes'
	static func LoadLargeScene(
		_to_load : String, 
		scene_resource : PackedScene, 
		_o : ResourceInteractiveLoader, 
		scene_loader : ResourceLoader, 
		loading_resource : bool, 
		a: int , 
		b : int, 
		progress: float
		) -> PackedScene:
		
		if _to_load != "" && scene_resource == null:
			var time_max = 50000 #sets an estimate maximum time to load scene
			var t = OS.get_ticks_msec()
			
			#scene_loader.load_interactive(_r) 
			
			_o= (scene_loader.load_interactive(_to_load)) #function returns a resourceInteractiveLoader

			scene_loader.load_interactive(_to_load) #function returns a resourceInteractiveLoader
			
		
			print (" Loader Debug Outer loop >>> Inner Loop")
			while OS.get_ticks_msec() < (t + time_max) && _o != null: 

				var err = _o.poll()
				#loading_resource = true
				
				print ("_q: ",scene_resource," _r: ",_to_load," Error: ",str(err),"Loop Debug") #Debugger
				
				
				
				if err == ERR_FILE_EOF: # Finished Loading #Works
					loading_resource = false
					
					scene_resource = (_o.get_resource()) 
					print (scene_resource , "Resource Loaded")
					#Functions.change_scene_to(scene_resource, get_tree()) # auto changes the scene
					#turn_off_processing("off") #introduces bugs
					
					break
					#return _q
				elif err == OK: #works
					a = _o.get_stage()
					b = _o.get_stage_count() 
					progress = (b/a) 
					print (a, "/",b,'/',"Progress: ", progress) #progress Debug?
				else: # Error during loading
					push_error("Problems loading Scene.  Debug Gloabls scene loader")
					print (str(progress) + "% " + str (_to_load))
					
					break
		if scene_resource != null: # 
			return scene_resource

		return scene_resource



	"""
	Really simple save file implementation. Just saving some variables to a dictionary
	"""

	#modify code to include current scene and player position. also enemy spawner postions and info
	# should take a parameter to save individual variables
	static func save_game(
		player: Array, 
		player_hitpoints : int, 
		spawn_x, spawn_y, 
		current_level, 
		os : String, 
		kill_count : int, 
		prev_scene, 
		prev_scene_spawnpoint,
		direction_control,
		Music_on_settings
		)-> bool: 
		
		print ("-------Saving Game -------")
		
		var save_game = File.new()
		save_game.open("user://savegeme.save", File.WRITE)
		var save_dict = {}
		if !player.empty():
			save_dict.player = player #saves the player node 
		if spawn_x != null:
			save_dict.spawn_x = spawn_x
		if spawn_y != null:
			save_dict.spawn_y =spawn_y
		if current_level != null:
			save_dict.current_level = current_level
		if !Inventory.list().empty():
			save_dict.inventory = Inventory.list()
		if !Quest.get_quest_list().empty():
			save_dict.quests = Quest.get_quest_list()
		if os != '':
			save_dict.os = os
		if kill_count != null:
			save_dict.kill_count = kill_count
		#save_dict.currency = Suds #should load from encrypted wallet.cfg
		if prev_scene != null:
			save_dict.prev_scene = prev_scene
		if prev_scene_spawnpoint != null: # Depreciate in favor of a singular spawpoint variable
			save_dict.prev_scene_spawnpoint = prev_scene_spawnpoint
		if player_hitpoints != 0:
			save_dict.player_hitpoints = player_hitpoints
		if direction_control != "":
			save_dict.direction_control = direction_control
		if Music_on_settings != null : # Redefine variable name
			save_dict.Music_on_settings = Music_on_settings #add other variables to save
		if Dialogs.language != '':
			save_dict.languague = Dialogs.language
		
		save_game.store_line(to_json(save_dict))
		save_game.close()
		print ("saved gameplay")
		return true

	"""
	If check_only is true it will only check for a valid save file and return true or false without
	restoring any data
	"""
	static func load_game(check_only=false) -> bool:
		print ("-------Loading Game -------")
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
	static func _restore_data(save_dict):
		# JSON numbers are always parsed as floats. In this case we need to turn them into ints
		for key in save_dict.quests:
			save_dict.quests[key] = int(save_dict.quests[key])
		Quest.quest_list = save_dict.quests
		
		# JSON numbers are always parsed as floats. In this case we need to turn them into ints
		for key in save_dict.inventory:
			save_dict.inventory[key] = int(save_dict.inventory[key])
		Inventory.inventory = save_dict.inventory
		
		Globals.spawn_x = save_dict.spawn_x 
		Globals.spawn_y = save_dict.spawn_y
		Globals.current_level = save_dict.current_level
		Globals.player = save_dict.player
		Globals.os = save_dict.os 
		Globals.kill_count = save_dict.kill_count  
		Globals.player_hitpoints = save_dict.player_hitpoints
		Globals.prev_scene =save_dict.prev_scene 
		Globals.prev_scene_spawnpoint = save_dict.prev_scene_spawnpoint 
		
		Globals.direction_control = save_dict.direction_control
		
		Dialogs.language = save_dict.languague
		
		######################################################
		print ("Loaded gameplay")

	# Loads Singular User Data from local storage
	# Version 2 of Load_game function
	# Should allow for loading individual variables from Local
	static func load_user_data( data: String ):
		print ("-------Loading User Data -------")
		var save_game = File.new()
		
		if not save_game.file_exists("user://savegeme.save"):
			return false
		save_game.open("user://savegeme.save", File.READ)
		var save_dict = parse_json(save_game.get_line())
		if typeof(save_dict) != TYPE_DICTIONARY:
			return false

		if save_dict.has(data):
			if data == 'languague':
				Dialogs.language = save_dict.languague
		pass


func turn_off_processing(toggle): # to improve game speed and turn off idle processsing
	if toggle is String:
		if toggle == "on":
			set_process(true)
		elif toggle == "off":
			set_process(false)
		else:
			push_warning ("This function only uses on/off strings to control the globals processing functon")
	else: return



		# Updates the raycast to the Enemy"s Direction
static func rotate_pointer(point_direction: Vector2, pointer) -> void:
	var temp =rad2deg(atan2(point_direction.x, point_direction.y))
	pointer.rotation_degrees = temp



func restaVectores(v1, v2): #vector substraction
	return Vector2(v1.x - v2.x, v1.y - v2.y)

func sumaVectores(v1, v2): #vector sum
	return Vector2(v1.x + v2.x, v1.y + v2.y)

#prints all orphaned nodes in project
func memory_leak_management():
	return print_stray_nodes() 

"Memory Leak/ Orphaned Nodes Management System"
class MemoryManagement extends Reference :
	static func queue_free_children(node: Node) -> void:
		for idx in node.get_child_count():
			node.queue_free()
			
	static func free_children(node: Node) -> void:
		for idx in node.get_child_count():
			node.free()

	static func free_object (object: Object) -> void:
		object.free()

	static func queue_free_array(nodes: Array) -> void:
		for i in nodes:
			if i != null:
				i.queue_free()


'Delete Files'
func delete_local_file(path_to_file: String) -> void:
	var dir = Directory.new()
	if dir.file_exists(path_to_file):
		dir.remove(path_to_file)
		dir.queue_free()
	else:
		push_error('File To Delete Doesnt Exist')
		return


'Upscale UI'
func upscale__ui(node ,size: String)-> void:
	#no one size fits all problem
	
	
	
	if size == "small": 
		var newScale = Vector2(0.08, 0.08); node.set_scale(newScale) 
	if size == "medium": 
		var newScale2 = Vector2(0.25,0.25); node.set_scale(newScale2)
	if size == "big": 
		var newScale3 = Vector2(1.5,1.5); node.set_scale(newScale3)
	if size == "XL": 
		var newScale4 = Vector2(3.5,3.5); node.set_scale(newScale4)
	else: pass
	
	




"Calculate the Average of an Array"
# assuming that it's an array of numbers
func calc_average(list: Array):
	if list.pop_front() != null:
		var numerator :int 
		var average : int 
		var denominator : int = list.size() + 1
		if numerator != null and denominator > 2:
			for i in list:
				numerator = numerator + i
			
			#if numerator && denominator != 0:
			average = numerator/denominator
			return average
	else : return

"File Checker"
# Global file checking method for DIrectory path and file name/type
# Copied from Wallet's Implementation
func check_files(path_to_dir: String, path_to_file : String)-> bool:
	if FileDirectory.dir_exists(path_to_dir):
		#print ("File Exists: ",FileCheck1.file_exists(path_to_file)) # For debug purposes only
		return FileCheck1.file_exists(path_to_file)
	else: return false


"Compression and Uncompression Algorithm"
# Documentation: https://git.sr.ht/~jelle/gdunzip
# Returns a pool byte array
# Has a problem with saving Text files
func uncompress(FILE: String) : #-> PoolByteArray:
	# Instance the gdunzip script
	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	
	
	var loaded = gdunzip.load(FILE)
	
	
	if loaded:
		
		print ("Zip File Data : ",gdunzip.files)
		
		print ("Files: ",gdunzip.files.keys().size())
		
		print ("First File: ",gdunzip.files.keys().front())
		

		

		# Returns an Uncompressed PoolByteArray
		# If string files contains excess characters, it would return an invalid utf-8 string
		# Only parses Zip files and decompresses the First Value 
		
		
		
		for f in gdunzip.files.values():
			print('File name: ' + f['file_name'])

			

			#Uncompresses files locally
			
			#for t in gdunzip.files.keys():
			#print ("Type of " + f['file_name'] + " ",typeof(gdunzip.get_compressed(t))) # for debug purposes only
			Networking.save_file_(gdunzip.get_compressed(f['file_name']), "res://"+f['file_name'], int(f['uncompressed_size'] ))


			# "compression_method" will be either -1 for uncompressed data, or
			# File.COMPRESSION_DEFLATE for deflate streams
			print('Compression method: ' + str(f['compression_method']))

			print('Compressed size: ' + str(f['compressed_size']))

			print('Uncompressed size: ' + str(f['uncompressed_size']))




"""
Quickly sets a videoplayer to Play music and videos
"""
# Would break if passed to anything other than videosteam player
func _Video_Stream(node : VideoPlayer, stream , _sound, viewport):
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



# Calculates the center of a Rectangle
func calc_center_of_rectangle(rect : Vector2) -> Vector2:
	return Vector2((rect.x/2), (rect.y/2))

# Produces Truely Randomized Results
func randomize_enemy_type() -> String:
	randomize()
	return ['Easy', "Intermediate", "Hard"][randi()%3]

static func calculateViewportSize( t : CanvasItem ) -> Vector2 :
	return t.get_viewport_rect().size



func _exit_tree():
	
	"Prints All Orphaned Nodes"
	# For proper Memory Leak Management
	memory_leak_management()
	#Globals.queue_free_children(Util)
	#MemoryManagement.free_object(Util)
