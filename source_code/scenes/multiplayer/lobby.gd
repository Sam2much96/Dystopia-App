# *************************************************
# godot3-RPG by Samuel Harrison
# Released under MIT License
# *************************************************
# LOBBY SETUP CODE
#
# Sets up lobby for online multiplayer matches
# 
# To DO
# (1) should use player's wallet address as default id
# (2) should parse the server's public id to the ui
# (3) Test Both Online MMO and Local Coop with 3-5 Players and fix all bugs
# (4) Dedicated Server Logic implementation
# *************************************************
# Bugs
# (1) Multiplayer is buggy (2/3)
# (2) Networking Packet is too Large (1/3)
# (3) Add Music Select For Local COop
# (4) MMO Player Instance is buggy (fixed)
# (5) MMO Server DOesnt Spawn WOrld Map
# *************************************************

extends Node

class_name lobbyV2

"""
I'LL BE CONNECTING STATIC METHODS FROM THE NETWORKING SINGLETON 
Code may be really hacky but will be thoughroughly Documented.
"""
@onready var network = ENetMultiplayerPeer.new()
@export (String) var pub_ipaddr = "https://icanhazip.com/" # used in match making to 
@export (String) var my_ip : String = ""

# Lobby UI Items
@onready var c_react : ColorRect = $ColorRect
#onready var image_tex : TextureRect = $TextureRect

# Host Button for Server
@onready var _host : Button = $ui/ScrollContainer/grid/host

# Selector for Local Lan or Online mmo 
@onready var _multiplayer_type : OptionButton = $ui/ScrollContainer/grid/input_game

@export var DEDICATED_SERVER: bool 


func _ready():
	" Get Local IP Addresses"
	for address in IP.get_local_addresses():
		if (address.split(".").size() == 4):
			#print_debug(address)
			Networking.ip.append(address)
		
	
	"Connect Lobby Signals"
	Networking.Lobby.ConnectSignal(get_tree(), self)
	
	# Add Multiplayer Options
	_multiplayer_type.add_item("lan")
	_multiplayer_type.add_item("mmo")
	
	# Make UI Global
	Networking.UserInterface = $ui
	
	#Request For Public Arrderss Depreciated
	
	# Connect Networking Signals
	#Networking.connect("request_completed", self, "_on_search_IP")
	
	# 
	#Networking.request(pub_ipaddr)

	

	
	# UI Scaling on mobile Devices 
			#Quick Fix for Upscaing
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		#if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		var newScale = Vector2(2,2)
		var newPosition = Vector2(-650,250)
		Utils.UI.upscale_ui($ui, newScale, newPosition)
		
	# SHould Hide The Host Button for Online MMO
	# 
	if Networking.GamePlay == Networking.MMO_SERVER:
		_host.hide()
		
	
	if DEDICATED_SERVER:
		# hide ui
		hide_lobby_UI_elements()
		
		# turn off music
		Music._notification(NOTIFICATION_APPLICATION_PAUSED)
		
		# host server
		_dedicated_server()
	
	

func _on_play_pressed():
	
	"""
	SELECT SERVER TYPE
	"""
	if _multiplayer_type.get_selected() == 0:
		Networking.GamePlay = Networking.LOCAL_COOP
	elif _multiplayer_type.get_selected() == 1:
		Networking.GamePlay = Networking.MMO_SERVER

	
	# Connects UI Button Signals
	
	#address: LineEdit, ClientPeer: NetworkedMultiplayerENet, Lobby : SceneTree
	Networking.Lobby._on_join_pressed($ui/ScrollContainer/grid/address_text, network, get_tree())
	hide_lobby_UI_elements()

func _on_host_pressed():
	"""
	SELECT SERVER TYPE
	"""
	if _multiplayer_type.get_selected() == 0:
		Networking.GamePlay = Networking.LOCAL_COOP
	elif _multiplayer_type.get_selected() == 1:
		Networking.GamePlay = Networking.MMO_SERVER

	
	# Connects UI Button Signals
	#peer : NetworkedMultiplayerENet, Lobby : SceneTree, host_button : Button, join_button : Button , dialog_box : DialogBox
	Networking.Lobby._on_host_pressed(network, get_tree(), $ui/ScrollContainer/grid/host, $ui/ScrollContainer/grid/play, $Dialog_box)
	hide_lobby_UI_elements()


func hide_lobby_UI_elements():
	c_react.hide()


func _on_back_pressed():
	Globals._go_to_title()


func _dedicated_server():
	# Hosts the Server at run time
	# select game type with option id instead
	Networking.GamePlay = Networking.MMO_SERVER # Run Logic For MMO Server
	
	print_debug("Gameplay Type",Networking.GamePlay)
	
	
	Networking.Lobby._on_host_pressed(network, get_tree(), $ui/ScrollContainer/grid/host, $ui/ScrollContainer/grid/play, $Dialog_box)
