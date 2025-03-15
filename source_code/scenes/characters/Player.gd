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
# (5) Extends to Top DOwn and SideScrolling Player Scripts
# (6) Player & Enemy SFX is handled by simulation singleton
# (7) Connects Dialog Signals From Dialogs Singleton
# *************************************************
# To Do:
# (1) Implement State Buffer (Done)
# (2) 
# (3) State blocked is unimplemented
# (4) State Hurt Should Implement Blood Spawning FX not Process
# (5) Implement State Emote for Dancing with New Dancing (Emote) Animation
# (6) 
# (7) Implement Item Equip Animation From Inventory.gd
# (8) Player Sword Attack is unimplemented
# (9) Player animation should be callable via exported scripts
# (10) Player should export it's COllision states to simulations singleton
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

enum {
	STATE_BLOCKED, STATE_IDLE, STATE_WALKING,
	STATE_ATTACK, STATE_ROLL, STATE_DIE,
	STATE_HURT, STATE_DANCE
	}

enum {UP, DOWN, LEFT, RIGHT}

export(int) var state = STATE_IDLE
export(int) var facing = DOWN

#********Miscellaneous***********#
onready var player_camera: Camera2D = $camera # the player's camera
onready var animation: AnimationPlayer = $AnimationTree/anims


var local_heart_box = null # Pointer To Heart Box HUD

# Multiplayer #Depreciated for Networking Enumerator
# Check if Player is playing a multipplayer game

export(int) var peer_id: int = -99 # Dummpy Placeholder Peer id


# For Despawn and Hit Collission Fx
onready var blood: BloodSplatter = Globals.blood_fx.instance()
onready var despawn_particles: DeSpawnFX = Globals.despawn_fx.instance()

onready var die_sfx: String = Music.nokia_soundpack[27]
onready var hurt_sfx: String = Music.nokia_soundpack[20]
onready var dash_sfx : String = Music.wind_sfx[1]

# Get Singletons
onready var music_singleton_: music_singleton = get_node("/root/Music")

"""
Update Global Scripts SO Other Nodes Are Aware Of Player
"""
	
func _enter_tree():
	
	# IF THis Code Bloc Breaks Its cuz youre running the scene from Overworld
	# so it doesnt have time to load game hud scene into memeory and provide a safe pointer
	
	Globals.update_curr_scene()
	Globals.players.append(self) # saves player to the Global player variable
	
	'Makes Player Hitpoint a Global Variable'
	Globals.player_hitpoints = hitpoints
	

	# Enable TOuch HuD
	#print_debug("Enabling Touch HUD For Player Input")
	
	
	#"Check If Online" #Depreciated for Networking Enumerator
	#OFFLINE = Simulation.all_player_objects.empty()


func _ready():
	
	# Buggy check ln 74
	#Behaviour.AutoSpawn(self)
	# Set Player Object To The Minimap
	# TO DO : Use Signals for cleaner Implementation
	GlobalInput.gameHUD._Stats._Mini_map.player_node = self # TO Do : Fix Onready var bug
	
	Android.emit_signal("player_ready") # Triggers Android Specific Config for Player Movement
	
	# Connect To Dialogue Singleton
	
	if not (
			Dialogs.connect("singleton_dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("singleton_dialog_ended", self, "_on_dialog_ended") == OK):
		push_error("Error Connecting To The Dialog System")
		print_debug("Error connecting to dialog system")
	
	# COnnect To Health Bar Node via Global Input Singleton
	if not is_instance_valid(GlobalInput.gameHUD.heart_box):
		push_error("Error Connecting To The Heart Box System")
		print_debug("Error Connecting To The Heart Box System")
	
	if is_instance_valid(GlobalInput.gameHUD.heart_box):
		local_heart_box = GlobalInput.gameHUD.heart_box
		self.connect("health_changed", local_heart_box, "_on_health_changed")
		
		update_heart_box()
	
		# Debug Connection
		if not self.is_connected("health_changed", local_heart_box, "_on_health_changed") == true:
			print_debug("Heart Box Node Not Connected")
			push_error("Heart Box Node Not Connected")

func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + _facing
	state = STATE_IDLE


func despawn():
	#this code breaks
	# To DO : Move this code to a dedicated hit collision detection calss
	
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood)
	if is_instance_valid(despawn_particles): # Check if the desapawn particle is available
		despawn_particles.global_position = global_position
	
	if is_instance_valid(blood): # Check if the blood particle is available
		blood.global_position = global_position
	
	
	self.hide()

# Exposed Dynamic Function To Upate The Game HUD Heart Box 
# From ANother Scen Throught THe Player
 
func update_heart_box():
	# Call The Method With My HP To Register Current Player HP
	local_heart_box._on_health_changed(hitpoints)


func respawn():
	'Updated Respawn Code'
	#Reboots the current scene if the Player Dies
	# Reusing the preloaded scene resource
	# Triggered with animation player
	if Globals.scene_resource != null:
		Utils.Functions.change_scene_to(Globals.scene_resource, get_tree())
	else:
		get_tree().reload_current_scene()
		emit_signal("health_changed", hitpoints)
		return 0


func shake(): # Shaky Cam FX
	Globals.player_cam.shake()


func hurt(from_position: Vector2):
	# Duplicate of _on_hurtbox_area_entered
	if state != STATE_DIE:
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction: Vector2 = (global_position - from_position).normalized()
		move_and_slide(pushback_direction * pushback)
		state = STATE_HURT
		
		blood.global_position = global_position
		get_parent().add_child(blood)
		
		music_singleton_.play_track(hurt_sfx)
		if hitpoints <= 2:
			# Play Music With SFX
			music_singleton_.set_sound_effect(music_singleton_.FX.PITCH_SHIFT, true)
		
		if hitpoints <= 0:
			state = STATE_DIE
			# turn off music sfx
			music_singleton_.set_sound_effect(music_singleton_.FX.PITCH_SHIFT, false)
			music_singleton_.play_track(die_sfx)


func dash():
	music_singleton_.play_track(dash_sfx)

