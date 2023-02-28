# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# 
# *************************************************
# All the client logics in one file!
# Needs Mesh network for peer to peer
# To Do:
# (1) Send Player inputs via remote functions
# (2) Duplicate Input Functions btw Client and Server (Using ROll back netcode as a reference)
# (3)  Remove player input from this client script and implement it in Player v2 script
# (4) Doesn't work on the open Internet
#		- Implement web socket client, server and webRTC ( done)
#		-cant create a networking peer (done, use WebRtcPeerConnection)
# (5) Implement NetworkingMultiplayer (fix ERROR: Condition "connection_status == CONNECTION_DISCONNECTED")

# *************************************************




extends Node


class_name Client


var status : int #............................# For debugging the webclient's connection status 
var status2 : int



var player_id : Array = []

export var autojoin = true
export var lobby = "" # Will create a new lobby if empty.

#web socket client
var web_client: WebSocketClient = WebSocketClient.new()
var code = 1000
var reason = "Unknown"

signal lobby_joined(lobby)
signal connected(id)
signal disconnected()
signal peer_connected(id)
signal peer_disconnected(id)
signal offer_received(id, offer)
signal answer_received(id, answer)
signal candidate_received(id, mid, index, sdp)
signal lobby_sealed()

var client_debug 

var my_info = { name = "Player" }
var preload_player = preload("res://scenes/characters/Aarin_networking.tscn")
var node_player

var chat_text: String

#var player_id #my code
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

#onready var client = $Client

onready var state #im trying to send player state using rpc call and update it on the server using a remote funtion

#var PEER_ID
var ch1 #data channel


var multiplayerAPI_peer = NetworkedMultiplayerENet.new()

#peer connection
var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()

#multiplayer
#open a data channel to send data using peer ID's
var rtc_mp: WebRTCMultiplayer = WebRTCMultiplayer.new()

var sealed = false


var debug_counter : int = 0


func _init():
	connecting_signals()




func connecting_signals()->void:
	#connect WebRTC signalling signals
	connect("connected", self, "connected")
	connect("disconnected", self, "disconnected")

	connect("offer_received", self, "offer_received")
	connect("answer_received", self, "answer_received")
	connect("candidate_received", self, "candidate_received")

	#connects peer joined and lobby joined signals
	connect("lobby_joined", self, "lobby_joined")
	
	#connect("lobby_sealed", self, "lobby_sealed") #disabled for debugging
	
	connect("peer_connected", self, "peer_connected")
	connect("peer_disconnected", self, "peer_disconnected")

	#Connects the Web Clients
	
	web_client.connect("data_received", self, "_parse_msg")
	web_client.connect("connection_established", self, "_connected")
	web_client.connect("connection_closed", self, "_closed")
	web_client.connect("connection_error", self, "_closed")
	web_client.connect("server_close_request", self, "_close_request")


	connect("lobby_joined", self, "_lobby_joined")
	
	
	connect("lobby_sealed", self, "_lobby_sealed")
	connect("connected", self, "_connected")
	connect("disconnected", self, "_disconnected")
	
	#Connect signals from WebRTCMultiplayer node
	
	rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	rtc_mp.connect("connection_succeeded", self, "_mp_connected")

	# Debug SIgnal connections

func connect_to_url(url):
	close()
	code = 1000
	reason = "Unknown"
	web_client.connect_to_url(url)
	


func close():
	web_client.disconnect_from_host()


func _closed(was_clean = false):
	emit_signal("disconnected")


func _close_request(code, reason):
	self.code = code
	self.reason = reason


func _connected(protocol = ""):
	web_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	if autojoin:
		join_lobby(lobby)

#parses all data packets put into the network
# implements a Regex based state machine
# Buggy
func _parse_msg():
	var pkt_str: String = web_client.get_peer(1).get_packet().get_string_from_utf8()

	var req: PoolStringArray = pkt_str.split("\n", true, 1)
	if req.size() != 2: # Invalid request size
		return

	var type: String = req[0]
	if type.length() < 3: # Invalid type size
		return

	if type.begins_with("J: "):
		emit_signal("lobby_joined", type.substr(3, type.length() - 3))
		return
	elif type.begins_with("S: "):
		emit_signal("lobby_sealed")
		return

	var src_str: String = type.substr(3, type.length() - 3)
	if not src_str.is_valid_integer(): # Source id is not an integer
		return

	var src_id: int = int(src_str)

	if type.begins_with("I: "):
		emit_signal("connected", src_id)
	elif type.begins_with("N: "):
		# Client connected
		emit_signal("peer_connected", src_id)
	elif type.begins_with("D: "):
		# Client connected
		emit_signal("peer_disconnected", src_id)
	elif type.begins_with("O: "):
		# Offer received
		emit_signal("offer_received", src_id, req[1])
	elif type.begins_with("A: "):
		# Answer received
		emit_signal("answer_received", src_id, req[1])
	elif type.begins_with("C: "):
		# Candidate received
		var candidate: PoolStringArray = req[1].split("\n", false)
		if candidate.size() != 3:
			return
		if not candidate[1].is_valid_integer():
			return
		emit_signal("candidate_received", src_id, candidate[0], int(candidate[1]), candidate[2])


func join_lobby(lobby):
	
	print ("-------sending joined Packet to peer")
	return web_client.get_peer(1).put_packet(("J: %s\n" % lobby).to_utf8())


func seal_lobby():
	return web_client.get_peer(1).put_packet("S: \n".to_utf8())


func send_candidate(id, mid, index, sdp) -> int:
	return _send_msg("C", id, "\n%s\n%d\n%s" % [mid, index, sdp])


func send_offer(id, offer) -> int:
	print ("-------sending offer")
	return _send_msg("O", id, offer)


func send_answer(id, answer) -> int:
	return _send_msg("A", id, answer)



#sends data to thr peer via webclient
func _send_msg(type, id, data) -> int:
	return web_client.get_peer(1).put_packet(("%s: %d\n%s" % [type, id, data]).to_utf8())


func _process(delta):
	
	# Logic controller for webclient connection status
	status = web_client.get_connection_status()
	if status == WebSocketClient.CONNECTION_CONNECTING:
		web_client.poll()
	if status == WebSocketClient.CONNECTION_CONNECTED:
		web_client.poll()
	if status == WebSocketClient.CONNECTION_DISCONNECTED:
		#push_error('disconected')
		return
	
	#connection successful
	if status == 2:
		#print ("webclient connected")
		web_client.poll()
	if status == 1:
		print ("webclient connecting")
	if status == 0:
		print ("webclient disconnected")
	#else: print ("WebClient Connection Status: ", status)
	
	
	status2 = peer.get_connection_state()
	
	# Logic controller for webMultiplayer connection status
	# uses a debug conter to stop printing overflow
	
	if status2 == 0:
		if debug_counter == 0:
			print ("""
			● STATE_NEW = 0
			The connection is new, data channels and an offer can be created in this state.

			""")
			debug_counter += 1

		return debug_counter 
	
	if status2 == 1:
		if debug_counter == 0:
			print ("""
			● STATE_CONNECTING = 1
			The peer is connecting, ICE is in progress, none of the transports has failed.

			""")
			debug_counter += 1
		
		return debug_counter
	if status2 == 2:
		
		print ("""
		● STATE_CONNECTED = 2
		The peer is connected, all ICE transports are connected..

		""")
		
		return
	if status2 == 3:
		print ("""
		● STATE_DISCONNECTED = 3
		At least one ICE transport is disconnected.

		""")

		
		
		return
	if status2 == 4:
		print ("""
		● STATE_FAILED = 4
		One or more of the ICE transports failed.

		""")


		return
	if status2 == 5:
		print ("""
		● STATE_CLOSED = 5
		The peer connection is closed (after calling close() for example).

		""")


		return
	

	
	
	#client_debug()
	#print (client.peer.get_connection_state() )
	
	
	#client.poll() #causes a bug
	
	
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
	var peer_id = rtc_mp.get_unique_id() #works
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

	rtc_mp.poll()
	while rtc_mp.get_available_packet_count() > 0:
		_log(rtc_mp.get_packet().get_string_from_utf8())



func start(url, lobby = ""):
	#stop()
	sealed = false
	self.lobby = lobby
	connect_to_url(url)
	print (" client connecting to " + url)

# temporarily disabling stop
func stop():
	rtc_mp.close()
	close()
	print ("stopping connection")

#called everytime a peer is connected from signals
#save the webrtc connection from this method
#peer is multiplayer api
func create_peer(id):
	print ("creating peer id")
	
	print ("webRTC peer connection: ",peer)
	
	
	
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.connect("session_description_created", self, "_offer_created", [id])
	peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])

	#saving these variables
	player_id.append(id)
	
	#peer is a webrtc connection
	#rtc_mp is the multiplayer architecture
	
	
	
	rtc_mp.add_peer(peer, id)
	
	
	
	if id > rtc_mp.get_unique_id():
		peer.create_offer()
	

	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	print ("--------------offer created---------")
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func connected(id):
	print("-----------Connected %d" % id)
	rtc_mp.initialize(id, true)
	
	#debug_rtc_mp()


func lobby_joined(lobby):
	self.lobby = lobby


func lobby_sealed():
	sealed = true


func disconnected():
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		#stop() # Unexpected disconnect
		pass


"Whenever a Peer Joins"
func peer_connected(id):
	print("-----------Peer connected %d" % id)

	#use rtc_MP depreciated
	#print("Created Multiplayer Client: ",create_multiplayer_client(Networking.BACKUP_HOSTNAME, web_client.get_connected_port()))

	create_peer(id)

	# my code starts from here
	#player_joined(id, '') #doesnt work

	#print("Created Multiplayer Client: ",create_multiplayer_client(str(web_client.get_connected_host()),web_client.get_connected_port()))
	 #IP


"Whenever a Peer Leaves"
func peer_disconnected(id):
	if rtc_mp.has_peer(id): rtc_mp.remove_peer(id)

	player_leaving(id)



func offer_received(id, offer):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


func answer_received(id, answer):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func candidate_received(id, mid, index, sdp):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)

# implemented from chatGPT
#Works-ish

func open_data_channel_to(channel: WebRTCPeerConnection, peer_id: int):
	#if status2 == 0:
	#var u= WebRTCDataChannel.new()
	#var p1 = WebRTCPeerConnection.new()
	# Placeholder Array, delete later
	var req : Array = ['1', '2']
	
	print ("------------Creating WebRTC Connection-----------")
	
	web_client.get_peer(1).put_packet(("O: %d\n%s" % [peer_id, req[1]]).to_utf8())

	var ch1 = channel.create_data_channel("chat", {"id": 1, "negotiated": true})

	channel.create_data_channel("chat", {"id": 1, "negotiated": true})
	print ("opening channel ", channel, " to Peer", peer_id ) # For debug purposes only
	
	
	var err = channel.create_offer()
	
	if err == OK:
		print ("offer created")
	else: push_error( "WebRTC connection error: " + str(err) )

		#ch1.put_packet(data)
	#if not status2 == 0 : return 0;




#onready var client = get_node("/root/world/Client")#$Client
#onready var client = Client #get_node("/root/world/Client")#$Client

func _ready():
	#print ('Client Main Logic: ',Client)#bug line remove
	
	
	


	UpscaleMobileUI()
	
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
	


	#_start() 
	start(Networking.cfg_client_ip + ":" + str(Networking.SERVER_PORT) , "")


	#var peer = NetworkedMultiplayerENet.new()
	var peer : WebRTCMultiplayer = rtc_mp #ive supplied the right connection type
	

	
	 
	if web_client.CONNECTION_CONNECTED:
		#var peer_id = peer.get_unique_id()

			#FIX THIS METHOD
		#print ('Data channel State:', client.peer.get_ready_state() )
		
		# Add a message to the chat box
		add_chat("Welcome to this network test!")
		add_chat("Connecting to server ....")
	#"Peer must be connecting or connected"
	
	
	
	
	
	#peer.add_peer(client.peer, client.peer_id)
		#print (peer.get_connection_state() ) # Invalid call. Nonexistent function 'get_connection_state' in base 'WebRTCMultiplayer'.
		print ("WebRTC Peer connection: ",peer )
		print ("MultiplayerENet connection: ",multiplayerAPI_peer )
		print ("Websocket client: ",web_client) #websocket client
		print ("Websocket peer: ",web_client.get_peer(1)) #websocket peer
		print ("Is connected to host 1: ", web_client.get_peer(1).is_connected_to_host() ) #websocket peer
		
		
		
		
		# Debug Peer connection state
	#if web_client.CONNECTION_CONNECTED:
		print ("Web Client Connected: ", web_client.CONNECTION_CONNECTED)
	
		#initialize resets the Network connection to a New State
		#disabling for testing



		"create a multiplayer peer here"


		#create_multiplayer_client()
		#rtc_MP already connected depreciated
		#print ("Cr8 Multiplayer client",create_multiplayer_client(Networking.cfg_client_ip, Networking.SERVER_PORT))
		

		#get_tree().set_network_peer(peer)
		#get_tree().set_network_peer(peer) #it's setting a webRTC connection as a peer. Which it shouldn't?
	
		#multiplayer network debug
		print ("has network peer: ",get_tree().has_network_peer())
		print ("is network server: ",get_tree().is_network_server())
		
		#print ("is network server: ",get_tree().set_multiplayer(rtc_mp))
	
		# Keep the current peer somewhere to differenciate between you and other players
		my_peer = peer
		
		# Connect signals
		if get_tree().connect("connected_to_server", self, "client_connected_ok") != OK:
			print("Unable to connect signal (connected_to_server) !")
			
		if get_tree().connect("connection_failed", self, "client_connected_fail") != OK:
			print("Unable to connect signal (connection_failed) !")
			
		if get_tree().connect("server_disconnected", self, "server_disconnected") != OK:
			print("Unable to connect signal (server_disconnected) !")


	if web_client.CONNECTION_DISCONNECTED:
		#print ("Is connected to host 2: ", peer.initialize(1) ) #websocket peer
		
		#print (client.client.get_peer(1).get_connected_host()  ) #websocket peer
		#print (client.client.get_peer(1).get_connected_port()  ) #websocket peer
	
	# Associate the current network peer to the tree
		#if peer.initialize(1) != OK: push_error('cannot create peer')
		
		print ("Web Client disConnected: ", web_client.CONNECTION_DISCONNECTED)
		
func __connected(id):
	_log("Signaling server connected with ID: %d" % id)


func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [code, reason])


func _lobby_joined(lobby):
	_log("Joined lobby %s" % lobby)
	debug_rtc_mp()


func _lobby_sealed():
	_log("Lobby has been sealed")


func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("Multiplayer peer %d connected" % id)


func _mp_peer_disconnected(id: int):
	_log("Multiplayer peer %d disconnected" % id)


func _log(msg):
	print(msg)
	#$VBoxContainer/TextEdit.text += str(msg) + "\n"


"Connect to buttons"
func ping():
	_log(rtc_mp.put_packet("ping".to_utf8()))


"Connect to buttons"
func peers():
	var d = rtc_mp.get_peers()
	_log(d)
	for k in d:
		_log(rtc_mp.get_peer(k))


"Backup Start Function "
func _start():
	start(Networking.cfg_client_ip + ":" + str(Networking.SERVER_PORT) , "")


func _on_Seal_pressed():
	seal_lobby()


func _stop():
	stop()




func UpscaleMobileUI()-> void:
	"Upscale UI on mobile"
	if Globals.screenOrientation == 1: #Mobile screen orientation
		Globals.upscale__ui(chat, "XL")
		chat.set_position($UI/Position2D.position)
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
	# reimplement networked multiplayer
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
	
	print ("sldkgsdgkbsglb Fix Chat Sub-system") 
	#chat.add_item(text)
	if chat.get_item_count() == 7:
		chat.remove_item(0)

	for i in range(0,chat.get_item_count()):
		chat.set_item_selectable(i,false)

# add chat via remote call
#sends data to server
	#data channel not open #to fix
	#peer = WebRTCPeerConnectionGDNative:2345

	# doesnt work. RTC_MP connection isnt established
	#open_data_channel_to(peer,1)
	
	debug_rtc_mp()
	
	send_data_to_webclient(text.to_utf8())
	



func send_data_to_webclient(data: PoolByteArray):
	"Sends Data to a peer"
	#Send poolbyte arrays
	# 
#	web_client.get_peer(1).put_packet(text.to_utf8()) #works-ish. 
	web_client.get_peer(1).put_packet(data) #works-ish. 


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
	print ('/Client Player info : Linear velocity: ',linear_vel, "// Peer ID: ", rtc_mp.get_peers(), ' State: ',state) #for debug purposes only
	print (rtc_mp)

"CHATS"
func _on_Chat_Button_pressed():
	var _text = $UI/LineEdit.text
	add_chat(_text)


func _on_peers_pressed():
	peers()


func _on_ping_pressed():
	ping()



func create_multiplayer_client(address : String, port)-> bool:
	#Networked Multiplayer Enet
	
	#Debug Connection Type
	#print ("Multiplayer Node Type:", multiplayerAPI_peer)
	
	
	#multiplayerAPI_peer.set_bind_ip(ip)
	
	print ("Connecting ENet to: ", address)
	
	# Associate the current network peer to the tree
	var err = multiplayerAPI_peer.create_client(address,port)
	
	if err == OK:
		
		get_tree().set_network_peer(multiplayerAPI_peer)
		return true
	else : 
		push_error("Networking Enet Error: " + str(err))
		return false

	
func debug_rtc_mp()-> void:
		# write a state machine bloc to debug rtc_mp
	
	print ("Web RTC Multiplayer Peers: ",rtc_mp.get_peers()) #shows all multiplayer peers
	print ("Web RTC Multiplayer disconnected: ",rtc_mp.CONNECTION_DISCONNECTED) #2


func _on_do_something_pressed():
	debug_counter = 0
	open_data_channel_to(peer,1)
	debug_rtc_mp()
