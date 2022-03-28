# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a auto-included singleton containing
# information used by the client and server codes.
# also used as a networking node 
# ************************************************* 

extends HTTPRequest

"""
NETWORKING SINGLETON 3.0

To query if there's internet access and connect to various websites
"""
export (bool) var enabled
#export(bool) var admob_enabled
#var admob_gd_script = load("res://singletons/Ads.gd") #add link to admob.gd
var debug = ''

var admob_debug = '' #Debugs the Ad methods being used

signal connection_success
signal error_connection_failed(code,message)
signal error_ssl_handshake

onready var world #= get_tree().get_nodes_in_group('online_world').pop_front()


onready var _ad #leave it, it updates from the admob node
var _admob_singleton #it updates from the admob node

onready var _y =get_node('/root/Networking')
onready var check_timer #= Timer.new()
#var admob_nodes =[] #stores all the admob nodes instanced in the scene

var _connection #stores connetion status
# Default hostname used by the login form
const DEFAULT_HOSTNAME = "127.0.0.1"

###############################multiplayer codes########################
var multiplayer_client_debug
var multiplayer_server_debug

const SERVER_PORT = 5225
const MAX_PLAYERS = 5
export onready var WORLD_SIZE = 40000.0
const TICK_DURATION = 50 # In milliseconds, it means 20 network updates/second

var player_info = {} 

# Those variables are only used by the client-side application
export (String) var cfg_server_ip 
var cfg_color = ""
var cfg_player_name = ""

var camera #stores general camera variables

#########################  Web browser codes  ############################3
export (String) var url = ''

#var xml = preload('res://scenes/UI & misc/xml.tscn') #used for downloading and logging file downloads

var youtube_dl = preload ('res://New game code and features/youtube streamer/Youtube-DL.gd')

func _ready():
	if cfg_server_ip == '':
		cfg_server_ip = DEFAULT_HOSTNAME
	print (cfg_server_ip,cfg_player_name)
	
	
	if check_timer == null:
		for _i in _y.get_children():
			if _i is Timer:
				check_timer = _i 
	
	
	
	######################Used to Control the App's Networking #######################
	pass

func _process(_delta): 

	debug = ( str(_connection)  + str (multiplayer_server_debug) + str(multiplayer_client_debug)) #




	for child in _y.get_children():
		if child is Timer:
			check_timer = child
			if not child.is_connected("timeout",self, '_check_connection') :
				child.connect("timeout",self, '_check_connection')
		if child is HTTPRequest:
#checks connection status
			if child.is_connected("connection_success",self, '_on_success') != true:
				connect("request_completed", self,'on_request_result')
		
				connect("connection_success",self, '_on_success')
				connect("error_connection_failed",self,'_on_failure')
				connect("error_ssl_handshake",self, '_on_fail_ssl_handshake')
 
func __init() :
	#write code to check if node has been instanced
	self.set_process(true)
	enabled = true 
	print ('Check_timer :' , check_timer) #code breaks here and gives cant resolve hostname errors

	check_timer.set_name ('check_timer') 
	check_timer.autostart = true
	check_timer.one_shot = false
	check_timer.wait_time = 3

func stop_check():
	_connection += ' stop check '
	if not check_timer.is_stopped():
		check_timer.stop()
		self.cancel_request()
		return _connection

func start_check():
	_connection = str('start check')
	if check_timer.is_stopped():
		check_timer.start()


func _check_connection(url): 
	#Ignore Warning
	var error = self.request(url,PoolStringArray(),false,0,"") 
	_connection = str (' making request  ')  + str (' Request Error: ',error)
	print (' Networking Request Error: ',error) #for debug purposes only
	return _connection



func on_request_result(result, response_code, headers, body):
	match result:
		RESULT_SUCCESS:
			emit_signal("connection_success") 
			_connection =(str ('connection success')) 
		RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			emit_signal("error_connection_failed", RESULT_CHUNKED_BODY_SIZE_MISMATCH,'RESULT_CHUNKED_BODY_SIZE_MISMATCH')
			_connection =(str ('connection failed')) 
		RESULT_CANT_CONNECT:
			emit_signal("error_connection_failed",RESULT_CANT_CONNECT,'RESULT_CANT_CONNECT')
			_connection =(str ('connection failed')) 
		RESULT_CANT_RESOLVE:
			emit_signal("error_connection_failed",RESULT_CANT_RESOLVE,'RESULT_CANT_RESOLVE')
			_connection = (str ('connection failed')) 
		RESULT_CONNECTION_ERROR:
			emit_signal("error_connection_failed",RESULT_CONNECTION_ERROR,'RESULT_CONNECTION_ERROR')
			_connection =(str ('connection failed')) 
		RESULT_SSL_HANDSHAKE_ERROR:
			emit_signal("error_ssl_handshake")
			_connection = (str ('connection failed')) 
		RESULT_NO_RESPONSE:
			emit_signal("error_connection_failed",RESULT_NO_RESPONSE,'RESULT_NO_RESPONSE')
			_connection =(str ('connection failed')) 
		RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			emit_signal("error_connection_failed", RESULT_BODY_SIZE_LIMIT_EXCEEDED,'RESULT_BODY_SIZE_LIMIT_EXCEEDED')
			_connection =(str ('connection failed')) 
		RESULT_REQUEST_FAILED:
			emit_signal("error_connection_failed", RESULT_REQUEST_FAILED, 'RESULT_REQUEST_FAILED')
			_connection =(str ('connection failed')) 
		RESULT_DOWNLOAD_FILE_CANT_OPEN:
			emit_signal("error_connection_failed",RESULT_DOWNLOAD_FILE_CANT_OPEN,'RESULT_DOWNLOAD_FILE_CANT_OPEN')
			_connection =(str ('connection failed')) 
		RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			emit_signal("error_connection_failed", RESULT_DOWNLOAD_FILE_WRITE_ERROR, 'RESULT_DOWNLOAD_FILE_WRITE_ERROR')
			_connection =(str ('connection failed')) 
		RESULT_REDIRECT_LIMIT_REACHED:
			emit_signal("error_connection_failed",RESULT_REDIRECT_LIMIT_REACHED, 'RESULT_REDIRECT_LIMIT_REACHED')
			_connection =(str ('connection failed')) 
	#stop_check()
	
func _on_success():
	print('connection success!!')
	_connection = str ('connection success!!')
	

func _on_failure(code, message):
	print('Connection Failure !!\nCode: ', code,"Message:", message)
	_connection = str ('connection failed!!')


#func on_admob_init_failed():
#	push_error ('admob init failed')
#	_connection = str ('admob init failed')




func _on_fail_ssl_handshake():
	print('SSL Handshake Error!!')
	_connection = str ('ssl handshake error!!')



#controls the admob display
#func _admob(): #rewrite this code for appodeal
	
	#admob.set_name('admob')
	#admob.enabled = true
	#admob.is_real_set(true)
	#admob.banner_id = str('ca-app-pub-1198869974398081/1991292180')
	#admob.banner_on_top = false
	#admob.banner_size = ("SMART_BANNER")
	#admob.is_real_set(true)
	
	#print('Admob nodes:........', admob_nodes,'..........')
	#_connection = str('instancing admob')
	#admob.init()
	#admob.load_banner()
	#admob.show_banner()
	
	#print ('initializing admob ',"Admob: " ,admob, 'Singleton:',_ad)

	#stop_check()
#	pass


#func admob_failed():
#	_connection= str('admob failed')


#func admob_success():
#	_connection= str('admob success')

########################Unused Codes##################################


