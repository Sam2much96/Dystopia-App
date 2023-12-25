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
# To Add :
#(1)
#
# Bugs : 
#
# (1) Enemy AI lacks ability to throw Projectiles (Done)
# (2) Enemy AI lacks projectile implementation
# (3) Too much Physics procesing (Done) 
# (4) Navigation AI (2/3)
# (5) Stop Enemy Collision with Enemy bug
# (6) Refactor Facing to use enumerations, not strings
#

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


extends KinematicBody2D

class_name Enemy


# Organize Vabiables Please? (Done)
export (int) var attack_wait_time #attack pause time
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

var velocity = Vector2.ZERO #the movement vector
var target_speed = Vector2() # used for walking State calculation
var m=0;  #distance variable

var run_speed : int = 100   #mob runspeeed

var enemy_distance_to_player : float # used to calculate how closely the enemy should follow the layer

onready var player #= get_tree().get_nodes_in_group('player')[0]  #reference to player
onready var raycast : RayCast2D = $enemy_eyesight/pointer/RayCast2D
onready var pointer : Node2D = $enemy_eyesight/pointer
onready var navi : NavigationAgent2D = $NavigationAgent2D
onready var path : Line2D = $Line2D
#onready var frame_counter : int = 0

onready var pos_data : Array = []


export(int) var WALK_SPEED = 350
export(int) var ROLL_SPEED = 1000
export(int) var hitpoints = 3 #enemy life


#var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#var Bullet = Globals.bullet_fx#load ("res://scenes/items/Bullet.tscn") #null resource


var linear_vel = Vector2.ZERO
var enemy_direction = Vector2(0,0)
var random_walk_direction : Vector2 = Vector2(100,100)


export(String, "up", "down", "left", "right") var facing = "down"

var anim = ""
var new_anim = ""

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, STATE_MOB, STATE_PROJECTILE} # state machine needs expansion


var state = STATE_MOB #Fixed
var center

"Enemy FX"
var despawn_particles
var blood

func _enter_tree():
	# Create A Global reference to self
	Utils.EnemyObjPool.append(self)
	randomize()


func _ready():
	#player =get_tree().get_nodes_in_group('player').pop_front()
	
	raycast.set_enabled(false) 
	
	
	
	
	# Redundancy Code
	_randomize_self(enemy_type)
	
	#if enemy_type == "" or null: # If enemy behaviour isn't preset
	#	enemy_type = Behaviour.randomize_enemy_type(['Easy', "Intermediate", "Hard"]) #Calls A Global Function
	
	#print_debug(enemy_type) 


func _process(delta):
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
	
	# set processor's rate as a correlation of the enemy type
	if enemy_type == "Easy":
		selected_frame_rate = SLOW_FRAME_RATE
	if enemy_type == "Intermediate":
		selected_frame_rate = AVERAGE_FRAME_RATE
	if enemy_type == "Hard":
		selected_frame_rate = FAST_FRAME_RATE
	
	# If the Frame Rate is Low, Optimizze Processor
	# Bug: THis creates a scenerio where a players that hack the games enemies by overloading the processors
	# Bug: Bugt It also allows for a smoothe framerate
	if Debug.FPS_debug() < 15:
		selected_frame_rate = IDIOT_FRAME_RATE
	
	"""
	ENEMY PROCESS LOGIC
	"""
	# Handles Players Processing like facing and Behavioural Patterns
	
	# if player is visible
	if player != null: 
			
		facing = Behaviour.update_facing(self.position, player.position, player, pointer, facing, Vector2(0,0))


		"Enemy Behaviour Logic 1"
		# Creates predictable enemy behaviour depending on certain parameters
		state = Behaviour.behaviour_logic(hitpoints, raycast, player, player.position, self.position , self, enemy_type, state, enemy_distance_to_player)
		
	if player == null:
		facing = Behaviour.update_facing(self.position, random_walk_direction, null, pointer, facing, Vector2(0,0))
		
		
		"Enemy Behaviour Logic 2"
		# Creates predictable enemy behaviour depending on certain parameters
		#state = Behaviour.behaviour_logic(hitpoints, raycast, player, player.position, self.position , self, enemy_type, state, enemy_distance_to_player)
		state = STATE_WALKING

	
	# Checks the Conditional Every 30th Frame
	# Called every selected framerate. 30th Frame for slower processing
	# LOGIC: frame counter is a modulous of the selected frame rate
	# Depreciated to free up the Main Thread Process from repeated checks
	#if Simulation.get_frame_counter() > 0 &&  Simulation.get_frame_counter() % selected_frame_rate == 0:
	#	pass

	if hitpoints <= 0: # Dies if hitpoint is zero
		state = STATE_DIE
		#despawn()


	# Reset Frame Counter TO Conserver Memory
#	if frame_counter >= 1000:
#		frame_counter = 0

func _physics_process(delta):
	
	# Consider Moving All Physics calculation to the Globals Script
	
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
			
			#linear_vel = move_and_slide((global_position- random_walk_direction).normalized() * WALK_SPEED) # move and slide to a random direction
			linear_vel = move_and_slide((random_walk_direction).normalized() * WALK_SPEED) # move and slide to a random direction
			
			linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			
			
			# implement Navigation 2d server
			Behaviour.enemy_navigation(navi, linear_vel, self.position, path, pos_data, 1)
			
			if linear_vel != Vector2.ZERO:
				new_anim = "walk_" + facing
				#print_debug("walk_" + facing)
			else:
				state = STATE_IDLE
			pass
			
			
			
			#linear_vel = position.direction_to(linear_vel) * WALK_SPEED
			#move_and_slide(linear_vel)
			#navi.set_velocity(linear_vel_)
			
			
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
			
			
			"""
			 the  MOB AI script works on the assumption there will
			 be only one player type visible at any given time
			"""

			"Enemy Navigation"
			# Duplicate of Walking State
			if player != null:
				#print_debug(Functions.calculate_center(player.position, self.position))
				linear_vel = Functions.calculate_center(player.position, self.position)
				
				Behaviour.enemy_navigation(navi, linear_vel, self.position, path, pos_data, 2)
				
				#print_debug(pos_data, navi.get_final_location())
				
				linear_vel = move_and_slide(linear_vel) # updates enemy movement
				
				# theres a process method for this
				#facing = Behaviour.update_facing(self.position, player.position, player, pointer,facing, target_speed)
				
				
				#print_debug(target_speed) #target_speed?

				target_speed *= WALK_SPEED
				
				linear_vel = linear_vel.linear_interpolate(target_speed, 0.9) # linear interpolate?
			
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
		$anims.play(anim)
	pass

# Reset to Idle State
func goto_idle():
	state = STATE_IDLE

func _randomize_self(enemy_type : String):
	# Creates Randomized Enemy Behaviour
	
	state = Behaviour.randomize_state(state)
	facing = Behaviour.randomize_facing(facing,["left", "right", "up", "down"])
	
	# Acts as redundancy code for preset and randomized enemy type
	if enemy_type == "":
		enemy_type = Behaviour.randomize_enemy_type(['Easy', "Intermediate", "Hard"])


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
func _on_hurtbox_area_entered(area):
	if not state == STATE_DIE && area.name == "player_sword": #if it's not dead and it's hit by the player"s sword collisssion
		hitpoints -= 1
		Music.play_sfx(Music.hit_sfx) # Plays sfx from the Music singleton
		#print_debug ("enemy hitpoint: "+ str(hitpoints))# for debug purposes only
		var pushback_direction = (global_position - area.global_position).normalized()
		move_and_slide( pushback_direction *   rand_range(2000,10000)) # Flies back at a random distance
		state = STATE_HURT
		var blood = Globals.blood_fx.instance()
		get_parent().add_child(blood) # Instances Blood FX
		blood.global_position = global_position # Makes the fx position global?
		
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
func turn_processing(toggle : String): 

	if toggle == "on":
		self.set_process(true)
		self.set_physics_process(true)
	elif toggle == "off":
		set_process(false)
		self.set_physics_process(false)
	else:
		push_warning ("This function only uses on/off strings to control the globals processing functon")


func debug()-> void:
	# Debugs AI variables to the Console log
	if Simulation.frame_counter % IDIOT_FRAME_RATE == 0:
		print_debug ("State: ",state,"/ Distance to player " ,enemy_distance_to_player, "/ Enemy Type",enemy_type)

func _exit_tree():
	# Delete self pointer from Global object pool 
	if Utils.EnemyObjPool.has(self): Utils.EnemyObjPool.erase(self)


"Perfomance Optimizers"

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	set_physics_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	set_physics_process(false)




class Behaviour extends Reference:
	"""
	# Enemy AI Behaviour in A  SeparateClass
	
	# Using Global Methods and Classes makes enemy behaviour AI to perform better
	# And Faster, in Realtime Gameplay
	
	"""
	
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
		return _facing
		
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
		navi.set_target_location(target_pos) # target location is the player position
		
		
		if Debug.enabled and type == 2: # Debug Navigation path
			line.add_point(navi.get_final_location())
			#line.points = [navi.get_final_location(), curr_pos]
			pos_data.append(line.points)

		if Debug.enabled and type == 1:
			line.points = [navi.get_final_location(), curr_pos]


	static func behaviour_logic(hitpoints: int, raycast : RayCast2D, player : Player, player_pos , _position,_enemy, enemy_type : String, state, enemy_distance_to_player):
		
		"Enemy Behaviour Logic"
		# Provides Predetermined enemy behaviour
		# Runs as a Process
		# Uses State Machine in Physics Process 
		# Expand to Add More Functionalities
		if not hitpoints == 0:
			if raycast.is_enabled() == true:
				"Enemy Envcounters Player Node"
				
				# Calculates Distance to Player
				if raycast.is_colliding() && player != null:
					var center = Functions.calculate_center(player.position, _position) #calculates distance to plaer
					_enemy.move_and_slide(center) # moves to player
					state = STATE_MOB
					# # Calculates the enemy distance to playrer
					enemy_distance_to_player = abs(_position.distance_to(player_pos )) # Calculates the enemy distance to playrer
					
					#print_debug(enemy_distance_to_player) #
					# 
					# Attack Player when in range
					#
					# Nested If's?
					if enemy_distance_to_player < 80: #uses enemy distance to auto attack
						state = STATE_ATTACK
						return state 
					if enemy_distance_to_player > 80:
						#shoot() #Disabling for now
						if enemy_type == "Hard":
							state = STATE_ROLL
							return state
							
						# TO DO: Implement Shoot State FOr ENemy AI
						if enemy_type == "Easy":
							state = STATE_MOB
							return state
						if enemy_type == "Intermediate":
							#state = STATE_PROJECTILE
							state = STATE_MOB
							return state
						else: return
		
		# If Raycast Detecting and Player is Available
		# The chances of this is very low except in Multiplayer Gameply
		if raycast.is_enabled() == false && player != null:
			#use state changer timer to turn off processing
			push_error ('Debug Enenmy Behaviour Check')
		
		# If Raycast Detecting and Player is not Available
		# The chances of this is very low except in Multiplayer Gameply
		if raycast.is_enabled() == false && player == null:
			#use state changer timer to turn off processing
			push_error ('Debug Enenmy Behaviour Check')


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


class Functions extends Reference:
	
	# calculates the center btw two vectors (player and target)
	static func calculate_center(player_position : Vector2, initial_position : Vector2)-> Vector2:
		
		var center = Utils.restaVectores(player_position, initial_position) 
		return center

