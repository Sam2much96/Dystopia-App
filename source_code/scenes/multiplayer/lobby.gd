# *************************************************
# godot3-RPG by Samuel Harrison
# Released under MIT License
# *************************************************
# CLIENT-SIDE CODE
#
# Populate the login form and handle callbacks
# on buttons.
# To DO
# (1) should use player's wallet address as default id
# (2) should parse the server's public id to the ui
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
export (String) var pub_ipaddr = "https://icanhazip.com/" # used in match making to 
export (String) var my_ip : String = ""
func _ready():
	
	# Make UI Global
	Networking.UserInterface = $ui
	
	# Connect Networking Signals
	#Networking.connect("request_completed", self, "_on_search_IP")
	
	#Networking.request(pub_ipaddr)
	for address in IP.get_local_addresses():
		if (address.split(".").size() == 4):
			#print_debug(address)
			Networking.ip.append(address)
	
	
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


#func _on_search_IP(result, response_code, headers, body):
	# run this code automatically and parse it to Dialogues UI
	# only works if internaet connected innit?

	# Finds Device Public IP Address from a WebSite
	#static func _on_find_public_ip_pressed() :
	#return OS.shell_open("https://icanhazip.com/")
	# runa http request to get ip data from this site
	#print_debug(body.get_string_from_utf8())
#	my_ip = body.get_string_from_utf8()
	
#	print_debug(my_ip)
	
	# make my pub ip global
#	Networking.CLIENT_IP = Networking.ip[0]
	
	#Dialogs.show_dialog("Clients Sould Connect To" + my_ip,"Admin")
	


func _on_Back_Button_pressed():
	Globals._go_to_title()
