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
# (5) Causes a ram hog with loaded and preloaded variables (1/2)
# *************************************************

extends Node

class_name GlobalsVar


# Load Scenes Programmatically
# Rewriting to Use Dictionary and only load scene when needed to optimise memory usage
var global_scenes : Dictionary = {"title": "res://scenes/Title screen.tscn",
"form":"'res://scenes/UI & misc/form/form.tscn'",
"controls": 'res://scenes/UI & misc/Controls.tscn',
"loading" : "res://scenes/UI & misc/LoadingScene.tscn",
"wallet" : 'res://scenes/Wallet/Wallet main.tscn',
"cinematics" : "res://scenes/cinematics/cinematics.tscn"
}

var form : PackedScene 
var controls : PackedScene 
var _wallet : PackedScene 
var title : PackedScene 
var cinematics : PackedScene 

onready var curr_scene : String = ""
onready var os: String = OS.get_name()
onready var kill_count : int = 0 #update to load from savefile

# 
var players : Array = [] # All Players
var player : Player # My Player

# Player cam
var player_cam 

#var _p # Player placeholder
var player_hitpoints : int
var enemy = null
var enemy_debug : String 
var initial_level : String = "res://scenes/levels/Overworld.tscn"  # loading outside environment bug fixed

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

var loading_scene : PackedScene = preload("res://scenes/UI & misc/LoadingScene.tscn")

var Overworld_Scenes : Dictionary = {0 : "res://scenes/levels/Temple interior.tscn",
1 : "res://scenes/levels/DuneProcedural.tscn",
2: "res://scenes/levels/Building3.tscn",
3: "res://scenes/levels/Overworld3D.tscn",
4: "res://scenes/levels/Building1.tscn",
5: "res://scenes/levels/Overworld.tscn"
} # for simplifying loading and scene changes states

"Crypto Variables" 
var address : String
var mnemonic : String
var player_name : String

# Buggy
onready var algos : int  #=  Wallet.Wallet.load_account_info(false, Wallet.token_write_path, Wallet.FileCheck3, Wallet.UserData).get("_wallet_algos")
	#MicroAlgos 


"Device Variables"
var user_data_dir : String =OS.get_user_data_dir()


"Screen Orientation"
# for upscaling and wonscaling UI
onready var screenOrientation : int = Utils.Screen.Orientation() 
var viewport_size : Vector2
var center_of_viewport : Vector2 

"In Game FX"
var blood_fx: PackedScene = load ('res://scenes/UI & misc/Blood_Splatter_FX.tscn') #only load this once gameplay is on (optimization)
var despawn_fx: PackedScene = load ("res://scenes/UI & misc/DespawnFX.tscn")
var bullet_fx : PackedScene

"Node Pointer"
#var _smoke_fx_ 

'Temporary variants'
#var temp

"Wallet Algo"
#var NFT: TextureRect #should ideally be an array for multiple NFT's
#var wallet_state  #wallet state global variabe





"Game Map"
# Features
# (1) Speeds up loading times by hiding it behind cinematics
# Depreciated
#var tile_map : TileMap
var OverWorld : PackedScene
func _ready():
	#print_debug('Blood fx:',blood_fx) #optimize blood fx to only load during game runtimes
	#print_debug("Despawn Fx:", despawn_fx)
	
	
	
	
	#Set White Background
	VisualServer.set_default_clear_color(ColorN("white")) 
	
	

func update_curr_scene() -> void:
	curr_scene= get_tree().get_current_scene().get_name() 
	
	#print_debug ("current scene is: ", curr_scene)


func _go_to_title():
	update_curr_scene()
	'Quits if already at title screen'
	if curr_scene == 'Menu':
		get_tree().quit()
	#Music.play_track(Music.ui_sfx[1])
	
	'changes scene to title_screen'
	# Refactoring to use Large Level Scene Loader
	#title = load(global_scenes["title"])
	
	
	"Loads Large Scene"
	
	Utils.Functions.change_scene_to(Utils.Functions.LoadLargeScene(
	global_scenes["title"], 
	scene_resource, 
	_o, 
	scene_loader, 
	loading_resource, 
	a, 
	b, 
	progress
	), get_tree())
	
	#Utils.Functions.change_scene_to(title, get_tree())#get_tree().change_scene()
	return 0

func _go_to_cinematics():
	cinematics = load(global_scenes["cinematics"])
	Utils.Functions.change_scene_to(cinematics, get_tree())#get_tree().change_scene() 
	return 0





func _exit_tree():
	
	"Deletes all Orphaned Nodes"

	
	
	"Prints All Orphaned Nodes"
	# For proper Memory Leak Management
	Utils.MemoryManagement.memory_leak_management(self)
