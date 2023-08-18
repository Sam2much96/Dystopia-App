# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a auto-included  Custom singleton containing
# information used by the client and server codes.
# also used as a networking node singleton
# Bugs
# (1) Singleton's start and stop state is not properly defined
# 
# ************************************************* 
# Contains Logic for querying internet access. Used by Game Form
# ************************************************* 
# Features to Add
# (1) Smart contract implementation using GDteal and Algodot (done)
# (2) Multiplayer lobby room logic And Client and Server Netcodes (Done)
# (3) Youtube Download Streamer Logic impementation (1/3 using godot-rustube)
# (4) Proper Documentation (done)
# (5) Run an online for PC and mobile Devices. The Hardware is available now (Done)
# (6) Implement Rollback NetCodes for Multiplayer Gameplay (Depreciated)
# (7) Video Downloaders
# (8) Downloads several files
# (9) Regex parser for IPFS (Done)



extends HTTPRequest

class_name Internet

"""
NETWORKING SINGLETON 4.0

To query if there's internet access and connect to various websites
"""
export (bool) var enabled
export(String) var connection_debug
export (String) var cfg_server_ip 
export (String) var cfg_client_ip 
#########################  Web browser codes  ############################3
var url : String = ''
var check_timer 
var debug = ''

# Default hostname used by the login form
#const DEFAULT_HOSTNAME = "127.0.0.1"
const DEFAULT_HOSTNAME = "ws://localhost"

const BACKUP_HOSTNAME = "127.0.0.1"
# should store Non-threathening Crypto and Multiplayerinfo too
# Data Integrity can be checked using hash
# Stores Data FOr Synchronizing Player Data Among Multiple Peers
# SHould be converted to Json before sent over Network
var player_info : Dictionary = {
	"peer id": {},
	"hitpoints" : {},
	"facing": {},
	"roll dir": {},
	"updates":{},  # Stores Present Update ID Across All Clients
	"wallet addr": {},
	"asset id": {},
	"smart contract": [], # Arrays As it will only be one Smart COntract
	"kill Count": {},
	"inventory": {},
	"hash": [] # Arrays because hash data is discarded eventually
	} 

var camera #stores general camera variables
###############################multiplayer codes########################
# Debugs to Debugger Singleton
var multiplayer_client_debug
var multiplayer_server_debug

# Those variables are only used by the client-side application

var cfg_color = ""
var cfg_player_name = ""





signal connection_success
signal error_connection_failed(code,message)
signal error_ssl_handshake


onready var world #= get_tree().get_nodes_in_group('online_world').pop_front()

onready var WORLD_SIZE = 40000.0
onready var _reference_to_self =get_node('/root/Networking') #formerly _y


const SERVER_PORT = 9080
const MAX_PLAYERS = 5

const TICK_DURATION = 50 # In milliseconds, it means 20 network updates/second


onready var timer :Timer  = $Timer2


#var youtube_dl # Replace with GodotRustube


#**********Helper Booleans***********#
var running_request : bool = false
var Timeout : bool = false


#*********IPFS Gateway***************#
# from https://ipfs.github.io/public-gateway-checker/
# 1 ,2 , 3 work
var gateway : Array = ['gateway.ipfs.io', "dweb.link", "ipfs.io","ipfs.runfission.com", "jorropo.net", "via0.com", "cloudflare-ipfs.com", "hardbin.com"]
var random : int
var selected_gateway : String

var good_internet : bool

# Lobby UI
var UserInterface : Control

# Multiplayer map
var map_instance

func _ready():
	_init_timer()
	
	
	if cfg_server_ip == '':
		cfg_server_ip = DEFAULT_HOSTNAME
		
	if cfg_client_ip == '':
		cfg_client_ip = DEFAULT_HOSTNAME
		
	
	print ("Networking Server Config and Player Name: ",cfg_server_ip,cfg_player_name, "/")
	
	


func _process(_delta): 

	debug = ( str(connection_debug)  + str (multiplayer_server_debug) + str(multiplayer_client_debug)) # Debugs the Networking and Multiplayer states



	"Checks Nodes Connections"
	for child in _reference_to_self.get_children():
		if child is Timer:
			check_timer = child
			if not child.is_connected("timeout",self, '_check_connection') :
				child.connect("timeout",self, '_check_connection') # connects timeout signal to check connection 
		if child is HTTPRequest:
#checks connection status -> Force connect HTTP request's signals
			if child.is_connected("connection_success",self, '_on_success') != true:
				return connect("request_completed", self,'on_request_result')
		
				return connect("connection_success",self, '_on_success')
				return connect("error_connection_failed",self,'_on_failure')
				return connect("error_ssl_handshake",self, '_on_fail_ssl_handshake')

 
# Creates a Networking timer
func _init_timer() : 
	#Uses a Timer Node in the Scene
	self.set_process(true)
	enabled = true 
	check_timer = timer
	check_timer.wait_time = 5
	
	# connect timer timeout signal
	"Updates the Networking Boolean of Timer State"
	if not timer.is_connected("timeout",self, "_on_Timer2_timeout"):
		timer.connect("timeout",self, "_on_Timer2_timeout")
	
	print ('Check_timer :' , check_timer, " Is connected: ", timer.is_connected("timeout",self, "_on_Timer2_timeout")) #code breaks here and gives cant resolve hostname errors
	


"Stops a check using Check timer Node"
func stop_check()-> bool: #Stops timer check
	connection_debug = ' stop check ' # Debug Variable
	if not check_timer.is_stopped():
		
		
		check_timer.stop()
		self.cancel_request()
		
		#Stopping Check Timer
		print ('Stopping Check Timer')
		return false
	else: return true


"Starts a check using Timer Node for 3 Seconds"
func start_check(time: int): 
	connection_debug = str('start check') # Debug Variable
	Timeout = false
	if time != null:
		check_timer.start(time) 
	
	# Reset Timeout parameter
	#
	check_timer.start()

# Check http unsecured Url connection
# fix multiple check bug
static func _check_connection(url, request_node: HTTPRequest): 
	#Ignore Warning
	#Request Node must be in the SceneTree
	print  ("Is Request Noode inside scene tree:", request_node.is_inside_tree())
	var error = request_node.request(url,PoolStringArray(),false,0,"") 
	print (' Networking Request Error: ',error) #for debug purposes only


func _check_connection_secured(url): # Check http secured Url connection
	#Ignore Warning
	url =url.http_escape()
	var error = .request(url,PoolStringArray(),false,HTTPClient.METHOD_GET) 
	connection_debug = str (' making request  ')  + str (' Request Error: ',error)
	print (' Networking Request Error: ',error) #for debug purposes only


func genrate_random_gateway():
	randomize()
	random = int(rand_range(-1,gateway.size())) #selects a random track number
	selected_gateway = gateway[random]

# List of valid IPFS web 2.0 Gateways
# An array may be a better fit
#https://ipfs.github.io/public-gateway-checker/
static func _connect_to_ipfs_gateway(parse : bool, url : String, selected_gateway: String ,request_node: HTTPRequest): # Check http secured Url connection
	#Ignore Warning
	
		# parse Url
		if parse:
			url = _parse(url) 
		

		# uses ipfs web 2 gateway Array
		
		
		url = "https://" + selected_gateway + "/ipfs/" + url
		
		#print ("NFT Url: ",url) #for debug purposes only
		
		var t=StreamPeerSSL.new()
	
		var error = request_node.request(url,PoolStringArray(),false,HTTPClient.METHOD_GET) 
		 
		print (' Networking Request Error: ',error) #for debug purposes only
		print ("Final Url: ", url)
		return



'Removes IPFS Domain from Asset url'
static func _parse(_url : String)-> String: #works
	_url=_url.replace('ipfs://', '')
	#print (_url) # for debug purposes only
	return _url


'Internet COnnectivity Check'
static func _check_if_device_is_online(node: HTTPRequest):
	
	_check_connection('https://mfts.io', node)



func on_request_result(result, response_code, headers, body): # I need to pass variables to this code bloc
	"HTTP REQUEST RESULT'S STATE MACHINE"
	#resets result if completed successfully
	running_request = false
	#connected to results and works as an auto emitter
	match result:
		RESULT_SUCCESS: #what happens to body? #always write a http request cmpleted function in the connecting script
			emit_signal("connection_success") 
			#_connection =(str ('connection success')) # Debugs to the Debug singleton # Depreciated--Delete
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body))  
		RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			emit_signal("error_connection_failed", RESULT_CHUNKED_BODY_SIZE_MISMATCH,'RESULT_CHUNKED_BODY_SIZE_MISMATCH')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CANT_CONNECT:
			emit_signal("error_connection_failed",RESULT_CANT_CONNECT,'RESULT_CANT_CONNECT')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CANT_RESOLVE:
			emit_signal("error_connection_failed",RESULT_CANT_RESOLVE,'RESULT_CANT_RESOLVE')
			#_connection = (str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CONNECTION_ERROR:
			emit_signal("error_connection_failed",RESULT_CONNECTION_ERROR,'RESULT_CONNECTION_ERROR')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_SSL_HANDSHAKE_ERROR:
			emit_signal("error_ssl_handshake")
			#_connection = (str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_NO_RESPONSE:
			emit_signal("error_connection_failed",RESULT_NO_RESPONSE,'RESULT_NO_RESPONSE')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			emit_signal("error_connection_failed", RESULT_BODY_SIZE_LIMIT_EXCEEDED,'RESULT_BODY_SIZE_LIMIT_EXCEEDED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_REQUEST_FAILED:
			emit_signal("error_connection_failed", RESULT_REQUEST_FAILED, 'RESULT_REQUEST_FAILED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) 
		RESULT_DOWNLOAD_FILE_CANT_OPEN:
			emit_signal("error_connection_failed",RESULT_DOWNLOAD_FILE_CANT_OPEN,'RESULT_DOWNLOAD_FILE_CANT_OPEN')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) 
		RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			emit_signal("error_connection_failed", RESULT_DOWNLOAD_FILE_WRITE_ERROR, 'RESULT_DOWNLOAD_FILE_WRITE_ERROR')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) 
		RESULT_REDIRECT_LIMIT_REACHED:
			emit_signal("error_connection_failed",RESULT_REDIRECT_LIMIT_REACHED, 'RESULT_REDIRECT_LIMIT_REACHED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) 
	#stop_check() # Disabled
	
	
func _on_success():
	print('connection success!!')
	#_connection = str ('connection success!!') # Debug Variable # Depreciated--Delete
	

func _on_failure(code, message):
	print('Connection Failure !!\nCode: ', code,"Message:", message)
	#_connection = str ('connection failed!!') # Debug Variable # Depreciated--Delete


func _on_fail_ssl_handshake():
	print('SSL Handshake Error!!')
	#_connection = str ('ssl handshake error!!') # Debug Variable # Depreciated--Delete

'Downloads a Json file and Stores it Locally'
#consider running 2 operations here. A read operation and a write operation
func download_json_(body: PoolByteArray, Save_path: String) -> File:
	var json = File.new()
	var cunt = []
	if body != null:
		
		print ("Loading Json--------", ( get_body_size()), " bytes")# wprks # for debug purposes 
		
		
		json.open((Save_path +".json"), File.WRITE )
		
		while not json.get_len() > get_body_size() : #kinda works
			cunt = body.get_string_from_utf8() #works with local storage
			
			json.store_line(str(cunt)) #works
			if json.get_len() == get_body_size(): break #works perfectly
			

		json.close()  
		# it's sending the data across the network, but its not decoding it properly                                           
		var data = get_downloaded_bytes()
		print ("data: ",data)
		if data == 0 :
			print("Download failed. Problem with the Server side Networking connection")
		elif data != 0:
			print ('json download successful: ',data, '/bytes') #works
		#print ("cunt debug: ",cunt) #for debug purposes only
		return json
	if body == null:
		push_error("Problem fetching json download")
	return json

"""
download a given image from a given http request
returns a PNG texture file, saves image file
"""
static func download_image_(body: PoolByteArray, Save_path: String, node : HTTPRequest) -> ImageTexture:
	var image = Image.new()
	var texture = ImageTexture.new()
	
	if body != null:
		var image_error = image.load_png_from_buffer(body)
		if image_error != OK:
			push_error("An error occurred while trying to display the image.")
		elif image_error == OK:
			"Save File locally"
			var local_tex =File.new()
			local_tex.open((Save_path +".png"), File.WRITE)
			
			
			
			
			while not node.get_downloaded_bytes() > node.get_body_size() && local_tex.eof_reached() == false: #causes a large file bug, generates a 3gb file
				print ("Loading Image--------", ( node.get_body_size()/1000), " kb") # for debug purposes 
				local_tex.store_buffer(body) #stores image locally
				#if local_tex.eof_reached() == true: #causes a significant lag
				if node.get_downloaded_bytes() == node.get_body_size(): #causes a significant lag
					local_tex.close()
					break
			print ("Image Download Successful")
			texture.create_from_image(image)
			"returns an image texture"
			return texture 
		return texture
	if body == null:
		push_error("Problem fetching image download")
	return texture

'Downloads A File and Stores it Locally'
#consider running 2 operations here. A read operation and a write operation
# works
static func download_file_(node : HTTPRequest,body: PoolByteArray, Save_path: String, file_type: String) -> File:
	var file = File.new()
	#var cunt = []
	if body != null:
		
		print ("Loading ",file_type, "--------", ( node.get_body_size()), " bytes")# wprks # for debug purposes 
		print("Downloaded bytes-------",node.get_downloaded_bytes())
		# Should be .zip or .json for different file types
		# SHould ideally contain a check for verifying the contents of the file type string
		#file.open_compressed((Save_path + file_type), File.WRITE, File.COMPRESSION_GZIP )
		file.open((Save_path + file_type), File.WRITE )
		
		while not node.get_downloaded_bytes() > node.get_body_size() && file.eof_reached() == false:
		
		
			file.store_buffer(body)
			
			if node.get_downloaded_bytes() == node.get_body_size(): #causes a significant lag
					file.close()
					break 
		
		if file.eof_reached(): file.close()
		
		# it's sending the data across the network, but its not decoding it properly                                           
		var data = node.get_downloaded_bytes()
		print ("data: ",data)
		if data == 0 :
			print("Download failed. Problem with the Server side Networking connection")
		elif data != 0:
			print ('json download successful: ',data, '/bytes') #works
		#print ("cunt debug: ",cunt) #for debug purposes only
		return file
	if body == null:
		push_error("Problem fetching json download")
	return file



'Saves A File and Stores it Locally'
#consider running 2 operations here. A read operation and a write operation
# works
static func save_file_(body: PoolByteArray, Save_path: String, file_size: int) -> File:
	var file = File.new()
	
	var Dir = Directory.new()
	
	if body != null : # && !Dir.file_exists(Save_path):
		
		#print ("Loading ",file_type, "--------", ( node.get_body_size()), " bytes")# wprks # for debug purposes 
		#print("Downloaded bytes-------",node.get_downloaded_bytes())
		# Should be .zip or .json for different file types
		# SHould ideally contain a check for verifying the contents of the file type string
		#file.open_compressed((Save_path + file_type), File.WRITE, File.COMPRESSION_GZIP )
		
		
		file.open((Save_path ), File.WRITE )
		
		#while not node.get_downloaded_bytes() > node.get_body_size() && file.eof_reached() == false:
		print ("storing file to ", Save_path)
		
		while not file.get_len() > file_size:
			file.store_buffer(body)
			
			if file.get_len() == file_size:
				file.close()
				break 
		
		if file.eof_reached(): file.close()
		
		# it's sending the data across the network, but its not decoding it properly                                           
		#var data = node.get_downloaded_bytes()
		#print ("data: ",data)
		#if data == 0 :
		#	print("Download failed. Problem with the Server side Networking connection")
		#elif data != 0:
		#	print ('json download successful: ',data, '/bytes') #works
		##print ("cunt debug: ",cunt) #for debug purposes only
		#return file
	if body == null:
		push_error("Problem fetching file to save")
	return file


func _on_Timer2_timeout():
	print ('check timer stopped')
	Timeout = true
	Comics_v6.SwipeLocked = false#!Comics_v6.SwipeLocked
	stop_check()

"""
MULTIPLAYER SIGNALS
"""
# Executes Multiplayer Logic In the Lobby Class
func _server_disconnected(_id : int):
	Lobby._on_server_disconnected(_id, get_tree(), UserInterface)

func _player_disconnected(_id : int):
	 # _id, Lobby: SceneTree, UI : Control)
	Lobby._on_player_disconnected(_id, get_tree(), UserInterface)
	

func _player_connected(_id : int):
	# Calls Player Logic in the Lobby Class
	# Method is called with the Noe's Unique ID
	# Idenftifying the player. This ID Should Be Saved
	
	Networking.player_info["peer id"] = _id
	
	OS.set_window_title('Client' + str(_id))
	 
	"Starts Game"
	
	Globals.current_level = "res://scenes/levels/Testing Scene.tscn"
	# Someone connected, start the game!
	var Map : PackedScene = Globals.Functions.LoadLargeScene(
		Globals.current_level, 
		Globals.scene_resource, 
		Globals._o, 
		Globals.scene_loader, 
		Globals.loading_resource, 
		Globals.a, 
		Globals.b, 
		Globals.progress
		)
	
	map_instance = Map.instance()
	
	# Connect deferred so we can safely erase it from the callback.
	# Defines the Type of COnnection
	# Connects the Game Loop's Game Finished Signal to an End Game Method
	map_instance.connect("game_finished", Lobby, "_end_game", [], CONNECT_DEFERRED)
	
	
	# Logic: If player connected, Start Game
	
	# Add Game Scene to tree
	get_tree().get_root().add_child(map_instance)
	
	Networking.UserInterface.hide()
	#UI.hide()
	#pass
	
	
	# Implements a Compatible statmechine optimized for  the rpc node/ multiplayer architecture 
	#var networked_player : GDScript = load("res://scenes/characters/Player v2.gd")
	# Set Player Script
	
	var player_group =get_tree().get_nodes_in_group("player")
	var player_ = player_group.pop_front() # Implement Unique ID
	
	
	# Set Player Object With Networked Multiplayer Script
	#player_.set_script(networked_player)

func _connected_fail():
	pass





class Downloader extends Node:
	# Unused Downloader Class   
	####Generic File downloader######
	var t = Thread.new()
		
	func _init():
		var arg_bytes_loaded = {"name":"bytes_loaded","type":TYPE_INT}
		var arg_bytes_total = {"name":"bytes_total","type":TYPE_INT}
		add_user_signal("loading",[arg_bytes_loaded,arg_bytes_total])
		var arg_result = {"name":"result","type":TYPE_RAW_ARRAY}
		add_user_signal("loaded",[arg_result])
		pass
		
	func __get(domain,url,port,ssl):
		if(t.is_active()):
			return
		t.start(self,"_load",{"domain":domain,"url":url,"port":port,"ssl":ssl})
		 
	func _load(params):
		var err = 0
		var http = HTTPClient.new()
		err = http.connect(params.domain,params.port,params.ssl)
		 
		while(http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING):
			http.poll()
			OS.delay_msec(100)
		  
		var headers = [
		  "User-Agent: Pirulo/1.0 (Godot)",
		  "Accept: */*"
		 ]
		 
		err = http.request(HTTPClient.METHOD_GET,params.url,headers)
		 
		while (http.get_status() == HTTPClient.STATUS_REQUESTING):
			http.poll()
			OS.delay_msec(500)
		 
		var rb = PoolByteArray()
		if(http.has_response()):
			headers = http.get_response_headers_as_dictionary()
			while(http.get_status()==HTTPClient.STATUS_BODY):
				http.poll()
				var chunk = http.read_response_body_chunk()
				if(chunk.size()==0):
					OS.delay_usec(100)
				else:
					rb = rb+chunk
					call_deferred("_send_loading_signal",rb.size(),http.get_response_body_length())
		  
		call_deferred("_send_loaded_signal")
		http.close()
		return rb
	func _send_loading_signal(l,t):
		emit_signal("loading",l,t)
		pass
		 
	func _send_loaded_signal():
		var r = t.wait_to_finish()
		emit_signal("loaded",r)
		pass





class Player_v3_networking extends KinematicBody2D:

	
	# Refactor to instead Extend Kinematic Bodt
	# Player
	# All the Player Logic In One Class
	# Implement Player v2 Networking here
	
	const MOTION_SPEED = 150

	export var left = false

	var _motion = 0
	var _you_hidden = false

	onready var _screen_size_y = get_viewport_rect().size.y

	

	func ___process___(delta): # Depreciated
		# Is the master of the paddle.
		if is_network_master():
			_motion = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

			#Depreciated
			#if not _you_hidden and _motion != 0:
			#	_hide_you_label()

			_motion *= MOTION_SPEED

			# Using unreliable to make sure position is updated as fast
			# as possible, even if one of the calls is dropped.
			rpc_unreliable("set_pos_and_motion", position, _motion)
		#else:
		#	if not _you_hidden:
		#		_hide_you_label()

		translate(Vector2(0, _motion * delta))

		# Set screen limits.
		position.y = clamp(position.y, 16, _screen_size_y - 16)

	"""
	GAME SYNCHRONIZER
	"""
	#Synchronize position and speed to the other peers.
	puppet func set_pos_and_motion(pos, motion):
		position = pos
		_motion = motion
		
		# Other Data to Synchronize
		# Health
		# Inventory with inventory duplicate
		# State
		#


	# Client Side Code

	# Player update function
	# This function is named "pu" to lower the network bandwidth usage, sending something
	# like "player_update" will use an extra 220 bytes / second for each connected player. 
	remote func pu(id, update_id : int, pos : Vector2, velocity, rotation):
		
		var last_update = -1
		
		# Unreliable packets can be sent in wrong order, we only work with the latest
		# data available.
		if update_id < last_update:
			print("Received update in wrong order. Discarding!")
			return
			
		last_update = update_id
		Networking.player_info[id].updates[OS.get_ticks_msec()] = { position = pos, velocity = velocity, rotation = rotation }
		while len(Networking.player_info[id].updates) > 10:
			Networking.player_info[id].updates.erase(
				Networking.player_info[id].updates.keys()[0]
				)
		
		if Networking.player_info[id].destroyed:
			return
			
		if Networking.player_info[id].node.has_node("particles"):
			Networking.player_info[id].node.get_node("particles").set_emitting(velocity != 0)

		if Networking.player_info[id].node.has_node("audio_thruster"):
			
			# SOund FX? Depreciated
			Networking.player_info[id].node.get_node("audio_thruster").stream_paused = velocity == 0




	func _on_paddle_area_enter(area):
		if is_network_master():
			# Random for new direction generated on each peer.
			area.rpc("bounce", left, randf())




#  Object/ Scene Manager

class SceneManager extends Node2D:

	signal game_finished()

	const SCORE_TO_WIN = 10

	var score_left = 0
	var score_right = 0

	onready var player2 = $Player2
	onready var score_left_node = $ScoreLeft
	onready var score_right_node = $ScoreRight
	onready var winner_left = $WinnerLeft
	onready var winner_right = $WinnerRight

	func _ready():
		# By default, all nodes in server inherit from master,
		# while all nodes in clients inherit from puppet.
		# set_network_master is tree-recursive by default.
		if get_tree().is_network_server():
			# For the server, give control of player 2 to the other peer.
			player2.set_network_master(get_tree().get_network_connected_peers()[0])
		else:
			# For the client, give control of player 2 to itself.
			player2.set_network_master(get_tree().get_network_unique_id())

		print("Unique id: ", get_tree().get_network_unique_id())


	remotesync func update_score(add_to_left):
		if add_to_left:
			score_left += 1
			score_left_node.set_text(str(score_left))
		else:
			score_right += 1
			score_right_node.set_text(str(score_right))

		var game_ended = false
		if score_left == SCORE_TO_WIN:
			winner_left.show()
			game_ended = true
		elif score_right == SCORE_TO_WIN:
			winner_right.show()
			game_ended = true

		if game_ended:
			$ExitGame.show()
			$Ball.rpc("stop")


	func _on_exit_game_pressed():
		emit_signal("game_finished")



"""

All Multiplayer Networking Logics in One FIle
Client, Server and Lobby
"""
# Lobby 

class Lobby extends Control:

	# Default game server port. Can be any number between 1024 and 49151.
	# Not on the list of registered or common ports as of November 2020:
	# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
	const DEFAULT_PORT = 8910


	# Lobby UI
	# Declares Variables
	#onready var address = $Address
	#onready var host_button = $HostButton
	#onready var join_button = $JoinButton
	#onready var status_ok = $StatusOk
	#onready var status_fail = $StatusFail
	#onready var port_forward_label = $PortForward
	#onready var find_public_ip_button = $FindPublicIP

	var peer = null

	# FOrmerly Ready Method
	static func ConnectSignal(scene_tree_obj : SceneTree, Lobby : Node) -> void:
		# Connect all the callbacks related to networking.
		# Inernet Class Contains Logic for the Implmentations Requiring Parameters
		
		# Players/CLients
		# Connect Signals
		# Debug Signal Connections
		# Signals Connect to Networking Main Script, which executeds Lobby Static Functions
		# Present in the Lobby Class
		scene_tree_obj.connect("network_peer_connected", Networking, "_player_connected")
		scene_tree_obj.connect("network_peer_disconnected", Networking, "_player_disconnected")
		
		# Connection Signal
		scene_tree_obj.connect("connected_to_server", Lobby, "_connected_ok") 
		scene_tree_obj.connect("connection_failed", Networking, "_connected_fail")
		
		# Server
		scene_tree_obj.connect("server_disconnected", Networking, "_server_disconnected")




	static func _on_player_disconnected(_id, Lobby: SceneTree, UI : Control):
		if Lobby.is_network_server():
			# with_error : String , Lobby : SceneTree, UI: Control ,Map = "/root/Pong"
			_end_game("Client disconnected", Lobby, UI)
		else:
			_end_game("Server disconnected", Lobby, UI)


	# Callback from SceneTree, only for clients (not server).
	static func _on_connected_ok():
		print_debug(" Connection OK")


	# Callback from SceneTree, only for clients (not server).
	static func _on_connected_fail(Lobby : SceneTree):
		
		print_debug("Couldn't Connect")
		#_set_status("Couldn't connect", false)

		Lobby.set_network_peer(null) # Remove peer.

		# Update UI and Enable Disabled Buttons
		
		#host_button.set_disabled(false)
		#join_button.set_disabled(false)


	static func _on_server_disconnected(_id, Lobby : SceneTree, UI : Control):
		_end_game(_id + "Server disconnected", Lobby, UI)


	##### Game creation functions ######
	# Change Map Parameter To Game Level (Map) Position in the Scene Trees 
	# End Game is Buggy
	static func _end_game(with_error : String , Lobby : SceneTree, Map = Networking.map_instance):
		if is_instance_valid(Map):
			
			# Debug Loobby Map Instance
			print_debug (Lobby.has_node(Map), is_instance_valid(Map))
			#if Lobby.has_node(Map):
			# Erase immediately, otherwise network might show
			# errors (this is why we connected deferred above).
			#Lobby.get_node(Map).free()
			Map.free()
			
			# UI SHow
			Networking.UserInterface.show()

		# Update UI when current Game Ends
		Lobby.set_network_peer(null) # Remove peer.
		
		# Enable UI buttons
		#host_button.set_disabled(false)
		#join_button.set_disabled(false)

		print_debug(with_error , false)
		_set_status(with_error, Dialogs.dialog_box , false)

	# SHows ingame Status
	# Connect to Dialogue Box
	static func _set_status(text : String, status : DialogBox, isok : bool):
		# Simple way to show status.
		#
		status.show_dialog( text + str(isok), "Admin") 
		
		


	# Starts Server Connections
	# Connects to UI Buttons
	static func _on_host_pressed( peer : NetworkedMultiplayerENet, Lobby : SceneTree, host_button : Button, join_button : Button , dialog_box : DialogBox) -> bool:
		peer = NetworkedMultiplayerENet.new()
		peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
		var err = peer.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
		
		# If Bad COnnection
		if err != OK:
			# Is another server running?
			_set_status("Can't host, address in use.",dialog_box ,false)
			return true

		OS.set_window_title('Server')
		
		# Sets Network Peer
		Lobby.set_network_peer(peer)
		
		
		host_button.set_disabled(true)
		join_button.set_disabled(true)
		
		#i/o
		print("Waiting for player...")
		
		# Sets UI Status : text : String, status : DialogBox, isok : bool
		_set_status("Waiting for player...",dialog_box ,true)

		# Only show hosting instructions when relevant.
		#
		# Show Host Instructionals
		#port_forward_label.visible = true
		#find_public_ip_button.visible = true
		return true

	# Connects to Server From Client
	static func _on_join_pressed( address: LineEdit, ClientPeer: NetworkedMultiplayerENet, Lobby : SceneTree ) -> bool :
		var ip = address.get_text()
		if not ip.is_valid_ip_address():
			print_debug("IP Address Is Invalid")
			#_set_status("IP address is invalid", false)
			return true

		#peer = NetworkedMultiplayerENet.new()
		ClientPeer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
		ClientPeer.create_client(ip, DEFAULT_PORT)
		Lobby.set_network_peer(ClientPeer)

		_set_status("Connecting...", Dialogs.dialog_box, true)
		print_debug(" Connecting...")
		
		return true

	# Finds Device Public IP Address from a WebSite
	static func _on_find_public_ip_pressed() -> void:
		OS.shell_open("https://icanhazip.com/")

class NetworkedObject extends Area2D:

	const DEFAULT_SPEED = 100

	var direction = Vector2.LEFT
	var stopped = false
	var _speed = DEFAULT_SPEED

	onready var _screen_size = get_viewport_rect().size

	func _process(delta):
		_speed += delta
		# Ball will move normally for both players,
		# even if it's sightly out of sync between them,
		# so each player sees the motion as smooth and not jerky.
		if not stopped:
			translate(_speed * delta * direction)

		# Check screen bounds to make ball bounce.
		var ball_pos = position
		if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > _screen_size.y and direction.y > 0):
			direction.y = -direction.y

		if is_network_master():
			# Only the master will decide when the ball is out in
			# the left side (it's own side). This makes the game
			# playable even if latency is high and ball is going
			# fast. Otherwise ball might be out in the other
			# player's screen but not this one.
			if ball_pos.x < 0:
				get_parent().rpc("update_score", false)
				rpc("_reset_ball", false)
		else:
			# Only the puppet will decide when the ball is out in
			# the right side, which is it's own side. This makes
			# the game playable even if latency is high and ball
			# is going fast. Otherwise ball might be out in the
			# other player's screen but not this one.
			if ball_pos.x > _screen_size.x:
				get_parent().rpc("update_score", true)
				rpc("_reset_ball", true)


	remotesync func bounce(left, random):
		# Using sync because both players can make it bounce.
		if left:
			direction.x = abs(direction.x)
		else:
			direction.x = -abs(direction.x)

		_speed *= 1.1
		direction.y = random * 2.0 - 1
		direction = direction.normalized()


	remotesync func stop():
		stopped = true


	remotesync func _reset_ball(for_left):
		position = _screen_size / 2
		if for_left:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT
		_speed = DEFAULT_SPEED


