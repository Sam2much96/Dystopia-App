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
# (4) It implements Translations UI
# (5) It is only Called Once and sets the user's pre-entered Languague for the Duration of the Match
# *************************************************
# To Do:
# (1) Only show once, when installing file. Should Save Information to Globals save file and only Load once



extends CanvasLayer


class_name Login

"""
This is a gate-keeper script to keep check user's internet connections, restrict their access
"""
var film : String = Globals.global_scenes["cinematics"]

var cinematics : PackedScene = load(film) # Bug : 
#var index : int = 0

onready var play_button : Button = $ui/grid/play
#onready var dialgue_box = $Dialog_box
onready var language : OptionButton = $ui/grid/language

########Label Spacer Codes Are Used For Aesthetics#########
onready var label_spacer : Label = $ui/grid/label_spacer
onready var label_spacer2 : Label = $ui/grid/label_spacer2
onready var label_spacer3 : Label =$ui/grid/label_spacer3



onready var UI_buttons : Array 

func _ready():

	UI_buttons = [
		play_button,  
		language, label_spacer, 
		label_spacer2, label_spacer3
	]
	
	Utils.UI.check_for_broken_links(UI_buttons)
	
	# Load Users Prefered DIalogue 
	Utils.Functions.load_user_data('languague')
	
	
	# Load Users Prefered DIalogue 
	#Globals.Functions.load_user_data('Music_on_settings')
	
	# If Dialogue Already Preset, Skip to Cinematics.
	print_debug("User Preloaded Language: ", Dialogs.language)
	print_debug("Changing to Cinematics")
	if not Dialogs.language.empty() :
		#get_tree().change_scene_to(cinematics)
		Utils.Functions.change_scene_to(cinematics, get_tree())
	

	#Adds 3 new languague selection
	language.add_item('English') 
	language.add_item('Brazilian Portuguese') 
	language.add_item('French')
	language.add_item('Telugu')
	language.add_item('Hindi')
	language.add_item('Japanese')
	language.add_item('Mandarin')
	language.add_item('Yoruba')
	language.add_item('Arabic')


	
	#translate()


	#print_debug("Globals scenes and level debug:", Globals.curr_scene, "/", Globals.current_level)
	#print_debug("Check if the current scene is a global scene: ", Globals.global_scenes.has(Globals.curr_scene))


func _on_play_pressed():
	
	# Saves User's Language to Global Variable
	# Language Sub system has to be reworked to load/create font packs for every supported Languague
	
	
	if language.get_selected() == 0:
		Dialogs.language = "en_US"
		#Globals.save_game()
	elif language.get_selected() == 1:
		Dialogs.language = "pt_BR"
		#Globals.save_game()
	elif language.get_selected() == 2:
		Dialogs.language = "fr"
	elif language.get_selected() == 3:
		Dialogs.language = "te_IN"
	elif language.get_selected() == 4:
		Dialogs.language = "hi_IN"
	elif language.get_selected() == 5:
		Dialogs.language = "ja"
	elif language.get_selected() == 6:
		Dialogs.language = "zh_CN"
	elif language.get_selected() == 7:
		Dialogs.language = "yo_NG"
	elif language.get_selected() == 8:
		Dialogs.language = "ar"
		#Globals.save_game()
	else : Dialogs.language = ""

	#print_debug(Dialogs.language) # for debug purposes only

	Utils.Functions.change_scene_to(cinematics, get_tree())



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
	print ("En: ",Dialogs.translate_to("char3", "en_US")) 
	print ("Es: ", Dialogs.translate_to("char3", "pt_BR"))
	print ("Es: ", Dialogs.translate_to("char3", "fr"))
	print ("Te: ", Dialogs.translate_to("char3", "te_IN")) # Not working i 3.5 only in 4.0
	print ("hi: ", Dialogs.translate_to("char3", "hi_IN"))
	print ("ja: ", Dialogs.translate_to("char3", "ja"))
	print ("cn: ", Dialogs.translate_to("char3", "zh_CN"))
	print ("yo: ", Dialogs.translate_to("char3", "yo_NG"))
	print_debug ("Error: ", Dialogs.translate_to("char7", "en"))




func _exit_tree():
	print_debug ("Selected Language: ",Dialogs.language)
	
	Utils.MemoryManagement.queue_free_array(UI_buttons)
