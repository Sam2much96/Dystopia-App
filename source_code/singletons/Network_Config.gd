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

signal connection_success
signal error_connection_failed(code,message)
signal error_ssl_handshake
signal game_finished
signal Timeout

@export var enabled : bool
@export var connection_debug: String
@export var cfg_server_ip : String 
@export var cfg_client_ip : String
#########################  Web browser codes  ############################3
@export var url : String = ''
var check_timer 
#var debug = ''
const WORLD_SIZE : int = 1000
@export var Data : Dictionary




var peer_id : int

var my_peer : ENetMultiplayerPeer
@export var ip : Array = []

#var camera #stores general camera variables
###############################multiplayer codes########################
# Debugs to Debugger Singleton
var multiplayer_client_debug
var multiplayer_server_debug

# Those variables are only used by the client-side application

var cfg_color : String = ""
var cfg_player_name : String = ""

#@onready var _reference_to_self =get_node('/root/Networking') #formerly _y
#@onready var _reference_to_debug =get_node('/root/Debug') #formerly _y

# Default hostname used by the login form
#const DEFAULT_HOSTNAME = "127.0.0.1"
const DEFAULT_HOSTNAME = "ws://localhost" # depreciated 
const BACKUP_HOSTNAME = "127.0.0.1" # depreciated
const SERVER_PORT = 9080
const MAX_PLAYERS = 4
@export var CLIENT_IP : String  

const TICK_DURATION = 50 # In milliseconds, it means 20 network updates/second





#var youtube_dl # Replace with GodotRustube


#**********Helper Booleans***********#
var running_request : bool = false
var Timeout_ : bool = false


#*********IPFS Gateway***************#
# from https://ipfs.github.io/public-gateway-checker/
# 1 ,2 , 3 work
@export var gateway : Array = [
	'gateway.ipfs.io', "dweb.link", "ipfs.io",
	"ipfs.runfission.com", "jorropo.net", "via0.com", 
	"cloudflare-ipfs.com", "hardbin.com"
	]

var random : int
var selected_gateway : String

@export var good_internet : bool

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


"Local Play or Multiplayer Parameters"
enum {OFFLINE, LOCAL_COOP, MMO_SERVER}
@export var GamePlay : int = LOCAL_COOP
