# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Description:
# This is a login form to gatekeep the app
# Features
# (1) It check for user's internet access
# (2)It triggers an error splash page in the debug script if user is offline
# (3) It aids monetization through online advertising on Mobile
# *************************************************
# To Do:
# (1) Languague functionality to convert to various languages via a global script variable or a state machine
		# How?
		#parse a csv file and trigger language functions / states through the dialogue singleton at res://singletons/Dialogs.gd
extends CanvasLayer
"""
This is a gate-keeper script to keep check user's internet connections, restrict their access
"""
####


var cinematics = load('res://scenes/cinematics/cinematics.tscn')
var index : int = 0

#Saves player name and emaol address to global script
var player_name : String
var email_addr : String
onready var play_button : Button = $ui/grid/play
onready var dialgue_box = $Dialog_box
onready var language = $ui/grid/language
########Label Spacer Codes Are Used For Aesthetics#########
onready var label_spacer = $ui/grid/label_spacer
onready var label_spacer2 = $ui/grid/label_spacer2
onready var label_spacer3 =$ui/grid/label_spacer3

onready var timer = $Timer

var os = Globals.os
onready var _debug =get_tree().get_root().get_node("/root/Debug")
func _ready():
	if _debug != null:
		_debug = get_tree().get_root().get_node("/root/Debug")
#Adds 3 new languague selection
	language.add_item('English') 
	language.add_item('Brazil') 
	#language.add_item('Nigerian Pidgin')

	# Connects the Networking signal
	Networking.connect("request_completed", self, "_http_request_completed")


	"Disables the Play button Until Internet Access is Verified "

	hide_play_button() 


	_check_if_device_is_online()

	translate()

func check_for_player_id(): #loads the player id details if it exists and skips this login.
	#Globals.load_game()
	#Email and player name are optional and should only be used to send bug reports
	pass





func _input(_event):

	dialgue_box.hide_dialogue()
	


func _on_play_pressed():
	get_tree().change_scene_to(cinematics)



"""
CHECKS IF THE DEVICE IS INTERNET CONNECTED AND GATEKEEPS ACCESS ON MOBILE DEVICES
"""
func _check_if_device_is_online(): 
	if os == 'Android' or 'iOS' or 'X11': #disable x11 for release build
		index = index + 1
		dialgue_box.show_dialog('Checking for Internet Connectivity','admin')
		#Networking.url = 
		Networking._check_connection( 'https://mfts.io', Networking)#url('https://play.google.com/store/apps/details?id=dystopia.app')


func _http_request_completed(result, response_code, headers, body):
	if body.empty() != true:
		show_play_button()
		
		Networking.good_internet = true #aves the internet status as a global variable
		
		dialgue_box.show_dialog('Device is internet connected','Admin')
		print ('Device is internet connected', result, response_code)
		return
	# Loop
	while body.empty() == true && index < 30:
		print ('No Internet Connection', result, response_code)
		index += 1
		_check_if_device_is_online()
		if _debug != null:
			
			get_tree().change_scene_to( _debug.error_splash_page)
		
		#Resets Networking node
		Networking.stop_check()
		# Error splash page
		if index == 10:
			#dialgue_box.show_dialog('No Internet Connection','Admin') #not needed
			get_tree().change_scene_to(_debug.error_splash_page)
			break


func show_play_button() :
	play_button.show()
	label_spacer.show()
	label_spacer3.show()
	label_spacer2.hide()
	
	#dialgue_box.hide()

func hide_play_button():
	play_button.hide()
	label_spacer.hide()
	label_spacer3.hide()
	label_spacer2.show()

"""
TRANSLATES THE ENTIRE APP TO ONE OF THE PRESELECTED lANGUAGUES INDICATED
"""
#Documentation: https://www.gotut.net/localisation-godot/

func translate()-> void:

	# For Debug Purposes only
	print ("Testing Translation En: ",Dialogs.translate_to("char3", "en_US")) 
	print ("Testing Translation Es: ", Dialogs.translate_to("char3", "pt_BR"))
	print ("Testing Translation Error: ", Dialogs.translate_to("char7", "en"))

