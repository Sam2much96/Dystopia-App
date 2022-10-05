# *************************************************
# Based on code by godot3-spacegame by Yanick Bourbeau
# Released under MIT License
# *************************************************
# CLIENT-SIDE CODE
#
# All the client logics in one file!
# Needs Mesh network for peer to peer
# To Do:
# (1) Send Player inputs via remote functions
# (2) Duplicate Input Functions btw Client and Server (Using ROll back netcode as a reference)
# (3)  
# *************************************************
extends Node
var client_debug 

var my_info = { name = "Player" }
var preload_player = preload("res://scenes/characters/Aarin.tscn")

var player_id #my code
export (int) var ______update_id
var hitpoints= 3#var preload_projectile = preload("res://New game code and features/multiplayer/scenes/projectile.tscn") #tweak
var preload_damage  #= preload("res://New game code and features/multiplayer/scenes/effects/damage.tscn") #tweak
var preload_explosion #= preload("res://New game code and features/multiplayer/scenes/effects/explosion.tscn") #tweak
var pos = Vector2(0,0)
var killcount = 0
var linear_vel
# Player info, associate ID to data
var player_info = {}
#var projectiles = []
var my_peer = null
var last_update = -1 #probably used for updating the network
onready var node_players = Node.new()#$players #p2p player nodes
onready var node_enemies=Node.new()  #= #= $camera/projectiles #rewrote progectile nodes to enemy nodes
#onready var camera = Camera2D.new()#$Camera2D#get_tree().get_root()
onready var progress_health = load('res://scenes/UI & misc/Healthbar.tscn')


#*******Chat Item*************#
onready var chat = $UI/item_chat


onready var state #im trying to send player state using rpc call and update it on the server using a remote funtion
func _ready():
	OS.set_window_title('Client') 
	#sdgagdfasdfasdf
	#Handles Network Connectivity
	node_enemies.name = 'node_enemies'
	node_players.name = 'node_players'
	
	self.add_child(node_players)
	self.add_child(node_enemies)
	
	
	print (' Who is more Authoritative? the client or the server? ') #question?
	
	
	#lists all local ip addresses on Device
	print ('LOCAL IP ADDRESSES: ',IP.get_local_addresses())
	print ('IP ADDRESSES: ',IP.get_local_interfaces())
	
	print("Server IP       : " + Networking.cfg_server_ip)
	print("Player Name     : " + Networking.cfg_player_name)
	print("Spaceship Color : " + Networking.cfg_color)
	
	print("Connecting to server ...")
	
	var peer = NetworkedMultiplayerENet.new()
	
	# Create a client using specified server ip
	peer.create_client(Networking.cfg_server_ip, Networking.SERVER_PORT)
	
	# Associate the current network peer to the tree
	get_tree().set_network_peer(peer)
	
	# Keep the current peer somewhere to differenciate between you and other players
	my_peer = peer
	
	# Connect signals
	if get_tree().connect("connected_to_server", self, "client_connected_ok") != OK:
		print("Unable to connect signal (connected_to_server) !")
		
	if get_tree().connect("connection_failed", self, "client_connected_fail") != OK:
		print("Unable to connect signal (connection_failed) !")
		
	if get_tree().connect("server_disconnected", self, "server_disconnected") != OK:
		print("Unable to connect signal (server_disconnected) !")
	
	# Add a message to the chat box
	add_chat("Welcome to this network test!")
	add_chat("Connecting to server ....")
	
func _process(_delta):
	
	# To mitigate latency issues we use interpolation. The idea is simple, we receive
	# position updates every TICK_DURATION (50 ms, 20 per seconds). We interpolate between
	# the last two previous updates, this way we always have smooth movements. The
	# main drawback is added latency (100 ms).
	
	var target_timestamp = OS.get_ticks_msec() - (Networking.TICK_DURATION*2)
	



	#Handles Client Side Player Position Calculation
	var peer_id = get_tree().get_network_unique_id()
	if player_info.has(peer_id): #if player if has my peer id, position.x is player_info[peer_id] position
		pos.x = player_info[peer_id].node.position.x 
		pos.y = player_info[peer_id].node.position.y #updates vvarible with player's position

		state = player_info[peer_id].node.state
		hitpoints = player_info[peer_id].node.hitpoints
		#print (pos) #for debug purposes only
		#print ('Update ID: ',peer_id) #for debug purposes only
		
		player_info[peer_id].position = pos #updates the player's dicitonary with current player position 
		
		linear_vel = player_info[peer_id].node.linear_vel
		pass
	

	# Handle input (keyboard)
	handle_input() #Handle's Player's Input and sends it to the Servers
	
	
	

func handle_input():
	
	# If not connected, don't handle input.
	if not my_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		return
		
	# if not currently playing, don't handle input too.
	if my_info == null:
		return
		
	# Send input events over network to the server
	var id = get_tree().get_network_unique_id()
	# Move left
	if Input.is_action_just_pressed("move_left"): #sends player input to the server
		
		# calls a remote player input method in the client via rpc
		rpc_id(1,"player_input",id,"left",true, pos, state, linear_vel) #sends position and state data directly to servers 
		
		#1 is peer ID
		
		client_debug()
	if Input.is_action_just_released("move_left"):
		#rpc triggers a remote function that changes Client player's Linear Velocity
		rpc_id(1,"player_input",id,"left",false,pos,state, linear_vel) 
		
	# Move right presssed
	if Input.is_action_just_pressed("move_right"):
		rpc_id(1,"player_input",id,"right",true,pos,state, linear_vel)
	
	# Move right released
	if Input.is_action_just_released("move_right"):
		rpc_id(1,"player_input",id,"right",false,pos,state, linear_vel)
		
	# Handle moving forward
	if Input.is_action_just_pressed("move_up"):
		rpc_id(1,"player_input",id,"up",true,pos,state, linear_vel) #sends player input on the network with the player input funtion
	if Input.is_action_just_released("move_up"):
		rpc_id(1,"player_input",id,"up",false,pos,state, linear_vel)
		
	# Handle moving backward
	if Input.is_action_just_pressed("move_down"):
		rpc_id(1,"player_input",id,"down",true,pos,state, linear_vel)
	if Input.is_action_just_released("move_down"):
		rpc_id(1,"player_input",id,"down",false,pos,state, linear_vel)
		
	# Handle player attacking
	if Input.is_action_just_pressed("attack"): #sends these input to the server's logic
		rpc_id(1,"player_input",id,"attack",true) #doesn't work
	if Input.is_action_just_released("attack"):
		rpc_id(1,"player_input",id,"attack",false)
	#Handles player rolling #my code
	if Input.is_action_just_pressed("roll"):
		rpc_id(1,"player_input",id,"roll",true)#doesn't work
	if Input.is_action_just_released("roll"):
		rpc_id(1,"player_input",id,"roll",false) #doesn't work




"When Client Succcessfully Connects"
func client_connected_ok():
	push_error("Callback: client_connected_ok")
	add_chat("Connected. Enjoy!")
	# Only called on clients, not server. Send my ID and info to all the other peers
	my_info.name = Networking.cfg_player_name
	my_info.color = Networking.cfg_color
	rpc_id(1,"register_player", get_tree().get_network_unique_id(), my_info)
	OS.set_window_title("Connected as " + my_info.name)

#####Add your codes here
	

"When Server Disconnects"
func  server_disconnected(): #tweak to 'sever diconnected, change scene to login
	push_error("Callback: server_disconnected")
	OS.alert('You have been disconnected!', 'Connection Closed')
	# Change to login scene
	get_tree().change_scene("res://scenes/login.tscn")
	if get_tree().change_scene("res://scenes/login.tscn") != OK:
		push_error("Unable to load login scene!")

func client_connected_fail():
	push_error("Callback: client_connected_fail")
	OS.alert('Unable to connect to server!', 'Connection Failed')
	# Change to login scene
	get_tree().change_scene("res://scenes/login.tscn")
	if get_tree().change_scene("res://scenes/login.tscn") != OK:
		push_error("Unable to load login scene!")
	
remote func player_joined(id, info): #tweak code###########################
	print("Callback: player_joined(" + str(id)+"," + str(info) + ")")
	player_info[id] = info
	add_chat("Player joined: " + player_info[id].name)
	
	var node_player = preload_player.instance()


	
	info.node = node_player #player node 
	info.updates = {}
	
	var pos = Vector2(info.position.x,info.position.y)
	#node_player.mode #= RigidBody2D.MODE_KINEMATIC
	node_player.set_position(pos)
	node_player.name = info.name
		
	node_players.add_child(node_player)
	

remote func player_respawned(id, info):
	print("Callback: player_respawned (" + str(id)+"," + str(info) + ")")
	player_info[id] = info
	add_chat("Player respawned: " + player_info[id].name)
	
	var node_player = preload_player.instance()
	var color = info.color.to_lower()
	
	#node_player.get_node("texture_player").texture = load("res://images/player_" + color + ".png")
	
	info.node = node_player
	info.updates = {}
	
	var pos = Vector2(info.position.x,info.position.y)
	#node_player.mode = RigidBody2D.MODE_KINEMATIC
	node_player.set_position(pos)
	node_player.name = info.name
	
	#node_players.append(node_player)
	node_players.add_child(node_player)
	
remote func player_leaving(id): #Called when player leaves the game
	print("Callback: player_leaving(" + str(id)+")")
	add_chat("Player leaving: " + player_info[id].name)
	player_info[id].node.queue_free()
	
	player_info.erase(id)

#updates players healths

remote func player_health(id, hitpoint): #where is this funtion called? 
	print("Callback: player_health(" + str(id) +","+str(hitpoint)+")")  #update this code to use player state
	if hitpoint == 0:
		player_info[id].destroyed = true
		add_chat(player_info[id].name +" destroyed!")
		player_info[id].node.queue_free()
		
	var peer_id = get_tree().get_network_unique_id()
	if id == peer_id:
		progress_health.value = hitpoint #updates the progress bar to player life
	
#PU updates the client's player state from the server
# Player update function can only be called from server
# This function is named "pu" to lower the network bandwidth usage, sending something
# like "player_update" will use an extra 220 bytes / second for each connected player. 
remote func pu(id, update_id, pos, hitpoints, state): #try and use killcounts
	
	# Unreliable packets can be sent in wrong order, we only work with the latest
	# data available.
	#print ('//////Last update/////', last_update, '/////Update ID////' , update_id) for debug purposes only
	______update_id = update_id+1 #stores the update id
	if update_id < last_update: #update_id breaks the code here
		print("Received update in wrong order. Discarding!")
		return
		
	last_update = update_id
	player_info[id].updates[OS.get_ticks_msec()] = { position = pos, hitpoints = hitpoints, killcount = killcount, state = state } #update these variables to the server
	while len(player_info[id].updates) > 10:
		player_info[id].updates.erase(player_info[id].updates.keys()[0]) #when length of player update is more than 10, erase some update data
	
	if player_info[id].destroyed: #if player is destroyed
		return
		
	
remote func attack(id, position, facing): #update code to be an attack #inhumanity
	#projectiles.append({ timestamp = OS.get_ticks_msec() + (Networking.TICK_DURATION * 2), id = id, position = position, current_angle = current_angle })
	#The original vode ran mainly using simulaions so
	#This was one of such simulations
	
	
	print('attack',id,position, facing)
	

"Adds Messages to ingame Chat"
func add_chat(text): #used the ui grid  
	chat.add_item(text)
	if chat.get_item_count() == 7:
		chat.remove_item(0)

	for i in range(0,chat.get_item_count()):
		chat.set_item_selectable(i,false)


func display_damage(body):#rewrite this to instance blood fx

	print ('damage: ' , body)
	


func client_debug()-> void:
	print ('/Client Player info : Linear velocity: ',linear_vel, "// Peer ID: ", get_tree().get_network_unique_id()) #for debug purposes only
