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
# Contains Logic for querying internet access and Web3 Access.
# ************************************************* 
# Features :
# (1) Smart contract implementation using GDteal and Algodot (done)
# (2) Multiplayer lobby room logic And Client and Server Netcodes (Done)
# (3) Youtube Download Streamer Logic impementation (1/3 using godot-rustube)
# (4) Proper Documentation (done)
# (5) Run an online for PC and mobile Devices. The Hardware is available now (Done)
# (7) Video Downloader
# (8) Download Logic
# (9) Regex parser for IPFS (Done)
#
# *************************************************
# To Do:
# (1) Implement Rollback NetCodes for Multiplayer Gameplay
# (2) Implement Match Making
#
#
# *************************************************


extends HTTPRequest

class_name Internet

signal connection_success
signal error_connection_failed(code, message)
signal error_ssl_handshake
signal game_finished
signal Timeout

"""
All Net Code In One Script
"""

@export var NetConfig : Resource 







@onready var world #= get_tree().get_nodes_in_group('online_world').pop_front()


@onready var timer :Timer  = $Timer2


# Netwroked Player Object
@onready var PlayerObject : PackedScene  = load("res://scenes/characters/Aarin_networking.tscn") # : Player_v2_networking

# I Need a way of keeping access to Player Object instancess

"Wallet Algo"
# To do :
# (1) port wallet connect for better wallet integration UX
@export var price_usd : String
@export var price_eur : String
@export var price_gbp : String
@export var price_btc : String 
@export var price_algo : String 

func _ready():
	_init_timer()
	
	
	if NetConfig.cfg_server_ip == '':
		NetConfig.cfg_server_ip = NetConfig.DEFAULT_HOSTNAME
		
	if NetConfig.cfg_client_ip == '':
		NetConfig.cfg_client_ip = NetConfig.DEFAULT_HOSTNAME
		
	if NetConfig.cfg_player_name == "":
		NetConfig.cfg_player_name = NetConfig.DEFAULT_HOSTNAME
	
	print_debug ("Networking Server Config and Player Name: ",NetConfig.cfg_server_ip,NetConfig.cfg_player_name, "/")
	


 
# Creates a Networking timer
func _init_timer() : 
	#Uses a Timer Node in the Scene
	#self.set_process(true)
	NetConfig.enabled = true 
	NetConfig.check_timer = timer
	NetConfig.check_timer.wait_time = 5
	
	# connect timer timeout signal
	"Updates the Networking Boolean of Timer State"
	if not timer.is_connected("timeout", Callable(self, "_on_Timer2_timeout")):
		timer.connect("timeout", Callable(self, "_on_Timer2_timeout"))
	
	print_debug ('Check_timer :' , NetConfig.check_timer, " Is connected: ", timer.is_connected("timeout", Callable(self, "_on_Timer2_timeout"))) #code breaks here and gives cant resolve hostname errors



"Stops a check using Check timer Node"
func stop_check()-> bool: #Stops timer check
	NetConfig.connection_debug = ' stop check ' # Debug Variable
	if not NetConfig.check_timer.is_stopped():
		
		
		NetConfig.check_timer.stop()
		self.cancel_request()
		
		#Stopping Check Timer
		print ('Stopping Check Timer')
		return false
	else: return true


"Starts a check using Timer Node for 3 Seconds"
func start_check(time: int): 
	NetConfig.connection_debug = str('start check') # Debug Variable
	NetConfig.Timeout_ = false
	if time != null:
		NetConfig.check_timer.start(time) 
	
	# Reset Timeout parameter
	#
	NetConfig.check_timer.start()


func start_check_v2(wait_time : int):
	await get_tree().create_timer(wait_time).timeout

# Check http unsecured Url connection
# fix multiple check bug
static func _check_connection(url, request_node: HTTPRequest): 
	#Ignore Warning
	#Request Node must be in the SceneTree
	print  ("Is Request Noode inside scene tree:", request_node.is_inside_tree())
	var error #= request_node.request(url,PackedStringArray(),false,0,"") 
	print (' Networking Request Error: ',error) #for debug purposes only


func _check_connection_secured(url): # Check http secured Url connection
	#Ignore Warning
	url =url.uri_encode()
	var error #= super.request(url,PackedStringArray(),false,HTTPClient.METHOD_GET) 
	NetConfig.connection_debug = str (' making request  ')  + str (' Request Error: ',error)
	print (' Networking Request Error: ',error) #for debug purposes only


"""
HTTP REQUEST STATE MACHINE
"""

func _on_Networking_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray): # I need to pass variables to this code bloc
	"HTTP REQUEST RESULT'S STATE MACHINE"
	print_debug("request completed")
	#print_stack()
	
	match result:
		HTTPRequest.RESULT_SUCCESS: #what happens to body? #always write a http request completed function in the connecting script
			connection_success.emit()
			NetConfig.good_internet = true
			#_connection =(str ('connection success')) # Debugs to the Debug singleton # Depreciated--Delete
			#print_debug (str(result) + str(response_code) + str(headers)+ str (body))  
			#print(body.get_string_from_utf8())
			# Parses API Get Result TO Json
			var _response_text = body.get_string_from_utf8()
			var json = JSON.new()
			var _result = json.parse(_response_text)

			if _result == OK:
				NetConfig.Data = json.data
				
				# to do:
				# (1) serialise vestige api data into a wallet config object class
				# Fetches price data in ready function
				print_debug("Internet Data debug: ", NetConfig.Data)  # 
				print_debug("Price serialisation: ", _format_price(NetConfig.Data.USD))
				
				# data serialisation is done in Stats HUD
				price_usd = _format_price(NetConfig.Data.USD)
				price_eur = _format_price(NetConfig.Data.EUR)
				price_gbp = _format_price(NetConfig.Data.GBP)
				price_btc = _format_price(NetConfig.Data.BTC)
				price_algo = _format_price(NetConfig.Data.price)
				
			else:
				print_debug("Failed to parse JSON. Error: ", json.get_error_message(), " at line ", json.get_error_line())
			#print_debug(body.get_string_from_utf8())
			#print_debug(body.get_string_from_utf8())
			
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			error_connection_failed.emit(HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH, 'RESULT_CHUNKED_BODY_SIZE_MISMATCH')
			print_debug("error_connection_failed", HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH, 'RESULT_CHUNKED_BODY_SIZE_MISMATCH')

		HTTPRequest.RESULT_CANT_CONNECT:
			error_connection_failed.emit(HTTPRequest.RESULT_CANT_CONNECT, 'RESULT_CANT_CONNECT')
			print_debug("error_connection_failed", HTTPRequest.RESULT_CANT_CONNECT, 'RESULT_CANT_CONNECT')

		HTTPRequest.RESULT_CANT_RESOLVE:
			error_connection_failed.emit(HTTPRequest.RESULT_CANT_RESOLVE, 'RESULT_CANT_RESOLVE')
			print_debug("error_connection_failed", HTTPRequest.RESULT_CANT_RESOLVE, 'RESULT_CANT_RESOLVE')
			#good_internet = false
			#_connection = (str ('connection failed')) # Debugs to the Debug singleton
			#print_debug (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function

		HTTPRequest.RESULT_CONNECTION_ERROR:
			error_connection_failed.emit(HTTPRequest.RESULT_CONNECTION_ERROR, 'RESULT_CONNECTION_ERROR')
			print_debug("error_connection_failed", HTTPRequest.RESULT_CONNECTION_ERROR, 'RESULT_CONNECTION_ERROR')
			NetConfig.good_internet = false
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			#print_debug (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function

		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			error_ssl_handshake.emit()
			print_debug("error_ssl_handshake")

		HTTPRequest.RESULT_NO_RESPONSE:
			error_connection_failed.emit(HTTPRequest.RESULT_NO_RESPONSE, 'RESULT_NO_RESPONSE')
			print_debug("error_connection_failed", HTTPRequest.RESULT_NO_RESPONSE, 'RESULT_NO_RESPONSE')

		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			error_connection_failed.emit(HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED, 'RESULT_BODY_SIZE_LIMIT_EXCEEDED')
			print_debug("error_connection_failed", HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED, 'RESULT_BODY_SIZE_LIMIT_EXCEEDED')

		HTTPRequest.RESULT_REQUEST_FAILED:
			error_connection_failed.emit(HTTPRequest.RESULT_REQUEST_FAILED, 'RESULT_REQUEST_FAILED')
			print_debug("error_connection_failed", HTTPRequest.RESULT_REQUEST_FAILED, 'RESULT_REQUEST_FAILED')

		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			error_connection_failed.emit(HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN, 'RESULT_DOWNLOAD_FILE_CANT_OPEN')
			print_debug("error_connection_failed", HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN, 'RESULT_DOWNLOAD_FILE_CANT_OPEN')

		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			error_connection_failed.emit(HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR, 'RESULT_DOWNLOAD_FILE_WRITE_ERROR')
			print_debug("error_connection_failed", HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR, 'RESULT_DOWNLOAD_FILE_WRITE_ERROR')

		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			error_connection_failed.emit(HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED, 'RESULT_REDIRECT_LIMIT_REACHED')
			print_debug("error_connection_failed", HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED, 'RESULT_REDIRECT_LIMIT_REACHED')

func _format_price(value):
	# formats vestigefi price data to 12 places
	return "%.12f" % value

func genrate_random_gateway():
	randomize()
	#Utils._randomize(self)
	NetConfig.random = int(randf_range(-1,NetConfig.gateway.size())) #selects a random track number
	NetConfig.selected_gateway = NetConfig.gateway[NetConfig.random]

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
		
		var t=StreamPeerTLS.new()
	
		var error #= request_node.request(url,PackedStringArray(),false,HTTPClient.METHOD_GET)  
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
	# to do:
	# (1) export and connect http request signals to game hud animations
	#
	
	NetConfig.running_request = false
	#connected to results and works as an auto emitter
	match result:
		RESULT_SUCCESS: #what happens to body? #always write a http request cmpleted function in the connecting script
			connection_success.emit()
			#_connection =(str ('connection success')) # Debugs to the Debug singleton # Depreciated--Delete
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body))
		RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			error_connection_failed.emit(RESULT_CHUNKED_BODY_SIZE_MISMATCH,'RESULT_CHUNKED_BODY_SIZE_MISMATCH')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CANT_CONNECT:
			error_connection_failed.emit(RESULT_CANT_CONNECT,'RESULT_CANT_CONNECT')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CANT_RESOLVE:
			error_connection_failed.emit(RESULT_CANT_RESOLVE,'RESULT_CANT_RESOLVE')
			#_connection = (str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_CONNECTION_ERROR:
			error_connection_failed.emit(RESULT_CONNECTION_ERROR,'RESULT_CONNECTION_ERROR')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		#RESULT_SSL_HANDSHAKE_ERROR:
		#	error_ssl_handshake.emit()
			#_connection = (str ('connection failed')) # Debugs to the Debug singleton
		#	connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_NO_RESPONSE:
			error_connection_failed.emit(RESULT_NO_RESPONSE,'RESULT_NO_RESPONSE')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			error_connection_failed.emit(RESULT_BODY_SIZE_LIMIT_EXCEEDED,'RESULT_BODY_SIZE_LIMIT_EXCEEDED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) #use in a function
		RESULT_REQUEST_FAILED:
			error_connection_failed.emit(RESULT_REQUEST_FAILED, 'RESULT_REQUEST_FAILED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body))
		RESULT_DOWNLOAD_FILE_CANT_OPEN:
			error_connection_failed.emit(RESULT_DOWNLOAD_FILE_CANT_OPEN,'RESULT_DOWNLOAD_FILE_CANT_OPEN')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body))
		RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			error_connection_failed.emit(RESULT_DOWNLOAD_FILE_WRITE_ERROR, 'RESULT_DOWNLOAD_FILE_WRITE_ERROR')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body))
		RESULT_REDIRECT_LIMIT_REACHED:
			error_connection_failed.emit(RESULT_REDIRECT_LIMIT_REACHED, 'RESULT_REDIRECT_LIMIT_REACHED')
			#_connection =(str ('connection failed')) # Debugs to the Debug singleton # Depreciated--Delete
			NetConfig.connection_debug = (str(result) + str(response_code) + str(headers)+ str (body)) 
	#stop_check() # Disabled
	
	
func _on_success():
	print('connection success!!')
	#_connection = str ('connection success!!') # Debug Variable # Depreciated--Delete
	

func _on_failure(code, message):
	print('Connection Failure !!\nCode: ', code,"Message:", message)
	#_connection = str ('connection failed!!') # Debug Variable # Depreciated--Delete


func _on_fail_ssl_handshake():
	print('SSL Handshake Error!!')


func _on_connected_ok_fwd() -> void:
	Lobby._on_connected_ok()

func _on_connected_fail_fwd() -> void:
	Lobby._on_connected_fail(get_tree())
	#_connection = str ('ssl handshake error!!') # Debug Variable # Depreciated--Delete

'Downloads a Json file and Stores it Locally'
#consider running 2 operations here. A read operation and a write operation
func download_json_(body: PackedByteArray, Save_path: String) : #-> File:
	var json = Utils.file
	var cunt = []
	if body != null:
		
		print ("Loading Json--------", ( get_body_size()), " bytes")# wprks # for debug purposes 
		
		
		#json.open((Save_path +".json"), File.WRITE )
		
		while not json.get_length() > get_body_size() : #kinda works
			cunt = body.get_string_from_utf8() #works with local storage
			
			json.store_line(str(cunt)) #works
			if json.get_length() == get_body_size(): break #works perfectly
			

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
static func download_image_(body: PackedByteArray, Save_path: String, node : HTTPRequest) -> ImageTexture:
	var image = Image.new()
	var texture = ImageTexture.new()
	
	if body != null:
		var image_error = image.load_png_from_buffer(body)
		if image_error != OK:
			push_error("An error occurred while trying to display the image.")
		elif image_error == OK:
			"Save File locally"
			var local_tex # =File.new()
			#local_tex.open((Save_path +".png"), File.WRITE)
			
			
			
			
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
static func download_file_(node : HTTPRequest,body: PackedByteArray, Save_path: String, file_type: String) : #-> File:
	var file #= File.new()
	#var cunt = []
	if body != null:
		
		print ("Loading ",file_type, "--------", ( node.get_body_size()), " bytes")# wprks # for debug purposes 
		print("Downloaded bytes-------",node.get_downloaded_bytes())
		# Should be .zip or .json for different file types
		# SHould ideally contain a check for verifying the contents of the file type string
		#file.open_compressed((Save_path + file_type), File.WRITE, File.COMPRESSION_GZIP )
		#file.open((Save_path + file_type), File.WRITE )
		
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
static func save_file_(body: PackedByteArray, Save_path: String, file_size: int ) : # -> File:
	var file #= File.new()
	
	#var Dir = Directory.new()
	
	if body != null : # && !Dir.file_exists(Save_path):
		
		#print ("Loading ",file_type, "--------", ( node.get_body_size()), " bytes")# wprks # for debug purposes 
		#print("Downloaded bytes-------",node.get_downloaded_bytes())
		# Should be .zip or .json for different file types
		# SHould ideally contain a check for verifying the contents of the file type string
		#file.open_compressed((Save_path + file_type), File.WRITE, File.COMPRESSION_GZIP )
		
		
		var err #= file.open((Save_path ), File.WRITE )
		
		#while not node.get_downloaded_bytes() > node.get_body_size() && file.eof_reached() == false:
		print ("storing file to ", Save_path)
		
		if err==OK:
			
			while not file.get_length() > file_size:
				file.store_buffer(body)
				
				if file.get_length() == file_size:
					file.close()
					break 
			
			if file.eof_reached(): file.close()
		else : push_error("Error:" + err)
		
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
	NetConfig.Timeout_ = true

	Timeout.emit()
	stop_check()
	#if is_instance_valid(Comics_v6): # Error Catcher
	#	Comics_v6.SwipeLocked = false#!Comics_v6.SwipeLocked

"""
MULTIPLAYER SIGNALS
"""
# Executes Multiplayer Logic In the Lobby Class
func _server_disconnected():
	#emit_signal("game_finished")
	#print_debug(int(Networking.player_info["peer id"][peer_id]))
	Lobby._on_server_disconnected(NetConfig.peer_id, get_tree(), NetConfig.UserInterface)


func _player_disconnected(_id : int):
	# _id, Lobby: SceneTree, UI : Control)
	#emit_signal("game_finished")
	Lobby._on_player_disconnected(_id, get_tree(), NetConfig.UserInterface)
	#_end_game()
	
	Lobby._set_status((str (_id )+ " Disconnected"), Dialogs.dialog_box, true)
	# SHould Ideally Only Delete the player that is disconnected

func _player_connected(_id : int):
	# Calls Player Logic in the Lobby Class
	# Method is called with the Noe's Unique ID
	# Idenftifying the player. This ID Should Be Saved
	print_debug("Player Connected Registering Player ID", _id)
	#Simulation.player_info["peer id"] = {_id : {}}
	# Player ID is registered by the player script
	
	NetConfig.peer_id = _id
	#OS.set_window_title('Client' + str(_id))
	
	# Make Multiplayer Gameplay Started into Global
	#GamePlay = ONLINE
	#xczczxc
	# Create Global Pointers to Connected Peer ID's
	
	"""
	 Register the Player ID
	"""
	
	# Register this devices Player ID
	if not Simulation.player_IDs.has(_id):
		Simulation.player_IDs.append(_id)
	
	# Register the Server ID
	if not Simulation.player_IDs.has(get_tree().get_unique_id()):
		Simulation.player_IDs.append(get_tree().get_unique_id())
	
	"""
	Starts Multiplayer Game
	"""
	# Logic
	# (1) If map instance is null, create map 
	# (2) If is server, don't instance map twice
	
	"Change Network State"
	# To DO: SHould be read from player's control settings and saved to local device
	#GamePlay = LOCAL_COOP
	
	if NetConfig.map_instance == null:
		Globals.current_level = "res://scenes/levels/OverworldOnline.tscn"
		var Map := load(Globals.current_level) as PackedScene
		if Map == null:
			push_error("_player_connected: failed to load map at " + Globals.current_level)
			return
		NetConfig.map_instance = Map.instantiate()

		if not game_finished.is_connected(_end_game):
			game_finished.connect(_end_game, CONNECT_DEFERRED)

		get_tree().get_root().add_child(NetConfig.map_instance)
		NetConfig.UserInterface.hide()
	

	
	"INstance Player Sprites as children"
	_instance_players(_id)
	
	


" Instance Players in a Loop"
# Bug:
# (1) Does not run on MMO server
func _instance_players(id : int ):
	# Instance Player Logic 
	# Logic : Where Zero is the Server Player ID
	# (1) Get all Online Player Objects in scene tree
	# (2) Get all Player ID's
	#var player_objects_spawned : Array =get_tree().get_nodes_in_group("online_player")
	var player_ids_stored : Array = Simulation.get_all_player_ids()
	
	print_debug("Server Type: ",NetConfig.GamePlay)
	"Spawns Two Players FOr LOcal Coop"
	
	
		# 1 Player
	#if object_spawned ==  0: # bno player object spawned
		
		# Note: server player has authority in this Multiplayer architecture
		# THis current Architecture is for testing local play
		# Online MMO shouldn't include a server player
	if NetConfig.GamePlay == NetConfig.LOCAL_COOP:
		print_debug("Online Players Debug: ", "id: ",id, "/", player_ids_stored, "/ Net play: " , NetConfig.GamePlay )
		
		var a = PlayerObject.instantiate() # Client Player
		var b = PlayerObject.instantiate() # server player
			
		# configure child to name of client & server to their id's
		a.name = str(id) # client player
		
		b.name = str(player_ids_stored[0]) # server player
		# Create Global Pointers to Player Objects for Simulation Logic
		Simulation.all_player_objects.append(a)
		Simulation.all_player_objects.append(b)
		
		# Store peer ids to Local player sceipts
		# changes it from default -99
		a.peer_id = id
		b.peer_id = player_ids_stored[0] # server id
		
		# add randomization to player object spawn point to avoid stuck collision bug
		
		NetConfig.map_instance.add_child(a) 
		NetConfig.map_instance.add_child(b) 
		
		#object_spawned + 2

	"Spawns 1 Player for Online MMO"
	# TO DO : 
	# (1) Should Account for Up to 4 Players
	# (2) Should Account for lots of networking bugs
	if NetConfig.GamePlay == NetConfig.MMO_SERVER:
		print_debug("Online Players Debug: ", "id: ",id, "/", player_ids_stored, "/ Net play: " , NetConfig.GamePlay )
		
		var a = PlayerObject.instantiate() # Client Player
		
		# configure child to name of client to their id's
		a.name = str(id) # client player
		
		# Create Global Pointers to Player Objects for Simulation Logic
		Simulation.all_player_objects.append(a)
		
		# Store peer ids to Local player sceipts
		# changes it from default -99
		a.peer_id = id
		NetConfig.map_instance.add_child(a) 
	
	# Seconnd Player and more Players Connection Logic
	# Temporarily Disabling
	#if object_spawned ==  1 && id_count > 2:
	#	# clean data
	#	for i in player_ids_stored:
	#		
	#		
	#		if not player_objects_spawned.has(str(i)):
	#			#player_ids_stored.remove(player_ids_stored.find(str(i)))
	#	
	#	# loop through clean data
	#	#for i in player_ids_stored: # Returns an Array of Numbers
	#			var b = PlayerObject.instance()
	#	
	#			# configure child
	#			b.name = str(i)
	#	
	#			map_instance.add_child(b) 
	#		
	#			# Should Store a Pointer to the Player Object
	#				


func _end_game():
	print_debug("Ending Game")
	#if is_instance_valid(map_instance):
		
		# Debug Loobby Map Instance
	#print_debug (get_tree().has_node(map_instance), is_instance_valid(map_instance))
	#if Lobby.has_node(Map):
	# Erase immediately, otherwise network might show
	# errors (this is why we connected deferred above).
	#Lobby.get_node(Map).free()
	
	var _map = get_tree().get_nodes_in_group("Multiplayer").pop_front()
	NetConfig.map_instance.queue_free()
	#_map.free()
	# UI SHow
	# Enable UI buttons
	NetConfig.UserInterface.show()

	# Update UI when current Game Ends
	get_tree().set_multiplayer_peer(null) # Remove peer.
		
		
		#host_button.set_disabled(false)
		#join_button.set_disabled(false)
	var with_error : String = "End Game! Server Disconnected"
	#print_debug(with_error , false)
	Lobby._set_status(with_error, Dialogs.dialog_box , false)


"Multiplayer NetCode Functions"

# Converts an Array to poolbyre
func array2poolByte( data_from : Array) -> PackedByteArray: 
	#	if frame_counter % 6_000 == 0:
	# To Do:
	# (1) update to check for data continuity
	# (2) Implement Algorithm to reduce Data size to < 1000 bytes 
	Simulation.RawData = var_to_bytes([JSON.new().stringify(data_from)])
	return PackedByteArray(Simulation.RawData)

# Converts a Poolbyte ro a Dictionary /String data type
func poolByte2Array(data_from: PackedByteArray) -> Array:
	if data_from.size() > 5:
		Simulation.RawDataArray = bytes_to_var(data_from)
		# Iterate through raw data
		for i in Simulation.RawDataArray:
			#Returns a String. Converting to Dictionary
			
			var test_json_conv = JSON.new()
			test_json_conv.parse(i) # Returns either a String or a Dictionary? Type 18 for dictionary
			NetConfig.RawJson = test_json_conv.get_data()
		return NetConfig.RawJson
 
	else: 
		push_error("Error calling built-in function 'bytes_to_var': Not enough bytes for decoding bytes, or invalid format.")
		return [] # returns an empty array



"""
PLAYER UPDATE
"""
# Player update function
# This function is named "pu" to lower the network bandwidth usage, sending something
# like "player_update" will use an extra 220 bytes / second for each connected player. 
# broadcasts server player data as poolbyte arrays to all peers

# Use Player Info Hash to Verify Packet Integrity
# Should Instead Receive A Json Compressed instead of individual Player Parameters
#
# receives player info from sever object


"""
PING
"""
# Calculates Ping Rate

func ping() -> Array:
	# For Debug Purposes Only
	
	var output = []
	#OS.execute('ping', ['-w', '3', 'godotengine.org'], true, output) 
	for line in output:
		print(line)
	return output

"""
BROADCAST WORLD POSITIONS
"""
#Broadcats world position from server to all peers using player update methods


@rpc("any_peer") func broadcast_world_positions():
	# Server Call
	# Calls the pu Method in all Renote peers
	# can only be called by Server
	# Only the Hosting Device Can Update All NEtwork peers
	if is_multiplayer_authority():
		
		# Ping
		
		#ping()
		
		
		# First, Convert Player Info Dictionary to Pool Byte Array
		
		
		Simulation.rpc_id(NetConfig.peer_id, "pu", NetConfig.peer_id, NetConfig.update_id, array2poolByte([Simulation.player_info])) # pu call is buggy cuz of peer id error
		NetConfig.update_id += 1



class Player_v3_networking extends CharacterBody2D:

	
	
	# Player
	# All the Player Logic In One Class
	# Implement Player v2 Networking here
	
	const MOTION_SPEED = 150

	@export var left = false

	var _motion = 0
	var _you_hidden = false

	@onready var _screen_size_y = get_viewport_rect().size.y


	func ___process___(delta): # Depreciated
		# Is the master of the paddle.
		if is_multiplayer_authority():
			_motion = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

			#Depreciated
			#if not _you_hidden and _motion != 0:
			#	_hide_you_label()

			_motion *= MOTION_SPEED

			# Using unreliable to make sure position is updated as fast
			# as possible, even if one of the calls is dropped.
			#rpc_unreliable("set_pos_and_motion", position, _motion)
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
	func set_pos_and_motion(pos, motion):
		position = pos
		_motion = motion
		
		# Other Data to Synchronize
		# Health
		# Inventory with inventory duplicate
		# State
		#





#  Object/ Scene Manager

class SceneManager extends Node2D:

	signal game_finished()

	const SCORE_TO_WIN = 10

	var score_left = 0
	var score_right = 0

	@onready var player2 = $Player2
	@onready var score_left_node = $ScoreLeft
	@onready var score_right_node = $ScoreRight
	@onready var winner_left = $WinnerLeft
	@onready var winner_right = $WinnerRight

	func _ready():
		# By default, all nodes in server inherit from master,
		# while all nodes in clients inherit from puppet.
		# set_network_master is tree-recursive by default.
		if multiplayer.is_server():
			# For the server, give control of player 2 to the other peer.
			player2.set_multiplayer_authority(multiplayer.get_peers()[0])
		else:
			# For the client, give control of player 2 to itself.
			player2.set_multiplayer_authority(get_tree().get_unique_id())

		print("Unique id: ", get_tree().get_unique_id())


	func update_score(add_to_left):
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

	static func ConnectSignal(scene_tree_obj: SceneTree, _lobby_node: Node) -> void:
		var mp := scene_tree_obj.get_multiplayer()
		if not mp.peer_connected.is_connected(Networking._player_connected):
			mp.peer_connected.connect(Networking._player_connected)
		if not mp.peer_disconnected.is_connected(Networking._player_disconnected):
			mp.peer_disconnected.connect(Networking._player_disconnected)
		if not mp.connected_to_server.is_connected(Networking._on_connected_ok_fwd):
			mp.connected_to_server.connect(Networking._on_connected_ok_fwd)
		if not mp.connection_failed.is_connected(Networking._on_connected_fail_fwd):
			mp.connection_failed.connect(Networking._on_connected_fail_fwd)
		if not mp.server_disconnected.is_connected(Networking._server_disconnected):
			mp.server_disconnected.connect(Networking._server_disconnected)




	static func _on_player_disconnected(_id, Lobby: SceneTree, UI : Control):
		if Lobby.is_server():
			# with_error : String , Lobby : SceneTree, UI: Control ,Map = "/root/Pong"
			_end_game("Client disconnected", Lobby, UI)
		else:
			_end_game("Server disconnected", Lobby, UI)


	# Callback from SceneTree, only for clients (not server).
	static func _on_connected_ok():
		print_debug(" Connection OK")


	static func _connected_fail():
		print_debug("Connection Fail")

	# Callback from SceneTree, only for clients (not server).
	static func _on_connected_fail(Lobby : SceneTree):
		
		print_debug("Couldn't Connect")
		#_set_status("Couldn't connect", false)

		Lobby.set_multiplayer_peer(null) # Remove peer.

		# Update UI and Enable Disabled Buttons
		
		#host_button.set_disabled(false)
		#join_button.set_disabled(false)


	static func _on_server_disconnected(_id : int, Lobby : SceneTree, UI : Control):
		_end_game( str(_id) + " Server disconnected", Lobby)
		UI.show()

	##### Game creation functions ######
	# Change Map Parameter To Game Level (Map) Position in the Scene Trees 
	# End Game is Buggy
	# Moving to Networking Singleton Implementation
	static func _end_game(with_error : String , Lobby : SceneTree, Map = Networking.map_instance, error = Networking._reference_to_debug.error_splash_page):
		if is_instance_valid(Map):
			
			# Debug Loobby Map Instance
			#print_debug (Lobby.has_node(Map), is_instance_valid(Map))
			
			Lobby.change_scene_to_packed(error)
			
			Map.queue_free()
			
			Networking.UserInterface.show()

		# Update UI when current Game Ends
		Lobby.set_multiplayer_peer(null) # Remove peer.
		
		# Enable UI buttons
		#host_button.set_disabled(false)
		#join_button.set_disabled(false)

		print_debug(with_error , false)
		_set_status(with_error, Dialogs.dialog_box , false)

	# SHows ingame Status
	# Connect to Dialogue Box
	static func _set_status(text : String, status : DialogBox, isok : bool):
		Networking. start_check(2)
		# Simple way to show status.
		#
		status.show_dialog( text + str(isok), "Admin") 
			
		# Bug: Dialogue box doesnt stop showing 
		

	# Starts Server Connections
	# Connects to UI Buttons
	static func _on_host_pressed( peer : ENetMultiplayerPeer, Lobby : SceneTree, host_button : Button, join_button : Button , dialog_box : DialogBox) -> bool:
		peer = ENetMultiplayerPeer.new()
		#peer.set_compression_mode(ENetMultiplayerPeer.COMPRESS_RANGE_CODER)
		var err = peer.create_server(DEFAULT_PORT, Networking.MAX_PLAYERS) # Maximum of % peers
		
		# If Bad COnnection
		if err != OK:
			# Is another server running?
			_set_status("Can't host, address in use.",dialog_box ,false)
			return true

		#get_window().set_title('Server')
		
		# Sets Network Peer
		Lobby.get_multiplayer().multiplayer_peer = peer #Lobby.set_multiplayer_peer(peer)

		# Host never receives its own peer_connected signal, so bootstrap
		# the host's map + player object here instead of waiting for one.
		if Networking.NetConfig.GamePlay == Networking.NetConfig.MMO_SERVER:
			Networking._player_connected(1)

		host_button.set_disabled(true)
		join_button.set_disabled(true)
		
		#i/o
		print_debug("Waiting for player..."+ str(Networking.ip[0]))
		
		# Sets UI Status : text : String, status : DialogBox, isok : bool
		_set_status("Waiting for players ..." + str(Networking.ip[0]) ,dialog_box ,true)

		# Only show hosting instructions when relevant.
		#
		# Show Host Instructionals
		#port_forward_label.visible = true
		#find_public_ip_button.visible = true
		return true

	# Connects to Server From Client
	static func _on_join_pressed( address: LineEdit, ClientPeer: ENetMultiplayerPeer, Lobby : SceneTree ) -> bool :
		var ip = address.get_text()
		if not ip.is_valid_ip_address():
			print_debug("IP Address Is Invalid")
			#_set_status("IP address is invalid", false)
			return true

		#peer = NetworkedMultiplayerENet.new()
		#ClientPeer.set_compression_mode(ENetMultiplayerPeer.COMPRESS_RANGE_CODER)
		var err = ClientPeer.create_client(ip, DEFAULT_PORT)
		if err != OK:
			print_debug("Failed to create client. Error code: ", str(err))
			_set_status("Failed to create client connection.", Dialogs.dialog_box, false)
			return false
		print_debug("Client created successfully for IP: " + ip + " on port: " + str(DEFAULT_PORT))
		Lobby.get_multiplayer().multiplayer_peer = ClientPeer

		_set_status("Connecting...", Dialogs.dialog_box, true)
		print_debug(" Connecting...")

		return true


	static func _on_steam_host_pressed(lobby_tree: SceneTree, max_players: int, dialog_box: DialogBox) -> void:
		var peer := SteamMultiplayerPeer.new()
		var err := peer.create_host(max_players)
		if err != OK:
			_set_status("Steam: Can't host (error %d)" % err, dialog_box, false)
			return
		lobby_tree.get_multiplayer().multiplayer_peer = peer
		_set_status("Steam: Waiting for players... (ID: %d)" % Steam.getSteamID(), dialog_box, true)
		print_debug("Steam host started. Local Steam ID: ", Steam.getSteamID())

		# Host never receives its own peer_connected signal, so bootstrap
		# the host's map + player object here instead of waiting for one.
		if Networking.NetConfig.GamePlay == Networking.NetConfig.MMO_SERVER:
			Networking._player_connected(1)

		# Create a matchmaking lobby so other players can find this game
		# instead of needing the host's Steam64 ID pasted in manually.
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, max_players)


	static func _on_steam_join_pressed(host_steam_id: int, lobby_tree: SceneTree, dialog_box: DialogBox) -> bool:
		if host_steam_id == 0:
			_set_status("Steam: Enter a valid Steam ID.", dialog_box, false)
			return false
		var peer := SteamMultiplayerPeer.new()
		var err := peer.create_client(host_steam_id)
		if err != OK:
			_set_status("Steam: Failed to connect (error %d)" % err, dialog_box, false)
			return false
		lobby_tree.get_multiplayer().multiplayer_peer = peer
		_set_status("Steam: Connecting to %d..." % host_steam_id, dialog_box, true)
		print_debug("Steam client connecting to Steam ID: ", host_steam_id)
		return true


	##### Steam Lobby matchmaking (find-a-game, instead of pasting a Steam64 ID) ######

	const STEAM_LOBBY_TAG_KEY := "dystopia_lobby"

	static func _on_steam_lobby_created(connect_result: int, lobby_id: int) -> void:
		if connect_result != Steam.RESULT_OK:
			push_error("Steam: failed to create matchmaking lobby (result %d)" % connect_result)
			return
		Steam.setLobbyData(lobby_id, "name", "%s's game" % Networking.NetConfig.cfg_player_name)
		Steam.setLobbyData(lobby_id, STEAM_LOBBY_TAG_KEY, "1")


	static func _on_steam_request_lobby_list() -> void:
		Steam.addRequestLobbyListStringFilter(STEAM_LOBBY_TAG_KEY, "1", Steam.LOBBY_COMPARISON_EQUAL)
		Steam.requestLobbyList()


	static func _on_steam_lobby_match_list(lobbies: Array, server_list: ItemList) -> void:
		server_list.clear()
		for lobby_id in lobbies:
			var lobby_name : String = Steam.getLobbyData(lobby_id, "name")
			if lobby_name == "":
				lobby_name = "Game #%d" % lobby_id
			var idx := server_list.add_item(lobby_name)
			server_list.set_item_metadata(idx, {"type": "steam", "lobby_id": lobby_id})


	static func _on_steam_lobby_joined(lobby_id: int, response: int, lobby_tree: SceneTree, dialog_box: DialogBox) -> void:
		if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			_set_status("Steam: Failed to join lobby (response %d)" % response, dialog_box, false)
			return
		var host_id := Steam.getLobbyOwner(lobby_id)
		_on_steam_join_pressed(host_id, lobby_tree, dialog_box)




class NetworkedObject extends Area2D:

	const DEFAULT_SPEED = 100

	var direction = Vector2.LEFT
	var stopped = false
	var _speed = DEFAULT_SPEED

	@onready var _screen_size = get_viewport_rect().size

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

		if is_multiplayer_authority():
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


#func bounce(left, random):
		# Using sync because both players can make it bounce.
#		pass


#func stop():
#		stopped = true


#func _reset_ball(for_left):
#		position = _screen_size / 2
#		if for_left:
#			direction = Vector2.LEFT
#		else:
#			direction = Vector2.RIGHT
#		_speed = DEFAULT_SPEED


func open_browser(url : String):
	return OS.shell_open(url)
