# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# THe Player Script v2 implements networking calls via rpc 
# Features
# (1) THe world's camera
# (2) Player hitboxes
# (3) It's a class and stores variables to the UI, Globals singleton, PlayersSave Files, and the Debug SIngleton
# To Do:
#(1) Update Documentation
# (2) Implement Remote Proceedure calls Networking
# (3) Im not sure how to implement sstate machine calls to the client/server
# (4) Too much Detection going on
# (5) Implement RPC calls as methods (implemented as child of Client Node)
# (6) Implement tokenized player asset
# (7) Play animation remotely (works)
# (8) Player Camera Hierarchy bug
#		2 or more spawned players have their own cameras which misaligns the scene tree

# Depreciated, Delete Script Later
# *************************************************

extends KinematicBody2D

class_name Player_v2_networking




export(int) var WALK_SPEED = 350 # pixels per second
export(int) var ROLL_SPEED = 1000 # pixels per second
export(int) var hitpoints = 3

export var linear_vel = Vector2()
export var roll_direction = Vector2.DOWN

signal health_changed(current_hp)

export(String, "up", "down", "left", "right") var facing = "down"


var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#export (PackedScene) var blood_fx #= load("res://scenes/UI & misc/Blood_Splatter_FX.tscn")

var anim = ""
var new_anim = ""

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }

export var state = STATE_IDLE

#************ Scene Tree Objects *************#
onready var camera = $camera #the player's camera
onready var impact_fx = $Impact

onready var animation = $anims

var peer_id



func _enter_tree():
	Globals.update_curr_scene()

	if Globals.player != null:
		if Globals.player.empty() == true  :
			Globals.player.append(self)  #saves player to the Global player variable
	
	'Makes Player Hitpoint a Global Variable'
	Globals.player_hitpoints = hitpoints


func _ready():
	
	#detect if networking connection
	camera._set_current(true) 
	
	
	
	peer_id = get_tree().get_network_unique_id()

	" Connects to the Dialogue System"
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	
	pass


func _process(_delta):
	pass


func _physics_process(_delta):


	## PROCESS STATES
	#only process states if connected to a newworking id and only change your peer id's parameters
	
	
	
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			if (
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up")
				):
					state = STATE_WALKING
					
					#rpc calls to server
					#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
					
			if Input.is_action_just_pressed("attack"):
				state = STATE_ATTACK
				
				#rpc calls to server
				#rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
				
			if Input.is_action_just_pressed("roll"):
				state = STATE_ROLL
				roll_direction = Vector2(
						- int( Input.is_action_pressed("move_left") ) + int( Input.is_action_pressed("move_right") ),
						-int( Input.is_action_pressed("move_up") ) + int( Input.is_action_pressed("move_down") )
					).normalized()
				_update_facing()
			new_anim = "idle_" + facing
			#get_material().
			
			pass
		STATE_WALKING:
			if Input.is_action_just_pressed("attack"):
				state = STATE_ATTACK
				
			if Input.is_action_just_pressed("roll"):
				state = STATE_ROLL
			
			linear_vel = move_and_slide(linear_vel)
			
			#print('Player linear velocity: ', linear_vel) #for debug purposes only
			
			var target_speed = Vector2()
			
			if Input.is_action_pressed("move_down"):
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				target_speed += Vector2.UP
			
			target_speed *= WALK_SPEED
			#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			linear_vel = target_speed
			roll_direction = linear_vel.normalized()
			
			_update_facing()
			
			if linear_vel.length() > 5:
				new_anim = "walk_" + facing
			else:
				goto_idle()
			
			#rpc calls to server
			#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
			
		STATE_ATTACK:
			new_anim = "slash_" + facing
			
			
			#rpc calls to server
			#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
			pass
		STATE_ROLL:
			if roll_direction == Vector2.ZERO:
				state = STATE_IDLE
			else:
				linear_vel = move_and_slide(linear_vel)
				var target_speed = Vector2()
				target_speed = roll_direction
				target_speed *= ROLL_SPEED
				#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
				linear_vel = target_speed
				new_anim = "roll"
				
				#rpc calls to server
				#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
				
				if Input.is_action_just_pressed("attack"): #punch and slide
					state = STATE_ATTACK
		STATE_DIE:
			new_anim = "die"
			
			#rpc calls to server
			#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
			
		STATE_HURT:
			new_anim = "hurt"
			
			#rpc calls to server
			#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
	
	'UPDATE ANIMATION'
	if new_anim != anim:
		anim = new_anim
		animation.play(anim)
	pass


func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE


func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "up"
	if Input.is_action_pressed("move_down"):
		facing = "down"


func despawn():  #this code breaks
	var blood = Globals.blood_fx.instance()
	var despawn_particles = despawn_fx.instance()
	
	
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood) 
	despawn_particles.global_position = global_position
	blood.global_position = global_position
	
	
	
	hide()
	print ('Update Player code for proper despawing')
	yield(get_tree().create_timer(0.5), "timeout")
	#Update this code to update player position
	
	print ("player respawn is broken")
	#get_tree().reload_current_scene() #Reboots the current scene if the Player Dies
	if Globals._q != null:
		Globals.change_scene_to(Globals._q)
	else: get_tree().reload_current_scene()

func _on_hurtbox_area_entered():
	pass
