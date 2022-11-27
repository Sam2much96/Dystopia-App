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
# (3)  Remove player input from this client script and implement it in Player v2 script
# (4) Doesn't work on the open Internet
#		- Implement web socket client, server and webRTC ( done)
#		-cant create a networking peer
# *************************************************
extends Node

class_name Client

var client_debug 

var my_info = { name = "Player" }
var preload_player = preload("res://scenes/characters/Aarin_networking.tscn")
var node_player

var chat_text: String

var player_id #my code
var client_animation : String
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

#*******Player Items*************#
var facing

#*******Chat Item*************#
onready var chat = $UI/item_chat

onready var client = $Client

onready var state #im trying to send player state using rpc call and update it on the server using a remote funtion

#var PEER_ID
var ch1 #data channel
func _ready():
	OS.set_window_title('Client') 
	#sdgagdfasdfasdf
	#Handles Network Connectivity
	node_enemies.name = 'node_enemies'
	node_players.name = 'node_players'
	
	self.add_child(node_players)
	self.add_child(node_enemies)
	
	
	print (' Who is more Authoritative? the client or the server? ') #question?
	
	
	#lists all local ip addresses on Device # not needed, repurpose to a debug method
	print ('LOCAL IP ADDRESSES: ',IP.get_local_addresses())
	print ('IP ADDRESSES: ',IP.get_local_interfaces())
	
	print("Server IP       : " + Networking.cfg_server_ip)
	print("Port            : " , Networking.SERVER_PORT)
	print("Player Name     : " + Networking.cfg_player_name)
	print("Team Color : " + Networking.cfg_color)
	
	print("Connecting to server ...")
	

	

	

	client.start( Networking.cfg_server_ip + ":" + str(Networking.SERVER_PORT), "") # Networking.cfg_server_ip is buggy
	#client.start("ws://" + "ws://localhost" + ":" + str(Networking.SERVER_PORT), "")
	
	
	
	
	#var peer = NetworkedMultiplayerENet.new()
	var peer : WebRTCMultiplayer = client.rtc_mp #ive supplied the right connection type
	
	
	
	#client.client is websocket client 
	if client.rtc_mp.CONNECTION_CONNECTED:
		#var peer_id = peer.get_unique_id()

	#"Peer must be connecting or connected"
	
	#peer.add_peer(client.peer, client.peer_id)
		print (client.peer.get_connection_state() )
		print ("WebRTC Peer connection: ",client.peer )
		print ("Websocket client: ",client.client) #websocket client
		print ("Websocket peer: ",client.client.get_peer(1)) #websocket peer
		print ("Is connected to host: ",client.client.get_peer(1).is_connected_to_host() ) #websocket peer
		#print (client.client.get_peer(1).get_connected_host()  ) #websocket peer
		#print (client.client.get_peer(1).get_connected_port()  ) #websocket peer
	# Associate the current network peer to the tree
		if peer.initialize(1) != OK: push_error('cannot create peer')
		
		get_tree().set_network_peer(peer)
	
		print ("has network peer: ",get_tree().has_network_peer())
	
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

		

	"Upscale UI on mobile"
	if Globals.screenOrientation == 1: #Mobile screen orientation
		Globals.upscale__ui(chat, "XL")
		chat.set_position($UI/Position2D.position)
		pass




func _process(_delta):
	#client_debug()
	#print (client.peer.get_connection_state() )
	#****************** Debugs Data channel********************************************************************#
	var test = false
	if ch1 != null && test == true:
		if ch1.get_ready_state() == ch1.STATE_OPEN and ch1.get_available_packet_count() > 0:
			print("P1 received: ", ch1.get_packet().get_string_from_utf8())
	#print (ch1.get_ready_state())
	
	#**************************************************************************************#
	
	# To mitigate latency issues we use interpolation. The idea is simple, we receive
	# position updates every TICK_DURATION (50 ms, 20 per seconds). We interpolate between
	# the last two previous updates, this way we always have smooth movements. The
	# main drawback is added latency (100 ms).
	
	var target_timestamp = OS.get_ticks_msec() - (Networking.TICK_DURATION*2)
	



	#Handles Client Side Player Position Calculation
	#var peer_id = get_tree().get_network_unique_id()
	var peer_id = client.rtc_mp.get_unique_id() #works
	#print ('peer id debug : ', peer_id)
	
	if player_info.has(peer_id): #if player if has my peer id, position.x is player_info[peer_id] position
		pos.x = player_info[peer_id].node.position.x 
		pos.y = player_info[peer_id].node.position.y #updates vvarible with player's position

		state = player_info[peer_id].node.state
		hitpoints = player_info[peer_id].node.hitpoints
		#print (pos) #for debug purposes only
		#print ('Update ID: ',peer_id) #for debug purposes only
		
		player_info[peer_id].position = pos #updates the player's dicitonary with current player position 
		
		linear_vel = player_info[peer_id].node.linear_vel
		
		facing = player_info[peer_id].node.facing
		
		client_animation = player_info[peer_id].node.anim
		
		
		
		pass
	


	"Handle Input v 1"
	# Handle input (keyboard)
	#sends player input to server
	
	#disabling for debugging
	#handle_input() #Handle's Player's Input and sends it to the Servers
	
	

"Handle Input v 2" #moved to player script
remote func handle_player_input_and_state():
	pass


#reads the player node parameters
#works
#depreciated
func read_player_parameters()-> void:
	if node_player != null:
		print('Player state: ',node_player.state)
		print('Player animation: ',node_player.anim , client_animation)


'Makes calls to the Server to Process player input sent via rpc calls '
#it duplicates the player statemachine code and sends the player's parameters to the server
#via PU function
func handle_input(): #DUplicate player state machine input here
	
	# If not connected, don't handle input.
	if not my_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		return
		
	# if not currently playing, don't handle input too.
	if my_info == null:
		return
		
	# Send input events over network to the server
	var id = get_tree().get_network_unique_id()
	
	if (
		Input.is_action_pressed("move_down") or
		Input.is_action_pressed("move_left") or
		Input.is_action_pressed("move_right") or
		Input.is_action_pressed("move_up")
		):
			state = 2 #works--ish
			rpc_id(1,"player_input",id,true, pos, state, linear_vel, facing, client_animation)
			
			#read_player_parameters() works
	



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
	
	
	#node player is the instanced player node
	node_player = preload_player.instance()


	
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



remote func pu(id, update_id, pos, hitpoints, state, _facing): #try and use killcounts
	
	# Unreliable packets can be sent in wrong order, we only work with the latest
	# data available.
	#print ('//////Last update/////', last_update, '/////Update ID////' , update_id) for debug purposes only
	______update_id = update_id+1 #stores the update id
	if update_id < last_update: #update_id breaks the code here
		print("Received update in wrong order. Discarding!")
		return
		
	last_update = update_id
	
	'Updates the Client Details'
	
	player_info[id].updates[OS.get_ticks_msec()] = { position = pos, hitpoints = hitpoints,  state = state, facing = _facing } #update these variables to the server
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
	#chat.add_item(text)
	if chat.get_item_count() == 7:
		chat.remove_item(0)

	for i in range(0,chat.get_item_count()):
		chat.set_item_selectable(i,false)

# add chat via remote call
#sends data to server

	#Can only send poolbyte arrays
	client.client.get_peer(1).put_packet(text.to_utf8()) #works-ish. DIsabled for testing
	#my_peer.put_packet(("dgsgsdfgdfgdf" ).to_utf8())

"Adds chat item to all clients from server"
remote func chat_added(id, info, text):
	#print (my_peer, '/', id)
	#if not id == my_peer: #breaks client
	#player_info[id] = info #breaks client
	chat.add_item( text)

func display_damage(body):#rewrite this to instance blood fx

	print ('damage: ' , body)
	

#'what is a sync function'
#sync func test(id, info):
#	pass

func client_debug()-> void:
	print ('/Client Player info : Linear velocity: ',linear_vel, "// Peer ID: ", client.rtc_mp.get_peers(), ' State: ',state) #for debug purposes only
	print (client.rtc_mp)

"CHATS"
func _on_Chat_Button_pressed():
	var _text = $UI/LineEdit.text
	add_chat(_text)
