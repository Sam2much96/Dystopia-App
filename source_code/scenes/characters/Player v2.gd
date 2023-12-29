# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# THe Player Script v2 implements networking calls via rpc 
# 
#
# Contains
# (1) THe world's camera
# (2) Player hitboxes

# Features:
#
# (1) It's a class and stores variables to the UI, Globals singleton, PlayersSave Files, and the Debug SIngleton
# (2) Updates a Player Info Networkig Dictionary and Shares this as Data packets with a Networking peer
#		as pool byte arrays
# (3) Shares code with Player.gd script
# (4) Sends player Data via Metworking.player input
# (5) Updates client peers via Networking.player_update

#
# To Do:
# (1) Too much Detection going on
# (2) Player  Networking Update should attach frame id to player positional data
# (3) Implement tokenized player asset
# (4) Play animation remotely (works)
# (5) Player Camera Hierarchy bug
#		2 or more spawned players have their own cameras which misaligns the scene tree
# (6) Check Data Synchronicity between Server and CLient Peer Player Info DIctionaries
# (7) Optimize Data Packet size from 3 kb to 20 Bytes by compressing data using wallet encode algorithms
#		- amdNetworking compression methods
# (8) Optimize Networking Player iInfo dictionary to only send over canged data to reduce data packet size to 20 bytes
#	# [a] Facing should instead use an enumeration data structure rather than a string. 
# (*) Write proper debug methods dfor measuring data packet size received and sent
# (9) Rewrite Player Facing to use Enum instead

# Bugs:
# (1) Breaks GameHUD
# (2) Server and Client Codes are not Documented
# (3) Player State Doesn't Update to Networking
# (4) Simulation Logic doesn't work on server peer
# (5) AccuratePositional Data isn't being sent to Server peer (fixed)
# (6) Base Player script Input method needs refactoring
# (7) Base Player Script accepts input from all devices
# *************************************************

extends Player

class_name Player_v2_networking





#const WALK_SPEED = 350 # pixels per second
#const ROLL_SPEED = 1000 # pixels per second
#var hitpoints = 3

#var linear_vel = Vector2()
#var roll_direction = Vector2.DOWN

#signal health_changed(current_hp)

#export(String, "up", "down", "left", "right") var facing = "down"


#var despawn_fx = preload("res://scenes/UI & misc/DespawnFX.tscn")
#export (PackedScene) var blood_fx #= load("res://scenes/UI & misc/Blood_Splatter_FX.tscn")

#var anim = ""
#var new_anim = ""

#enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }

#export var state = STATE_IDLE

#************ Scene Tree Objects *************#
onready var camera = $camera #the player's camera
onready var impact_fx = $Impact

#onready var animation : AnimationPlayer = $anims

var peer_id : int


#Server Variable
var update_id : int = 0


var world_radius = Networking.WORLD_SIZE / 2
var my_info

"Update Player Peer Physics"
# A Lazy Implementation f Roleback Netcode?
# Calculates Speed And Rotation
var trust_origin 
var rotate_origin1
var rotate_origin2

var SIMULATING : bool = false

# Simulation Logic 1
var SIMULATING_1 : bool = false

#var frame_counter : int = 0

# For World Boundarty calculation
var v : Vector2 = Vector2.ZERO

func _ready():
	#Globals.update_curr_scene()
	#if Globals.player_hitpoints != null:
	#	hitpoints = Globals.player_hitpoints #Updates player health across scenes

	#Globals.player.append(self)  #saves player to the Global player variable
	
	# Make Player object a global variable
	

	'Makes Player Hitpoint a Global Variable'
	#Globals.player_hitpoints = hitpoints


	# Load Unique Player ID
	peer_id = int(get_tree().get_network_unique_id())
	
	# Save Player Details
	
	Networking.player_info["peer id"] = {peer_id : {
		"node": [],
		"position": [], # updated positional data, 
		"frames": [], #frame data
		"input": [], # input buffer for client prediction
		"hitpoints" : 3,
		"facing": "",
		"state" : [], # AN array of state s for Roll Back Networking Prediction would be ideal
		"roll dir": [],
		"destroyed": int(false), # boolean converted to integer for smaller packet size
		"updates": [],  # Stores Present Update ID Across All Clients
		"wallet addr": {}, # wallet Address and ID
		"asset id": {},
		"smart contract": [], # Arrays As it will only be one Smart COntract
		"kill Count": 0,
		"inventory": {}, # symchronizes
		"velocity":[],
		"rotation":[],
		"firing":false,
		"current_angle": 0,
		"rewspawn_time":1000,}}
	
	print_debug("Networking Peer ID: ",Networking.player_info["peer id"])
	
	print_debug("Peer ID: ", peer_id)

	# Create A Frame Buffer for Player Information
	# From Simulaton
	# Update Networking Player Info With Player Info
	# Works
	Networking.player_info["peer id"][peer_id] = Simulation.player_info
		
	Networking.player_info["peer id"][peer_id] ["node"].append(self)
	
	Networking.player = self
	
	print_debug("Initial Player Info Debug: ",Networking.player_info)
	
	#detect if networking connection
	camera._set_current(true) 
	
	# Error Catcher 1
	#if peer_id == 0:
	#	peer_id = get_tree().get_network_unique_id() # Defaults to Zero If Not Connected to MultiplayerENet

	#for i in Networking.player_info:
		

	# Error Catcher 2
	if Networking.player_info["peer id"].empty():
		Networking.player_info["peer id"] = {peer_id : {}}
		print_debug(Networking.player_info["peer id"])# For Debug Purposes ONly


	" Connects to the Dialogue System"
	if not (
			Dialogs.connect("dialog_started", self, "_on_dialog_started") == OK and
			Dialogs.connect("dialog_ended", self, "_on_dialog_ended") == OK ):
		printerr("Error connecting to dialog system")
	
	pass



	# Connect SIgnals
	
	if is_network_master():
		Networking.connect("PlayerInput", self,"poop", [peer_id])
		print_debug(Networking.is_connected("PlayerInput", self,"poop"))


func _process(delta : float):

		
	# BroadCasts player info to client peers from Host Devide
	# 
	# Delta Update counts up to Delta interval, and resets to zero when exceeding delta interval
	# It also brodcasts player data to all remote peers from the server
	# Allows the Server to Broadcast Player Data 
	# To All Client Peers using pu remote function
	
	#if is_network_master(): #creates a bug on the Cluent device
		# Raises up a Frame Counter
	#frame_counter += delta
		

		
		
		# Checks the Spawning Boolean Every 60th Frame
		# Called #very 60th Frame
		# tEMPORARILY dISABLED FOR DEBUGGING
	#if frame_counter % 6_000 == 0:
			# BroadCasts Player Info to Each Client Peer suing the pu remote call
			# Should Be Called From the Server Class Instead
	#	Networking.broadcast_world_positions()

	
	# Resets Frame Counter
	#if frame_counter >= 6_000:
	#	frame_counter = 0

	
	"Clears the Frame Buffer"
	# Prevents Memory overflow and increased bandwidth from large packet sizes
	# Should ideally only clear up to the last two?
	# Buggy
	#if Networking.player_info["peer id"][peer_id]["state"].size() > 10:
	#	Networking.player_info["peer id"][peer_id]["state"].clear()


func _input(event):
	"NETWORKING INPUTS"
	
	# Send input events over network to the server My Peer Across the Networks
	# Sends Input Twice, Once when Pressed and one when not pressed
	
	# Each Method Calls the Player Input Remote Function in
	# It's Calls THis client Player Input to the Remote Peer
	
	# Sends Data by updating the Netwprking.player info dictionary
	# And broadcasting updates across network every 6000th frame
	
	# If not connected, don't handle input.
	#if not my_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
	if not get_tree().has_network_peer() :
		push_error(" Connection Bad, Not Handling Input")
		return
		


# Mapping All Player Input to A Remote Player Call Function
# Note: client peer id is peer_id whereas server peer_id for client peer is 1

# CLIENT SIDE CODE
	if not is_network_master():
		if Input.is_action_just_pressed("move_up"):
			#
			# Updates player Info to Server Object for Broadcasting
			
			Networking.player_info["peer id"][peer_id]["facing"] = self.facing
			#print(Networking.peer_ids) # for debug purposes only
			
			# Update Positional Data
			Networking.player_info["peer id"][peer_id]["position"]["x"] = self.position.x
			Networking.player_info["peer id"][peer_id]["position"]["y"] = self.position.y
			
			# update frame Data
			Networking.player_info["peer id"][peer_id]["frames"] = Simulation.get_frame_counter()
			
			
			# update Input buffer
			Networking.player_info["peer id"][peer_id]["input"] = GlobalInput._get_input_buffer() 
			
			#print_debug(Networking.player_info["peer id"][peer_id]["frames"])
			
			
			
			# Update Player Info Data as poolbyte
			Networking.RawData = Networking.array2poolByte([Networking.player_info])
			
			# One KB Per Input is too Large. Please optimize to 20 Bytes Maz
			# Only send changed innformation rather than entire merged dictionary
			print_debug("Size (Bytes) : ", Networking.RawData.size())
			
			
			#print("Largest Peer ID: ",Networking.peer_ids[0], "No: ", Networking.peer_ids.size() ) # for debug purposes only
			
			
		if Input.is_action_just_released("move_up"):
		
			# Code Logic : Cal0l Player Inputs function via remote calls sending the following parameters
			#id, key, pressed
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"up",false)
			Networking.player_info["peer id"][peer_id]["facing"] = facing
			
			
			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error
			
		# Move Down
		if Input.is_action_just_pressed("move_down"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"right",true)
			
			Networking.player_info["peer id"][peer_id]["facing"] = facing
			
		if Input.is_action_just_released("move_down"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"right",false)
			
			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error
		
		# Move Left
		if Input.is_action_just_pressed("move_left"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"up",true)
			
			
			Networking.player_info["peer id"][peer_id]["facing"] = facing
		if Input.is_action_just_released("move_left"):
			
			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error
			
		# Move RIght
		if Input.is_action_just_pressed("move_right"):
			
			Networking.player_info["peer id"][peer_id]["facing"] = facing
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"down",true)
		if Input.is_action_just_released("move_right"):
			
			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error
			
		# Attack
		if Input.is_action_just_pressed("attack"):
			
			
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"fire",true)
			Networking.player_info["peer id"][peer_id]["state"].append(state)
			
		if Input.is_action_just_released("attack"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"fire",false)
			Networking.player_info["peer id"][peer_id]["state"].append(state)

			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error
		
		# Roll
		if Input.is_action_just_pressed("roll"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"fire",true)
			Networking.player_info["peer id"][peer_id]["state"].append(state)
			
		if Input.is_action_just_released("roll"):
			#rpc_id(1,"player_input",get_tree().get_network_unique_id(),"fire",false)
			Networking.player_info["peer id"][peer_id]["state"].append(state)
			
			
			"Updates Player Input Data Across Client/Server Peers"
			Networking.rpc_unreliable_id(1, "pi", peer_id, "up", true, Networking.RawData) # Packet Loss Error



func _physics_process(delta):

	
	## PROCESS STATES
	#only process states if connected to a newworking id and only change your peer id's parameters
	# SHould Contain Different Physics processes for Server and Client Class
	


	"""
	CLIENT SDE PHYSICS PROCESS
	"""
	# server dowsnrt do any processing
	
	if not is_network_master():
		
		match state:
			STATE_BLOCKED:
				new_anim = "idle_" + _facing
				pass
			STATE_IDLE:
				if (
						Input.is_action_pressed("move_down") or
						Input.is_action_pressed("move_left") or
						Input.is_action_pressed("move_right") or
						Input.is_action_pressed("move_up")
					):
						state = STATE_WALKING
						
						# Updates State to Global Dictionary
						# RPC calls to client peer
						Networking.player_info["peer id"][peer_id]["state"].append(state)
						
						

						
				if Input.is_action_just_pressed("attack"):
					state = STATE_ATTACK
					
					#rpc calls to server
					Networking.player_info["peer id"][peer_id]["state"].append(state)

					
				if Input.is_action_just_pressed("roll"):
					state = STATE_ROLL
					#roll_direction = Vector2(
					#		- int( Input.is_action_pressed("move_left") ) + int( Input.is_action_pressed("move_right") ),
					#		-int( Input.is_action_pressed("move_up") ) + int( Input.is_action_pressed("move_down") )
					#	).normalized()
					
					
					
					#asfafaf
					Networking.player_info["peer id"][peer_id]["roll direction"].append(roll_direction)


					# Update Facing
						
					# FOrmmerly update facing
					# Depreciated code bloc
					# SHould Ideally Call Remote Player input for it's Client Peer Accross the Networl
					#if Input.is_action_pressed("move_left"):
					#	
					#	_facing = "left"
					#if Input.is_action_pressed("move_right"):
					#	_facing = "right"
					#if Input.is_action_pressed("move_up"):
					#	_facing = "up"
					#if Input.is_action_pressed("move_down"):
					#	_facing = "down"
					
					#_update_facing()
				new_anim = "idle_" + _facing
				#get_material().
				
				pass
			STATE_WALKING:
				if Input.is_action_just_pressed("attack"):
					state = STATE_ATTACK
					
				if Input.is_action_just_pressed("roll"):
					state = STATE_ROLL
				
				#linear_vel = move_and_slide(linear_vel)
				
				#print('Player linear velocity: ', linear_vel) #for debug purposes only
				
				#var target_speed = Vector2()
				
				#if Input.is_action_pressed("move_down"):
				#	target_speed += Vector2.DOWN
				#if Input.is_action_pressed("move_left"):
				#	target_speed += Vector2.LEFT
				#if Input.is_action_pressed("move_right"):
				#	target_speed += Vector2.RIGHT
				#if Input.is_action_pressed("move_up"):
				#	target_speed += Vector2.UP
				
				#target_speed *= WALK_SPEED
				#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
				#linear_vel = target_speed
				#roll_direction = linear_vel.normalized()
				
				
				# FOrmmerly update facing
				# Depreciated code bloc
				# SHould Ideally Call Remote Player input for it's Client Peer Accross the Networl
				#if Input.is_action_pressed("move_left"):
				#	
				#	facing = "left"
				#if Input.is_action_pressed("move_right"):
				#	facing = "right"
				#if Input.is_action_pressed("move_up"):
				#	facing = "up"
				#if Input.is_action_pressed("move_down"):
				#	facing = "down"

				
				
				#_update_facing()
				
				#if linear_vel.length() > 5:
				#	new_anim = "walk_" + _facing
				#else:
				#	goto_idle()
				
				#rpc calls to server
				#Client.rpc_id(peer_id,"player_input_v2",state,facing,position, linear_vel) 
				
			STATE_ATTACK:
				#new_anim = "slash_" + _facing
				
				# should broadcast input 
				 
				pass
			STATE_ROLL:
				if roll_direction == Vector2.ZERO:
					state = STATE_IDLE
				else:
					#linear_vel = move_and_slide(linear_vel)
					#var target_speed = Vector2()
					#target_speed = roll_direction
					#target_speed *= ROLL_SPEED
					#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
					#linear_vel = target_speed
					#new_anim = "roll"
					
					
					#if Input.is_action_just_pressed("attack"): #punch and slide
					#	state = STATE_ATTACK
					pass
			STATE_DIE:
				new_anim = "die"
				

				
			STATE_HURT:
				new_anim = "hurt"
				
		
		'UPDATE ANIMATIONS'
		if new_anim != anim:
			anim = new_anim
			animation.play(anim)
		pass
	#if is_network_master():
	#	set_position(Networking.player_info["peer id"][peer_id]["position"]) 
	
	"""
	SERVER SDE PHYSICS PROCESS
	"""
	# Simulation Logic
	if is_network_master():
		
		
		# Debugx Server sie position
		
		#print(Networking.player_info["peer id"][Networking.peer_ids[0]]["position"])
		#print(Networking.player_info["peer id"].keys()) # works
		if Networking.player_info["peer id"].keys().size() > 1:
			#print(Networking.player_info["peer id"].keys()[1] ,": ",Networking.player_info["peer id"][Networking.player_info["peer id"].keys()[1]]["position"] ,"/", Networking.player_info["peer id"][Networking.player_info["peer id"].keys()[0]]["position"])
			pass
		
		#print_debug(Networking.peer_ids) # Works # For debug purposes only
		pass
		
		
		#should ideally set server player position to peer's position
		# But getting positional data is somewhat buggy

# Refactored to A Simulation Singleton on Nov 20, 23
# COnnetcs to a Player Input Signal from the Networking Singleton
# Simulates player position on Kinematic body 2d
#func poop(id : String):

#	"Server Simulation Logic"
	# Refactored to A Simulation Singleton on Nov 20, 23
	# Merges Server Player Info to Server Player Info with Peer ID's
	# Trying to get updated positinal data from data packed
	# SHould Ideally be called i the Player Networking script
	# SHould connect to a Networking Signal to optimize performance

	# SHould instead be a physics process method
	
#	if Networking.player_info["peer id"].has(id):
			
			

			# position simulation
			#print(Vector2(float(i["peer id"][id_as_string]["position"]["x"]), float(i["peer id"][id_as_string]["position"]["y"]))) # For Debug Purposes only
			
		# should ideally be called in a process method
		# SHould implement position translations using the Networking frame buffer
#		set_position(Vector2(float(Networking.player_info["peer id"][id]["position"]["x"]), float(Networking.player_info["peer id"][id]["position"]["y"])))
		
		# facing
#		self.facing = Networking.player_info["peer id"][id]["facing"]
		
		# State
		
		# roll directin
		
		#linear velocity
		
		# BroadCast Update to all Network Peers
		# 
#		Networking.broadcast_world_positions()




func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + _facing
	state = STATE_IDLE

#func _update_facing():
	#facing = Networking.player_info["peer id"][var2str(peer_id)]["facing"] #Buggy
#	if Input.is_action_pressed("move_left"):
#		facing = "left"
#	if Input.is_action_pressed("move_right"):
#		facing = "right"
#	if Input.is_action_pressed("move_up"):
#		facing = "up"
#	if Input.is_action_pressed("move_down"):
#		facing = "down"
#	pass

func despawn():  #this code breaks
	var blood = Globals.blood_fx.instance()
	var despawn_particles = Globals.despawn_fx.instance()
	
	
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

#func _on_hurtbox_area_entered():
#	pass



#var last_update = -1


# Registers player info to Global peer id Dictionary
remote func player_joined(id : int, info):
	print("Callback: player_joined(" + str(id)+"," + str(info) + ")")
	Networking.player_info[id] = info
	
	Dialogs.dialog_box.show_dialog("Player joined: " + Networking.player_info[id].name, "Admin")
	#add_chat()
	
	var preload_player : String = ""
	var node_player = load(preload_player).instance()
	var color = info.color.to_lower()
	
	node_player.get_node("texture_player").texture = load("res://images/player_" + color + ".png")
	
	info.node = node_player
	info.updates = {}
	
	var pos = Vector2(info.position.x,info.position.y)
	node_player.mode = RigidBody2D.MODE_KINEMATIC
	node_player.set_position(pos)
	node_player.name = info.name
		
	#node_players.add_child(node_player)


remote func player_leaving(id : int):
	print("Callback: player_leaving(" + str(id)+")")
	Dialogs.dialog_box.show_dialog("Player leaving: " + Networking.player_info[id].name, "Admin")
	Networking.player_info[id].node.queue_free()
	Networking.player_info.erase(id)









func player_got_shot(body : Player_v2_networking):
	print("player got shot!")
	for peer_id in Networking.player_info:
		if Networking.player_info[peer_id].node == body:
			if not Networking.player_info[peer_id].health == 0:
				Networking.player_info[peer_id].health -= 10
				if Networking.player_info[peer_id].health < 0:
					Networking.player_info[peer_id].health = 0
					
				# broadcast!
				print("Broadcast health: " + str(Networking.player_info[peer_id].health))
				for peer_id2 in Networking.player_info:
						rpc_id(peer_id2, "player_health", peer_id, Networking.player_info[peer_id].health)
						
				if Networking.player_info[peer_id].health == 0:
					Networking.player_info[peer_id].destroyed = true
					Networking.player_info[peer_id].respawn_time = 5.0
					Networking.player_info[peer_id].node.queue_free()
					


remote func player_respawned(id : int, info):
	print("Callback: player_respawned (" + str(id)+"," + str(info) + ")")
	Networking.player_info[id] = info
	Dialogs.dialog_box.show_dialog("Player respawned: " + Networking.player_info[id].name, "Admin")
	
	var preload_player : String = ""
	var node_player = load(preload_player).instance()
	var color = info.color.to_lower()
	
	node_player.get_node("texture_player").texture = load("res://images/player_" + color + ".png")
	
	info.node = node_player
	info.updates = {}
	
	var pos = Vector2(info.position.x,info.position.y)
	
	# Should Be Kinematic Body instead
	node_player.mode = RigidBody2D.MODE_KINEMATIC
	node_player.set_position(pos)
	node_player.name = info.name
		
	# Add Player to SceneTree
	#node_players.add_child(node_player)


# Updates Client Peer Remote Health
# Replace Explosion with Global Blood Instances
remote func player_health(id : int, health: int):
	print("Callback: player_health(" + str(id) +","+str(health)+")")
	if health == 0:
		Networking.player_info[id].destroyed = true
		Dialogs.dialog_box.show_dialog(Networking.player_info[id].name +" destroyed!", "Admin")
		Networking.player_info[id].node.queue_free()
		var preload_explosion
		
		var node_explosion = preload_explosion.instance()
		node_explosion.get_node("particles").emitting = true
		node_explosion.get_node("particles").one_shot = true
		node_explosion.position = Networking.player_info[id].node.position
		
		#node_projectiles.add_child(node_explosion)
	# Update HealthBar
	var progress_health
	
	var peer_id = get_tree().get_network_unique_id()
	if id == peer_id:
		progress_health.value = health

# Player update function
# This function is named "pu" to lower the network bandwidth usage, sending something
# like "player_update" will use an extra 220 bytes / second for each connected player. 

# Use Player Info Hash to Verify Packet Integrity
# Should Instead Receive A Json Compressed instead of individual Player Parameters
#remote func pu(id : int, update_id : int, updates: PoolByteArray):
#	
#	print_debug (" Packet Recieved")
#	var velocity #placeholder depreciated Variable
#	
#	
#	# Unreliable packets can be sent in wrong order, we only work with the latest
#	# data available.
#	if update_id < last_update:
#		print("Received update in wrong order. Discarding!")
#		return
#	
#	# Maintain an Updated Timeline so older packets are discarded
#	last_update = update_id
#	
#	
#	# Updates the Update Parameter for This Peer ID. 
#	# Is Called Remotely From a Peer
#	print ("Data Packet:",updates.get_string_from_utf8())
##	# REwrite to instead Parse json
#	Networking.download_json_(updates, "res://")
#	#Networking.player_info[id].updates[OS.get_ticks_msec()] = { position = pos, velocity = velocity, rotation = rotation }
	
#	# Stops a Stack Overflow or by Eraci=sing Excess Updates over 10
#	while len(Networking.player_info[id].updates) > 10:
#		Networking.player_info[id].updates.erase(Networking.player_info[id].updates.keys()[0])
#	
	
	# Dont Update If Peer Destroyed
#	if Networking.player_info[id].destroyed:
#		return
	
	
	# Remote Update Particles
#	if Networking.player_info[id].node.has_node("particles"):
#		Networking.player_info[id].node.get_node("particles").set_emitting(velocity != 0)
#
#	if Networking.player_info[id].node.has_node("audio_thruster"):
#		Networking.player_info[id].node.get_node("audio_thruster").stream_paused = velocity == 0
#
#
## Remote FUnction for emitting and displaying Damages points and Particles
remote func display_damage(body):
	var player_info 
	
	for peer_id in player_info:
		if player_info[peer_id].node == body:
			var preload_damage : String = ""
			var node_damage = load(preload_damage).instance()
			node_damage.name = "damage"
			node_damage.get_node("particles").emitting = true
			node_damage.get_node("particles").one_shot = true
			player_info[peer_id].node.add_child(node_damage)
			break


class server  extends Reference:
	remote func fire_weapon(id, position, current_angle):
		Simulation.projectiles.append({ timestamp = OS.get_ticks_msec() + (Networking.TICK_DURATION * 2), id = id, position = position, current_angle = current_angle })

class server2 extends Reference:
	func fire_weapon(id : int):
		print("Fire weapon!")
			
		var info = Networking.player_info[id]
		var preload_projectile
		var node_projectiles
		var node_projectile = preload_projectile.instance()
		var pos = Vector2(info.position.x,info.position.y)
		
		node_projectile.name = info.name
		node_projectile.contacts_reported = 1
		node_projectiles.add_child(node_projectile)

		var weapon_angle = info.node.rotation + rand_range(-Networking.PROJECTILE_RANDOM/2, Networking.PROJECTILE_RANDOM/2)
		var trustp = Vector2(0,Networking.PROJECTILE_OFFSET).rotated(weapon_angle)
		node_projectile.set_position(pos - trustp)
		node_projectile.set_linear_velocity(-trustp * Networking.PROJECTILE_SPEED)
		
		for peer_id in Networking.player_info:
			#rpc_id(peer_id, "fire_weapon", id, Networking.player_info[id].position, weapon_angle)
			pass
