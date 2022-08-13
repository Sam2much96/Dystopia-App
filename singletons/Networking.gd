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
# (2) Multiplayer lobby room logic And Client and Server Netcodes (next)
# (3) Youtube Download Streamer Logic impementation 
# (4) Proper Documentation (done)
# (5) Run an online for PC and mobile Devices. The Hardware is available now
# (6) Implement Rollback NetCodes for Multiplayer Gameplay
# (7) Video Downloaders
# (8) Downloads several files

#Note
#if using https connection on a self hosted server with self signed certificate
#make sure the .crt file exported from your web browser contains the private key generated
# from your server's .pem file

#Note 
# This script cannot print pool byte array and wuld return it as an empty array


extends HTTPRequest

"""
NETWORKING SINGLETON 3.0

To query if there's internet access and connect to various websites
"""
export (bool) var enabled
export(String) var connection_debug
export (String) var cfg_server_ip 
#########################  Web browser codes  ############################3
var url : String = ''
var check_timer #= Timer.new()
var debug = ''
#var _connection #stores connetion status
# Default hostname used by the login form
const DEFAULT_HOSTNAME = "127.0.0.1"

var admob_debug = '' #Debugs the Ad methods being used

var player_info = {} # should store Crypto info

var camera #stores general camera variables
###############################multiplayer codes########################
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


#onready var _ad #leave it, it updates from the admob node
#var _admob_singleton #it updates from the admob node

#var admob_nodes =[] #stores all the admob nodes instanced in the scene




const SERVER_PORT = 5225
const MAX_PLAYERS = 5

const TICK_DURATION = 50 # In milliseconds, it means 20 network updates/second


onready var timer = $Timer2


#var youtube_dl = preload ('res://New game code and features/youtube streamer/Youtube-DL.gd') #what if youtube goes down lool

func _ready():
	_init_timer()
	
	
	if cfg_server_ip == '':
		cfg_server_ip = DEFAULT_HOSTNAME
	print ("Networking Server Config and Player Name: ",cfg_server_ip,cfg_player_name, "/")
	
	
	#if check_timer == null: #Error catcher #stops multiple instance?
	#	for _i in _reference_to_self.get_children():
	#		if _i is Timer:
	#			check_timer = _i 
	
	######################Used to Control the App's Networking #######################
	

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
func _init_timer() : #rewrite to use actual timer
	#write code to check if node has been instanced
	self.set_process(true)
	enabled = true 
	check_timer = timer
	print ('Check_timer :' , check_timer) #code breaks here and gives cant resolve hostname errors
	

"Stops a check using Check timer Node"
func stop_check(): #Stops timer check
	connection_debug = ' stop check ' # Debug Variable
	if not check_timer.is_stopped():
		check_timer.stop()
		self.cancel_request()

"Starts a check using Check timer Node"
func start_check(): #Starts time check using Check timer
	connection_debug = str('start check') # Debug Variable
	print ("start check")
	check_timer.start()


func _check_connection(url): # Check http unsecured Url connection
	#Ignore Warning
	var error = .request(url,PoolStringArray(),false,0,"") 
	connection_debug = str (' making request  ')  + str (' Request Error: ',error)
	print (' Networking Request Error: ',error) #for debug purposes only


func _check_connection_secured(url): # Check http secured Url connection
	#Ignore Warning
	url =url.http_escape()
	var error = .request(url,PoolStringArray(),false,HTTPClient.METHOD_GET) 
	connection_debug = str (' making request  ')  + str (' Request Error: ',error)
	print (' Networking Request Error: ',error) #for debug purposes only



func on_request_result(result, response_code, headers, body): # I need to pass variables to this code bloc
	"HTTP REQUEST RESULT'S STATE MACHINE"
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
		
			#json.store_string(to_json(download_file.to_utf8())) #returns encrypted data #kinda works #backup
			
			#json.store_line(to_json(download_file.to_utf8())) #returns encrypted data #kinda works #backup #better
			#*****************************
			#for _i in download_file:
			#for _i in download_file:
			#	for _t in _i:
			#	cunt.append(_i)
				#poop = _i
			#pussy.parse( body.get_string_from_utf8())
			#pussy.print(body,'', true
			#******************************
			#json.store_line(to_json(body.get_string_from_utf8())) #It stores each string as a character #returns encrypted data
			cunt = body.get_string_from_utf8() #works with local storage
			
			json.store_line(str(cunt)) #works
			
			#*****************************************************
			
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
func download_image_(body: PoolByteArray, Save_path: String) -> ImageTexture:
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
			
			
			
			
			while not get_downloaded_bytes() > get_body_size() && local_tex.eof_reached() == false: #causes a large file bug, generates a 3gb file
				print ("Loading Image--------", ( get_body_size()/1000), " kb") # for debug purposes 
				local_tex.store_buffer(body) #stores image locally
				#if local_tex.eof_reached() == true: #causes a significant lag
				if get_downloaded_bytes() == get_body_size(): #causes a significant lag
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



func _on_Timer2_timeout():
	print ('check timer stopped')
