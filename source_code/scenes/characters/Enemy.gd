# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# Enemy AI State Machine
#
# This is the enemy mob AI machine
# information used by the Enemy mob.
# it uses a Finite state machine, with a mob state for attacking
# It also includes signals for when the player is enters and exits the enemy's collision
#
# To Do :
#(1) Refactor Enemy Logic to SImulations singleton for multiplayer gameplay, making sure no to depreciate current inmplementation
# (2) Implement boids algorithm as enemy behaviour
# (3) Separate Eyesight Logic from main enemy script
# (4) Object pool processing
# (5) Boids Algorithm
# (6) Fix Projectile System
# (7) Temporarily disabling Enemy AI for debugging and refactoring
# (8) Mob state should implement boids algorith using Enemy Object Pool
# (9) Enemy Simulation should be runnable from external scripts via exported functoins and variables
# (10 ) Navigarion agent code should be thoroughtly debugged
# (11) Enemy Kickback code on Hard enemy is excessive (1/2)
# (12) Expose Player and Enemy Collisions Easily to Each othe via simulation singleton
# (13) Expose ENemy Collision To Impack FX, a sub Player Script
# (14) Expose ENemy AI to Simulations singleton

# Bugs : 
#
# (1) Enemy AI lacks ability to throw Projectiles (Done)
# (2) Enemy AI lacks projectile implementation
# (3) Too much Physics procesing (Done) 
# (4) Navigation AI (Done)
# (5) Stop Enemy Collision with Enemy bug
# (6) Refactor Facing to use enumerations, not strings
# (7) Uses Too Much Static Memory
# (8) Hard Enemy Collision bug on ANdroid Mobiles
# (9) Implement Navigation Server/ Obstacles in walking state 
# (10) Implement collision detection with walls
# (11) Calculateds Distance to Player 3 times

# *************************************************
# Features
# (1) Raycast 2d for precision 
# (2) Navigation Agent for better Navigation
# (3) Static Memory optimization
# (4) Randomized Enemy Behaviour
# (5) Preprogrammed Behaviour Logic for differnent Environment
# (6) Uses an Enemy Object pool connected to Utils singleton
# (7) Enemy Pathfinding Visual Debugging
# (8) Spawn Randomized Items Upon Despawn
# (9) Proximity Attack : Attacks player when in range


extends KinematicBody2D

class_name Enemy


export (String, 'Easy', "Intermediate", "Hard") var enemy_type #changes enemy behaviour depending on the enemy tpype # 



# Used As Delta for Determining AI Processing rate
# i.e, if calculations are called every 30th frame or 5th frame
# This also Affects enemy mob speed and processor

# Match Frame Rate to Both Enemy TIme And Engine FPS
const IDIOT_FRAME_RATE = 60
const SLOW_FRAME_RATE = 30
const AVERAGE_FRAME_RATE = 15
const FAST_FRAME_RATE = 5

var selected_frame_rate : int

"Enemy Movement & Path Finding"

export (Vector2) var velocity = Vector2.ZERO #the movement vector
export (Vector2) var target_speed = Vector2() # used for walking State calculation
#var m=0;  #distance variable

export (int) var run_speed : int = 100   #mob runspeeed

export (float) var enemy_distance_to_player : float # used to calculate how closely the enemy should follow the layer
export (Vector2) var center : Vector2 # Used in Enemy Behaviour Logic calculation
onready var player #= get_tree().get_nodes_in_group('player')[0]  #reference to player
onready var raycast : RayCast2D = $enemy_eyesight/pointer/RayCast2D
onready var pointer : Node2D = $enemy_eyesight/pointer
onready var navi : NavigationAgent2D = $NavigationAgent2D
onready var path : Line2D = $Line2D
#onready var frame_counter : int = 0

export (Array) var pos_data : Array = []


export(int) var WALK_SPEED = 350
export(int) var ROLL_SPEED = 1000
export(int) var hitpoints = 3 #enemy life


#var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#var Bullet = Globals.bullet_fx#load ("res://scenes/items/Bullet.tscn") #null resource


export (Vector2) var linear_vel = Vector2.ZERO
export (Vector2) var enemy_direction = Vector2(0,0)
export (Vector2) var random_walk_direction : Vector2 = Vector2(100,100)


# refactor facing to use int instead of string literals
export(String, "up", "down", "left", "right") var facing = "down"

export (String) var anim = ""
export (String) var new_anim = ""

enum { 
	STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, # implemented 
	STATE_DIE, STATE_HURT, STATE_MOB, # implemented
	STATE_PROJECTILE, STATE_PLAYER_SIGHTED, # unimplemented
	STATE_PLAYER_HIDDEN , STATE_NAVIGATION_AI #unimplemented
	} # state machine needs expansion


# Enemy Animation Player
onready var anims : AnimationPlayer = $anims

export (int) var state = STATE_MOB #Fixed


"Enemy FX"
var despawn_particles
var blood : BloodSplatter

var kick_back_distance : int 
var pushback_direction : Vector2

func _enter_tree():
	# Create A Global reference to self
	# To DO: Use Enemy Object Pool to run enemy ai via simulations
	Utils.EnemyObjPool.append(self)
	
	
	# set processor's rate as a correlation of the enemy type
	if self.enemy_type == "Easy":
		self.selected_frame_rate = SLOW_FRAME_RATE
	if self.enemy_type == "Intermediate":
		self.selected_frame_rate = AVERAGE_FRAME_RATE
	if self.enemy_type == "Hard":
		self.selected_frame_rate = FAST_FRAME_RATE
	
	# randomize seed generator
	randomize()


func _ready():
	#player =get_tree().get_nodes_in_group('player').pop_front()
	
	# Disable Raycast
	raycast.set_enabled(false) 
	
		# If the Frame Rate is Low, Optimizze Processor
	# Bug: THis creates a scenerio where a players that hack the games enemies by overloading the processors
	# Bug: Bugt It also allows for a smoothe framerate
	if Debug.FPS_debug < 15:
		self.selected_frame_rate = IDIOT_FRAME_RATE
	
	kick_back_distance = Utils.calc_rand_number() # Calculates a random kickback distance
	
	# Redundancy Code
	_randomize_self(enemy_type)
	



func _process(_delta):
	#debug() #turn off when not debugging
	
	
	# Debug MOb Calculation
	#print_debug(abs(linear_vel.x),"/",abs(linear_vel.y))
	
	#if player != null:
	
	"Proximity Attack Logic"
	# buggy
	# use behavoiural logic instead
	#if abs(linear_vel.x) && abs(linear_vel.y) <= 8 and player != null: # Player is in clo9se proximity
	#	state = STATE_ATTACK
	#else : state = STATE_IDLE # change to state walk for random enemy parterns
	
	# Raises up a Frame Counter
	#frame_counter += 1
	

	"""
	ENEMY PROCESS LOGIC
	"""
	# Handles Players Processing like facing and Behavioural Patterns
	# Temporarily disabling processes for mobile debugging
	#
	# if player is visible
	if player != null: 
	#	
		# temporarily Disabling fofr debugging+
		# Bug: 
		# (1) Causues Wierd Swoop bug in Hard Enemy Types
		# (2) Disabling MBreaks the Player tracking mechanics
		
		# To Do:
		# (1) Separate Navigation Agent AI and  Enemy AI
		facing = Behaviour.update_facing(self.position, player.position, player, pointer, facing, Vector2(0,0))
#

	#	"Enemy Behaviour Logic 1"
	#	# Creates predictable enemy behaviour depending on certain parameters
		state = Simulation.Enemy_.proximity_attack_simulation(
			hitpoints, 
			raycast, 
			player, 
			player.position, 
			self.position , 
			self, 
			enemy_type, 
			state, 
			enemy_distance_to_player,
			center
			)
	#	
	#if player == null: # DUplicate State, TUrning off
	#	facing = Behaviour.update_facing(self.position, random_walk_direction, null, pointer, facing, Vector2(0,0))
	#	
	#	
	#	"Enemy Behaviour Logic 2"
	#	# Creates predictable enemy behaviour depending on certain parameters
	#	#state = Behaviour.behaviour_logic(hitpoints, raycast, player, player.position, self.position , self, enemy_type, state, enemy_distance_to_player)
	#	state = STATE_WALKING


	#if hitpoints <= 0: # Dies if hitpoint is zero # DUplicate state
	#	state = STATE_DIE


func _physics_process(_delta):
	
	
	match state:
		STATE_IDLE:
			new_anim = "idle_" + facing
		STATE_WALKING:
			# Features:
			# (1) Enemy Walks to a randomized Position
			# To Do:
			# (1) Implement Navigation Server/ Obstacles in walking state 
			# (2) Implement collision detection with walls
			#
			# # Set Navigation to Navigation server
			# replace with randomized walking sequence on ready
			
			#print_debug(facing, random_walk_direction)
			#afafaf
			# uses facing to determine enemy random walk directiom
			if facing == "up":
				random_walk_direction =Vector2(0,-100)#target_speed.y = -1
			if facing == "down":
				random_walk_direction =Vector2(0,100)
			if facing == "left":
				random_walk_direction =Vector2(-100,0)
			if facing == "right":
				random_walk_direction =Vector2(100,0)
			
			linear_vel = move_and_slide((random_walk_direction).normalized() * WALK_SPEED) # move and slide to a random direction
			
			linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			
			
			# implement Navigation 2d server
			Behaviour.enemy_navigation(navi, linear_vel, self.position, path, pos_data, 1)
			
			if linear_vel != Vector2.ZERO:
				new_anim = "walk_" + facing
				#print_debug("walk_" + facing)
			else:
				state = STATE_IDLE
			
			
		STATE_ATTACK:
			new_anim = "slash_" + facing
			pass
		STATE_ROLL:
			"Calculate DIstance to Player"
			if player != null:
				linear_vel = Utils.restaVectores(player.position, self.position) 
				linear_vel = move_and_slide(linear_vel) # THis line breaks if player is null
				#var target_speed = Vector2()
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
			if player == null: 
				state = STATE_WALKING
			
		STATE_DIE:
			new_anim = "die"
		STATE_HURT:
			new_anim = "hurt"
		STATE_MOB: # Calculates enemy Mob ai to player
			
			
			"""
			 the  MOB AI script works on the assumption there will
			 be only one player type visible at any given time
			"""

			"Enemy Navigation"
			# Duplicate of Walking State
			# TO Do :
			# (1) Implement boids algorithm
			# (2) Fix enemy flying off screeen bug
			if player != null:
				
				
				
				#print_debug(Functions.calculate_center(player.position, self.position))
				# unpotimized code uses static typed singleton. COnsider using singleton function directly
				#linear_vel = Functions.calculate_center(player.position, self.position)
				
				"Calculate DIstance to Player"
				linear_vel = Utils.restaVectores(player.position, self.position) 
				
				
				
				#
				# Bugs
				# (1) Enemy Naviagation Breaks Mob State
				# (2) Temporarily disabling
				
				#print_debug("Enemty Navigation breaks mob state")
				#Behaviour.enemy_navigation(navi, linear_vel, self.position, path, pos_data, 2)
				
				#print_debug(pos_data, navi.get_final_location())
				
				linear_vel = move_and_slide(linear_vel) # updates enemy movement
				
				# theres a process method for this
				# so what?
				facing = Behaviour.update_facing(self.position, player.position, player, pointer,facing, target_speed)
				
				
				#print_debug(target_speed) #target_speed?
				
				# Target speed is an unused parameter
				#target_speed *= WALK_SPEED
				
				#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9) # linear interpolate? # temporarily disabling
				
				"Debug AAll Mob State Parameters"
				#print_debug("mob state debug :", linear_vel,"/ " ,target_speed)
			
			
			if player == null:
				# walk to a predetermined location
				state = STATE_WALKING
			
			# reset animation name pointer
			new_anim = ""
			#uses the linear velocity to use an algorithm to decide the facing animation for walk state
			if linear_vel != Vector2.ZERO:
				new_anim = "walk_" + facing
				
				# debug new anim
				#print_debug("walk_" + facing) # works
				
				
				
				
			else:
				print_debug("Linear Velocity :" ,linear_vel)
				state = STATE_IDLE
			
			pass
		
		STATE_PROJECTILE:
			shoot()

	if new_anim != anim:
		anim = new_anim
		anims.play(anim)
	pass

# Reset to Idle State
func goto_idle():
	state = STATE_IDLE

func _randomize_self(enemy_type_ : String):
	# Creates Randomized Enemy Behaviour
	
	state = Behaviour.randomize_state(state)
	facing = Behaviour.randomize_facing(facing,["left", "right", "up", "down"])
	
	# Acts as redundancy code for preset and randomized enemy type
	if enemy_type_ == "":
		enemy_type_ = Behaviour.randomize_enemy_type(['Easy', "Intermediate", "Hard"])


func _get_player() -> Player :
	#
	# Gets the Player Object in the Scene Tree if Player unavailable 
	#rwfwdgfdg
	#
	#rgfefgefg
	if player == null:
		player =get_tree().get_nodes_in_group('player').pop_front() # Incase there are more than 1 players
	return player

# Hurt Box collission is closest to the body's collision
# To Do:
# (1) Expose Enemy Collision to Player Impact Script via simulation Singleton
# Bugs:
# (1) Triggers Prematurely by Spawn Area 
func _on_hurtbox_area_entered(area):
	Simulation.Enemy_.hit_collision_detected(
		area, 
		state, 
		hitpoints, 
		pushback_direction, 
		self,
		global_position,
		kick_back_distance
		)
	
	#print_debug("Fix ENemy Player Collision Spammer")
	#if not state == STATE_DIE && area.name == "player_sword": #if it's not dead and it's hit by the player"s sword collisssion
	#	print_debug("Enemy Struck, Implement Make RPC CAll if error > 0")
	#	hitpoints -= 1
	#	Music.play_sfx(Music.hit_sfx) # Plays sfx from the Music singleton
	#	#print_debug ("enemy hitpoint: "+ str(hitpoints))# for debug purposes only
	#	var pushback_direction = (global_position - area.global_position).normalized()
	#	move_and_slide( pushback_direction *   kick_back_distance) # Flies back at a random distance
	#	state = STATE_HURT
	#	blood = Globals.blood_fx.instance()
	#	#get_parent().add_child(blood) # Instances Blood FX
	#	
	#	get_parent().call_deferred("add_child", blood)
	#	blood.global_position = global_position # Makes the fx position global?
		
		
		#$state_changer.start() # Disabled Random State Changer For Debugging
		


# Despawn Logic
# despawn logic is buggy
func despawn()->  void:
	# Increase global pointer
	Globals.kill_count +=1
	
	# Create Despawn Particle fx
	despawn_particles = Globals.despawn_fx.instance()
	blood = Globals.blood_fx.instance()
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood)
	despawn_particles.global_position = global_position
	blood.global_position = global_position
	
	# Spawn Item If able to
	if has_node("item_spawner"):
		get_node("item_spawner").spawn()
	
	#Remove Object from Ojbject pool
	Utils.EnemyObjPool.erase(self)
	
	#Prevents memory leaks
	#get_parent().remove_child(self)
	self.queue_free()


#NEW_CODES
# warning-ignore:unused_argument
"Detects Player's entry and exit with an area 2d"

func _on_enemy_eyesight_body_entered(body)-> void:
	if body is Player :
		player = body
		raycast.set_enabled(true)
		run_speed = 300 #increase run speed if player is seen
		
		# set up fight cam
		# buggy
		#Globals.player_cam.add_target(self)
		#Globals.player_cam.add_target(player)
		
		
		# Disabbling for Refactoring
		#Behaviour.enemy_navigation(navi, body.position, path, pos_data)
		state = STATE_MOB
		
		#print_debug('player seen', 'State: ', state)
		#print_debug ("Enemy Type:", enemy_type) # for debug purposes



func _on_enemy_eyesight_body_exited(body)-> void:
	#help detect the player when he leaves
	if body is Player:
		
		run_speed = 150
		
		# Turn off Raycast detection
		raycast.set_enabled(false) 
		player = null
		#state = STATE_WALKING
		
		#print ('player hidden, Turning of Raycast Detection')
		
		# Disabling for Refactoring
		#state = Behaviour.randomize_state(state)
		


func shoot()-> void: #spawns a bullet at a particular position
	#Disabling for now
	# Method Is Buggy
	
	print ('shooting player')
	var b = Globals.bullet_fx.instance()
	self.add_child(b)
	b.transform = pointer.global_transform


func _on_hurtbox_area_exited(area):
	if state == STATE_DIE && area.name == "player_sword":
		if hitpoints <= 0:
			despawn()

# to improve game speed and turn off idle processsing
# use wisely
# no really useefull is it?
#func turn_processing(toggle : String): 
#
#	if toggle == "on":
#		self.set_process(true)
#		self.set_physics_process(true)
#	elif toggle == "off":
#		set_process(false)
#		self.set_physics_process(false)
#	else:
#		push_warning ("This function only uses on/off strings to control the globals processing functon")


func debug()-> void:
	# Debugs AI variables to the Console log
	if Simulation.frame_counter % IDIOT_FRAME_RATE == 0:
		print_debug ("State: ",state,"/ Distance to player " ,enemy_distance_to_player, "/ Enemy Type",enemy_type)

func _exit_tree():
	# Delete self pointer from Global object pool 
	if Utils.EnemyObjPool.has(self): Utils.EnemyObjPool.erase(self)


"Perfomance Optimizers"
#
# Features
# (1) Turns off processing and physics processing when player is off screen
func _on_VisibilityNotifier2D_screen_entered():
	self.set_process(true)
	self.set_physics_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	self.set_process(false)
	self.set_physics_process(false)




class Behaviour extends Reference:
	"""
	# Enemy AI Behaviour in A  SeparateClass
	
	# Using Global Methods and Classes makes enemy behaviour AI to perform better
	# And Faster, in Realtime Gameplay
	
	"""
	
	# TO DO : Implement Boids Algorithm
	
	# body is self
	static func update_facing(body_position : Vector2, player_position : Vector2, player , pointer, _facing : String, enemy_direction: Vector2)-> String:
		""" 
		Updates the Enemy to face the Player
		returns a string "facing"
		"""
		#handles enemy facing player
		if player != null: 
			
			enemy_direction= (body_position.direction_to(player_position))
			Utils.rotate_pointer(Vector2((enemy_direction.x), (enemy_direction.y)), pointer) # Rotates a Racast 2d to face the Enemy
			
			var X = round(enemy_direction.x) ; var Y =round (enemy_direction.y)
			if X == 0 and Y == 1:
				_facing = 'down'
			if X == 1 and Y == 0:
				_facing = 'right'
			if X == -1 and Y == 0:
				_facing = 'left'
			if X == 0 and Y == -1:
				_facing = 'up'
			
			return _facing
			
			#FACING CHEATSHEET
			#DOWN :X=0 , Y =1 [ Y> X] 
			#RIGHT :X= 1, Y= 0 [X > Y ]
			#LEFT: X = -1, Y = 0 [Y>X]
			#UP: X= 0, Y= -1   [X>Y]
		#return _facing
		
		# handles enemy facing a target location
		if player == null:
			enemy_direction= (body_position.direction_to(player_position))
			
			Utils.rotate_pointer(Vector2((enemy_direction.x), (enemy_direction.y)), pointer) # Rotates a Racast 2d to face the Enemy
			
			var X = round(enemy_direction.x) ; var Y =round (enemy_direction.y)
			if X == 0 and Y == 1:
				_facing = 'down'
			if X == 1 and Y == 0:
				_facing = 'right'
			if X == -1 and Y == 0:
				_facing = 'left'
			if X == 0 and Y == -1:
				_facing = 'up'
			
		return _facing


	static func enemy_navigation(navi : NavigationAgent2D, target_pos : Vector2, curr_pos : Vector2, line : Line2D, pos_data : Array, type: int): 
		# refactored Navigation agent
		# Navigation Agent doesn't focus on Player instead focuses on the scene origin's point
		navi.set_target_location(target_pos) # target location is the player position
		
		
		if Debug.enabled and type == 2: # Debug Navigation path
			line.add_point(navi.get_final_location())
			#line.points = [navi.get_final_location(), curr_pos]
			pos_data.append(line.points)

		if Debug.enabled and type == 1:
			line.points = [navi.get_final_location(), curr_pos]


	static func randomize_facing(facing : String, number_of_options : Array) :
		
		facing = number_of_options[randi()% int(number_of_options.size()- 1)]
		
		return facing


# Sets the enemy to a random state btw the first 3 states and a random direction
	static func randomize_state(state):
		
		state = randi() %3
		
		
		return state 

	static func randomize_enemy_type( options : Array):
		return Utils.randomize_enemy_type() # Returns Hard

	# Updates the raycast to the Enemy"s Direction
	static func rotate_pointer(point_direction: Vector2, pointer) -> void:
		var temp =rad2deg(atan2(point_direction.x, point_direction.y))
		pointer.rotation_degrees = temp


#class Functions extends Reference:
#	
#	# calculates the center btw two vectors (player and target) as a static method callable from any script
#	depreciated in favour for dynaamically typed singleton function
#	static func calculate_center(player_position : Vector2, initial_position : Vector2)-> Vector2:
#		
#		var center = Utils.restaVectores(player_position, initial_position) 
#		return center

