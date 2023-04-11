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


var cinematics : PackedScene = load('res://scenes/cinematics/cinematics.tscn')
var index : int = 0

#Saves player name and emaol address to global script
var player_name : String
var email_addr : String
var dialgue_box
var _debug
var play_button : Button

var label_spacer
var label_spacer2
var label_spacer3

var os : String

var result : int
var responsecode : int = 0
var body : PackedByteArray
var headers : PackedStringArray


func _init():
	translate()


func _ready():
	play_button = $ui/grid/play
	dialgue_box = $Dialog_box
	var language = $ui/grid/language
	########Label Spacer Codes Are Used For Aesthetics#########
	label_spacer = $ui/grid/label_spacer
	label_spacer2 = $ui/grid/label_spacer2
	label_spacer3 =$ui/grid/label_spacer3

	var timer = $Timer

	os = Globals.os
	_debug =get_tree().get_root().get_node("/root/Debug")

	
	
	if _debug != null:
		_debug = get_tree().get_root().get_node("/root/Debug")

	if Dialogs.language != "":
		get_tree().change_scene_to_packed(cinematics)

	

	#Adds 3 new languague selection
	language.add_item('English') 
	language.add_item('Brazilian Pt') 
	language.add_item('French')
	language.add_item('Telugi')
	language.add_item('Hindi')



	# Connects the Networking signal
	#Networking.connect("request_completed", _http_request_completed(result, responsecode, headers, body))


	"Disables the Play button Until Internet Access is Verified "

	#hide_play_button() 
	_check_if_device_is_online()




func _input(_event):
	dialgue_box.hide_dialogue()
	pass 



func _on_play_pressed():
	get_tree().change_scene_to_packed(cinematics)



"""
CHECKS IF THE DEVICE IS INTERNET CONNECTED AND GATEKEEPS ACCESS ON MOBILE DEVICES
"""
func _check_if_device_is_online(): 
	for i in Globals.platforms:
		if i == Globals.os:
		#disable x11 for release build
			index = index + 1
			dialgue_box.show_dialog('Checking for Internet Connectivity','admin')
			#Networking.url = 
			Networking._check_connection( 'https://mfts.io', Networking)#url('https://play.google.com/store/apps/details?id=dystopia.app')


func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if body.is_empty() != true:
		show_play_button()
		
		Networking.good_internet = true #aves the internet status as a global variable
		
		#dialgue_box.show_dialog('Device is internet connected','Admin')
		print ('Device is internet connected', result, response_code)
		return
	
	# Loop
	while body.is_empty() == true && index < 30:
		print ('No Internet Connection', result, response_code)
		index += 1
		_check_if_device_is_online()
		if _debug != null:
			
			get_tree().change_scene_to_packed( _debug.error_splash_page)
		
		#Resets Networking node
		Networking.stop_check()
		# Error splash page
		if index == 10:
			#dialgue_box.show_dialog('No Internet Connection','Admin') #not needed
			get_tree().change_scene_to_packed(_debug.error_splash_page)
	#		break


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
# https://phrase.com/blog/posts/godot-game-localization/

func translate()-> void:

	# For Debug Purposes only
	print ("Testing Translation te: ", Dialogs.translate_to("la", "te_IN"))
	
	
	
	print ("Testing Translation En: ",Dialogs.translate_to("char3", "en_US")) 
	print ("Testing Translation Es: ", Dialogs.translate_to("char3", "pt_BR"))
	print ("Testing Translation Fr: ", Dialogs.translate_to("char3", "fr"))
	print ("Testing Translation hi: ", Dialogs.translate_to("char3", "hi_IN"))
	#print ("Testing Translation te: ", Dialogs.translate_to("char1", "te"))
	print ("Testing Translation Error: ", Dialogs.translate_to("char7", "en"))



# Saves User's Language to Global Variable
func _on_language_item_selected(index):
	if index == 0:
		Dialogs.language = "en_US"
		#Globals.save_game()
	elif index == 1:
		Dialogs.language = "pt_BR"
		#Globals.save_game()
	elif index == 2:
		Dialogs.language = "fr"
		#Globals.save_game()
	elif index == 3:
		Dialogs.language = "te_IN"
	elif index == 4:
		Dialogs.language = "hi_IN"

	else : Dialogs.language = ""



func _exit_tree():
	print ("Selected Language: ",Dialogs.language)
