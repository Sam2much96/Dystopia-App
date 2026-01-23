# *************************************************
# godot4-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Network Config
# All Networking & Multiplayer Configuration Variables in One resource class
#
# *************************************************

extends Resource

class_name Network_Config


export (bool) var enabled
export(String) var connection_debug
export (String) var cfg_server_ip 
export (String) var cfg_client_ip 
#########################  Web browser codes  ############################3
export (String) var url : String = ''
var check_timer 
#var debug__ = ''
var WORLD_SIZE : int = 1000





var peer_id : int

var my_peer : NetworkedMultiplayerENet
export (Array) var ip : Array = []

#var camera #stores general camera variables
###############################multiplayer codes########################
# Debugs to Debugger Singleton
var multiplayer_client_debug
var multiplayer_server_debug

# Those variables are only used by the client-side application

var cfg_color : String = ""
var cfg_player_name : String = ""





signal connection_success
signal error_connection_failed(code,message)
signal error_ssl_handshake
signal game_finished
signal Timeout

#onready var world #= get_tree().get_nodes_in_group('online_world').pop_front()

#onready var Wallet_ : wallet
#onready var _reference_to_self = self#get_node('/root/Networking') #formerly _y
#onready var _reference_to_debug =get_node('/root/Debug') #formerly _y

# Default hostname used by the login form
#const DEFAULT_HOSTNAME = "127.0.0.1"
const DEFAULT_HOSTNAME = "ws://localhost" # depreciated 
const BACKUP_HOSTNAME = "127.0.0.1" # depreciated
const SERVER_PORT = 9080
const MAX_PLAYERS = 4
#export (String) var CLIENT_IP : String  
export (Dictionary) var Data : Dictionary


const TICK_DURATION = 50 # In milliseconds, it means 20 network updates/second





#var youtube_dl # Replace with GodotRustube


#**********Helper Booleans***********#
var running_request : bool = false
var Timeout : bool = false



var random : int

export (bool) var good_internet : bool

# Lobby UI
var UserInterface : Control

# Multiplayer map
var map_instance : Node2D

# Server Update ID
var update_id : int = -1

# Raw Player Info Data

var RawJson 
#var peer_ids : Array

# World Root Node
var WorldRoot : Node

#const WORLD_SIZE = 1000
"Local Play or Multiplayer Parameters"
enum {OFFLINE, LOCAL_COOP, MMO_SERVER}
export (int) var GamePlay = OFFLINE

