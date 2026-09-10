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
# (5) MMO Server DOesnt Spawn WOrld Map (fixed)
# *************************************************

extends Node

class_name lobbyV2

const DISCOVERY_PORT := 8911

@onready var network := ENetMultiplayerPeer.new()
@export var pub_ipaddr : String = "https://icanhazip.com/"
@export var my_ip : String = ""

# Lobby UI Items
@onready var c_react : ColorRect = $ColorRect
@onready var _host : Button = $ui/ScrollContainer/grid/host
@onready var _multiplayer_type : OptionButton = $ui/ScrollContainer/grid/input_game
@onready var _transport_type : OptionButton = $ui/ScrollContainer/grid/input_transport
@onready var _address_input : LineEdit = $ui/ScrollContainer/grid/address_text
@onready var _server_list : ItemList = $ui/ScrollContainer/grid/server_list

@export var DEDICATED_SERVER: bool

var _discovery_broadcast : PacketPeerUDP
var _discovery_broadcast_timer : Timer
var _discovery_listener : PacketPeerUDP
var _lan_result_ips : Dictionary = {} # ip -> item list index, for de-duping scan results


func _ready():
	for address in IP.get_local_addresses():
		if address.split(".").size() == 4:
			Networking.NetConfig.ip.append(address)

	Networking.Lobby.ConnectSignal(get_tree(), self)

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_joined.connect(_on_lobby_joined)

	_multiplayer_type.add_item("lan")
	_multiplayer_type.add_item("mmo")

	_transport_type.add_item("ENet")
	_transport_type.add_item("Steam")

	Networking.NetConfig.UserInterface = $ui

	_discovery_broadcast_timer = Timer.new()
	_discovery_broadcast_timer.wait_time = 1.0
	_discovery_broadcast_timer.timeout.connect(_broadcast_lan_announce)
	add_child(_discovery_broadcast_timer)

	if DEDICATED_SERVER:
		hide_lobby_UI_elements()
		Music._notification(NOTIFICATION_APPLICATION_PAUSED)
		_dedicated_server()


func _process(_delta: float) -> void:
	if _discovery_listener == null:
		return
	while _discovery_listener.get_available_packet_count() > 0:
		var packet := _discovery_listener.get_packet()
		var sender_ip := _discovery_listener.get_packet_ip()
		var parsed = JSON.parse_string(packet.get_string_from_utf8())
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("name"):
			_add_lan_result(sender_ip, str(parsed.name))


func _on_input_transport_item_selected(_idx: int) -> void:
	if _transport_type.get_selected() == 1:
		_address_input.placeholder_text = "Host Steam ID"
		_address_input.text = str(Steam.getSteamID())
	else:
		_address_input.placeholder_text = ""
		_address_input.text = "127.0.0.1"
	_server_list.clear()
	_lan_result_ips.clear()


func _on_play_pressed():
	print_debug("Play button pressed")
	if _multiplayer_type.get_selected() == 0:
		Networking.NetConfig.GamePlay = Networking.NetConfig.LOCAL_COOP
	elif _multiplayer_type.get_selected() == 1:
		Networking.NetConfig.GamePlay = Networking.NetConfig.MMO_SERVER

	if _transport_type.get_selected() == 1:
		var host_id := int(_address_input.get_text())
		Networking.Lobby._on_steam_join_pressed(host_id, get_tree(), $Dialog_box)
	else:
		Networking.Lobby._on_join_pressed(_address_input, network, get_tree())

	_stop_lan_discovery()
	hide_lobby_UI_elements()


func _on_host_pressed():
	if _multiplayer_type.get_selected() == 0:
		Networking.NetConfig.GamePlay = Networking.NetConfig.LOCAL_COOP
	elif _multiplayer_type.get_selected() == 1:
		Networking.NetConfig.GamePlay = Networking.NetConfig.MMO_SERVER

	if _transport_type.get_selected() == 1:
		Networking.Lobby._on_steam_host_pressed(get_tree(), Networking.NetConfig.MAX_PLAYERS, $Dialog_box)
	else:
		Networking.Lobby._on_host_pressed(network, get_tree(), _host, $ui/ScrollContainer/grid/play, $Dialog_box)
		_start_lan_broadcast()

	hide_lobby_UI_elements()


func hide_lobby_UI_elements():
	c_react.hide()


func _on_back_pressed():
	_stop_lan_discovery()
	Globals._go_to_title()


func _dedicated_server():
	Networking.NetConfig.GamePlay = Networking.NetConfig.MMO_SERVER
	print_debug("Gameplay Type: ", Networking.NetConfig.GamePlay)
	Networking.Lobby._on_host_pressed(network, get_tree(), _host, $ui/ScrollContainer/grid/play, $Dialog_box)
	_start_lan_broadcast()


"""
LAN DISCOVERY (ENet transport)
"""

func _start_lan_broadcast() -> void:
	_discovery_broadcast = PacketPeerUDP.new()
	_discovery_broadcast.set_broadcast_enabled(true)
	_discovery_broadcast.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	_broadcast_lan_announce()
	_discovery_broadcast_timer.start()


func _broadcast_lan_announce() -> void:
	if _discovery_broadcast == null:
		return
	var announce := {"name": Networking.NetConfig.cfg_player_name}
	_discovery_broadcast.put_packet(JSON.stringify(announce).to_utf8_buffer())


func _start_lan_scan() -> void:
	_server_list.clear()
	_lan_result_ips.clear()
	if _discovery_listener != null:
		return
	_discovery_listener = PacketPeerUDP.new()
	var err := _discovery_listener.bind(DISCOVERY_PORT)
	if err != OK:
		push_error("LAN discovery: failed to bind port %d (error %d)" % [DISCOVERY_PORT, err])
		_discovery_listener = null


func _stop_lan_discovery() -> void:
	_discovery_broadcast_timer.stop()
	if _discovery_broadcast != null:
		_discovery_broadcast.close()
		_discovery_broadcast = null
	if _discovery_listener != null:
		_discovery_listener.close()
		_discovery_listener = null


func _add_lan_result(ip: String, player_name: String) -> void:
	if _lan_result_ips.has(ip):
		return
	var idx := _server_list.add_item("%s (%s)" % [player_name, ip])
	_server_list.set_item_metadata(idx, {"type": "lan", "ip": ip})
	_lan_result_ips[ip] = idx


"""
REFRESH / SERVER LIST UI
"""

func _on_refresh_pressed() -> void:
	if _transport_type.get_selected() == 1:
		_server_list.clear()
		Networking.Lobby._on_steam_request_lobby_list()
	else:
		_start_lan_scan()


func _on_server_list_item_selected(index: int) -> void:
	var meta = _server_list.get_item_metadata(index)
	if typeof(meta) != TYPE_DICTIONARY:
		return
	if meta.get("type") == "lan":
		_address_input.text = meta.ip
	elif meta.get("type") == "steam":
		Steam.joinLobby(meta.lobby_id)


"""
STEAM LOBBY MATCHMAKING CALLBACKS
"""

func _on_lobby_created(connect_result: int, lobby_id: int) -> void:
	Networking.Lobby._on_steam_lobby_created(connect_result, lobby_id)


func _on_lobby_match_list(lobbies: Array) -> void:
	Networking.Lobby._on_steam_lobby_match_list(lobbies, _server_list)


func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int) -> void:
	Networking.Lobby._on_steam_lobby_joined(lobby, response, get_tree(), $Dialog_box)
