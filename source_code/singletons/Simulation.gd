# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Simulation Version 1
# Handles all Non Player Simulations within the game core loop
# A Good Simulator Predicts Everythin
# *************************************************
# Features:
# (1) Shares Game Code With the Networking, Player& Enemy scripts
# (2) Optimizes Enemy Mob Physics and Processess into a single Script with threads
# (3) Global Frame counter
# (4) Triggers rain / snow particle fx
# *************************************************
# Bugs:
# (1) Client is authoritative Bug
# (2) State Buffer is the same bug
# *************************************************
# To-Do:
# (1) Implement Timeline
# (2) Client SIde Predition using Input Buffer & State Buffer for Simulation 
# (3) Implement an optimized player info only containing player data
#  - Using a palyer updtimized player info containing only updated ifo for both server and player class
# (4) Implement Dedicated Server and Peer 2 Peer player networking architechture separatyely
# (5) Implement method to decrypt state buffer back to separate individual state items for simulation
# (6) Implement animation tweening logic using state and input buffer
# (7) Test Multiplayer with max 4 players
# (8) Host Hathora & Godot Server for open playtesting
# (9) Implement Simulating 1 and Simulating 2
# (10) Implement Networking Hit Collision detection
# (11) Implement Enemy Networking using Utils.Enemy Object Pool
# (12) Implement Dedicated Server
# (13) Implement TImestamp from line 222
# *************************************************

extends Node

class_name Simulationv1


enum {SIMULATING, NON_SIMULATING}

# world gravity
export (int) var gravity = 3500 # default gravity

# Frame ID
onready var frame_id : int 

# Frame Counter
export (int) var frame_counter = 0

var last_update = -1

# Placeholder variables ported from another multiplayer template
var SIMULATING_1: bool = false
var v : Vector2
var world_radius : int
var player_data : PoolByteArray
export (PoolByteArray) var RawData : PoolByteArray # Raw Data Sent Every Player Input
export (PoolByteArray) var RawDataArray : Array # Raw Data Sent Every Player Input
var id_as_string : String #= Networking.id_as_string


# My Player Networking object
# for simulation calculations
# 
var player : Player_v2_networking

export (Array) var all_player_objects = [] # kinematic2d and integers
export (Array) var player_IDs = [] # IDs


"""
Player Data + Game State

0 is the Server's Data 
"""
# (1) Depreciating Inventory data until it is optimized

export (Dictionary) var player_info : Dictionary = { 0 : { # server peer id
		"pos": {"x": 0, "y":0}, # updated positional data, 
		"vel":{"x": 0, "y": 0},
		"fr": 0, #frame data
		"in": 0, #input buffer
		"hp" : 3,
		"st" : 0, # AN array of state s for Roll Back Networking Prediction would be ideal
		"rd": {"x": 0, "y": 0},
		"dx": 0, # boolean converted to integer for smaller packet size
		"up": 0,  # Stores Present Update ID Across All Clients #
		"wa": "",#[Wallet.address], # wallet Address and ID
		"ai": 0, # Asset ID
		"sc": 0,#[Wallet.smart_contract_addr, Wallet._app_id, Wallet._app_args], # Arrays As it will only be one Smart COntract
		"kc": 0,
		"inv": "", #Inventory.jsonify(), # symchronizes Inventory Item,
		"rt":60,
		"hash" : "" # Arrays because hash data is discarded eventually
	}}
	

# Fpr Uptimizzing Player Info 
# Currently unimplemented
# Would only Send Players Updated Data rather than the whole information
var data_packet : Dictionary = {}

# Input & State Buffer
# Used for simulation logic
# decoded from player info updates
var _input_buffer_decoded : Array
var _state_buffer_decoded : Array


"""
CPU FX
"""
# Uses setters and getters for proper setup
var rainFX : RainFX setget set_rainFx, get_rainFx
var smokeFX : smoke_fx setget set_smokeFx, get_smokeFx



"""
SIMULATION LOGIC
"""
# Simulates player position on Kinematic body 2d using player id and player info

# Was Refactored to A Simulation Singleton on Nov 20, 23
# 
# TO DO: 
# (1) SHould Implement Input Buffer into simulation Logic
# (2) Should implement Server Side Prediction
# (3) Should implement Sttae Buffer Into simulation logic
# (4) Current Implementation only works on 2 players, should be expanded to include 4 Players
# (5) Should Implement Animation Player Into Logic 
# (6) Implement Enemy Simulation into Data Packet
#(7) SHould Ideally be run as a physics process
func simulate(id : int): # playerclass controls all player networkinf objects
	
	"Server & Client Simulation Logic"
	# Bugs : Data is corrupted with Integer additions
	
	#print_debug("Simulation Debug 1: ", all_player_objects) # For Debug Purposes Only
	#print_debug("Simulation Debug 2:", id) # For Debug Purposes Only`
	#print_debug("Simulation Debug 3:", player) # PLAYER CANNOT BE NULL
	
	
	""" 
	NETWORKED PLAYER OBJECT SELECTION 
	"""
	#Select Player Object in 2 Player Games
	#
	# To DO: 
	# (1) Refactor Logic to account for up to 4 players
	# (2) Refactor Logic to be less hardcoded an account for multiple player count, duplicate of # 1
	if Networking.GamePlay == Networking.LOCAL_COOP:
		#print_debug("Simulation Debug 4: ", all_player_objects) # For Debug Purposes Only
		# Where id 1 and above is for client devices while id 0 is for server devices
		if id == 1: #CLient
			player = all_player_objects[2]
		if id == 0: # Server
			player = all_player_objects[3]
	if Networking.GamePlay == Networking.MMO_SERVER:
		# Bugs : 
		# (1) Server is Authoritative, client should be more authoritative in MMO Client Server
		# (2) Breaks in dedicate server if player-connected signals are broken
		print_debug("Simulation Debug 5: ", all_player_objects, "/", id) # For Debug Purposes Only
		player = all_player_objects[2] # Breaks Here in Server Builds
	
	if player_info.has(id):
		
		
		
		
		# State & input buffer decoded to animation
		# Bugs
		# (1) Animation Logic Affects Both Players
		# (2) Player Animation Script Needs refactoring to Play animation as an extended method 
		# (3) Doesn't Work
		if _input_buffer_decoded.pop_back() == 3 : # Input Down
			#player.animation.play("walk_down")
			player.new_anim ="walk_down"
		#
		if _input_buffer_decoded.pop_back() == 2 : # Input Up
		#	player.animation.play("walk_up")
			player.new_anim ="walk_up"
		#
		if _input_buffer_decoded.pop_back() == 1 : # Input Right
		#	player.animation.play("walk_right")
			player.new_anim = "walk_right"
			
		if _input_buffer_decoded.pop_back() == 0 : # Input Left
			#player.animation.play("walk_left")
			player.new_anim = "walk_left"
		
		# Data packet Lost
		player.move_and_slide(Vector2(float(player_info[id]["vel"]["x"]), float(player_info[id]["vel"]["y"])))
		
		"TWEEN ANIMATION"
		# Position
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(player, "global_position", Vector2(float(player_info[id]["pos"]["x"]), float(player_info[id]["pos"]["y"])), 0.5)
		
		
		# PARALLEL ANIMATION
		#tween.parallel().tween_property()
		
		#player.set_position(Vector2(float(Simulation.player_info[id]["pos"]["x"]), float(Simulation.player_info[id]["pos"]["y"])))
		
		# facing
		# should use input buffer instead
		#player.facing = Simulation.player_info["peer id"][id]["facing"]
		
		# State
		
		# roll directin
		
		#linear velocity
		
		# BroadCast Update to all Network Peers
		# Only if player count greater than 2 
		# else it's just wasted packets
		
		#if get_all_player_ids().size() > 2: # use a static variable instead because this method would be called frequently
		Networking.broadcast_world_positions()


func _process(_delta):
	
	frame_counter += 1
	
	
		# Reset Frame Counter TO Conserver Memory
	if frame_counter >= 1000:
			frame_counter = 0

	"""
	FRAME ID CAPTURE
	"""
	# Physics Simulation Only happens when Player is Online
	#
	# 
	if Networking.GamePlay > 0: # If Multiplayer Network is up & running
		

		
		# Gets the Frame ID of this client on every 12th frame
		if (frame_counter) % 12 == 0: # every 12th frame
			frame_id = get_tree().get_frame() # Get the current frame id
			#print_debug(frame_id)
		
		"Auto Broadcast Server Database"
		# (1) Broadcasts Server Database to All Connected Players after every 60th frame
		# (2) Requires finetuning on the greter global internet for optimal frame times
		# Enabled For MMO Gameplay with Dedicated Server
		if Networking.GamePlay == Networking.MMO_SERVER:
			if (frame_counter) % 60 == 0: # every 60th frame
			#	
			#	# Auto Broadcasts Server's Database every 60th frame to all 
				Networking.broadcast_world_positions()
			#pass


func _physics_process(_delta):

	
	"SIMULATION LOGIC 2"
	# Simulates Peer Logic On All Client Peers
	# By Interpolating Between the Last Update And Recent Updates
	
	
	if SIMULATING:

		# To mitigate latency issues we use interpolation. The idea is simple, we receive
		# position updates every TICK_DURATION (50 ms, 20 per seconds). We interpolate between
		# the last two previous updates, this way we always have smooth movements. The
		# main drawback is added latency (100 ms).
		var pos = Vector2(0,0)
		var target_timestamp = OS.get_ticks_msec() - (Networking.TICK_DURATION*2)
		
		for peer_id in Networking.player_info:
			# Update position using lerp with 2 prior states
			var keys = Networking.player_info[peer_id].updates.keys()
			for i in range(0, keys.size()):
				if keys[i] > target_timestamp:
					if not Networking.player_info[peer_id].destroyed:
						var percent = float(target_timestamp - keys[i-1]) / Networking.TICK_DURATION
						Networking.player_info[peer_id].position.x = lerp(Networking.player_info[peer_id].updates[keys[i-1]].position.x, Networking.player_info[peer_id].updates[keys[i]].position.x, percent)
						Networking.player_info[peer_id].position.y = lerp(Networking.player_info[peer_id].updates[keys[i-1]].position.y, Networking.player_info[peer_id].updates[keys[i]].position.y, percent)
						Networking.player_info[peer_id].node.set_position(Networking.player_info[peer_id].position)
						Networking.player_info[peer_id].velocity = lerp(Networking.player_info[peer_id].updates[keys[i-1]].velocity, Networking.player_info[peer_id].updates[keys[i]].velocity, percent)
						#Networking.player_info[peer_id].rotation = Networking.lerp_angle(Networking.player_info[peer_id].updates[keys[i-1]].rotation, Networking.player_info[peer_id].updates[keys[i]].rotation, percent)
						Networking.player_info[peer_id].node.set_rotation(Networking.player_info[peer_id].rotation)
					break
		
		




class projectiles:
	# THe Projectile Class's TimeStamp
	var timestamp : float = 0
	# SHould Implement Some Form of Projectiles that update with the server
	
	# Simulates Projectile Calculations
	# Uses Target Stamp Variable to Ensure Projectile Integrity Across ALl Peers
	func SimulateProjectile():
		# We spawn projectiles based on required timestamp (received from server)
		var target_timestamp = OS.get_ticks_msec() 
		for projectile in projectiles:
			if projectile.timestamp <= target_timestamp:
				var preload_projectile : String = ""
				var node_projectile = load(preload_projectile).instance()
				var info = Networking.player_info[projectile.id]
				var projectile_os = Vector2(projectile.position.x,projectile.position.y)
				node_projectile.name = "projectile_" + info.name
				
				# Add Projectile to the Scene Tree
				#node_projectiles.add_child(node_projectile)
				
				var trustp = Vector2(0,Networking.PROJECTILE_OFFSET).rotated(projectile.current_angle)
				node_projectile.contacts_reported = 1
				node_projectile.set_position(projectile_os - trustp)
				node_projectile.set_linear_velocity(-trustp * Networking.PROJECTILE_SPEED)
				projectiles.erase(projectile)



"Player Info"
# Features: 
# (1) should store Non-threathening Crypto and Multiplayerinfo too
# (2) Data Integrity can be checked using hash
# (3) Stores Data FOr Synchronizing Player Data Among Multiple Peers
# (4) converted to poolbyte array before sent over Network
# (5) synchronizes game states across player network mesh
"""
REGISTERS PLAYERS INITIALLY
"""
func register_player(id : int)-> Dictionary:
	# To Do:
	# (1) Optimize Dictionary size to Max 1000 bytes
	# (2) Implewment Data Optimization for  Data packet (gdunzip/zip)
	# (3) Depreciating Inventory Item for data optimization
	
	player_info[id] = {
		 #id : { # server peer id
		"pos": {"x": 0, "y":0}, # updated positional data, 
		"vel":{"x": 0, "y": 0},
		"fr": 0, #frame data
		"in": 0, #input buffer
		"hp" : 3,
		"st" : 0, # AN array of state s for Roll Back Networking Prediction would be ideal
		"rd": {"x": 0, "y": 0},
		"dx": 0, # boolean converted to integer for smaller packet size
		"up": 0,  # Stores Present Update ID Across All Clients #
		"wa": 0,#[Wallet.address], # wallet Address and ID
		"ai": 0,
		"sc": 0,#[Wallet.smart_contract_addr, Wallet._app_id, Wallet._app_args], # Arrays As it will only be one Smart COntract
		"kc": 0,
		"inv": "", #Inventory.jsonify(), # symchronizes Inventory Item
		"rt":60,
		"hash" : player_info.hash() # player data hash
	}
	
	
	 
	return player_info

func get_all_player_ids()-> Array:
	return player_info.keys()

static func set_position(x : Vector2):
	pass


func get_frame_counter()-> int:
	return frame_counter 


"""
REGISTERS PLAYER INPUT AND RELEASES
"""
# Debugs Player Data
# Also updates the server object with player data from respective peers
remote func pi(id : int,player_data : PoolByteArray):
	# Remote Calls Player Input From Client Peer for each client peer
	# Should Connect to Physics Process Simulation Logic
	# Bug: Player positional data is not sent properly (Fixed)


	"""
	SERVER LOGIC
	"""
	# (1) Server receives player input from CLinet Peers
	# (2) Server authenticates data packet
	# (3) Server updates its records
	# (4) Server Performs simulation on server
	# (5) Server Broadcasts data to all client peers to replicate SImulation
	# (6) Server Maintains states Synchronizations across all CLient Peers
	if is_network_master():
		#print("Player Input Registered ",str (poolByte2Array(player_data)), "from ", id ) # player data returns array
		
		
		
		# update Update ID
		#last_update = update_id
		
		
		print_debug("Packet Size (Bytes): ", player_data.size())
		
		#print(player_info) # for debug purposes only
		
		"Registers the Player Connected Peer ID Locally if not registered"
		if not player_info.has(id):
			
			# Register New Player Info
			
			register_player(id) 
			
		
		
		
		
		id_as_string = var2str(id) 
		for i in Networking.poolByte2Array(player_data):
			
			if i != null:
				
				"Data to debug"
				# Debugs the sent Data
				# works
				#Position
				#print_debug("Positional Data: ",i[id_as_string]["pos"])
				
				# Velocity
				#print_debug("Positional Data: ",i[id_as_string]["vel"])
				
				
				# Input Buffer
				# decoded
				_input_buffer_decoded = Utils.int_to_array(i[id_as_string]["in"])
				#print_debug("Input Buffer: ", _input_buffer_decoded)
				
				# Inventory Buffer
				# Inventory items need custom decoding
				#print_debug("Inventory Buffer: ",i[id_as_string]["inv"])
				
				# State Buffer
				# decoded
				_state_buffer_decoded = Utils.int_to_array(i[id_as_string]["st"])
				#print_debug("State Buffer: ", _state_buffer_decoded)
				
				# Facing
				# use input buffer instead 
				
				# Update ID
				#print_debug("Update ID: ",i[id_as_string]["up"])
				
				# Frame Data
				# COmpare Server Frame to Client Frame
				#print_debug("Frame: ",i[id_as_string]["fr"], "/", "Server Frame :", get_frame_counter())
				
					
				
				
			"""
			Update Player Database ON Server From CLient Packets
			"""
			
			
			#print_debug (player_info[id])
			
			"Positional Data"
			#print_debug("Updating Player Information for peer ",id, " from " ,player_info[id]["pos"], " to " , i[id_as_string]["pos"])
			player_info[id]["pos"] = i[id_as_string]["pos"] #WORKS
			
			
			"Input Buffer"
			player_info[id]["in"] = i[id_as_string]["in"]
			
			"State Buffer"
			
			
			"""
			
			RUNS MULTIPLAYER SIMULATION 
			
			"""
			# (1) Runs Client & Server side simulations using position tweens and animation tweens
			# (2) Implements Simple CLient & Server Side Prediction using both states and input buffers where the last state is the next state
			simulate(id)
			



remote func pu(id : int, update_id : int, updates: PoolByteArray):
	
	"Client Logic"
	#Client Side Database Update & Simulation
	# Handles Client side simulation Logic for other Players
	# Bugs: Player Update Packet is unoptimized
	print_debug (" Packet Size (Bytes): ", updates.size()) # for debug purposes only
	
	#Error Catcher 1
	# Unreliable packets can be sent in wrong order, we only work with the latest
	# data available.
	if update_id < last_update:
		print("Received update in wrong order. Discarding!")
		return
	
	# parse data as array
	#RawData = bytes2var(updates) #Warning: Can also contain code for remote execution; potential security flaw
	

	
	var id_as_string : String = var2str(Networking.peer_id) 
	
	# Maintain an Updated Timeline so older packets are discarded
#	last_update = update_id
	
	#print("Data Packets:", str(RawData)) # Works
	
	
	
	for i in Networking.poolByte2Array(updates):
		#Returns a String. Converting to Dictionary
		
		#RawJson = JSON.parse(i) # Returns either a String or a Dictionary? Type 18 for dictionary 
		#print(i)
		
		# Returns a Dictionary
		#print(RawJson.get_result()) # Works
		
		# Merges Server Player Info to Local Player Info with Peer ID's
		#player_info["peer id"].merge(RawJson.get_result()["peer id"])
		
		print("I: ",i) # for debug purposes only
		
		#print ("Client Database debug: ",Simulation.player_info.keys()) #for debug purposes only
		# id is fpr local client, id as string is for server's client # for debug purposes only
		#print(id, "/", id_as_string) # id is client id  # for debug purposes only
		
		if not player_info.has(get_all_player_ids().pop_back()):
			return
		
		if Networking.GamePlay == Networking.LOCAL_COOP:
			# Bug: If Player Scene for Client devices takes too long to instance, this code line breaks
			# Fix : Below
			# 1 for single player
			# Expand Code to Account 
			"Update the Clients Player Info"
			# Where Server is ID 0 and Client is Id 1
			# Update the Server Player' Positional data On the Client
			player_info[0]["pos"] = i["0"]["pos"]
			
			
			# Server Player Simulation
			# I avoid updating the client positional data but for 3-4 players, this code need to be impemented
			# Run SImulation for Server peer on client
			# Bug: Causes a stuck player bug in Online MMO where 0 is the Client Player's Object
			simulate(0)
		
		# MMO SImulation requires other player Targets

"Enemy Collision Hit Detection & STATE "

class Enemy_ extends Reference:
	
	# Enemy States Ruplicated
	enum {
	STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, # implemented 
	STATE_DIE, STATE_HURT, STATE_MOB, # implemented
	STATE_PROJECTILE, STATE_PLAYER_SIGHTED, # unimplemented
	STATE_PLAYER_HIDDEN , STATE_NAVIGATION_AI, #unimplemented
	STATE_ERROR
	}
	
	static func proximity_attack_simulation(
		hitpoints: int, 
		raycast : RayCast2D, 
		player : Player, 
		player_pos : Vector2, 
		_position : Vector2,
		_enemy: Enemy, 
		enemy_type : String, 
		state : int, 
		enemy_distance_to_player : float,
		center : Vector2
		) -> int: # Returms the enemy state
		
		"Enemy Behaviour Logic"
		# Provides Predetermined enemy behaviour
		# Runs as a Process
		# Uses State Machine in Physics Process 
		# Expand to Add More Functionalities
		# Bugs fix:
		# (1) Nested If's bloc
		# (2) Export center variable
		# (3) Clone function to Dynamic singleton function
		# (4) Organize Error Catchers
		# (5) Return An Integers from all nexted if's  
		
		# TO DO:
		# (1) Export All Logic parameters for simulation logic e.g enemy_distance to player
		"Error Catchers"
		
		if hitpoints <= 0:
			return STATE_DIE
		
		if raycast.is_enabled() == false:
			return STATE_IDLE
			
		"Enemy Envcounters Player Node"
		
		"Calculates Distance to Player"
		# To Do :
		# (1) Calculation should be callable from external script (done)
		if player == null:
			return STATE_WALKING
		
		if raycast.is_colliding():
			
			
			" Calculate distance to Player"
			# using a co routine
			#
			# Features:
			# (1) Calculates the center to the player using a coroutine
			# (2) Calculates the approximate distance to the player using enemy position and player position vector calculations
			# (3)
			
			center = Utils.restaVectores(player.position, _position) #Functions.calculate_center(player.position, _position) #calculates distance to plaer
			
			
			_enemy.move_and_slide(center) # moves to player center
			state = STATE_MOB
			# # Calculates the approximate enemy distance to playrer
			#enemy_distance_to_player = abs(_position.distance_to(player_pos )) # Calculates the enemy distance to playrer
			enemy_distance_to_player = Utils.calc_2d_distance_approx(_position, player_pos)
					
			"Proximity Attacks"
			# Features
			# 
			# Attack Player when in range
			# 
			# Bugs
			# (1) Bugs out at nu,bers at 200 - 300 on Hard Modes
			#
			# To DO:
			# (1) Expand functionality
			
			#print_debug("Enemy Distance To Player: ",enemy_distance_to_player) # uses sprite size directly in calculations
			
			# If clase, attack
			if enemy_distance_to_player < 81: #uses enemy distance to auto attack
				state = STATE_ATTACK
				return state 
				
				# if far :
				# Bugs 
				# (1) Bugs Out On Hard Enemies
				# (2) Roll State is Buggy
				# Fix :
				# (1) SHould recalculate center and roll to pcenter
			if enemy_distance_to_player > 81:
				if enemy_type == "Hard":
					#print_debug("Enemy Distance To Player debug 1: ",enemy_distance_to_player, "/",center, "/ ", state)
					state = STATE_ROLL
					return state
					
						# TO DO: Implement Shoot State FOr ENemy AI
				if enemy_type == "Easy":
					state = STATE_MOB
					
					#print_debug("Enemy Distance To Player debug 2: ",enemy_distance_to_player, "/",center)
					
					return state
				if enemy_type == "Intermediate":
					#state = STATE_PROJECTILE
					state = STATE_MOB
					return state
		return state
		# If Raycast Detecting and Player is Available
		# The chances of this is very low except in Multiplayer Gameply
		#if raycast.is_enabled() == false && player != null:
			#use state changer timer to turn off processing
		#	push_error ('Debug Enenmy Behaviour Check')
		
		# If Raycast Detecting and Player is not Available
		# The chances of this is very low except in Multiplayer Gameply
		#if raycast.is_enabled() == false && player == null:
		#	#use state changer timer to turn off processing
		#	push_error ('Debug Enenmy Behaviour Check')

	static func hit_collision_detected(
		area : Area2D, 
		state : int, 
		hitpoints : int, 
		pushback_direction : Vector2, 
		_body : Enemy,
		_global_position : Vector2,
		kick_back_distance : int
		):
		# Features
		# (1) Hit Detection
		# (2) Hit Registration
		# (3) RPC Call for multiplayer mesh
		#print_stack()
		print_debug("Fix ENemy Player Collision Spammer")
		if not state == STATE_DIE && area.name == "player_sword": #if it's not dead and it's hit by the player"s sword collisssion
			
			print_debug("Enemy Struck, Implement Make RPC CAll if error > 0")
			_body.hitpoints -= 1
			
			Music.play_sfx(Music.hit_sfx) # Plays sfx from the Music singleton
			#print_debug ("enemy hitpoint: "+ str(hitpoints))# for debug purposes only
			pushback_direction = (_global_position - area.global_position).normalized()
			_body.move_and_slide( pushback_direction *   kick_back_distance) # Flies back at a random distance
			state = STATE_HURT
			var blood = Globals.blood_fx.instance()
			#get_parent().add_child(blood) # Instances Blood FX
			
			_body.get_parent().call_deferred("add_child", blood)
			blood.global_position = _global_position # Makes the fx position to the Kinematic object position
			
		

class Player_:
	
	# DUplicate of Player States
	enum { 
	STATE_BLOCKED, STATE_IDLE, STATE_WALKING, 
	STATE_ATTACK, STATE_ROLL, STATE_DIE, 
	STATE_HURT, STATE_DANCE 
	}
		
	static func hit_collision_detected(
		area : Area2D, 
		state : int, 
		hitpoints : int, 
		_body : Player,
		_global_position : Vector2
		):
		
		if state != STATE_DIE and area.is_in_group("enemy_weapons"):
			_body.hitpoints -= 1
			_body.emit_signal("health_changed", _body.hitpoints)
			#
			# Kick back code for Top DOwn Player script
			# Temporarily disabling for debugging
			#
			#var pushback_direction = (global_position - area.global_position).normalized()
			#move_and_slide( pushback_direction * pushback)
			
			_body.state = _body.TOP_DOWN.STATE_HURT
			var blood = Globals.blood_fx.instance()
			blood.global_position = _global_position
			_body.get_parent().add_child(blood)
			Globals.player_cam.shake()
			Music.play_sfx(Music.sword_sfx)
			Music.play_track(Music.nokia_soundpack[20]) # Hurt Sound Track
			
			if _body.hitpoints <= 0:
				_body.state = _body.TOP_DOWN.STATE_DIE
				Music.play_track(Music.nokia_soundpack[27]) # Death Sound Track


# Setter and Getter functions for Singleton objects handling

func set_rainFx(vfx : RainFX):
	rainFX = vfx

func get_rainFx() -> RainFX:
	return rainFX

func set_smokeFx(vfx : smoke_fx):
	smokeFX = vfx

func get_smokeFx() -> smoke_fx:
	return smokeFX



func _exit_tree():
	# Delete all simulated objects
	
	Utils.MemoryManagement.queue_free_array([rainFX])

