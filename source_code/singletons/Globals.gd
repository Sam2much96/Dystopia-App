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

#class_name GlobalsVar


# Load Scenes Programmatically
# Rewriting to Use Dictionary and only load scene when needed to optimise memory usage
export (Dictionary) var global_scenes  = {"title": "res://scenes/Title screen.tscn",
"form":"'res://scenes/UI & misc/form/form.tscn'",
"controls": 'res://scenes/UI & misc/Controls.tscn',
"loading" : "res://scenes/UI & misc/LoadingScene.tscn",
"wallet" : 'res://scenes/Wallet/Wallet main.tscn',
"cinematics" : "res://scenes/cinematics/cinematics.tscn"
}

export( PackedScene ) var form
export ( PackedScene ) var controls  
export ( PackedScene ) var _wallet 
export ( PackedScene ) var title 
export ( PackedScene ) var cinematics 

onready var curr_scene = "" # String
onready var os = OS.get_name() # String
export(int) var kill_count = 0 #update to load from savefile

# 
export (Array) var players  = [] # All Players
var player #: Player # My Player

# Player cam
var player_cam 

#var _p # Player placeholder
export (int) var player_hitpoints #: int
var enemy = null
export (String) var enemy_debug #: String 
export (String) var initial_level = "res://scenes/levels/Overworld.tscn"  # loading outside environment bug fixed

var video_stream #for the video streamers



# warning-ignore:unused_class_variable
export (Vector2) var spawnpoint = Vector2(0,0)
export (int ) var spawn_x# : int 
export (int ) var spawn_y #: int 
export (String) var current_level #: String


# Music



export (Dictionary) var _controller_type = {1:'modern', 2:'classic'} # : Dictionary 
export (String) var direction_control   = _controller_type[2] # : String #toggles btw analogue and d-pad

var uncompressed # Varible holds uncompressed zip files


#'ingame Environment Variables'
export (bool) var near_interractible_objects #which objects use this? # signposts

#'Scene Loading variables'
export (PackedScene) var scene_resource #: PackedScene # Large Resouce Scene Placeholder
export (String) var _to_load #: String  # Large Resource Placeholder Variable
var _o = ResourceInteractiveLoader#for polling resource loader
export (int) var err
export (int) var a #: int # Loader progress variable (a/b) 
export (int) var b #: int
export (bool) var loading_resource = false
onready var scene_loader= ResourceLoader
export (float) var progress #: float

# Loading scene preloading temporarilily disabled for Back porting
export (PackedScene) var loading_scene = load("res://scenes/UI & misc/LoadingScene.tscn")

export (Dictionary) var Overworld_Scenes = {0 : "res://scenes/levels/Temple interior.tscn",
1 : "res://scenes/levels/DuneProcedural.tscn",
2: "res://scenes/levels/Building3.tscn",
3: "res://scenes/levels/Overworld3D.tscn",
4: "res://scenes/levels/Building1.tscn",
5: "res://scenes/levels/Overworld.tscn"
} # for simplifying loading and scene changes states

#"Crypto Variables" 
export (String) var address #: String
export (String) var mnemonic #: String
export(String) var player_name #: String

# Buggy
export(int) var algos #=  Wallet.Wallet.load_account_info(false, Wallet.token_write_path, Wallet.FileCheck3, Wallet.UserData).get("_wallet_algos")
	#MicroAlgos 


#"Device Variables"
export (String) var user_data_dir = "res://" #OS.get_user_data_dir()


#"Screen Orientation"
# for upscaling and wonscaling UI
onready var screenOrientation = Utils.Screen.Orientation() #  : int
export (Vector2) var viewport_size #: Vector2
export (Vector2) var center_of_viewport #: Vector2 

#"In Game FX"
export (PackedScene) var blood_fx = load ('res://scenes/UI & misc/Blood_Splatter_FX.tscn') #: PackedScene #only load this once gameplay is on (optimization)
export (PackedScene) var despawn_fx = load ("res://scenes/UI & misc/DespawnFX.tscn")
export (PackedScene) var bullet_fx # Is this being Used by bullet instance?





#"Game Map"
# Features
# (1) Speeds up loading times by hiding it behind cinematics

export (PackedScene) var OverWorld #: PackedScene
func _ready():
	#print_debug('Blood fx:',blood_fx) #optimize blood fx to only load during game runtimes
	#print_debug("Despawn Fx:", despawn_fx)
	
	
	
	
	#Set White Background
	VisualServer.set_default_clear_color(ColorN("white")) 
	
	

func update_curr_scene() : #-> void:
	curr_scene= get_tree().get_current_scene().get_name() 
	
	#print_debug ("current scene is: ", curr_scene)


func _go_to_title():
	'Quits if already at title screen'
	if get_tree().get_current_scene().get_name() == 'Menu':
		get_tree().quit()
	Music.play_track(Music.ui_sfx[1])
	
	'changes scene to title_screen'
	title = load(global_scenes["title"])
	
	Utils.Functions.change_scene_to(title, get_tree())#get_tree().change_scene()
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
