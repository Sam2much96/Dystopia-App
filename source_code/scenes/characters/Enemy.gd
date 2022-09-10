# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is the enemy mob AI machine
# information used by the Enemy mob.
# it uses a Finite state machine, with a mob state for attacking
# It also includes signals for when the player is enters and exits the enemy's collision
# To Add
#(1) Different enemy behaviours and classes
#Bugs 
# (1) Enemy AI is too simple to beat (i.e Dumb) (fixed)
# (2) Enemy AI lacks ability to throw Projectiles (fixed not implemented)
# (3) No Documentation
# (4) Enemy mob uses too much computer procesing power
# (5) Too much Physics procesing (fixed)
# (6) Navigation 
# *************************************************
# New Features
#(1) Raycast 2d for precision 
#



extends KinematicBody2D

class_name Enemy



var run_speed = 100   #mob runspeeed
var velocity = Vector2.ZERO #the movement vector
onready var player # = get_tree().get_nodes_in_group('player')  #reference to player
var m=0;  #distance variable

var enemy_distance_to_player # used to calculate how closely the enemy should follow the layer
export (int) var attack_wait_time #attack pause time

onready var raycast := $enemy_eyesight/pointer/RayCast2D
onready var pointer := $enemy_eyesight/pointer

#not used
export (String, 'Easy', "Intermediate", "Hard") var enemy_type #changes enemy behaviour depending on the enemy tpype # 
"""
 the  MOB AI script works on the assumption there will
 be only one player type
"""


export(int) var WALK_SPEED = 350
export(int) var ROLL_SPEED = 1000
export(int) var hitpoints = 3 #enemy life

#export (bool) var mob
var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#export (PackedScene) var blood_fx #= load("res://scenes/UI & misc/Blood_Splatter_FX.tscn") #uses globals scene instead
var Bullet = load ("res://scenes/items/Bullet.tscn")


var linear_vel = Vector2()
export(String, "up", "down", "left", "right") var facing = "down"

var anim = ""
var new_anim = ""

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, STATE_MOB } # state machine needs expansion

# Expansion of State Machine into?
#(1) State Chase
#(2) State Shoot
# 
var state = STATE_MOB #mob state is broken, needs to cast to raycast 2d
var center

func _ready():
	randomize_state()
	randomize_enemy_type() #disabling to debug
	
	update_facing()#for debug purposes only
	state = STATE_WALKING#for debug purposes only
	

func _process(_delta):
	"FACE THE PLAYER, IF HE'S VISIBLE"
	if player != null: 
		update_facing()

	if hitpoints <= 0: # Dies if hitpoint is zero
		state = STATE_DIE
		#despawn()

	"Enemy Behaviour Logic"
	
	if raycast.is_enabled() == true:
		if raycast.is_colliding() && player != null:
			calculate_center() #calculates distance to plaer
			move_and_slide(center) # moves to plater
			state = STATE_WALKING
			enemy_distance_to_player = abs(position.distance_to(player.position )) # Calculates the enemy distance to playrer
			
			#print (enemy_distance_to_player) # For debug purposes only
			if enemy_distance_to_player < 80: #uses enemy distance to auto attack
				#yield(get_tree().create_timer(attack_wait_time), "timeout") #adds an error #
				#IMPLEMENT TIMER TIMEOUT
				state = STATE_ATTACK
				#return state 
			if enemy_distance_to_player > 80:
				#shoot() #Disabling for now
				if enemy_type == "Hard":
					state = STATE_ROLL
					#return state
				if enemy_type == "Easy":
					state = STATE_WALKING
					#return state
				if enemy_type == "Intermediate":
					state = STATE_WALKING
				else: return




func _physics_process(_delta):
	match state:
		STATE_IDLE:
			new_anim = "idle_" + facing
		STATE_WALKING:
			linear_vel = move_and_slide(linear_vel)
			var target_speed = Vector2()
			
			if facing == "down":
				target_speed += Vector2.DOWN
			if facing == "left":
				target_speed += Vector2.LEFT
			if facing == "right":
				target_speed += Vector2.RIGHT
			if facing == "up":
				target_speed += Vector2.UP
			
			target_speed *= WALK_SPEED
			linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			
			new_anim = ""
			if abs(linear_vel.x) > abs(linear_vel.y):
				if linear_vel.x < 0:
					facing = "left"
				if linear_vel.x > 0:
					facing = "right"
			if abs(linear_vel.y) > abs(linear_vel.x):
				if linear_vel.y < 0:
					facing = "up"
				if linear_vel.y > 0:
					facing = "down"
			
			if linear_vel != Vector2.ZERO:
				new_anim = "walk_" + facing
			else:
				state = STATE_IDLE
			pass
		STATE_ATTACK:
			new_anim = "slash_" + facing
			pass
		STATE_ROLL:
			linear_vel = move_and_slide(linear_vel)
			var target_speed = Vector2()
			if facing == "up":
				target_speed.y = -1
			if facing == "down":
				target_speed.y = 1
			if facing == "left":
				target_speed.x = -1
			if facing == "right":
				target_speed.x = 1
			target_speed *= ROLL_SPEED
			linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			new_anim = "roll"
			pass
		STATE_DIE:
			new_anim = "die"
		STATE_HURT:
			new_anim = "hurt"
		STATE_MOB: # Calculates enemy Mob ai to player
			 # create a behavioural tree using raycast 2d
			player =get_tree().get_nodes_in_group('player').pop_front() # Incase there are more than 1 players
			var target = player.position  
			
			# update assumed distance to use both x and y co-ordinate planes and update outside mob state
			var assumed_distance = ((raycast.get_collision_point()).y) # An assumed distance using raycast collision point
			enemy_distance_to_player = abs(position.distance_to(target)) # Calculates the enemy distance to playrer

			"Enemy Distance to Player Can Be used to create Behavioral Trees"
			# Enemy Detection needs improvement
		
			if enemy_distance_to_player < assumed_distance : # compares the real distance to an assumed distance
				print ('player near me: True (', enemy_distance_to_player,')' ,' state: ', state) #for debug purposes only
			# Enemy distance is always greater than asumed distance
			if enemy_distance_to_player >  assumed_distance  : # compares the real distance to an assumed distance
				print ('player near me: False (', enemy_distance_to_player,')' ,' state: ', state) #for debug purposes only
				#goto_idle() 
				#state = STATE_ATTACK
				
			if raycast.is_colliding() :
				print (" Player is colliding with Raycast")
				print ("Raycast collides with body at point ", str(raycast.get_collision_point()))
				state = STATE_ATTACK
			
			if not raycast.is_colliding() :
				return
			

	if new_anim != anim:
		anim = new_anim
		$anims.play(anim)
	pass

# Reset to Idle State
func goto_idle():
	state = STATE_IDLE

func _on_state_changer_timeout(): # Disabled to write better enemy ai
	"A  RANDOM STATE CHANGER  "
	
	$state_changer.wait_time = rand_range(1.0, 5.0)
	state = randi() %3
	
	facing = ["left", "right", "up", "down"][randi()%3]
	

# Sets the enemy to a random state btw the first 3 states and a random direction
func randomize_state():
	randomize()
	state = randi() %3
	facing = ["left", "right", "up", "down"][randi()%3]
	return state 

func randomize_enemy_type():
	randomize()
	enemy_type = ['Easy', "Intermediate", "Hard"][randi()%3]
	return enemy_type

# Hurt Box collission is closest to the body's collision
func _on_hurtbox_area_entered(area):
	if not state == STATE_DIE && area.name == "player_sword": #if it's not dead and it's hit by the player"s sword collisssion
		hitpoints -= 1
		Music.play_sfx(Music.hit_sfx) # Plays sfx from the Music singleton
		#print ("enemy hitpoint: "+ str(hitpoints))# for debug purposes only
		var pushback_direction = (global_position - area.global_position).normalized()
		move_and_slide( pushback_direction *   rand_range(2000,10000)) # Flies back at a random distance
		state = STATE_HURT
		var blood = Globals.blood_fx.instance()
		get_parent().add_child(blood) # Instances Blood FX
		blood.global_position = global_position # Makes the fx position global?
		
		#$state_changer.start() # Disabled Random State Changer For Debugging
		


# Despawn Logic
func despawn()->  void:
	Globals.kill_count +=1
	var despawn_particles = despawn_fx.instance()
	var blood = Globals.blood_fx.instance()
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood)
	despawn_particles.global_position = global_position
	blood.global_position = global_position
	if has_node("item_spawner"):
		get_node("item_spawner").spawn()
	
	get_parent().remove_child(self)





#NEW_CODES
# warning-ignore:unused_argument
"Detects Player's entry and exit with an area 2d"

func _on_enemy_eyesight_body_entered(body):
	if body is Player :
		player = body
		raycast.set_enabled(true)
		run_speed = 150 #increase run speed if player is seen
		state = STATE_MOB
		print('player seen', 'State: ', state)
		print ("Enemy Type:", enemy_type) # for debug purposes
		#update_facing()

func _on_enemy_eyesight_body_exited(body):
	#help detect the player when he leaves
	if body is Player:
		
		run_speed = 300
		raycast.set_enabled(false) 
		player = null
		print ('player hidden, Turning of Raycast Detection')
		randomize_state()
		



func update_facing(): # Updates the Enemy to face the Player

	if player != null: #handles enemy facing player
		
		var enemy_direction= (self.position.direction_to(player.position))
		
		rotate_pointer(Vector2((enemy_direction.x), (enemy_direction.y))) # Rotates a Racast 2d to face the Enemy
		
		var X = round(enemy_direction.x) ; var Y =round (enemy_direction.y)
		if X == 0 and Y == 1:
			facing = 'down'
		if X == 1 and Y == 0:
			facing = 'right'
		if X == -1 and Y == 0:
			facing = 'left'
		if X == 0 and Y == -1:
			facing = 'up'
		#FACING CHEATSHEET
		#DOWN :X=0 , Y =1 [ Y> X] 
		#RIGHT :X= 1, Y= 0 [X > Y ]
		#LEFT: X = -1, Y = 0 [Y>X]
		#UP: X= 0, Y= -1   [X>Y]

func restaVectores(v1, v2): #vector substraction
		return Vector2(v1.x - v2.x, v1.y - v2.y)

func sumaVectores(v1, v2): #vector sum
		return Vector2(v1.x + v2.x, v1.y + v2.y)

# Updates the raycast to the Enemy"s Direction
func rotate_pointer(point_direction: Vector2) -> void:
	var temp =rad2deg(atan2(point_direction.x, point_direction.y))
	pointer.rotation_degrees = temp 

# calculates the center btw two vectors (player and target)
func calculate_center()-> Vector2:
	
	var target = player.position  
	var position = self.position 
	center = restaVectores(target, position) 
	return center

func shoot(): #spawns a bullet at a particular position
	#Disabling for now
	print ('shooting player')
	var b = Bullet.instance()
	self.add_child(b)
	b.transform = pointer.global_transform


func _on_hurtbox_area_exited(area):
	if state == STATE_DIE && area.name == "player_sword":
		if hitpoints <= 0:
			despawn()
