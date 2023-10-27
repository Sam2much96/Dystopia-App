# *************************************************
# godot3-RPG by Samuel Harrison
# Released under MIT License
# *************************************************
# CLIENT-SIDE CODE
#
# Populate the login form and handle callbacks
# on buttons.
# To DO
#(1) should use player's wallet address
# 
# *************************************************
# Bugs
# (1) Multiplayer is buggy
# (2) Networking Packet is too Large
# *************************************************

extends Node

class_name lobbyV2

"""
I'LL BE CONNECTING STATIC METHODS FROM THE NETWORKING SINGLETON 
Code may be really hacky but will be thoughroughly Documented.
"""
onready var network = NetworkedMultiplayerENet.new()

func _ready():
	
	# Make UI Global
	Networking.UserInterface = $ui
	
	#Connect Lobby Signals
	Networking.Lobby.ConnectSignal(get_tree(), self)



func _on_play_pressed():
	# Connects UI Button Signals
	
	#address: LineEdit, ClientPeer: NetworkedMultiplayerENet, Lobby : SceneTree
	Networking.Lobby._on_join_pressed($ui/ScrollContainer/grid/address_text, network, get_tree())

func _on_host_pressed():
	# Connects UI Button Signals
	#peer : NetworkedMultiplayerENet, Lobby : SceneTree, host_button : Button, join_button : Button , dialog_box : DialogBox
	Networking.Lobby._on_host_pressed(network, get_tree(), $ui/ScrollContainer/grid/host, $ui/ScrollContainer/grid/play, $Dialog_box)


func _on_search_IP_pressed():
	Networking.Lobby._on_find_public_ip_pressed()


func _on_Back_Button_pressed():
	Globals._go_to_title()
