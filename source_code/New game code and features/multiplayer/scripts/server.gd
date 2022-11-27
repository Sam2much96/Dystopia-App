# *************************************************
# godot3-dystopia by Inhumanity_arts
# Released under MIT License
# *************************************************
# SERVER-SIDE CODE
#
# All the server  logics in one file!
# It also contains the world's logics *inhumanity
# Bugs:
# (1) It implements roll back netcode (depreciated)
# (2) Player Control affects both client and server player: use rpc_id to control player movement
# (3) Client player's movement is choppy, doesn't show animations (fixed)
# (4) Implement remote pfunctions for server player inputs (remote functions are used via nodes rpc calls)
# (5) Implement a separate player for the server

# (6) Send Player inputs via remote functions
# (7) Duplicate Input Functions btw Client and Server (Using ROll back netcode as a reference)
# (8) Does not work on open internet 
#		- Implement web socket client, server and webRTC
# (9) Include Matchmaking system
# *************************************************
extends Node

#my code
var player = {}

export (int) var state
var debug
#onready var Networking = GDScript.new()
#try and instance the outside scene and add a player

# Player info, associate ID to data
var player_info = {}

var delta_update = 0
var delta_interval = float(Networking.TICK_DURATION) * 0.001
#onready var server_camera = Camera2D.new()
onready var node_players = Node.new()#$Player
onready var node_projectiles #= $camera/projectiles #not needed
onready var node_enemies  = Node.new()#$Enemies

#.pop_front()

var preload_player = preload("res://scenes/characters/Aarin_networking.tscn") #spawn different players
var preload_enemy = preload("res://scenes/characters/Enemy.tscn") # spawn different enemies

var server_debug

var update_id = 0

onready var server = get_node("/root/world/Server")
	
func _ready():
	
	OS.set_window_title('Server') #renames the  app Window
	
	node_enemies.name = 'node_enemies'
	node_players.name = 'node_players'
	self.add_child(node_players)
	self.add_child(node_enemies)

	
	
	
	
	
	
	"WebRTC implementation"
	server.listen(Networking.SERVER_PORT) #port
	
	
	
	
	
	
	print (' Who is more Authoritative? the client or the server? ') #question?
	
	#adfadfadfa
	
	#print('Networking Camera: ' ,Networking.camera, 'Server Camera: ', server_camera) #for debug purposes only
	#print ('Networking world: ', Networking.world , 'Online world', self)
	
	print("Starting the server ...")
	print("Server port: " + str(Networking.SERVER_PORT))
	
	print("Max players: " + str(Networking.MAX_PLAYERS))
	
	# used for LAN Gaming

	#var peer = server.server
	#var peer = server.rtc_mp
	
	#var peer = 
	
	# used for onlie gaming
	#var peer = WebSocketServer.new()
	
	print ("websocket server: ", server.server) #websocket server
	
	
	#print(server.server.get_peer_address(server.peers.keys()[0]))
	
	# Debugs local server addresses. Does the job of a STUN server
	print ('IP: ' + str (Networking.cfg_server_ip) + ":" + str(Networking.SERVER_PORT))
	print ('LOCAL IP ADDRESSES: ',IP.get_local_addresses())
	print ('IP ADDRESSES: ',IP.get_local_interfaces())
	
	
	#print("Listening on port: " + str(Networking.SERVER_PORT)) # should be called on the webrtc code?

	#if peer.create_server(Networking.SERVER_PORT, Networking.MAX_PLAYERS) != OK: #used for lan, disabling for online multiplayer
	#	print("Unable to create server")
	#	return
	

	print (server.server.get_bind_ip())
	
	#print (peer.get_bind_ip())
	
	#peer.listen(Networking.SERVER_PORT, PoolStringArray(), true)
	
	
	

	# Connect the signals
	if get_tree().connect("network_peer_connected", self, "player_connected") != OK:
		print("Unable to connect signal (network_peer_connected) !")
		
	if get_tree().connect("network_peer_disconnected", self, "player_disconnected") != OK:
		print("Unable to connect signal (network_peer_disconnected) !")


	#Connect signals from the server node
	server.server.connect("client_connected",self, "player_connected")
	#check if signal is connected
	print ("my custom signal connected: ",server.server.is_connected("client_connected",self, "player_connected"))


func _input(_event):
	if Input.is_action_just_pressed("move_left"):
		server_debug()
	
	#handle_input()
	pass

func _process(delta):
	#print(player_info, state) #for debug purposes only
	#yield(get_tree().create_timer(3.5), "timeout"); print(player_info)
	
	
	for peer_id in player_info: #iterates over player info
		#print ('Server Pos',player_info[peer_id].pos)
	
	
		if player_info[peer_id].respawn_time != -999:
			player_info[peer_id].respawn_time -= delta
			if player_info[peer_id].respawn_time <= 0:
				
				player_info[peer_id].position = get_spawn_position()  #when first instanced to the scene


				player_info[peer_id].hitpoints = 3
				player_info[peer_id].respawn_time = -999
				player_info[peer_id].destroyed = false
				
				var node_player = preload_player.instance()
				print ('player instanced')
				player_info[peer_id].node = node_player
			
				var pos = Vector2(player_info[peer_id].position.x,player_info[peer_id].position.y)
				
				node_player.set_position(pos)
				node_player.show()
				node_player.set_process(true)
				
				node_player.name = player_info[peer_id].name #set name to player's name
				
				node_players.add_child(node_player)
				
				node_players.add_child(player_info[peer_id].node) #my code
				
				# Broadcast the new player to everyone
				for peer_id2 in player_info:
					rpc_id(peer_id2, "player_respawned", peer_id, player_info[peer_id])

	
func _physics_process(delta):
	#controls the playr's movements
	for peer_id in player_info: #player_info[peer_id].node is the player node. player_info stores player information

		#print (debug) #for debug purposes only
		if player_info[peer_id].destroyed: #rewrite to use despawned #add destroyed variable to the player script
			continue
		
		#var v = Vector2(0,0) #not needed
		if player_info[peer_id].node != null: #pass information from the player nodes
			#state =player_info[peer_id].node.state
			pass
		if player_info[peer_id].node.hitpoints == 0: #if playerhas no life
			player_info[peer_id].node.despawn()
			print('player/', player_info[peer_id], ' is dead') #

	
	#delta_update += delta breaks
	while delta_update >= delta_interval:
		delta_update -= delta_interval
		broadcast_world_positions()

#uses rpc to update player info
func broadcast_world_positions(): #calls the player update function on all clients
	#buggy
	
	for peer_id in player_info:
		for peer_id_2 in player_info:
			rpc_unreliable_id(peer_id, "pu", peer_id_2, update_id, player_info[peer_id_2].node.position, player_info[peer_id_2].node.hitpoints, player_info[peer_id_2].node.state, player_info[peer_id_2].node.facing)
			
	update_id += 1
	

"Broadcasts chat text to server and to all clients"
remote func broadcast_chat(text: String):
	
	#should send the text to all client chats
	for peer_id in player_info:
		print ("server chat:",text) #for debug purposes only
		
		rpc_id(peer_id,"chat_added", peer_id, player_info[peer_id], text)
	pass

#depreciated
func player_connected(id):
	print("Callback: server_player_connected: " + str(id))
	OS.set_window_title("Connected as " + str('server'))

func player_disconnected(id):
	print("Callback: server_player_disconnected: " + str(id))
	
	# Broadcast the "player_left" message to every other players
	for peer_id in player_info:
		rpc_id(peer_id, "player_leaving", id)

	# Erase player from player information array
	player_info[id].node.queue_free()
	player_info.erase(id) 
	
##note player_info[id] is how to call players

func get_spawn_position(): #Random Spawning Code
	
	var pos = Vector2(0,0)
	pos.x = rand_range(-950,950)
	pos.y = rand_range(-950,950)
	return pos





# Register a new player from client
remote func register_player(id, info): #rewrite this
	print("Remote: register_player(" + str(id) +","+str(info)+")")


##################################Gets information from player when first enters world#####################################
	info.position = get_spawn_position()  #calls a random spawnpoint in the world

	info.poss =Vector2()  #edit this
	info.killcount = Globals.kill_count
	info.state = state
	info.hitpoints = 3
	info.respawn_time = -999
	info.destroyed = false
#####################################################################################################
	# send list of previous players to the new one
	for peer_id in player_info:
		rpc_id(id, "player_joined", peer_id, player_info[peer_id]) #calls the player joined function on all clients
	
	
	var node_player = preload_player.instance()
	info.node = node_player

	var pos = Vector2(info.position.x,info.position.y) #position is player into position
	
	node_player.set_position(pos)
	node_player.show()
	node_player.set_process(true)
	
	node_player.name = info.name
	
	node_players.add_child(node_player) #adds child to the scene as a child of node-players
	
	# Store the information
	player_info[id] = info
	
	# Broadcast the new player to everyone
	for peer_id in player_info:
		rpc_id(peer_id, "player_joined", id, player_info[id])


# Handles player input from player script
remote func player_input_v2(peer_id ,state,facing,position, linear_vel):
	
	'Updates Server Player Info From Client player'
	player_info[peer_id].node.state = state
	player_info[peer_id].node.facing = facing
	player_info[peer_id].node.position = position
	player_info[peer_id].node.linear_vel = linear_vel
	
	
	pass

#Handles player movement from  received input from Clients via rpc calls

#remote functions can be called remotely via rpc calls
remote func player_input(id, pressed, client_position, client_state, linear_velocity, facing, animation): # #it receives player input through rpc
	#Remote Player Input Debugger
	#print("Remote: player_input(" + str(id)+","+key+","+str(pressed)+")") 

	#if key == "left": #sets player info from remote input
	#	player_info[id].node.facing = 'left'#sets player node to face left
	if pressed == true: #update player position in this code block
		
		#debugs info
		#player_input_debug(id, client_position, client_state, linear_velocity)
		
		#Run this code in physics process (does this work? kinda does)
		_process(_update_player_position_and_states(id,client_position, client_state,linear_velocity, facing, animation)) #updates player's motion and states
		
		
		#print ('Remote player Input is Pressed: ', pressed, 'Player Position: ',  player_info[id].node.position ) #for debug purposes only
		
		
	if  pressed == false: #it changes state but not position
		#player_info[id].node.animation.play('idle')
		
		pass


	
	
	


'#updates players states from the handle input function sent from clients'
#implement animation player
func _update_player_position_and_states(id,position ,state, linear_vel, facing, animation): 
	#works
	player_info[id].node.position = position #updates the player node's position to the client position
	player_info[id].node.state = state #updates player state to the client's state

	#doesnt work
	player_info[id].node.linear_vel = linear_vel #updates player state to the client's state
	
	#probably works
	player_info[id].node.move_and_slide(linear_vel) #This line of code works

	player_info[id].node.facing = facing

	player_info[id].node.animation.play(str(animation)) #plays client current animation
	pass

#server debug 1
#Depreciated
func player_input_debug(id, client_position, client_state, linear_velocity)-> void:
	#Debugs player position and State
	print ('Player  ID/////////',id)
	print ('Player  position/////////',client_position)
	print ('Player  state/////////',client_state)
	print ('Player  linear vel/////////',linear_velocity)


# server debug 2

func server_debug()-> void:
	print ("Server ID:", get_tree().get_network_unique_id())



