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
#(1) Different enemy behaviours and classes (Done)
#Bugs 

# (2) Enemy AI lacks ability to throw Projectiles (Done)
# (3) No Documentation (Done)
# (4) Enemy mob uses too much computer procesing power (Done)
# (5) Too much Physics procesing (Done) 
# (6) Navigation AI (1/2)
# (7) Too much Detection (Done)
# (8) Stop Enemy Collision with Enemy bug

# *************************************************
# Features
# (1) Raycast 2d for precision 
# (2) Navigation Agent for better Navigation
# (3) Static Memory optimization
# (4) Enemy Can Either Be Hard Intermediate or Easy


extends KinematicBody2D

class_name Enemy


# Organize Vabiables Please?

var run_speed : int = 100   #mob runspeeed
onready var frame_counter : int = 0

# Used As Delta for Determining AI Processing rate
# i.e, if calculations are called every 30th frame or 5th frame
# This also Affects enemy mob speed and processor

# Match Frame Rate to Both Enemy TIme And Engine FPS
const IDIOT_FRAME_RATE = 60
const SLOW_FRAME_RATE = 30
const AVERAGE_FRAME_RATE = 15
const FAST_FRAME_RATE = 5

var selected_frame_rate : int

var velocity = Vector2.ZERO #the movement vector
onready var player # = get_tree().get_nodes_in_group('player')  #reference to player
var m=0;  #distance variable

var enemy_distance_to_player : float # used to calculate how closely the enemy should follow the layer
export (int) var attack_wait_time #attack pause time

onready var raycast : RayCast2D = $enemy_eyesight/pointer/RayCast2D
onready var pointer : Node2D = $enemy_eyesight/pointer
onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D

export (String, 'Easy', "Intermediate", "Hard") var enemy_type #changes enemy behaviour depending on the enemy tpype # 
"""
 the  MOB AI script works on the assumption there will
 be only one player type
"""


export(int) var WALK_SPEED = 350
export(int) var ROLL_SPEED = 1000
export(int) var hitpoints = 3 #enemy life


#var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#var Bullet = Globals.bullet_fx#load ("res://scenes/items/Bullet.tscn") #null resource


var linear_vel = Vector2.ZERO
export(String, "up", "down", "left", "right") var facing = "down"

var anim = ""
var new_anim = ""

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, STATE_MOB, STATE_PROJECTILE} # state machine needs expansion


var state = STATE_MOB #mob state is broken, needs to cast to raycast 2d
var center

"Enemy FX"
var despawn_particles
var blood

func _ready():
	#player =get_tree().get_nodes_in_group('player').pop_front()
	
	raycast.set_enabled(false) 
	
	state = Behaviour.randomize_state(state)
	facing = Behaviour.randomize_facing(facing,["left", "right", "up", "down"])
	
	
	enemy_type = Behaviour.randomize_enemy_type(['Easy', "Intermediate", "Hard"]) #Calls A Global Function
	#print(enemy_type) #disabling to debug
	
	#if player != null:
	#var enemy_direction = Vector2(0,0)
	
	Behaviour.update_facing(self.position, Vector2(0,0), Vector2(0,0), pointer, facing, Vector2(0,0))#for debug purposes only
	
	state = STATE_WALKING#for debug purposes only
	



func _process(delta : float):
	#debug() #turn off when not debugging
	
	# Raises up a Frame Counter
	frame_counter += 1
	
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
	

	
	# Checks the Conditional Every 30th Frame
	# Called every selected framerate. 30th Frame for slower processing
	# LOGIC: frame counter is a modulous of the selected frame rate
	if frame_counter % selected_frame_rate == 0:
		
		"FACE THE PLAYER, IF HE'S VISIBLE"
		if player != null: 
			facing = Behaviour.update_facing(self.position, player.position, player, pointer, facing, Vector2(0,0))


			"Enemy Behaviour Logic"

			state = Behaviour.behaviour_logic(hitpoints, raycast, player, player.position, self.position , self, enemy_type, state, enemy_distance_to_player)


	if hitpoints <= 0: # Dies if hitpoint is zero
		state = STATE_DIE
		#despawn()


	# Reset Frame Counter TO Conserver Memory
	if frame_counter >= 1000:
		frame_counter = 0

func _physics_process(delta):
	
	# Consider Moving All Physics calculation to the Globals Script
	
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
		
		STATE_PROJECTILE:
			shoot()

	if new_anim != anim:
		anim = new_anim
		$anims.play(anim)
	pass

# Reset to Idle State
func goto_idle():
	state = STATE_IDLE



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
# despawn logic is buggy
func despawn()->  void:
	Globals.kill_count +=1
	despawn_particles = Globals.despawn_fx.instance()
	blood = Globals.blood_fx.instance()
	get_parent().add_child(despawn_particles)
	get_parent().add_child(blood)
	despawn_particles.global_position = global_position
	blood.global_position = global_position
	if has_node("item_spawner"):
		get_node("item_spawner").spawn()
	
	#Prevents memory leaks
	self.queue_free()
	#Globals.queue_free_children(self)
	#get_parent().remove_child(self) #buggy



#NEW_CODES
# warning-ignore:unused_argument
"Detects Player's entry and exit with an area 2d"

func _on_enemy_eyesight_body_entered(body)-> void:
	if body is Player :
		player = body
		raycast.set_enabled(true)
		run_speed = 150 #increase run speed if player is seen
		state = STATE_MOB
		print('player seen', 'State: ', state)
		print ("Enemy Type:", enemy_type) # for debug purposes
		#update_facing()

func _on_enemy_eyesight_body_exited(body)-> void:
	#help detect the player when he leaves
	if body is Player:
		
		run_speed = 300
		raycast.set_enabled(false) 
		player = null
		print ('player hidden, Turning of Raycast Detection')
		state = Behaviour.randomize_state(state)
		


# Moved to Global Singleton
#func restaVectores(v1, v2): #vector substraction
#		return Vector2(v1.x - v2.x, v1.y - v2.y)

#func sumaVectores(v1, v2): #vector sum
#		return Vector2(v1.x + v2.x, v1.y + v2.y)



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
func turn_processing(toggle): 
	if toggle is String:
		if toggle == "on":
			set_process(true)
			set_physics_process(true)
		elif toggle == "off":
			set_process(false)
			set_physics_process(false)
		else:
			push_warning ("This function only uses on/off strings to control the globals processing functon")
	else: return

# Debugs AI variables to the Console log
func debug()-> void:
	print ("State: ",state,"/ Distance to player " ,enemy_distance_to_player, "/ Enemy Type",enemy_type)

#func _exit_tree():
#	#Globals.queue_free_children(self)
#	#Globals.free_children(self)

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
	
	func _ready():
		randomize()
	
	# body is self
	static func update_facing(body_position : Vector2, player_position : Vector2, player , pointer, _facing : String, enemy_direction: Vector2)-> String: # Updates the Enemy to face the Player

		if player != null: #handles enemy facing player
			
			enemy_direction= (body_position.direction_to(player_position))
			
			Globals.rotate_pointer(Vector2((enemy_direction.x), (enemy_direction.y)), pointer) # Rotates a Racast 2d to face the Enemy
			
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
		
		if player == null:
			pass


	static func enemy_navigation(navigation_agent : NavigationAgent2D, position : Vector2): 
		var move_direction = position.direction_to(navigation_agent.get_next_location())
		var linear_vel
		navigation_agent.set_velocity(linear_vel)
	
	static func behaviour_logic(hitpoints: int, raycast : RayCast2D, player : Player, player_pos , _position,_enemy, enemy_type : String, state, enemy_distance_to_player):
		
		"Enemy Behaviour Logic"
		# Provides Randomized enemy behaviour
		if not hitpoints == 0:
			if raycast.is_enabled() == true:
				"Enemy Envcounters Player Node"
				
				if raycast.is_colliding() && player != null:
					var center = Functions.calculate_center(player, _position) #calculates distance to plaer
					_enemy.move_and_slide(center) # moves to player
					state = STATE_WALKING
					#var enemy_distance_to_player = abs(position.distance_to(player.position )) # Calculates the enemy distance to playrer
					enemy_distance_to_player = abs(_position.distance_to(player_pos )) # Calculates the enemy distance to playrer
					
					#print (enemy_distance_to_player) # For debug purposes only
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
							state = STATE_WALKING
							return state
						if enemy_type == "Intermediate":
							#state = STATE_PROJECTILE
							state = STATE_WALKING
							return state
						else: return
		if raycast.is_enabled() == false && player != null:
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
		#randomize()
		#enemy_type = ['Easy', "Intermediate", "Hard"][randi()%3]
		#enemy_type = 
		#return options [randi()% int(options.size() - 1)] # Returns Easy
		#return ['Easy', "Intermediate", "Hard"][randi()%3] # Returns Hard
		return Globals.randomize_enemy_type() # Returns Hard

	# Updates the raycast to the Enemy"s Direction
	static func rotate_pointer(point_direction: Vector2, pointer) -> void:
		var temp =rad2deg(atan2(point_direction.x, point_direction.y))
		pointer.rotation_degrees = temp


class Functions extends Reference:
	
	# calculates the center btw two vectors (player and target)
	static func calculate_center(player, initial_position)-> Vector2:
		
		var center = Globals.restaVectores(player.position, initial_position) 
		return center

