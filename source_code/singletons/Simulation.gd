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
var RawData : Array
var id_as_string : String #= Networking.id_as_string


# My Player Networking object
var player : Player_v2_networking


export (Dictionary) var player_info : Dictionary = {
	"peer id": { 0 : { # server peer id
		"position": {"x": 0, "y":0}, # updated positional data, 
		"velocity":{"x": 0, "y": 0},
		"frames": 0, #frame data
		"input": [], #input buffer
		"hitpoints" : 3,
		"facing": 0,
		"state" : 0, # AN array of state s for Roll Back Networking Prediction would be ideal
		"roll dir": {"x": 0, "y": 0},
		"destroyed": 0, # boolean converted to integer for smaller packet size
		"updates": 0,  # Stores Present Update ID Across All Clients #
		"wallet addr": 0,#[Wallet.address], # wallet Address and ID
		"asset id": {},
		"smart contract": 0,#[Wallet.smart_contract_addr, Wallet._app_id, Wallet._app_args], # Arrays As it will only be one Smart COntract
		"kill Count": 0,
		"inventory": Inventory.list(), # symchronizes Inventory Item
		"rotation":0,
		#"firing":false,
		"current_angle": 0,
		"rewspawn_time":1000,
	}},
	
	"hash" : "" # Arrays because hash data is discarded eventually
	} 


# Refactored to A Simulation Singleton on Nov 20, 23
# COnnetcs to a Player Input Signal from the Networking Singleton
# Simulates player position on Kinematic body 2d
#
# SHould Implement Input Buffer into simulation Logic
func simulate(id : String, player : Player_v2_networking ):

	"Server Simulation Logic"
	# Refactored to A Simulation Singleton on Nov 20, 23
	# Merges Server Player Info to Server Player Info with Peer ID's
	# Trying to get updated positinal data from data packed
	# SHould Ideally be called i the Player Networking script
	# SHould connect to a Networking Signal to optimize performance

	# SHould instead be a physics process method
	
	if Simulation.player_info["peer id"].has(id):
			
			

			# position simulation
			#print(Vector2(float(i["peer id"][id_as_string]["position"]["x"]), float(i["peer id"][id_as_string]["position"]["y"]))) # For Debug Purposes only
			
		# should ideally be called in a process method
		# SHould implement position translations using the Networking frame buffer
		#player.move_and_slide(Vector2(float(Networking.player_info["peer id"][id]["velocity"]["x"]),float(Networking.player_info["peer id"][id]["velocity"]["y"]))
		# Data packet Lost
		player.move_and_slide(Vector2(float(Simulation.player_info["peer id"][id]["velocity"]["x"]), float(Simulation.player_info["peer id"][id]["velocity"]["y"])))
		
		
		player.set_position(Vector2(float(Simulation.player_info["peer id"][id]["position"]["x"]), float(Simulation.player_info["peer id"][id]["position"]["y"])))
		
		# facing
		player.facing = Simulation.player_info["peer id"][id]["facing"]
		
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
				if bool(Networking.player_info["peer id"][i]["destroyed"]) == false:
					continue
				
				
				#synchronize positions for my peer
				Networking.player_info["peer id"][1]["node"].pop_front().set_position(Networking.player_info["peer id"][i]["position"])
				
				
				var velocity_speed = 2
				if int(Networking.player_info["peer id"][i]["velocity"]) != 0:
					continue
				
				# Apply Impulse Simulation To Peer UD

			#	pass
				if Networking.player_info["peer id"][i]["rotation"] != 0:
						if Networking.player_info["peer id"][i]["rotation"] < 0:
							# More Impulse Calculation
							pass

				"""
				KEEP PLAYER WITHIN BOUNDARIES
				"""
				
				# Debugging
		
				v = Vector2(Networking.player_info["peer id"][i]["position"])
				
				if v.x > world_radius:
					v.x = world_radius
					Networking.player_info["peer id"][i]["node"].pop_front().set_position(v)
				if v.x < -world_radius:
					v.x = -world_radius
					Networking.player_info["peer id"][i]["node"].pop_front().set_position(v)
				if v.y > world_radius:
					v.y = world_radius
					Networking.player_info["peer id"][i]["node"].pop_front().set_position(v)
				if v.y < -world_radius:
					v.y = -world_radius
					Networking.player_info["peer id"][i]["node"].pop_front().set_position(v)
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
			print(Networking.player_info["peer id"][i])
			
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
#
# should store Non-threathening Crypto and Multiplayerinfo too
# Data Integrity can be checked using hash
# Stores Data FOr Synchronizing Player Data Among Multiple Peers
# Should be converted to Json before sent over Network
# Organize player Info for each client peer id. It should synchronize game states across player network mesh
func register_player(id : int)-> Dictionary:
	# To Do:
	# (1) Optimize Dictionary size to Max 1000 bytes
	# (2) Implewment Data Optimization for  Data packet (gdunzip/zip)
	var player_info : Dictionary = {
		"peer id": { id : { # server peer id
		"position": {"x": 0, "y":0}, # updated positional data, 
		"velocity":{"x": 0, "y": 0},
		"frames": 0, #frame data
		"input": 0, #input buffer
		"hitpoints" : 3,
		"facing": 0,
		"state" : 0, # AN array of state s for Roll Back Networking Prediction would be ideal
		"roll dir": {"x": 0, "y": 0},
		"destroyed": 0, # boolean converted to integer for smaller packet size
		"updates": 0,  # Stores Present Update ID Across All Clients #
		"wallet addr": 0,#[Wallet.address], # wallet Address and ID
		"asset id": 0,
		"smart contract": 0,#[Wallet.smart_contract_addr, Wallet._app_id, Wallet._app_args], # Arrays As it will only be one Smart COntract
		"kill Count": 0,
		"inventory": 0, # symchronizes Inventory Item
		"rotation":0,
		#"firing":false,
		"current_angle": 0,
		"rewspawn_time":1000,
	}},
	
	"hash" : "" # Arrays because hash data is discarded eventually
	} 
	return player_info

func get_all_player_ids()-> Array:
	return Simulation.player_info["peer id"].keys()

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


	"Server Logic"
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
		
		
		
		
		id_as_string = var2str(id) 
		for i in Networking.poolByte2Array(player_data):
			
			if i != null:
					#Returns a String. Converting to Dictionary
					
			#	RawJson = JSON.parse(i) # Returns either a String or a Dictionary? Type 18 for dictionary 
				
				
				# Bug : Nerging Dictionaries may be overwrite positional data? 
				# Fix : Set Overwrite to true for duplicate keys
				
				
				#print ("I: ", i["peer id"][var2str(id)]["position"]) # works # for debug purposes only
				#print ("I: ", i) # works # for debug purposes only
				
				"Data to debug"
				
				#Position
				print_debug("Positional Data: ",i["peer id"][id_as_string]["position"])
				
				# Velocity
				print_debug("Positional Data: ",i["peer id"][id_as_string]["velocity"])
				
				
				# Input Buffer
				print_debug("Input Buffer: ",i["peer id"][id_as_string]["input"])
				
				# Facing
				print_debug("Facing: ",i["peer id"][id_as_string]["facing"])
				
				# Update ID
				print_debug("Update ID: ",i["peer id"][id_as_string]["updates"])
				
				# Frame Data
				print_debug("Frame: ",i["peer id"][id_as_string]["frames"], "/", "Server Frame :", get_frame_counter())
				
					
				# Registers the Player Connected Peer ID Locally if not registered
				if not player_info["peer id"].has(id_as_string):
					
					# Register New Player Info
					
					player_info["peer id"][id_as_string] = {
					"position": i["peer id"][id_as_string]["position"], # updated positional data, 
					"frames": 0, #frame data
					"input" : [],
					"hitpoints" : 3,
					"facing": 0,
					"state" : [], # AN array of state s for Roll Back Networking Prediction would be ideal
					"roll dir": [],
					"destroyed": 0,
					"updates": 0,  # Stores Present Update ID Across All Clients # Depreciated
					"wallet addr": [0],
					"asset id": {},
					"smart contract": [], # Arrays As it will only be one Smart COntract
					"kill Count": 0,
					"inventory": {},
					"velocity":{"x": 0, "y": 0},
					"rotation":0,
					"firing":0,
					"current_angle": 0,
					"rewspawn_time":1000,
					"hash" : ""
					
					}
				
				
			"Player Variables"
			# Positional Data
			print_debug("Updating Player Information for peer ",id_as_string, " from " ,player_info["peer id"][id_as_string]["position"], " to " , i["peer id"][id_as_string]["position"])
			player_info["peer id"][id_as_string]["position"] = i["peer id"][id_as_string]["position"] #WORKS
			
			# Emit Signal
			#emit_signal("PlayerInput", id_as_string) # Buggy Signal
			
			"Simulates Player Posititional Data "
			#player.poop(id_as_string)
			simulate(id_as_string, player)
			

			#Requires Debugging
			#if key == "left":
			#	Networking.player_info[id].facing = key
			##	Networking.player_info[id].rotation = -1 if pressed else 0
			#elif key == "right":
			#	Networking.player_info[id].rotation = 1 if pressed else 0
			#elif key == "up":
			#	Networking.player_info[id].velocity = -1 if pressed else 0
			#elif key == "down":
			#	Networking.player_info[id].velocity = 1 if pressed else 0
			#elif key == "fire":
			#	Networking.player_info[id].firing = 1 if pressed else 0
			#elif key == "attack":
			##	
			#else : pass

