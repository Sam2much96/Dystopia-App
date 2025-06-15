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
# (4) Sends player Data via Simulation.player input
# (5) Updates client peers via SImulation.player_update

#
# To Do:
# (1) Too much Detection going on
# (2) Implement tokenized player asset
# (3) Play animation remotely (works)
# (4) Player Camera Hierarchy bug

# (5) Check Data Synchronicity between Server and CLient Peer Player Info DIctionaries
# (6) Optimize Data Packet size from 3 kb to 20 Bytes by compressing data using wallet encode algorithms
#		- amdNetworking compression methods
# (7) Optimize Networking Player iInfo dictionary to only send over canged data to reduce data packet size to 20 bytes

# (8) Enemy Networking SImulation
# (9) Implement SideScrolling Lvevls for Multiplayer

# Bugs:
# (1) State Buffer is buggy : Data is largely redundant
# *************************************************

extends Player_v1_TopDown

class_name Player_v2_networking


#************ Scene Tree Objects *************#


#Server Variable
var update_id : int = 0


var world_radius = Networking.WORLD_SIZE / 2
var my_info

var SIMULATING : bool = false

# Simulation Logic 1
var SIMULATING_1 : bool = false

#var frame_counter : int = 0

# For World Boundarty calculation
var v : Vector2 = Vector2.ZERO

onready var _label : Label = $Label



func _ready():
	randomize() # Random Seed Generator
	
	#print_debug(err)
	
	# Name is then Same As Peed ID
	_label.set_text(self.name)
	
	# add a random position to fix  stuck colision bug on client
	var random = Vector2(rand_range(0,2), rand_range(0,2))
	self.set_position(random)
	
	connect("state_changed",self,"update_state_buffer",[state])
	print_debug(is_connected("input_event",self,"update_state_buffer"),[state])
	
	# Load Unique Player ID
	# Error catcher
	if peer_id == -99: # Dummy peer id
		peer_id = int(get_tree().get_network_unique_id()) # Get the real peer id
	
	# Save Player Details
	#CLient Peer Details Locally
	Simulation.register_player(peer_id)
	
	#print_debug ("Client Peer Data ", Simulation.player_info[peer_id])
	
	#print_debug("Networking Peer ID: ", Simulation.get_all_player_ids())
	
	#print_debug("Peer ID: ", peer_id)

	
	"Register Player Error Catcher"
	# Error Catcher 2
	if Simulation.player_info.keys().empty():
		Simulation.player_info = {peer_id : {}}
		print_debug(Simulation.player_info.keys())# For Debug Purposes ONly

	# Connect SIgnals
	# (1) Networking Singleton to SImulation SIngleton
	if is_network_master():
		
		Simulation.connect("pi", Simulation,"simulate", [peer_id, self])
		print_debug("Simulation signal is connected: ",Simulation.is_connected("pi", Simulation,"simulate"))

	"Active Camera"
	
	if not is_network_master():
		if Networking.GamePlay == Networking.LOCAL_COOP:
			# Fixes Client Player Inactive Camera
			# Breaks in Online MMO Gameplay
			Simulation.all_player_objects[2].player_camera.make_current()



func _input(_event):
	"""
	NETWORKING INPUTS
	
	Send input events over network to the server My Peer Across the Networks
	Sends Input Twice, Once when Pressed and one when not pressed
	
	Each Method Calls the Player Input Remote Function in
	It's Calls THis client Player Input to the Remote Peer
	
	Sends Data by updating the Simulatoin player info dictionary
	And broadcasting updates across network every 6000th frame
	"""
	# Depreciated code
	# If not connected, don't handle input.
	#if not my_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
	
# Mapping All Player Input to A Remote Player Call Function
# Note: client peer id is peer_id whereas server peer_id for client peer is 1

# CLIENT SIDE CODE


	"""
	Client SIde Payer Input 
	
	"""
	if err > 0: # Networked Multiplayer Is Up
	
		if not get_tree().has_network_peer() :
			push_error(" Connection Bad, Not Handling Input")
			return
			


		
		
		if not is_network_master():
			if Networking.GamePlay == Networking.LOCAL_COOP:
				facing_logic(Simulation.all_player_objects[2], 0) # Where Zero is the default server player id
			if Networking.GamePlay == Networking.MMO_SERVER:
				facing_logic(self, peer_id) 
			if (Input.is_action_just_pressed("move_up") or 
			Input.is_action_just_pressed("move_down") or
			Input.is_action_just_pressed("move_left") or
			Input.is_action_just_pressed("move_right") or 
			Input.is_action_just_pressed("attack") or
			Input.is_action_just_pressed("roll") ):
			
				# Update update ID to prevent wrong packet order 
				
				# Updates player Info to Server Object for Broadcasting
				update_player_info()
				
				
				# Update Player Info Data as poolbyte
				#Networking.RawData = Networking.array2poolByte([Networking.player_info])
				
				# Debug Raw data
				# Shows Data as Raw Poolbyte array
				#print_debug("Raw Data: ", Networking.RawData)
				
				# One KB Per Input is too Large. Please optimize to 20 Bytes Maz
				# Only send changed innformation rather than entire merged dictionary
				#print_debug("Size (Bytes) : ", Simulation.RawData.size())
				
				
				#print("Largest Peer ID: ",Networking.peer_ids[0], "No: ", Networking.peer_ids.size() ) # for debug purposes only
				
				
			
			if (Input.is_action_just_released("move_up") or 
			Input.is_action_just_released("move_down") or
			Input.is_action_just_released("move_left") or
			Input.is_action_just_released("move_right") or
			Input.is_action_just_pressed("attack") or
			Input.is_action_just_pressed("roll") ):
				
				"Updates Player Input Data Across Client/Server Peers"
				Simulation.rpc_unreliable_id(1, "pi", peer_id, Simulation.RawData) # Packet Loss Error
		
		
	# Server Side Code
	# Hack : I'm hardcoding for 2 players for faster development, future code should account for more and pay back this technical debt 
		# Multiplayer Input Facing Logic
		
		if is_network_master(): # Server player
			# call the refactored state machine logic with the peed id parameter
			if Networking.GamePlay == Networking.LOCAL_COOP:
				facing_logic(Simulation.all_player_objects[3], 0) # Where Zero is the default server player id
			
				"""
				Server Logic : Should only process inputs in local coop
				"""
				
				if (Input.is_action_just_pressed("move_up") or 
				Input.is_action_just_pressed("move_down") or
				Input.is_action_just_pressed("move_left") or
				Input.is_action_just_pressed("move_right") or 
				Input.is_action_just_pressed("attack") or 
				Input.is_action_just_pressed("roll") ):
					update_player_info()
					
					
				
				if (Input.is_action_just_released("move_up") or 
				Input.is_action_just_released("move_down") or
				Input.is_action_just_released("move_left") or
				Input.is_action_just_released("move_right") or
				Input.is_action_just_pressed("attack") or 
				Input.is_action_just_pressed("roll") ):
					Networking.broadcast_world_positions()



func _physics_process(_delta):
	
	"Process Physics Only If Player Is Online"
		
	"""
	STATE BUFFER LOGIC & STATE MACHINE IMPL
	
	(1) Implements a SImple Sate buffer As an array for Simulation prediction
	"""
	# Should Contain Logic to account for 2 or more client players
	
	# Top Down Physics Processing for ONline Matches
	
	if err > 0: # Networked Multiplayer Is Up
		
		# State Buffer Is Buggy
		# Prevent Memory Leak/ Stack Overflow error 
		if StateBuffer.size() >= 6:
			#print("State Buffer Debug: ",StateBuffer) # for debug purposes only
			StateBuffer.clear()


		# Server
		if is_network_master():
			if Networking.GamePlay == Networking.LOCAL_COOP:
				# Server Class
				
				state_machine_logic(Simulation.all_player_objects[3],0)
			
		# Client
		if not is_network_master():
			if Networking.GamePlay == Networking. LOCAL_COOP:
				# Place Error Catcher Here
				# Client Class
				# (1) Update facing based on my input
				# (2) Simulate Physics process for only my player object using peed id
				#print(Simulation.all_player_objects)
				state_machine_logic(Simulation.all_player_objects[2],0)
			
			if Networking.GamePlay == Networking.MMO_SERVER:
				state_machine_logic(self,peer_id)





func _get_state_buffer() : #-> int:
	return int(Utils.array_to_string(StateBuffer.duplicate()))


	"""
	CLIENT SDE PHYSICS PROCESS
	"""
	# server dowsnrt do any processing
	
	if not is_network_master():
		pass
	
	"""
	SERVER SIDE PHYSICS PROCESS
	
	
	"""
	# Simulation Logic
	if is_network_master():
	
		if Simulation.player_info.keys().size() > 1:
			pass



func update_player_info():
	"""
	UPDATES ALL PLAYER INFO TO A GLOBAL DICTIONARY
	"""
	# Features:
	# (1) Is called Twice on Both Server And Client Peers
	#
	# TO DO :
	# (1) Update Only the Info that changes to reduce bbandwidth size
	
	update_id += 1
	
	#print_debug(peer_id)
	#print_debug("UPdate Player Debug: ",Simulation.player_info[peer_id])
	
	# Updates player Info to Server Object for Broadcasting
	
	#Simulation.player_info["peer id"][peer_id]["facing"] = self.facing
	#print(Networking.peer_ids) # for debug purposes only
	
	# Update Positional Data
	Simulation.player_info[peer_id]["pos"]["x"] = self.position.x
	Simulation.player_info[peer_id]["pos"]["y"] = self.position.y
	
	# Update Velocity
	Simulation.player_info[peer_id]["vel"]["x"] = self.linear_vel.x
	Simulation.player_info[peer_id]["vel"]["y"] = self.linear_vel.y
	
	# update Update ID
	
	# update frame Data
	Simulation.player_info[peer_id]["fr"] = Simulation.get_frame_counter()
	

	# update Input buffer
	Simulation.player_info[peer_id]["in"] = GlobalInput._get_input_buffer()
	
	# Hitpoints
	Simulation.player_info[peer_id]["hp"] = self.hitpoints
	
	# State
	# implement state buffer for player script
	Simulation.player_info[peer_id]["st"] = _get_state_buffer()
	
	# roll direction
	# is useable? 
	# requires simulation test
	Simulation.player_info[peer_id]["rd"] = self.roll_direction
	
	# despawn
	Simulation.player_info[peer_id]["dx"] = 1 # false
	
	# Update ID
	#
	Simulation.player_info[peer_id]["up"] = self.update_id
	
	# Wallet Address Requires Third party integration login
	Simulation.player_info[peer_id]["wa"] = ""
	
	# Asset ID
	Simulation.player_info[peer_id]["ai"] = 0 # Requires 3rd party integration
	
	# Kill COunt
	Simulation.player_info[peer_id]["kc"] = Globals.kill_count
	
	
	# Inventory
	# Depreciating Inventory Updates Temporarily for data optimization
	Simulation.player_info[peer_id]["inv"] = Inventory._get_inventory_buffer() #Inventory.jsonify()
	
	# Respawn Time
	Simulation.player_info[peer_id]["rt"] = 60
	
	# 
	# Hash
	# Adds the client infoo
	Simulation.player_info[peer_id]["hash"] = Simulation.player_info.hash() 
	
	
	# Update Player Info Data as poolbyte
	
	Simulation.RawData = Networking.array2poolByte([Simulation.player_info])
	
	#print_debug(Networking.RawData) # for debug purposes only


func update_state_buffer(state, state_):
	# works
	# Breaks roll state calculations / shader
	# Needs a limiter because it is called in a physics process with rapid fire
	
	
	#print("Updating State Buffer 1 :", StateBuffer)
	return StateBuffer.append(state)



remote func player_leaving(id : int):
	print_debug("Callback: player_leaving(" + str(id)+")")
	Dialogs.dialog_box.show_dialog("Player leaving: " + Networking.player_info[id].name, "Admin", false)
	Simulation.player_info[id].node.queue_free()
	Simulation.player_info.erase(id)




remote func enemy_hit_collision(id ,body : Player_v2_networking):
	pass

remote func player_hit_collision(id):
	# Logic:
	# (1) On CLient Player, Simulate the Hit Commision on the Player Object using it's ID
	# (2) On Server, Simulate Logic if Local Lan else broadcast collision if Online MMO
	print_debug("player got hit!")
	if not is_network_master(): # Client Player
		
		for peer_id in Networking.player_info:
			if Networking.player_info[peer_id].node ==KinematicBody2D: # Depreciated line
				if not Networking.player_info[peer_id].health == 0:
					Networking.player_info[peer_id].health -= 10
					if Networking.player_info[peer_id].health < 0:
						Networking.player_info[peer_id].health = 0
	
	if is_network_master(): # Server Player
		# Server Player
		# broadcast!
		print("Broadcast health: " + str(Networking.player_info[peer_id].health))
		for peer_id2 in Networking.player_info:
				rpc_id(peer_id2, "player_health", peer_id, Networking.player_info[peer_id].health)
				
		if Networking.player_info[peer_id].health == 0:
			Networking.player_info[peer_id].destroyed = true
			Networking.player_info[peer_id].respawn_time = 5.0
			Networking.player_info[peer_id].node.queue_free()




# Updates Client Peer Remote Health
# Replace Explosion with Global Blood Instances
remote func player_health(id : int, health: int):
	print("Callback: player_health(" + str(id) +","+str(health)+")")
	if health == 0:
		Networking.player_info[id].destroyed = true
		Dialogs.dialog_box.show_dialog(Networking.player_info[id].name +" destroyed!", "Admin", false)
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
 
