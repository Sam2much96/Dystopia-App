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

extends CharacterBody2D

class_name Player



@export var WALK_SPEED: int = 500 # pixels per second
@export var ROLL_SPEED: int = 1000 # pixels per second # Im getting rid of roll speed. ROll speed has to be twice of walk speed
# to endable speed stacking
@export var GRAVITY: int = 0 # For Platforming Levels
@export var ATTACK: int = 1 # For Item Equip
@export var hitpoints: int = 3
@export var pushback: int = 5000

@export var linear_vel : Vector2 = Vector2()
@export var roll_direction : Vector2 = Vector2.DOWN

@export var StateBuffer: Array = []
@export var item_equip: String = "" # Unused Item Equip Variant
signal health_changed(current_hp)

@export var _facing = "down" # used as a parameter for the player animation state machine # (String, "up", "down", "left", "right")


# For Animation Player State Machine
@export var anim: String = ""
@export var new_anim: String= ""

enum { 
	STATE_BLOCKED, STATE_IDLE, STATE_WALKING, 
	STATE_ATTACK, STATE_ROLL, STATE_DIE, 
	STATE_HURT, STATE_DANCE 
	}

enum { UP, DOWN, LEFT, RIGHT}

@export var state : int = STATE_IDLE
@export var facing : int = DOWN

#********Miscellaneous***********#
@onready var player_camera : Camera2D = $camera #the player's camera
@onready var animation : AnimationPlayer = $anims


# Multiplayer #Depreciated for Networking Enumerator
# Check if Player is playing a multipplayer game
#export (bool) var OFFLINE : bool = true 

@export var peer_id : int = -99 # Dummpy Placeholder Peer id

# For Despawn and Hit Collission Fx
@onready var blood : BloodSplatter = Globals.blood_fx.instantiate()
@onready var despawn_particles : DeSpawnFX = Globals.despawn_fx.instantiate()

@onready var die_sfx : String = Music.nokia_soundpack[27]
@onready var hurt_sfx : String = Music.nokia_soundpack[20]

# Get Music Singleton
@onready var music_singleton_ : music_singleton = get_node("/root/Music")

func _enter_tree():
	Globals.update_curr_scene()
	Globals.players.append(self)  #saves player to the Global player variable
	
	'Makes Player Hitpoint a Global Variable'
	Globals.player_hitpoints = hitpoints

	#"Check If Online" #Depreciated for Networking Enumerator
	#OFFLINE = Simulation.all_player_objects.empty()


func _ready():
	
	
	if not (
			Dialogs.connect("dialog_started", Callable(self, "_on_dialog_started")) == OK and
			Dialogs.connect("dialog_ended", Callable(self, "_on_dialog_ended")) == OK ):
		printerr("Error connecting to dialog system")



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
	#this code breaks and is under refactoring

	
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood) 
	despawn_particles.global_position = global_position
	blood.global_position = global_position
	
	
	
	self.hide()


func respawn():
	'Updated Respawn Code'
	#Reboots the current scene if the Player Dies
	# Reusing the preloaded scene resource
	# Triggered with animation player
	if Globals.scene_resource != null:
		Globals.change_scene_to_packed(Globals.scene_resource)
	else: 
		return get_tree().reload_current_scene()


func shake(): # Shaky Cam FX
	Globals.player_cam.shake()


func hurt(from_position : Vector2):
	# Duplicate of _on_hurtbox_area_entered
	# To DO: Move To Separate Hit Collisionb CLass
	if state != STATE_DIE :
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction : Vector2 = (global_position - from_position).normalized()
		set_velocity(pushback_direction * pushback)
		move_and_slide()
		state = STATE_HURT
		#var blood = Globals.blood_fx.instantiate()
		blood.global_position = global_position
		get_parent().add_child(blood)
		
		await music_singleton_.play_track(hurt_sfx)
		
		if hitpoints <= 0:
			state = STATE_DIE
			await music_singleton_.play_track(die_sfx)




