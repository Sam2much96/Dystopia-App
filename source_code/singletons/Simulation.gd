# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Simulation Version 1
# Handles all Non Player Simulations within the game core loop
#
# *************************************************
# Features:
# (1) Shares Game Code With the Networking, Player& Enemy scripts
# (2) Optimizes Enemy Mob Physics and Processess into a single Script with threads
# (3) Global Frame counter
# *************************************************
# Bugs:
#
# *************************************************
# To-Do:
# (1) Implement Timeline
# (2) Input Buffer Simulation
# *************************************************

extends Node

class_name Simulationv1


enum {SIMULATING, NON_SIMULATING}

# Frame ID
onready var frame_id : int 

# Frame Counter
export (int) var frame_counter = 0


# Placeholder variables ported from another multiplayer template
var SIMULATING_1: bool = false
var v : Vector2
var world_radius : int
var player_data : PoolByteArray
export (PoolByteArray) var RawData : PoolByteArray # Raw Data Sent Every Player Input
export (PoolByteArray) var RawDataArray : Array # Raw Data Sent Every Player Input
var id_as_string : String #= Networking.id_as_string


# My Player Networking object
var player : Player_v2_networking

export (Array) var all_players = [] 


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
		"ai": 0,
		"sc": 0,#[Wallet.smart_contract_addr, Wallet._app_id, Wallet._app_args], # Arrays As it will only be one Smart COntract
		"kc": 0,
		"inv": Inventory.jsonify(), # symchronizes Inventory Item,
		"rt":60,
		"hash" : "" # Arrays because hash data is discarded eventually
	}}
	
	
	



# Refactored to A Simulation Singleton on Nov 20, 23
# COnnetcs to a Player Input Signal from the Networking Singleton
# Simulates player position on Kinematic body 2d
#
# SHould Implement Input Buffer into simulation Logic
func simulate(id : int, player : Player_v2_networking ):

	"Server Simulation Logic"
	# Refactored to A Simulation Singleton on Nov 20, 23
	# Merges Server Player Info to Server Player Info with Peer ID's
	# Trying to get updated positinal data from data packed
	# SHould Ideally be called i the Player Networking script
	# SHould connect to a Networking Signal to optimize performance

	# SHould instead be a physics process method
	
	if Simulation.player_info.has(id):
			
			

			# position simulation
			#print(Vector2(float(i["peer id"][id_as_string]["position"]["x"]), float(i["peer id"][id_as_string]["position"]["y"]))) # For Debug Purposes only
			
		# should ideally be called in a process method
		# SHould implement position translations using the Networking frame buffer
		#player.move_and_slide(Vector2(float(Networking.player_info["peer id"][id]["velocity"]["x"]),float(Networking.player_info["peer id"][id]["velocity"]["y"]))
		# Data packet Lost
		player.move_and_slide(Vector2(float(Simulation.player_info[id]["vel"]["x"]), float(Simulation.player_info[id]["vel"]["y"])))
		
		"TWEEN ANIMATION"
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(player, "global_position", Vector2(float(Simulation.player_info[id]["pos"]["x"]), float(Simulation.player_info[id]["pos"]["y"])), 0.5)
		
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
		# 
		Networking.broadcast_world_positions()

#func _ready():
	#print_debug("Frame ID debug: ",frame_id)
#	pass

func _process(_delta):
	
	frame_counter += 1
	
	
		# Reset Frame Counter TO Conserver Memory
	if frame_counter >= 1000:
			frame_counter = 0

	
	# Physics Simulation Only happens when Player is Online
	if Networking.GamePlay == Networking.ONLINE:
		

		
		# Gets the Frame ID of this client on every 12th frame
		if (frame_counter) % 12 == 0: # every 12th frame
			frame_id = get_tree().get_frame() # Get the current frame id
			#print_debug(frame_id)
		


func _physics_process(_delta):

	"""
	UNIMPLEMENTED SIMULATION LOGIC
	"""
	if SIMULATING_1: # Placeholder conditional boolean
		"Multiplayer Enet"
		
		# Handles Calculations for all Peer ID
		# Adds COnsiderable performance hog
		# Requires Optimization
		
		
		for i in Networking.peer_ids:
			#print_debug(str(player_info[peer_id].node.rotation) + " / " + str(player_info[peer_id].node.position) + " / " + str(player_info[peer_id].velocity))
			#print_debug("Player:" + str(peer_id) + " = " + str(player_info[peer_id].position) + " = " + str(player_info[peer_id].velocity))
			
			# Only Runs simulation calculations on client peers not server peer
			#for _peer_id in i.keys():
			if int(i) > Networking.MAX_PLAYERS:
				print ("Using Peer ID Data for  ",i, " simulation calculation")
			
			
			#print(Networking.peer_ids)
				#print(Networking.player_info["peer id"][i]["destroyed"]) # for debug purposes only
				if Networking.player_info[i]["dx"] == 0:
					continue
				
				
				#synchronize positions for my peer
				#Networking.player_info["peer id"][1]["node"].pop_front().set_position(Networking.player_info["peer id"][i]["position"])
				
				
				#var velocity_speed = 2
				#if int(Networking.player_info["peer id"][i]["velocity"]) != 0:
				#	continue
				
				# Apply Impulse Simulation To Peer UD

			#	pass
				#if Networking.player_info["peer id"][i]["rotation"] != 0:
				#		if Networking.player_info["peer id"][i]["rotation"] < 0:
				#			# More Impulse Calculation
				#			pass

				"""
				KEEP PLAYER WITHIN BOUNDARIES
				"""
				# refactor to use simulation function instead
				# player Networking Node direct placement is depreciated
				# Debugging
		
				v = Vector2(Networking.player_info[i]["pos"])
				
				if v.x > world_radius:
					v.x = world_radius
					Networking.player_info[i]["node"].pop_front().set_position(v)
				if v.x < -world_radius:
					v.x = -world_radius
					Networking.player_info[i]["node"].pop_front().set_position(v)
				if v.y > world_radius:
					v.y = world_radius
					Networking.player_info[i]["node"].pop_front().set_position(v)
				if v.y < -world_radius:
					v.y = -world_radius
					Networking.player_info[i]["node"].pop_front().set_position(v)
	#

	
	
	if SIMULATING_1:
		"SIMULATION LOGIC 1"
		# Updates All Player Peers with Most Recent Update
		
		for i in Networking.peer_ids:
			
			
			
			# Only Use client peer for Simulation logic
			# Bug fix until client peer data is properly synchronized
			#for _peer_id in i.keys(): 
			#print_debug("Type of: ",typeof(i))
			
			#if typeof(i) == TYPE_INT:
			#	continue
			
			
			
			if int(i) > Networking.MAX_PLAYERS: # Peer ID cannot be single digits
				continue
				
				#print_debug(i)
			print(Networking.player_info[i])
			
			# BUGGY:
			#if Networking.player_info["peer id"][i]["respawn_time"] != -999:
			#	Networking.player_info["peer id"][i]["respawn_time"] -= delta
				
			
			# only set updated positional data
			#if Networking.player_info["peer id"][i]["position"] > Vector2.ZERO:
			#	var pos : Vector2 = Vector2(Networking.player_info["peer id"][i]["position"])
				
			#	set_position(pos)

					
				# Handles Respawns
				# Broadcast the new player to everyone
				#for peer_id2 in Networking.player_info:
				#	rpc_id(peer_id2, "player_respawned", peer_id, Networking.player_info[peer_id])

		
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
		
		
		# Updates The Position of This Peer 
		#@ Not Sure What This COde Does
		#if Networking.player_info.has(peer_id):
		#	pos.x += Networking.player_info[peer_id].position.x
		#	pos.y += Networking.player_info[peer_id].position.y
		





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



class Behaviour extends Reference:

	"""
	Autospawn Code
	"""
	 # Buggy:
	 # Produces Stuck Collision on Player Bug 
	static func AutoSpawn(body):
			# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
		if Globals.spawnpoint is Vector2 and Globals.spawnpoint != null: #auto spawn code
			if Globals.curr_scene == 'Outside' :
				if Globals.current_level != null:
					body.position = Globals.spawnpoint
					print ('auto spawn')
			if Globals.curr_scene == 'HouseInside':
				pass






"Player Info"
# Features: 
# (1) should store Non-threathening Crypto and Multiplayerinfo too
# (2) Data Integrity can be checked using hash
# (3) Stores Data FOr Synchronizing Player Data Among Multiple Peers
# (4) converted to poolbyte array before sent over Network
# (5) synchronizes game states across player network mesh
func register_player(id : int)-> Dictionary:
	# To Do:
	# (1) Optimize Dictionary size to Max 1000 bytes
	# (2) Implewment Data Optimization for  Data packet (gdunzip/zip)
	
	
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
		"inv": Inventory.jsonify(), # symchronizes Inventory Item
		"rt":60,
		"hash" : "" # Arrays because hash data is discarded eventually
	}
	
	
	 
	return player_info

func get_all_player_ids()-> Array:
	return Simulation.player_info.keys()

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
	# (4) Server Performs simulation
	# (5) Server Broadcasts data to all client peers to replicate SImulation
	# (6) Server Measures states Synchronizations across all CLient Peers
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
				print_debug("Positional Data: ",i[id_as_string]["pos"])
				
				# Velocity
				print_debug("Positional Data: ",i[id_as_string]["vel"])
				
				
				# Input Buffer
				print_debug("Input Buffer: ",i[id_as_string]["in"])
				
				# Facing
				# use input buffer instead 
				
				# Update ID
				print_debug("Update ID: ",i[id_as_string]["up"])
				
				# Frame Data
				print_debug("Frame: ",i[id_as_string]["fr"], "/", "Server Frame :", get_frame_counter())
				
					
				
				
			"Player Variables"
			
			print_debug (player_info[id])
			
			# Positional Data
			print_debug("Updating Player Information for peer ",id, " from " ,player_info[id]["pos"], " to " , i[id_as_string]["pos"])
			player_info[id]["pos"] = i[id_as_string]["pos"] #WORKS
			
			# Emit Signal
			#emit_signal("PlayerInput", id_as_string) # Buggy Signal
			
			"""
			
			RUNS MULTIPLAYER SIMULATION 
			
			"""
			
			simulate(id, player)
			
