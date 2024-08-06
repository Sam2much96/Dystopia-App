# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Utils
# Contains Shared Calculation Codes between scenes
# Features:
# (1) Handles all Gameplay Calculations
# (2) Implements Multithreading

# To Do:
# (1) Document
# (2) Refactor codebase to move all calculation code from Globals Singleton
#
# 
# Bugs 
# (1) 
# *************************************************

extends Node


@export var screenOrientation : int
@export var viewport_size : Vector2
@export var center_of_viewport : Vector2 

@export var EnemyObjPool : Array = [] #Stores shared pointer to enemy Mob instances

var dir : DirAccess #= DirAccess.new() # Global FIle And DirAccess Paths
var file : FileAccess #= File.new()

"Compression and Uncompression Algorithm"
# Documentation: https://git.sr.ht/~jelle/gdunzip
# Reads Data from a Zip File
# Has a problem with saving Text files
# Has a problem with Large files (Decompression is really slow)

class Zip extends RefCounted:
	func uncompress(FILE: String, Uncompressd_rooot_dir: String) : #-> PackedByteArray:
		# Instance the gdunzip script and Check if it is valid
		var gdunzip_script : GDScript = load('res://addons/gdunzip/gdunzip.gd')
		var gdunzip : GDunzip = gdunzip_script.new()
		
		assert(gdunzip.get_script() == gdunzip_script)
		
		var FileCheck1 : FileAccess = Utils.file
		
		#"Compression/Uncompression"
		var unziped_file : PackedByteArray
		
		var loaded = gdunzip.load(FILE)
		if loaded:
			
			print ("Zip File Data : ",gdunzip.files) # for debug purposes only
			
			print ("Files: ",gdunzip.files.keys().size()) # For Debug purposes only
			
			print ("First File: ",gdunzip.files.keys().front()) # For Debug purposes only 
			


			
			# Returns an Uncompressed PoolByteArray
			# If string files contains excess characters, it would return an invalid utf-8 string
			# Only parses Zip files and decompresses the First Value 
			
			"Debugs Zip Files"
			
			for f in gdunzip.files.values():
				print('File name: ' + f['file_name'])

				
				
				
				var concat : String = Uncompressd_rooot_dir+f['file_name']
				
				"Checks if Zipped File is present at file path" 
				if not FileCheck1.file_exists(Uncompressd_rooot_dir + f['file_name']):
					# save the file's uncompressed Pool Byte Array
					unziped_file = gdunzip.uncompress(f["file_name"])

		 			#Uncompresses files locally
					print("saving", f["file_name"], "Locally", unziped_file.size(), "to: ", concat)
				#for t in gdunzip.files.keys():
				#	print ("Type of " + f['file_name'] + " ",typeof(gdunzip.get_compressed(t))) # for debug purposes only
				
					Networking.save_file_(unziped_file, concat, int(f['uncompressed_size']))


				# "compression_method" will be either -1 for uncompressed data, or
				# File.COMPRESSION_DEFLATE for deflate streams
				print('Compression method: ' + str(f['compression_method']))

				print('Compressed size: ' + str(f['compressed_size']))

				print('Uncompressed size: ' + str(f['uncompressed_size']))



class Player_utils extends RefCounted:
	
	
	
	func _get_player(scene_tree : SceneTree) :
	#
	# Gets the Player Object in the Scene Tree if Player unavailable 
	#	
	# Rewrite into a separate function
		Globals.players.append( scene_tree.get_nodes_in_group('player') )#gets all player nodes in the scene
	 #it shows deleted object once player is despawns.
		if Globals.players.is_empty() == true: #error catcher 1            
			Globals.players.clear()
		#
		if Globals.player == null:
			Globals.player = Globals.players[0] # Incase there are more than 1 players
		return Globals.player
		pass

# Calculates the center of a Rectangle
func calc_center_of_rectangle(rect : Vector2) -> Vector2:
	return Vector2((rect.x/2), (rect.y/2))

# Produces Truely Randomized Results
func randomize_enemy_type() -> String:
	randomize()
	#_randomize(self)
	return ['Easy', "Intermediate", "Hard"][randi()%3]

# Randomizes node
# FIxes the randomize states on Game Objects
#func _randomize(node):
	#node.get_script().
#	return randomize()

func array_to_string(arr: Array) -> String:
	# Used For Multiplayer data Encoding
	# Converts an array to a string and concatonates it
	# The result s is then converted to an integer
	# This is a simple encoding formulae for input and state buffer to reduce data packet size
	var s = ""
	for i in arr:
		s += String(i)
	return s

func int_to_array(data : int)-> Array:
	# Used For Multiplayer Data decoding
	# converts a large integer into separate value and encodes the result into an array
	# essentialy decoding the data that array_to_string encodes
	# used in simulation logic
	var num_str = str(data)
	var num_array = []
	for i in range(num_str.length()):
		num_array.append(int(num_str[i]))
	return num_array

"Memory Leak/ Orphaned Nodes Management System"
class MemoryManagement extends RefCounted :
	# To-Do: Method Should Implement a THread
	
	static func queue_free_children(node: Node) -> void:
		for idx in node.get_child_count():
			node.queue_free()
			
	static func free_children(node: Node) -> void:
		for idx in node.get_child_count():
			node.free()

	static func free_object (object: Object) -> void:
		object.free()

	static func queue_free_array(nodes: Array) -> void:
		# SHould Ideally Spawn a THread
		
		for i in nodes:
			if i != null:
				i.queue_free()

	#prints all orphaned nodes in project
	static func memory_leak_management(from : Node):
		return 1 #from.print_orphan_nodes() 


"Functions Class"

class Functions extends RefCounted:
	# Shared Functions Class
	

	
	
	
	
	static func change_scene_to_packed(scene : PackedScene, tree : SceneTree): #Loads scenes faster?
		
		#if scene is PackedScene: 
			if scene != null: 
				return tree.change_scene_to_packed(scene)  

			else: print_debug (scene," ", typeof(scene) ,"is not supported in this function")
	
	'Resource Loader FOr Large Scenes'
	# Bugs
	# (11 Performance Hog on Low powered devices
	# (2) Progress Debug is not exportable
	static func LoadLargeScene(
		_to_load : String, 
		scene_resource : PackedScene, 
		_o : ResourceLoader, 
		scene_loader : ResourceLoader, 
		_loading_resource : bool, 
		a: int , 
		b : int, 
		progress: float
		) -> PackedScene:
		
		print_debug("Loading Large Scene :", _to_load, "/", scene_resource)
		if _to_load != "" && scene_resource == null:
			var time_max = 50000 #sets an estimate maximum time to load scene
			var t = Time.get_ticks_msec()
			
			
			
			#_o= (scene_loader.load_threaded_request(_to_load)) #function returns a resourceInteractiveLoader

			scene_loader.load_threaded_request(_to_load) #function returns a resourceInteractiveLoader
			
		
			#print (" Loader Debug Outer loop >>> Inner Loop")
			while Time.get_ticks_msec() < (t + time_max) && _o != null: 

				var err = _o.poll()
				#loading_resource = true
				
				print_debug ("_q: ",scene_resource," _r: ",_to_load," Error: ",str(err),"Loop Debug") #Debugger
				
				
				
				if err == ERR_FILE_EOF: # Finished Loading #Works
					_loading_resource = false
					
					scene_resource = (_o.get_resource()) 
					print_debug (scene_resource , "Resource Loaded")
					
					break
					#return _q
				# Tracks Scene Resource Progress. 
				# Should be exportable to UI/ UX
				elif err == OK: #works
					a = _o.get_stage()
					b = _o.get_stage_count() 
					progress = (b/a) 
					#print (a, "/",b,'/',"Progress: ", progress) #progress Debug?
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
		
		print_debug ("-------Saving Game -------")
		var save_dict : Dictionary = {}
		var save_game : FileAccess = Utils.file 
		save_game.open("user://savegeme.save", FileAccess.WRITE_READ)
		if !player.is_empty():
			save_dict.player = player #saves the player node 
		if spawn_x != 0:
			save_dict.spawn_x = spawn_x
		if spawn_y != 0:
			save_dict.spawn_y =spawn_y
		if not current_level.is_empty() :
			save_dict.current_level = current_level
		
		# Inventory List is saved individually
		if !Inventory.list().is_empty():
			save_dict.inventory = Inventory.list()
		if !Quest.get_quest_list().is_empty():
			save_dict.quests = Quest.get_quest_list()
		if not os.is_empty():
			save_dict.os = os
		if kill_count != 0 :
			save_dict.kill_count = kill_count
		#save_dict.currency = Suds #should load from encrypted wallet.cfg
		
		# For preserving scene changing information
		if not prev_scene.is_empty() :
			save_dict.prev_scene = prev_scene
			
		if prev_scene_spawnpoint != null: # Depreciate in favor of a singular spawpoint variable
			save_dict.prev_scene_spawnpoint = prev_scene_spawnpoint
		
		if player_hitpoints != 0:
			save_dict.player_hitpoints = player_hitpoints
		if not direction_control.is_empty():
			save_dict.direction_control = direction_control
		
		#Music on settings is a boolean converted to int
		if Music != null : 
			save_dict.music = int(Music.music_on) #add other variables to save
		
		# Language is saved independently
		if not Dialogs.language.is_empty():
			save_dict.languague = Dialogs.language
		
		# Control Settings
		# Vibration
		save_dict.vibrate = GlobalInput.vibrate
		
		save_game.store_line(JSON.new().stringify(save_dict))
		save_game.close()
		print ("saved gameplay")
		print_debug("Save GamePlay Is Buggy in v 4.2 port")
		return false

	"""
	If check_only is true it will only check for a valid save file and return true or false without
	restoring any data
	"""
	static func load_game(check_only : bool, GlobalScript : GlobalsVar) -> bool:
		check_only = false
		print_debug ("-------Loading Game-------")
		var save_game : FileAccess =Utils.file
		
		
		if not save_game.file_exists("user://savegeme.save"):
			return false
		save_game.open("user://savegeme.save", FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_game.get_line())
		var save_dict = test_json_conv.get_data()
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

		if save_dict.has("vibrate"):
			GlobalInput.vibrate = bool(save_dict.vibrate)

		if save_dict.has("music"):
			print_debug("Mus: ",bool(save_dict.music)) # For Debug Purposes Only
			Music.music_on = bool(save_dict.music)

		
		######################################################
		print_debug("Loaded gameplay")

	# Loads Singular User Data from local storage
	# Version 2 of Load_game function
	# Should allow for loading individual variables from Local
	static func load_user_data( data: String ):
		
		var save_game : FileAccess = Utils.file 
		if not save_game.file_exists("user://savegeme.save"):
			return false
		save_game.open("user://savegeme.save", FileAccess.READ)
		var test_json_conv : JSON = JSON.new()
		test_json_conv.parse(save_game.get_line())
		var save_dict : Dictionary = test_json_conv.get_data()
		if typeof(save_dict) != TYPE_DICTIONARY:
			return false

		if save_dict.has(data):
			print_debug ("Loading user data: ", data)
			if data == 'languague':
				Dialogs.language = save_dict.languague
			if data == "Music_on_settings":
				Music.Music_on_settings = save_dict.Music_on_settings
				Music._ready()




	static func calculate_length_breadth(point_positions: Array) -> Vector2:
		# Calculates the Length and Breadth of a 2Dimensional Vector
		
		var min_x = float('inf')
		var max_x = -float('inf')
		var min_y = float('inf')
		var max_y = -float('inf')

		# Find the minimum and maximum x and y coordinates
		for point in point_positions:
			min_x = min(min_x, point.x)
			max_x = max(max_x, point.x)
			min_y = min(min_y, point.y)
			max_y = max(max_y, point.y)

		# Calculate the length and breadth
		var length = max_x - min_x
		var breadth = max_y - min_y

		return Vector2(length, breadth)
 
	static func edge_length(point_data: PackedVector2Array) -> Vector2:
	# Caclulates the Edge Length of a 4 Point Structure
	# Calculates the distance between 2 points
	# Source : https://stackoverflow.com/questions/7475004/calculate-width-and-height-from-4-points-of-a-polygon
		var width = sqrt(pow(point_data[1].x - point_data[0].x, 2) + pow( point_data[1].y - point_data[0].y,2)) 
		var height = sqrt(pow(point_data[2].x - point_data[1].x, 2) + pow( point_data[2].y - point_data[1].y,2)) 
		return Vector2(width, height)

"Screen Class "
class Screen  :
	
	
	var screenOrientation : int
	var screenOrientationSettings : int = DisplayServer.screen_get_orientation()
	
	# This Apps Global Screen Orientation
	enum { SCREEN_HORIZONTAL, SCREEN_VERTICAL} 
		
	
	# Should Get Screen Size, Screen Scale and All screen properties
	# Should Debug this data to the Debug Singleton
	# Should only be called once
	static func debug_screen_properties():
		print ('OS Screen Orientation: ', DisplayServer.screen_get_orientation())
		print('Global Screen Orientation: ',Globals.screenOrientation)
		# match this variable to Global Screen Orientation
		print ('Screen Size 1: ',DisplayServer.screen_get_size(-1)) #yes. This variable changes when screen rotates
		print ('Screen Scale: ',DisplayServer.screen_get_scale())
		pass


	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile
	static func Orientation() -> int:
		'Screen Size Resolution'
		var screenSize : Vector2
		
		var screenOrientation : int
		
		'Algorithm for Calculating Screen Orientation'
		# Features:
		# (1) uses an Integer from the Global Singleton to stroe the calculation
		# (2) Returns an integer representain an Enumeration of the screen orientation
		var screen : Vector2 =DisplayServer.screen_get_size(-1) # get the current screen size
		
		
		# screen orientation enum copied from Globals main
		# To Do: Write an algorithm that compares the x and y values for OS.get_screen_size(-1) and the OS.get_screen_orientation() parameters
		# to determine if Screen is Horizontal or vertical. Use the Result to set Screen Orientation
		# in a process function
		
		
		# Resizes window the preselected sizes
		# Sets Default Screen Orientation for Android
		# Disabled
		#if GlobalScript.os == "Android":
		#	screenOrientation = GlobalScript.SCREEN_VERTICAL
		#else: screenOrientation = GlobalScript.SCREEN_HORIZONTAL 
		
		
		
		# Algorithmic calculation using screen orientation
		# And screen size to determine if the screen 
		# is horizontal or vertical
		
		if screen.x > screen.y:
			screenOrientation = SCREEN_HORIZONTAL
		if screen.x < screen.y:
			screenOrientation = SCREEN_VERTICAL

		# for debug purposes only
		print_debug("Screen orientation is: ", screenOrientation, "/",'screen size :',screen)


		
		#screenOrientation = OS.get_screen_orientation() # Should return a 6 for AutoRotate on Ndroid # Should ideally be a process function
		
		return screenOrientation
		
	static func calculateViewportSize( t : CanvasItem ) -> Vector2 :
		return t.get_viewport_rect().size



	static func display_calculations( display, GlobalScript):
		'Screen Display Calculations'
		if display is CanvasItem:
			# Get Viewport Size, Make it Globally accessible
			GlobalScript.viewport_size = calculateViewportSize(display)
			#Globals.center_of_viewport = Globals.calc_center_of_rectangle(Globals.viewport_size)
			
		if display is SubViewport:
			GlobalScript.viewport_size = display.size
		
		
		GlobalScript.center_of_viewport = GlobalScript.calc_center_of_rectangle(GlobalScript.viewport_size)
		
		# Prints out the Current Viewport Size
		#print_debug("Viewport Size: ", GlobalScript.viewport_size ,"/","Center of Viewprt: ", GlobalScript.center_of_viewport ) # for debug purposes only
		
	
	
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
	
	
	static func calculate_button_positional_data(
		menu : TouchScreenButton, 
		_interract : TouchScreenButton,
		stats : TouchScreenButton, 
		roll : TouchScreenButton, 
		slash : TouchScreenButton, 
		comics : TouchScreenButton, 
		joystick : TouchScreenButton, 
		D_pad : Control
		)-> Array:
		
		# OS Check
		assert(Globals.os == "Android")
		
		# Returns an Array containing the position of all Touch HUD items
		# Only Used in Mobile devices for adjusting TOuchscreen HUD
		# Rewrite as Static function under utils screen class (Done)
	# *************************************************
		var buttons_positional_data : Array = []
		
		# Create Variabls
		
		
		var menu_position : Vector2
		var _interract_position : Vector2
		var stats_position : Vector2
		var roll_position : Vector2
		var slash_position : Vector2
		var comics_position : Vector2
		var joystick_position : Vector2
		var D_pad_position : Vector2
		
		
		# BUTTONS POSITIONAL DATA 
		menu_position = menu.position
		_interract_position = _interract.position
		stats_position = stats.position
		roll_position = roll.position
		slash_position = slash.position
		comics_position = comics.position
		joystick_position = joystick.position
		D_pad_position = D_pad.get_rect().position

		buttons_positional_data = [
			menu_position,
			stats_position,
			comics_position,
			_interract_position,
			slash_position,
			roll_position,
			
			#joystick_position, # Joystick Positional data is buggy in debugg
			D_pad_position,
			menu_position
		]
		return buttons_positional_data
	
	
	static func _adjust_touchHUD_length(Anim : AnimationPlayer):
		
		# *************************************************
		"Touch Screen UI"
		#
		# Features
		# (1) Uses a Global Screen Orienation variable
		# (2) Uses an Animation Player to Set Node Position
		#
		# Bugs
		# (1) Disaligns on Different Mobile Devices
		# To Do
		# (1) Implement Globals Screnn Class Calculations
		# (2) Use Scene Display Calculations to Fix Misalignment Bug on Mobile Devices 
		# (3) Implement Calculations in the Animation Player
		# *************************************************
		
		
		
		#'Changes the button Layout depending on the screen orientation for Mobile UI'
		#implement joystick and D-pad variations
		
		if Globals.screenOrientation == 1 && Globals.direction_control == Globals._controller_type[2]: #worksif _action_button_showing == false
			Anim.play("SCREEN_VERTICAL_1");
		if Globals.screenOrientation == 1 && Globals.direction_control == Globals._controller_type[1]: #works
			Anim.play("SCREEN_VERTICAL_2");
		##If screen Is Horizontal, it would be PC UI, making this code obsolete
		elif Globals.screenOrientation == 0:
			Anim.play("SCREEN_HORIZONTAL");
		else: pass
	
	


	# Convert bytes to Megabytes
	static func _ram_convert(bytes) :
		if bytes >= int(1):
			var _mb = String(round(float(bytes) / 1_048_576))
			return _mb


"Procedural Generation"
class procedural extends RefCounted:
	# Bug: Maxes Out Static Memory, Refactoring to use dynamic memeory instead
	#
	
	static func genereate(simplex_noise : FastNoiseLite, 
	world_seed : String, 
	noise_octaves : int, 
	noise_period : int, 
	noise_persistence : float, 
	noise_lacunarity : float, 
	noise_threshold : float,
	map_height : int,
	map_width : int,
	tile_map : TileMap
	):
		# generate a seed using a string and the hash of that string
		simplex_noise.seed = world_seed.hash()
		
		# set simplex noise using Editor values
		simplex_noise.fractal_octaves = noise_octaves
		simplex_noise.period = noise_period
		simplex_noise.persistence = noise_persistence
		simplex_noise.lacunarity = noise_lacunarity
		
		# Loop to every tile within Map Area Co-ordinates
		for x in range( round(-map_width) / 2, round(map_width) / 2):
			for y in range(round(-map_height) / 2, round(map_height) / 2):
				
				# conditional
				if simplex_noise.get_noise_2d(x, y) < noise_threshold:
					
					# generataes a tilemap
					_set_autotile(x, y, tile_map)
		if is_instance_valid(tile_map):
			tile_map.update_dirty_quadrants()


	# Sets the scenes autotile programmatically
	# Uses the Tilemap's set cell method & the x and y auto tile co-ordinates
	static func _set_autotile(x : int, y : int, tile_map : TileMap) -> void :
		if is_instance_valid(tile_map):
			#tile_map.set_cell(
			#	x,
			#	y, 
			#	tile_map.get_tileset().get_tiles_ids()[0], # Tile ID, the first one 
			#	false, # Completeley ignore the next three arguments
			#	#false, 
				#false, 
			#	tile_map.get_cell_autotile_coord(x, y ) # co-ordinate of the TileSet
			#)
			
			tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling

	static func clear(tile_map : TileMap):
		if is_instance_valid(tile_map):
			# Completely clearts the current tilemap
			tile_map.clear()
		else: push_error("TileMap Error: TIlemap not found")

'Delete Files'
func delete_local_file(path_to_file: String) -> void:
	
	if dir.file_exists(path_to_file):
		dir.remove(path_to_file)
		dir.queue_free()
	else:
		push_error('File To Delete Doesnt Exist')
		return




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

func calc_rand_number()-> int:
	var rando : int = randf_range(2000,10000)
	return rando


func calc_2d_distance_approx(x : Vector2, y : Vector2) -> int:
	var distance_float : float = 0.0
	var distance_int : int = 0
	distance_float=x.distance_to(y)
	distance_int = abs(distance_float)
	return distance_int

"File Checker"
# Global file checking method for DIrectory path and file name/type
# Copied from Wallet's Implementation
func check_files(path_to_dir: String, path_to_file : String)-> bool:
	var FileCheck1 #=File.new() # checks wallet mnemonic
	var FileDirectory=DirAccess #.new() #deletes all theon reset
	if FileDirectory : #.dir_exists(path_to_dir):
		#print ("File Exists: ",FileCheck1.file_exists(path_to_file)) # For debug purposes only
		return FileCheck1.file_exists(path_to_file)
	else: return false





		# Updates the raycast to the Enemy"s Direction
static func rotate_pointer(point_direction: Vector2, pointer : Node2D) -> void:
	var temp =rad_to_deg(atan2(point_direction.x, point_direction.y))
	pointer.rotation_degrees = temp



func restaVectores(v1 : Vector2, v2 : Vector2) -> Vector2: #vector substraction
	return Vector2(v1.x - v2.x, v1.y - v2.y)

func sumaVectores(v1 : Vector2, v2 : Vector2) -> Vector2: #vector sum
	return Vector2(v1.x + v2.x, v1.y + v2.y)


class UI extends RefCounted:
	
	'Upscale UI'
	static func upscale_ui(node ,size: Vector2, position : Vector2)-> void:
		#Upscales the UI elements of Nodes
		
		node.set_scale(size) 
		node.set_position(position)





class Downloader extends Node:
	# Unused Downloader Class   
	#
	###Generic File downloader######
	var t = Thread.new()
	
	func _init():
		var arg_bytes_loaded = {"name":"bytes_loaded","type":TYPE_INT}
		var arg_bytes_total = {"name":"bytes_total","type":TYPE_INT}
		add_user_signal("loading",[arg_bytes_loaded,arg_bytes_total])
		var arg_result = {"name":"result","type":TYPE_PACKED_BYTE_ARRAY}
		add_user_signal("loaded",[arg_result])
		pass
		
	func __get(domain : String ,url : String ,port: String,ssl : bool):
		if(t.is_active()):
			return
		t.start(Callable(self, "_load").bind({"domain":domain,"url":url,"port":port,"ssl":ssl}))
		 
	func _load(params): # what params?
		var err = 0
		var http = HTTPClient.new()
		err = http.connect(params.domain, Callable(params.port, params.ssl))
		 
		while(http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING):
			http.poll()
			OS.delay_msec(100)
		  
		var headers = [
		  "User-Agent: Pirulo/1.0 (Godot)",
		  "Accept: */*"
		 ]
		 
		err = http.request(HTTPClient.METHOD_GET,params.url,headers)
		 
		while (http.get_status() == HTTPClient.STATUS_REQUESTING):
			http.poll()
			OS.delay_msec(500)
		 
		var rb = PackedByteArray()
		if(http.has_response()):
			headers = http.get_response_headers_as_dictionary()
			while(http.get_status()==HTTPClient.STATUS_BODY):
				http.poll()
				var chunk = http.read_response_body_chunk()
				if(chunk.size()==0):
					OS.delay_usec(100)
				else:
					rb = rb+chunk
					call_deferred("_send_loading_signal",rb.size(),http.get_response_body_length())
		  
		call_deferred("_send_loaded_signal")
		http.close()
		return rb
	func _send_loading_signal(l,t):
		emit_signal("loading",l,t)
		pass
		 
	func _send_loaded_signal():
		var r = t.wait_to_finish()
		emit_signal("loaded",r)
		pass

			
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
		Utils.dir.open ("user://")
		var file_exists
		if Globals.os != str ('Android'):
			file_exists = Utils.dir.file_exists('user://video.webm')
		if Globals.os == str ('Android'):
			file_exists = Utils.dir.file_exists('user://video.ogv')
		
		print ('Video File Exists: ', file_exists)
		if not file_exists : # && downloading_video != true:
			print ('Video File Doesn.t exist,downloading' )#;_check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes())
			return Networking.request(Networking.url)
			#play_loading_cinematic() #Plays the Loading cinematic while the video file downloads
			#downloading_video = true
			Networking.connect("request_completed", Callable(self, "_http_request_completed"))
			print ('download completed')
		if not file_exists : #&& downloading_video == true:
			print('Already Downloading video, Please Wait or Quit and Restart')

	#Checks if the file exists

		if file_exists: 
			print ('Video File Exists')
			#stop_playing_laoding_cinematic()
			#downloading_video = false
			var err
			var video_file : FileAccess = Utils.file #File.new()
			var video_file_path = "user://video.ogv"
			#video_file.open(video_file_path, File.READ_WRITE)
			#err = (video_file.open(video_file_path, File.READ))
			print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
			
			var video_file_absolute_path = video_file.get_path_absolute()
			print ('Video File Path3D: ',video_file_path)
			print('Video file size : ', video_file.get_length())
			
			# Chhecks if the video is an 0 byte error
			if video_file.get_length() ==0 :
				push_error('Video file is corrupted /'+ str(video_file.get_length()))
			
			if video_file.is_open() && err == 0: #error catcher 2
				#Globals.VIDEO = ResourceLoader.load(video_file_path, 'VideoStreamTheora', false) #Don't make the video a global file
				#Music.notification(NOTIFICATION_PREDELETE) #. Fix Music off function #not needed
				print ('Playing Global video File: ', Globals.VIDEO )
				#_Video_Stream((Globals.AMV)) #Plays the AMV video with Shootback




	"""
	parses the poopbyte array as a video stream
	"""
	# Refactor into proper clas/static function
	func _http_request_completed(result, response_code, _headers, body): # dOWNLOADS A VIDEO FROM A SERVER
		if body.is_empty() != true: #Executes once a Connection is established 

			Utils.dir.open ("user://")
			var file_exists = Utils.dir.file_exists('user://video.webm')
			print ('Video File Exists: ', file_exists)
			
			#Checks if video file exits
			if not file_exists : #executes if videofile doesnt exit
				Utils.dir.open("user://")
				var _absolute_path = Utils.dir.get_current_dir ( )
				
				print ('DirAccess //', _absolute_path)
				var err : int
				var video_file = cinematic.Function.store_video_files(body)
				print ('Video file is open: ',video_file.is_open(), '/error :', err) #Debugs if file can open
				if video_file.is_open() && err == 0: #error catcher 2
					
					#download_video_size = Networking.get_body_size()#8gets video size from servers
					
					
					#downloading_video: bool, download_video_size : int
					cinematic.Function._check_download_size(int(Networking.get_body_size()), Networking.get_downloaded_bytes(), false, false)
					#var parser = _body.decompress(download_video_size) #decompresses the poolbyte
					


					#downloading_video = false
				#return Globals.video_stream
			if file_exists:
				print ('File Exists', file_exists)
		if body.is_empty() == true:
			print ('Streaming Site '+ Networking.url+ ' is unavailable ')
			print ('It could be a myriad of problems. Please debug carefully')



	"""
	STORES A POOL BYTE ARRAY TO A VIDEO FILE AND PUBLISHES IT AS A GLOBAL VARIABLE
	"""



func check_screen_orientation(orientation : int):
	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile
	orientation = Screen.Orientation()

