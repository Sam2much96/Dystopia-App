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
var direction_control  : String = _controller_type[2]  #toggles btw analogue and d-pad

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





"Tilemap"
var tile_map : TileMap

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


#



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
