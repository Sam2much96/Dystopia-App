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



var pilot_ep 
var VIDEO

var cinematics = preload ('res://resources/title animation/title..ogv') #I free memory once this is used
var title_screen = load( 'res://scenes/Title screen.tscn')
onready var form = load ('res://scenes/UI & misc/form/form.tscn')
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
var initial_level : String = "res://scenes/levels/Overworld.tscn"  # loading outside environment bug fixed
#var _Debug = null
var _player_state # gets state data from the player state machine
var video_stream #for the video streamers



# warning-ignore:unused_class_variable
var spawnpoint : Vector2
var spawn_x : int 
var spawn_y : int 
var current_level : String


# Music



var _controller_type : Dictionary = {1:'modern', 2:'classic'}
var direction_control  : String = _controller_type[1]  #toggles btw analogue and d-pad

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

# This Apps Global Screen Orientation
enum { SCREEN_HORIZONTAL, SCREEN_VERTICAL} 

# OS based Hardware Screen Orientation
# Would most likely be 6 for Auto-Rotate Setting on Android
#enum {
#	SCREEN_ORIENTATION_LANDSCAPE, SCREEN_ORIENTATION_PORTRAIT , SCREEN_ORIENTATION_REVERSE_LANDSCAPE,
#	SCREEN_ORIENTATION_REVERSE_PORTRAIT ,SCREEN_ORIENTATION_SENSOR_LANDSCAPE , SCREEN_ORIENTATION_SENSOR_PORTRAIT 
#	SCREEN_ORIENTATION_SENSOR  
#}

var screenOrientation : int
var viewport_size : Vector2
var center_of_viewport : Vector2 

"In Game FX"
var blood_fx: PackedScene = load ('res://scenes/UI & misc/Blood_Splatter_FX.tscn') #only load this once gameplay is on (optimization)
var despawn_fx: PackedScene = load ("res://scenes/UI & misc/DespawnFX.tscn")
var bullet_fx : PackedScene

"Node Pointer"
var _smoke_fx_ : smoke_fx 

'Temporary variants'
var temp

"Wallet Algo"
var NFT: TextureRect #should ideally be an array for multiple NFT's
var wallet_state  #wallet state global variabe


#" File Checkers"



"Ingame HUD"
# Mobiles
var _TouchScreenHUD : TouchScreenHUD



func _ready():
	print_debug('Blood fx:',blood_fx) #optimize blood fx to only load during game runtimes
	print_debug("Despawn Fx:", despawn_fx)


	player.append( get_tree().get_nodes_in_group('player') )#gets all player nodes in the scene
	 #it shows deleted object once player is despawns.
	if player.empty() == true: #error catcher 1            
		player.clear()
	
	
	#Set White Background
	VisualServer.set_default_clear_color(ColorN("white")) 



func update_curr_scene() -> void:
	curr_scene= get_tree().get_current_scene().get_name() 
	print_debug ("current scene is: ", curr_scene)


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
	# Can Save individual parameters by setting other parameters to Null
	#
	#
	static func save_game(
		player: Array, 
		player_hitpoints : int, 
		spawn_x : int, 
		spawn_y : int, 
		current_level : String, 
		os : String, 
		kill_count : int, 
		prev_scene : String, 
		prev_scene_spawnpoint,
		direction_control : String
		)-> bool: 
		
		print ("-------Saving Game -------")
		var save_dict : Dictionary = {}
		var save_game = File.new()
		save_game.open("user://savegeme.save", File.WRITE_READ)
		if !player.empty():
			save_dict.player = player #saves the player node 
		if spawn_x != 0:
			save_dict.spawn_x = spawn_x
		if spawn_y != 0:
			save_dict.spawn_y =spawn_y
		if not current_level.empty() :
			save_dict.current_level = current_level
		
		# Inventory List is saved individually
		if !Inventory.list().empty():
			save_dict.inventory = Inventory.list()
		if !Quest.get_quest_list().empty():
			save_dict.quests = Quest.get_quest_list()
		if not os.empty():
			save_dict.os = os
		if kill_count != 0 :
			save_dict.kill_count = kill_count
		#save_dict.currency = Suds #should load from encrypted wallet.cfg
		
		# For preserving scene changing information
		if not prev_scene.empty() :
			save_dict.prev_scene = prev_scene
			
		if prev_scene_spawnpoint != null: # Depreciate in favor of a singular spawpoint variable
			save_dict.prev_scene_spawnpoint = prev_scene_spawnpoint
		
		if player_hitpoints != 0:
			save_dict.player_hitpoints = player_hitpoints
		if not direction_control.empty():
			save_dict.direction_control = direction_control
		
		#Music on settings is a boolean converted to int
		if Music != null : 
			save_dict.music = int(Music.music_on) #add other variables to save
		
		# Language is saved independently
		if not Dialogs.language.empty():
			save_dict.languague = Dialogs.language
		
		save_game.store_line(to_json(save_dict))
		save_game.close()
		print ("saved gameplay")
		return true

	"""
	If check_only is true it will only check for a valid save file and return true or false without
	restoring any data
	"""
	static func load_game(check_only : bool, GlobalScript) -> bool:
		check_only = false
		print ("-------Loading Game -------")
		var save_game = File.new()
		
		
		if not save_game.file_exists("user://savegeme.save"):
			return false
		save_game.open("user://savegeme.save", File.READ)
		var save_dict = parse_json(save_game.get_line())
		if typeof(save_dict) != TYPE_DICTIONARY:
			return false
		if not check_only:
			_restore_data(save_dict, GlobalScript)
		
		save_game.close()
		return true

	"""
	Restores data from the JSON dictionary inside the save files
	"""
	static func _restore_data(save_dict : Dictionary, GlobalScript ):
		
		"Quest Loader"
		
		if save_dict.has('quests'):
			# JSON numbers are always parsed as floats. In this case we need to turn them into ints
			for key in save_dict.quests:
				save_dict.quests[key] = int(save_dict.quests[key])
			Quest.quest_list = save_dict.quests
		
		"Inventory Loader"
		
		if save_dict.has('inventory'):
			# JSON numbers are always parsed as floats. In this case we need to turn them into ints
			for key in save_dict.inventory:
				save_dict.inventory[key] = int(save_dict.inventory[key])
			Inventory.inventory = save_dict.inventory
		
		'OS loader'
		
		if save_dict.has('os'):
			GlobalScript.os = save_dict.os
		
		'Player'
		if save_dict.has('player'):
			GlobalScript.player = save_dict.player
			
		if save_dict.has("kill_count"):
			GlobalScript.kill_count = save_dict.kill_count  
			
		
		if save_dict.has('player_hitpoints'):
			GlobalScript.player_hitpoints = int(save_dict.player_hitpoints)
		
		'Player Object Spawn Position'
		if save_dict.has('spawn_x'):
			GlobalScript.spawn_x = save_dict.spawn_x 
			GlobalScript.spawn_y = save_dict.spawn_y
		
		'Saves Player Spawn Point'
		if save_dict.has('current_level'):
			GlobalScript.current_level = save_dict.current_level
		
		 
		"Scene Loader"
		if save_dict.has('prev_scene'):
			# Presumably a bugfix for scene changing
			GlobalScript.prev_scene =save_dict.prev_scene 
			GlobalScript.prev_scene_spawnpoint = save_dict.prev_scene_spawnpoint 
		
		'Control Settings'
		# Direction controller
		if save_dict.has('direction_control') && str(save_dict.direction_control) != 'Null':
			GlobalScript.direction_control = str(save_dict.direction_control)
		
		if save_dict.has("languague"):
			Dialogs.language = save_dict.languague


		if save_dict.has("music"):
			print_debug(bool(save_dict.music)) # For Debug Purposes Only
			Music.music_on = bool(save_dict.music)

		
		######################################################
		print_debug("Loaded gameplay")

	# Loads Singular User Data from local storage
	# Version 2 of Load_game function
	# Should allow for loading individual variables from Local
	static func load_user_data( data: String ):
		print ("-------Fast Loading User Data -------")
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
		#	if data == "Music_on_settings":
		#		Music.Music_on_settings = save_dict.Music_on_settings
		#		Music._ready()
		pass

	
	static func scroll(direction : bool , visible : bool, _scroller : ScrollContainer)-> void:
		# DOCS : https://godotengine.org/qa/92054/how-programmatically-scroll-horizontal-list-texturerects
		# using a boolean because it allows for only two options in it's data structure
		# True is up, false is down
		# Max is 449
		var scroll_constant : int = 4
		# Requires Delta Parameter for smooth scrolling 
		# but running this function as a static function means
		# it scrolls choppily
		
		
		if visible && direction:
			_scroller.scroll_vertical += 20 * scroll_constant  #* delta
		elif visible && !direction:
			_scroller.scroll_vertical -= 20 * scroll_constant  #* delta

			#print (scroller.scroll_vertical )#= scroll_constant  * delta



func turn_off_processing(toggle): # to improve game speed and turn off idle processsing
	if toggle is String:
		if toggle == "on":
			set_process(true)
		elif toggle == "off":
			set_process(false)
		else:
			push_warning ("This function only uses on/off strings to control the globals processing functon")
	else: return



func _exit_tree():
	
	"Deletes all Orphaned Nodes"

	
	
	"Prints All Orphaned Nodes"
	# For proper Memory Leak Management
	Utils.MemoryManagement.memory_leak_management(self)
