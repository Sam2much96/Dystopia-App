extends Node


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
#		- Implement web socket client, server and webRTC *Done, Debugging)
# (9) Include Matchmaking system
# (10) Organizing codebase into classes for better readablility
# *************************************************

class_name Server

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

#onready var _server = Server #get_node("/root/world/Server")

#creating a server class
#onready var t : Server = Server.new()

	
#line 234

var multiplayerAPI_peer = NetworkedMultiplayerENet.new()




const TIMEOUT = 1000 # Unresponsive clients times out after 1 sec
const SEAL_TIME = 10000 # A sealed room will be closed after this time
const ALFNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

var _alfnum = ALFNUM.to_ascii()

var rand: RandomNumberGenerator = RandomNumberGenerator.new()
var lobbies: Dictionary = {}
var server: WebSocketServer = WebSocketServer.new()
var peers: Dictionary = {}

class Peer extends Reference:
	var id = -1
	var lobby = ""
	var time = OS.get_ticks_msec()

	func _init(peer_id):
		id = peer_id



class Lobby extends Reference:
	var peers: Array = []
	var host: int = -1
	var sealed: bool = false
	var time = 0


	func _init(host_id: int):
		host = host_id

	func join(peer_id, server) -> bool:
		if sealed: return false
		if not server.has_peer(peer_id): return false
		var new_peer: WebSocketPeer = server.get_peer(peer_id)
		new_peer.put_packet(("I: %d\n" % (1 if peer_id == host else peer_id)).to_utf8())
		for p in peers:
			if not server.has_peer(p):
				continue
			server.get_peer(p).put_packet(("N: %d\n" % peer_id).to_utf8())
			new_peer.put_packet(("N: %d\n" % (1 if p == host else p)).to_utf8())
		peers.push_back(peer_id)
		return true


	func leave(peer_id, server) -> bool:
		if not peers.has(peer_id): return false
		peers.erase(peer_id)
		var close = false
		if peer_id == host:
			# The room host disconnected, will disconnect all peers.
			close = true
		if sealed: return close
		# Notify other peers.
		for p in peers:
			if not server.has_peer(p): return close
			if close:
				# Disconnect peers.
				server.disconnect_peer(p)
			else:
				# Notify disconnection.
				server.get_peer(p).put_packet(("D: %d\n" % peer_id).to_utf8())
		return close


	func seal(peer_id, server) -> bool:
		# Only host can seal the room.
		if host != peer_id: return false
		sealed = true
		for p in peers:
			server.get_peer(p).put_packet("S: \n".to_utf8())
		time = OS.get_ticks_msec()
		return true


class WebServer extends Reference:

	func _init():
		"connect server signals"
		
		# connect signals from another codebloc
		


	func connect_signals(server : WebSocketServer )->void:
		#when data is received
		server.connect("data_received", self, "_on_data")
		
		#when a peer connects and Disconnects
		server.connect("client_connected", self, "_peer_connected")
		server.connect("client_disconnected", self, "_peer_disconnected")

		#duplicate?
		#Connect signals from the server node
		server.connect("client_connected",self, "player_connected")

		# Connect the signals
		# Debug the signals
		#if get_tree().connect("network_peer_connected", self, "player_connected") != OK:


		#buggy connections
	#	if not is_connected("network_peer_connected", self, "player_connected"):

	#		get_tree().connect("network_peer_connected", self, "player_connected")
		
	#	if not is_connected("network_peer_disconnected", self, "player_disconnected"):
	#		get_tree().connect("network_peer_disconnected", self, "player_disconnected") 
		
		
	#	if get_tree().connect("network_peer_disconnected", self, "player_disconnected") != OK:
	#		print("Unable to connect signal (network_peer_disconnected) !")

		#check if signal is connected
		print ("my custom signal connected: ", server.is_connected("client_connected",self, "player_connected"))




func _process(delta):
	poll()
	
	
	
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



func listen(server : WebSocketServer,_IP,port):
	stop()
	rand.seed = OS.get_unix_time()
	server.set_bind_ip(_IP)
	server.listen(port, PoolStringArray([]), false)
	print ("server listening on port: ", str(port)) 



func stop():
	server.stop()
	peers.clear()


func poll():
	if not server.is_listening():
		return

	server.poll()

	# Peers timeout.
	for p in peers.values():
		if p.lobby == "" and OS.get_ticks_msec() - p.time > TIMEOUT:
			server.disconnect_peer(p.id)
	# Lobby seal.
	for k in lobbies:
		if not lobbies[k].sealed:
			continue
		if lobbies[k].time + SEAL_TIME < OS.get_ticks_msec():
			# Close lobby.
			for p in lobbies[k].peers:
				server.disconnect_peer(p)

#connected from websocket server
func _peer_connected(id, protocol = ""): #works
	print ('peer connected')
	peers[id] = Peer.new(id)

	#Genneric peer debug
	print ('Peer id: ',id) 
	print ("Connected Players: ",peers.size())
	print ("ALL Players ID ",peers.keys())
	print ("My Players ID ",peers.keys()[0])
	print ("peer address: ",server.get_peer_address(id))
	print ("peer port: ",server.get_peer_port(id))
	
	#************************************************************************************#
	#peers is a dictionary
	print ("Websocket peer: ",server.get_peer(id))
	
	
	#create multiplayer peer here
	
	
	
	
	var rtc_mp : WebRTCMultiplayer = WebRTCMultiplayer.new()
	#peer connection
	var peer_connection: WebRTCPeerConnection = WebRTCPeerConnection.new() #rjkehrj
	#debug multiplayer API
	
	
	if rtc_mp.CONNECTION_CONNECTED:
	
		#print("Server peer connection state : ",peer.get_connection_state())
		
		#rtc_mp.add_peer(peer, id)
		
		#Debug rtc_mp connection state and open data channel
		rtc_mp.initialize(id)

		print("set network peer: ",get_tree().set_network_peer(rtc_mp)) #testing websocket client multipplayer

		print ('has network peer : ',get_tree().has_network_peer())
		#rtc_mp must be connecting or connected
		if get_tree().set_network_peer(rtc_mp) != OK: #unable to set network peer on the server
			print("Unable to set network peer!")

	
	#if get_tree().set_network_peer(peer) != OK: #unable to set network peer on the server
	#	print("Unable to set network peer!")
#*******************************************************************************************#

#disabled for debugging
#	create_multiplayer_server(5000, Networking.MAX_PLAYERS)



func _peer_disconnected(id, was_clean = false):
	var lobby = peers[id].lobby
	print("Peer %d disconnected from lobby: '%s'" % [id, lobby])
	if lobby and lobbies.has(lobby):
		peers[id].lobby = ""
		if lobbies[lobby].leave(id, server):
			# If true, lobby host has disconnected, so delete it.
			print("Deleted lobby %s" % lobby)
			lobbies.erase(lobby)
	peers.erase(id)


func _join_lobby(peer, lobby) -> bool:
	if lobby == "":
		for _i in range(0, 32):
			
			#calculates the lobby name
			lobby += char(_alfnum[rand.randi_range(0, ALFNUM.length()-1)])
		lobbies[lobby] = Lobby.new(peer.id)
	elif not lobbies.has(lobby):
		return false
	lobbies[lobby].join(peer.id, server)
	peer.lobby = lobby
	# Notify peer of its lobby
	server.get_peer(peer.id).put_packet(("J: %s\n" % lobby).to_utf8())
	
	#peer id and lobby name
	print("Peer %d joined lobby: '%s'" % [peer.id, lobby])
	return true

"when data is received from client"
func _on_data(id): #works-ish
	print ("data received")
	if not _parse_msg(id):
		print("Parse message failed from peer %d" % id)
		
		#determine what data it is
		#send positional data
		
		
		
		#disabling for testing
		#print ('Disconnecting peer from server')
		#server.disconnect_peer(id)

#client and server are connected via udp
func _parse_msg(id) -> bool:
	var pkt_str: String = server.get_peer(id).get_packet().get_string_from_utf8()

	"REGEX State Machine for Handling All Packets sent via webclient"
	# Uses types and maps them to actions

	print ("Packet from client: ",pkt_str)

	var req = pkt_str.split("\n", true, 1)
	if req.size() != 2: # Invalid request size
		return false

	var type = req[0]
	if type.length() < 3: # Invalid type size
		return false

	if type.begins_with("J: "):
		if peers[id].lobby: # Peer must not have joined a lobby already!
			return false
		return _join_lobby(peers[id], type.substr(3, type.length() - 3))

	if not peers[id].lobby: # Messages across peers are only allowed in same lobby
		return false

	if not lobbies.has(peers[id].lobby): # Lobby not found?
		return false

	var lobby = lobbies[peers[id].lobby]

	if type.begins_with("S: "):
		# Client is sealing the room
		return lobby.seal(id, server)

	var dest_str: String = type.substr(3, type.length() - 3)
	if not dest_str.is_valid_integer(): # Destination id is not an integer
		return false

	var dest_id: int = int(dest_str)
	if dest_id == NetworkedMultiplayerPeer.TARGET_PEER_SERVER:
		dest_id = lobby.host

	if not peers.has(dest_id): # Destination ID not connected
		return false

	if peers[dest_id].lobby != peers[id].lobby: # Trying to contact someone not in same lobby
		return false

	if id == lobby.host:
		id = NetworkedMultiplayerPeer.TARGET_PEER_SERVER


	"Connecting with webrtc_mp"

	if type.begins_with("O: "):
		
		print ("////",id, req[1])# for debug purposes only
		# Client is making an offer
		server.get_peer(dest_id).put_packet(("O: %d\n%s" % [id, req[1]]).to_utf8())
	elif type.begins_with("A: "):
		# Client is making an answer
		server.get_peer(dest_id).put_packet(("A: %d\n%s" % [id, req[1]]).to_utf8())
	elif type.begins_with("C: "):
		# Client is making an answer
		server.get_peer(dest_id).put_packet(("C: %d\n%s" % [id, req[1]]).to_utf8())
	return true



func _ready():
	
	OS.set_window_title('Server') #renames the  app Window
	
	node_enemies.name = 'node_enemies'
	node_players.name = 'node_players'
	self.add_child(node_players)
	self.add_child(node_enemies)

	
	WebServer.connect_signals(server)
	
	
	
	
	"WebRTC implementation"
	WebServer.listen(Networking.cfg_server_ip,Networking.SERVER_PORT) #port
	#listen(Networking.SERVER_PORT) #port
	
	
	# NEtworking ENet
	create_multiplayer_server(Networking.SERVER_PORT,Networking.MAX_PLAYERS)
	
	
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
	
	print ("websocket server: ", server) #websocket server
	
	print ("Websocket Bind IP: ", server.get_bind_ip() )
	
	#print(server.server.get_peer_address(server.peers.keys()[0]))
	
	# Debugs local server addresses. Does the job of a STUN server
	print ('IP: ' + str (Networking.cfg_server_ip) + ":" + str(Networking.SERVER_PORT))
	print ('LOCAL IP ADDRESSES: ',IP.get_local_addresses())
	print ('IP ADDRESSES: ',IP.get_local_interfaces())
	
	
	#print("Listening on port: " + str(Networking.SERVER_PORT)) # should be called on the webrtc code?

	#if peer.create_server(Networking.SERVER_PORT, Networking.MAX_PLAYERS) != OK: #used for lan, disabling for online multiplayer
	#	print("Unable to create server")
	#	return
	

	print (server.get_bind_ip())
	
	#print (peer.get_bind_ip())
	
	#peer.listen(Networking.SERVER_PORT, PoolStringArray(), true)
	
	


	print ("MultiplayerENet connection: ",multiplayerAPI_peer )

func _input(_event):
	if Input.is_action_just_pressed("move_left"):
		server_debug()
	
	#handle_input()
	pass

#func _process(delta):
	#print(player_info, state) #for debug purposes only
	#yield(get_tree().create_timer(3.5), "timeout"); print(player_info)
	
	
	
	
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



#doesnt work yet
#gfgsfglkdsfglkdf
func create_multiplayer_server(port : int, MAX_PLAYERS: int)-> void:
	#get your client and server ports
	#var port: int
	#var MAX_PLAYERS: int
	
	
	# Associate the current network peer to the tree
	var err = multiplayerAPI_peer.create_server(port,MAX_PLAYERS)
	
	if err == OK:
		
		get_tree().set_network_peer(multiplayerAPI_peer)
		#return true
	else : 
		push_error("Networking Enet Error: " + str(err))
		#return false
	
	
	if multiplayerAPI_peer.create_server(port, MAX_PLAYERS) != OK:
		print("Unable to create multiplayer server")
		return

		if get_tree().set_network_peer(multiplayerAPI_peer) != OK:
			print("Unable to set network peer!")
	
	# Connect the signals
	if get_tree().connect("network_peer_connected", self, "player_connected") != OK:
		print("Unable to connect signal (network_peer_connected) !")
		
	if get_tree().connect("network_peer_disconnected", self, "player_disconnected") != OK:
		print("Unable to connect signal (network_peer_disconnected) !")
