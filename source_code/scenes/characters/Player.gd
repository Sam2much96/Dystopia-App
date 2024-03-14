# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# THe Player Script
#
# Features
# (1) THe world's camera
# (2) Player hitboxes
# (3) It's a class and stores variables to the UI, Globals singleton, PlayersSave Files, and the Debug SIngleton
# (4) Extend input from Global Input Singleton
# (5) FOr Top Dwon View
# *************************************************
# To Do:
#(1) Update Documentation (Done)
# (2) Implement Networking Calls (done in v2)
# (3) State blocked is unimplemented
# (4) State Hurt Should Implement Blood Spawning FX not Process
# (5) Implement State Emote for Dancing with New Dancing (Emote) Animation
# (6) Implement Fight Camera (Done)
# (7) Implement Item Equip Animation From Inventory.gd
# (8) Player Attack is unimplemented
# (9) Separate into 2 Separate Core Classes with inheritances. A COre Player class and a Top DOwn Player Class (Done) 
# *************************************************

extends KinematicBody2D

class_name Player



export(int) var WALK_SPEED = 350 # pixels per second
export(int) var ROLL_SPEED = 1000 # pixels per second
export(int) var GRAVITY = 0 # For Platforming Levels
export(int) var ATTACK = 1 # For Item Equip
export(int) var hitpoints = 3
export(int) var pushback = 5000
#export (Array) var state_buffer : Array # Useful For Multuiplayer Simulation
export (Vector2) var linear_vel = Vector2()
export (Vector2) var roll_direction = Vector2.DOWN

export(String) var item_equip = ""
signal health_changed(current_hp)

export(String, "up", "down", "left", "right") var _facing = "down" # used as a parameter for the player animation state machine


# For Animation Player State Machine
export(String) var anim : String = ""
export(String) var new_anim : String= ""

enum { 
	STATE_BLOCKED, STATE_IDLE, STATE_WALKING, 
	STATE_ATTACK, STATE_ROLL, STATE_DIE, 
	STATE_HURT 
	}

enum { UP, DOWN, LEFT, RIGHT}

export (int) var state = STATE_IDLE
export (int) var facing = DOWN

#********Miscellaneous***********#
onready var player_camera : Camera2D = $camera #the player's camera
onready var animation : AnimationPlayer = $anims


# Helper Booleans
export (bool) var server_player : bool = false

func _enter_tree():
	Globals.update_curr_scene()
	Globals.players.append(self)  #saves player to the Global player variable
	
	'Makes Player Hitpoint a Global Variable'
	Globals.player_hitpoints = hitpoints


	# Check if Player is playing a multipplayer game
	# 0 is NO, 1 is yes
	if Networking.GamePlay != Networking.ONLINE:
		pass
	
	if Networking.GamePlay == Networking.ONLINE: # Connection Successful
		if is_network_master(): # if Server
			server_player = true # Indicate



func _ready():



	
	# Buggy check ln 74
	#Behaviour.AutoSpawn(self)
	
	
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	
	pass


func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + _facing
	state = STATE_IDLE



func despawn():  #this code breaks
	var blood = Globals.blood_fx.instance()
	var despawn_particles = Globals.despawn_fx.instance()
	
	
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
		Globals.change_scene_to(Globals.scene_resource)
	else: 
		return get_tree().reload_current_scene()


func equip(type : String):
	# Equips an item in the player class by setting a string variable
	# as a parameter that alters the top down player state
	# A Hacky Implementation of item equip logic
	self.item_equip = type

func shake(): # Shaky Cam FX
	Globals.player_cam.shake()


func hurt(from_position : Vector2):
	# Duplicate of _on_hurtbox_area_entered
	if state != STATE_DIE :
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction = (global_position - from_position).normalized()
		move_and_slide( pushback_direction * pushback)
		state = STATE_HURT
		var blood = Globals.blood_fx.instance()
		blood.global_position = global_position
		get_parent().add_child(blood)
		
		Music.play_track(Music.nokia_soundpack[20])
		
		if hitpoints <= 0:
			state = STATE_DIE
			Music.play_track(Music.nokia_soundpack[27])


#func start_timer(time: float):
#	timer.start(time)




