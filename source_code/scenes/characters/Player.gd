# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# THe Core Player Script
#
# Features
# (1) THe world's camera
# (2) Player hitboxes
# (3) It's a class and stores variables to the UI, Globals singleton, PlayersSave Files, and the Debug SIngleton
# (4) Extend input from Global Input Singleton
# (5) Extends to Top DOwn, Online and SideScrolling Player Scripts
# (6) Player & Enemy SFX is handled by simulation singleton
# (7) Connects Dialog Signals From Dialogs Singleton
# (8) Collision detectin is done from simulation singleton
# *************************************************
# To Do:
# (1) 
# (2) 
# (3) 
# (4) State Hurt Should Implement Blood Spawning FX not Process
# (5) Implement State Emote for Dancing with New Dancing (Emote) Animation (Done)
# (6) 
# (7) Implement Item Equip Animation From Inventory.gd
# (8) Player Sword Attack is unimplemented
# (9) Player animation should be callable via exported scripts (1/2)

# (11) Impact fx should take a player & enemy colliding boolean parameter and should only trigger then, rather than whenever the attack button is pressed

# *************************************************

extends KinematicBody2D

class_name Player


export(int) var WALK_SPEED = 500 # pixels per second
export(int) var ROLL_SPEED = 1000 # pixels per second # Im getting rid of roll speed. ROll speed has to be twice of walk speed
# to endable speed stacking
export(int) var GRAVITY = 0 # For Platforming Levels
export(int) var ATTACK = 1 # For Item Equip
export(int) var hitpoints = 3
export(int) var pushback = 5000

export(Vector2) var linear_vel = Vector2()
export(Vector2) var roll_direction = Vector2.DOWN

export(Array) var StateBuffer: Array = []
export(String) var item_equip = "" # Unused Item Equip Variant
signal health_changed(hitpoints)

export(String, "up", "down", "left", "right") var _facing = "down" # used as a parameter for the player animation state machine


# For Animation Player State Machine
export(String) var anim: String = ""
export(String) var new_anim: String = ""

enum TOP_DOWN{
	STATE_BLOCKED, STATE_IDLE, STATE_WALKING,
	STATE_ATTACK, STATE_ROLL, STATE_DIE,
	STATE_HURT, STATE_DANCE
	}

enum FACING {UP, DOWN, LEFT, RIGHT}

export(int) var state = TOP_DOWN.STATE_IDLE
export(int) var facing = FACING.DOWN

#********Miscellaneous***********#
onready var player_camera: Camera2D = $camera # the player's camera
onready var animation: AnimationPlayer = $AnimationTree/anims
onready var TouchTimer : Timer = $TouchTimer

var local_heart_box = null # Pointer To Heart Box HUD

# Multiplayer #Depreciated for Networking Enumerator
# Check if Player is playing a multipplayer game

export(int) var peer_id: int = -99 # Dummpy Placeholder Peer id


# Get Global Singletons
# for safe calls 
onready var music_singleton_ = get_node("/root/Music") # : music_singleton
var global_singleton_ 
onready var utils_singleton_= get_node("/root/Utils") #  : GlobalsVar 
onready var safe_Android = get_node("/root/Android")
onready var safe_GameHud = get_node("/root/GameHud")
onready var safe_Dialogs = get_node("/root/Dialogs")
onready var safe_TouchScreen = safe_GameHud.get_TouchInterface()
onready var safe_Simulation = get_node("/root/Simulation")

#onready var TouchHUD = safe_GameHud

# For Despawn and Hit Collission Fx
# to do:
# (1) set get function for parent class in charge of blood fx
onready var blood = global_singleton_.blood_fx.instance() # : BloodSplatter
onready var despawn_particles = global_singleton_.despawn_fx.instance() # : DeSpawnFX

onready var die_sfx: String = music_singleton_.nokia_soundpack.get(27)
onready var hurt_sfx: String = music_singleton_.nokia_soundpack.get(20)
onready var dash_sfx : String = music_singleton_.wind_sfx.get(1)

# Client & Server Logic for Top Down Player Movement

# Error Catcher for physics logic
# Checks if Peer Id can be called and Network Is Set up
onready var err = Networking.GamePlay

"""
Update Global Scripts SO Other Nodes Are Aware Of Player
"""
	
func _enter_tree():
	global_singleton_= get_node("/root/Globals")  
	
	
	# IF THis Code Bloc Breaks Its cuz youre running the scene from Overworld
	# so it doesnt have time to load game hud scene into memeory and provide a safe pointer
	# temporarily disabling for refactor 2/June 2025. Would turn on later
	if is_instance_valid(global_singleton_):
		global_singleton_.update_curr_scene()
		global_singleton_.players.append(self) # saves player to the Global player variable
	
		'Makes Player Hitpoint a Global Variable'
		global_singleton_.hp = hitpoints
	if !is_instance_valid(global_singleton_):
		# use signals to fix this error
		push_error("player script not detecting  global singleton on start")


func _ready():
	
	# Buggy check ln 74
	#Behaviour.AutoSpawn(self)
	# Set Player Object To The Minimap
	# TO DO : Use Signals for cleaner Implementation
	safe_GameHud._Stats._Mini_map.player_node = self # TO Do : Fix Onready var bug
	
	safe_Android.emit_signal("player_ready") # Triggers Android Specific Config for Player Movement
	
	
	# COnnect To Health Bar Node via Global Input Singleton
	if not is_instance_valid(safe_GameHud.heart_box):
		push_error("Error Connecting To The Heart Box System")
		print_debug("Error Connecting To The Heart Box System")
	
	if is_instance_valid(safe_GameHud.heart_box):
		local_heart_box = safe_GameHud.heart_box
		self.connect("health_changed", local_heart_box, "_on_health_changed")
		
		update_heart_box()
	
		# Debug Connection
		if not self.is_connected("health_changed", local_heart_box, "_on_health_changed") == true:
			print_debug("Heart Box Node Not Connected")
			push_error("Heart Box Node Not Connected")


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + _facing
	state = TOP_DOWN.STATE_IDLE


func despawn():
	#this code breaks
	# To DO : Move this code to a dedicated hit collision detection calss
	print_debug("Debugging Player Despawn")
	
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood)
	if is_instance_valid(despawn_particles): # Check if the desapawn particle is available
		despawn_particles.global_position = global_position
	
	if is_instance_valid(blood): # Check if the blood particle is available
		blood.global_position = global_position
	
	# increase player's death count
	global_singleton_.death_count +=1
	
	self.hide()
	
	get_tree().reload_current_scene()


# Heartbox Update ROuter
# Exposed Dynamic Function To Upate The Game HUD Heart Box 
# From ANother Scene Throught THe Player
 
func update_heart_box():
	# Call The Method With My HP To Register Current Player HP
	local_heart_box._on_health_changed(hitpoints)


func respawn():
	'Updated Respawn Code'
	#Reboots the current scene if the Player Dies
	# Reusing the preloaded scene resource
	# Triggered with animation player
	if global_singleton_.scene_resource != null:
		utils_singleton_.Functions.change_scene_to(global_singleton_.scene_resource, get_tree())
	else:
		get_tree().reload_current_scene()
		emit_signal("health_changed", hitpoints)
		return 0


func shake(): # Shaky Cam FX
	global_singleton_.player_cam.shake()




func dash():
	music_singleton_.play_track(dash_sfx)


func _exit_tree():
	self.queue_free()
