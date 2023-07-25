# *************************************************
# godot3-spacegame by Yanick Bourbeau
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
# (1) Multiplayer Doesn't Work
# (2) WebRTC library is depreciated
# *************************************************
extends CanvasLayer


class_name lobby

"UI inputs buttons"
onready var input_color : OptionButton = $ui/ScrollContainer/grid/input_color 
onready var input_player : LineEdit =$ui/ScrollContainer/grid/text_player
onready var input_hostname : LineEdit = $ui/ScrollContainer/grid/text_hostname

onready var animation : AnimationPlayer= $AnimationPlayer

func _ready():
	# Adding four spaceship colors
	input_color.add_item("Blue") #tweak this code
	input_color.add_item("Red") #used to separate players into colour codes
	input_color.add_item("Green")
	input_color.add_item("Yellow")
	
	# Set default hostname
	input_hostname.text = Networking.DEFAULT_HOSTNAME
	
	#scale up UI with global script
	if Globals.os == "Android" && Globals.screenOrientation == 1: 
		#Globals.upscale_wallet_ui($ui,'XL')
		animation.play("HORIZONTAL_SCREEN")
	else: animation.play("VERTICAL_SCREEN")

# Callback function for "Start!" button
func _on_button_login_pressed(): #others join
	
	# Store information about spaceship color and player name #modify #spaceship colour to player colour
	#Networking.cfg_color = input_color.text
	Networking.cfg_player_name = input_player.text + str(Globals.address)
	
	# Lookup hostname and store resolved IP
	#Networking.cfg_server_ip = IP.resolve_hostname(input_hostname.text) (depreciated)
	Networking.cfg_client_ip = input_hostname.text
	
	print ("Client Networking IP :", Networking.cfg_client_ip)
	
	
	# Change to client scene
	if get_tree().change_scene("res://New game code and features/multiplayer/scenes/client.tscn") != OK:
		push_error("Unable to load client scene!")

# Callback function for "Start Server" button
# COnnets to 0:0:0:0:0:0:0:0  by default cuz of converstions of web url string to IP
func _on_button_start_server_pressed(): #someone starts the server #inhumanity
	Networking.cfg_server_ip = input_hostname.text
	
	print ("Server Networking IP :", Networking.cfg_server_ip)
	
	# Change to server scene
	if get_tree().change_scene("res://New game code and features/multiplayer/scenes/server.tscn") != OK:
		push_error("Unable to load server scene!")




func _on_Twitter_Button_pressed():
	return OS.shell_open('https://twitter.com/dystopiaO')


func _on_Back_Button_pressed():
	get_tree().change_scene_to(Globals.title_screen)
