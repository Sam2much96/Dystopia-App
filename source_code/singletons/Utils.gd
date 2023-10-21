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


var screenOrientation : int
var viewport_size : Vector2
var center_of_viewport : Vector2 

"Compression and Uncompression Algorithm"
# Documentation: https://git.sr.ht/~jelle/gdunzip
# Reads Data from a Zip File
# Has a problem with saving Text files
# Has a problem with Large files (Decompression is really slow)
func uncompress(FILE: String, Uncompressd_rooot_dir: String) : #-> PoolByteArray:
	# Instance the gdunzip script
	var gdunzip = load('res://addons/gdunzip/gdunzip.gd').new()
	var FileCheck1 = File.new()
	
	#"Compression/Uncompression"
	var unziped_file : PoolByteArray
	var loaded = Gdunzip.load(FILE)
	if loaded:
		
		print ("Zip File Data : ",Gdunzip.files) # for debug purposes only
		
		print ("Files: ",Gdunzip.files.keys().size()) # For Debug purposes only
		
		print ("First File: ",Gdunzip.files.keys().front()) # For Debug purposes only 
		


		
		# Returns an Uncompressed PoolByteArray
		# If string files contains excess characters, it would return an invalid utf-8 string
		# Only parses Zip files and decompresses the First Value 
		
		"Debugs Zip Files"
		
		for f in Gdunzip.files.values():
			print('File name: ' + f['file_name'])

			
			
			
			var concat : String = Uncompressd_rooot_dir+f['file_name']
			
			"Checks if Zipped File is present at file path" 
			if not FileCheck1.file_exists(Uncompressd_rooot_dir + f['file_name']):
				# save the file's uncompressed Pool Byte Array
				unziped_file = Gdunzip.uncompress(f["file_name"])

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






# Calculates the center of a Rectangle
func calc_center_of_rectangle(rect : Vector2) -> Vector2:
	return Vector2((rect.x/2), (rect.y/2))

# Produces Truely Randomized Results
func randomize_enemy_type() -> String:
	randomize()
	return ['Easy', "Intermediate", "Hard"][randi()%3]




"Memory Leak/ Orphaned Nodes Management System"
class MemoryManagement extends Reference :
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
		return from.print_stray_nodes() 

"Screen Class "
class Screen extends Reference :
	var screenOrientation : int
	var screenOrientationSettings : int = OS.get_screen_orientation()
	# Should Get Screen Size, Screen Scale and All screen properties
	# Should Debug this data to the Debug Singleton
	# Should only be called once
	static func debug_screen_properties():
		print ('OS Screen Orientation: ', OS.get_screen_orientation())
		print('Global Screen Orientation: ',Globals.screenOrientation)
		# match this variable to Global Screen Orientation
		print ('Screen Size 1: ',OS.get_screen_size(-1)) #yes. This variable changes when screen rotates
		print ('Screen Scale: ',OS.get_screen_scale())
		pass


		"Handles Screen Orientation"
	static func Orientation(GlobalScript):
		
		
		'Algorithm for Calculating Screen Orientation'
		var screen : Vector2 =OS.get_screen_size(-1)
		
		
		# screen orientation enum copied from Globals main
		# Write an algorithm that compares the x and y values for OS.get_screen_size(-1) and the OS.get_screen_orientation() parameters
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
			GlobalScript.screenOrientation = GlobalScript.SCREEN_HORIZONTAL
		if screen.x < screen.y:
			GlobalScript.screenOrientation =  GlobalScript.SCREEN_VERTICAL

		
		print_debug("Screen orientation is: ", GlobalScript.screenOrientation, "/",'screen size :',screen)


		
		#screenOrientation = OS.get_screen_orientation() # Should return a 6 for AutoRotate on Ndroid # Should ideally be a process function
		if GlobalScript.screenOrientation == GlobalScript.SCREEN_VERTICAL :

			pass
		elif GlobalScript.screenOrientation == GlobalScript.SCREEN_HORIZONTAL:

			pass
		else: return 1;
		
		
	static func calculateViewportSize( t : CanvasItem ) -> Vector2 :
		return t.get_viewport_rect().size

	
	static func display_calculations( display, GlobalScript):
		'Screen Display Calculations'
		if display is CanvasItem:
			# Get Viewport Size, Make it Globally accessible
			GlobalScript.viewport_size = calculateViewportSize(display)
			#Globals.center_of_viewport = Globals.calc_center_of_rectangle(Globals.viewport_size)
			
		if display is Viewport:
			GlobalScript.viewport_size = display.size
		
		
		GlobalScript.center_of_viewport = GlobalScript.calc_center_of_rectangle(GlobalScript.viewport_size)
		# Prints out the Current Viewport Size
		print_debug("Viewport Size: ", GlobalScript.viewport_size ) # for debug purposes only
		print_debug ("Center of Viewprt: ", GlobalScript.center_of_viewport ) # for debug purposes onlys
		
		


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
	var FileCheck1=File.new() # checks wallet mnemonic
	var FileDirectory=Directory.new() #deletes all theon reset
	if FileDirectory.dir_exists(path_to_dir):
		#print ("File Exists: ",FileCheck1.file_exists(path_to_file)) # For debug purposes only
		return FileCheck1.file_exists(path_to_file)
	else: return false





		# Updates the raycast to the Enemy"s Direction
static func rotate_pointer(point_direction: Vector2, pointer) -> void:
	var temp =rad2deg(atan2(point_direction.x, point_direction.y))
	pointer.rotation_degrees = temp



func restaVectores(v1, v2): #vector substraction
	return Vector2(v1.x - v2.x, v1.y - v2.y)

func sumaVectores(v1, v2): #vector sum
	return Vector2(v1.x + v2.x, v1.y + v2.y)


