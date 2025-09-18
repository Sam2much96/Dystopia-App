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
# (6) Connects to menu Object stae via signals
# *************************************************
# To Do:
# (1) Only show once, when installing file. Should Save Information to Globals save file and only Load once
# (2) Add and store player's name
# (3) Lock all UI elementss into single global Control themes
# (4) Store font data to theme, and a theme manager that sychnornised selected parent theme with language server locale

# Bug:
# (0) Fix entire game dialogue translation and translation files
# (1) Save Function overwrites presaved file
# (2) Game Translate is broken and needed for the game's screenshots
# (3) Game User Language doesn't save
# (4) The entire game translation UI requires an Audit 



extends CanvasLayer


class_name Login

"""
This is a gate-keeper script to keep check user's internet connections, restrict their access
"""

# safe pointer to global singletons
onready var safe_Globals = get_node("/root/Globals")
onready var safe_Utils = get_node("/root/Utils")
onready var safe_Diag = get_node("/root/Dialogs")

onready var film : String = safe_Globals.global_scenes.get("cinematics")

onready var cinematics : PackedScene = load(film) # Bug : 
#var index : int = 0
onready var Art : TextureRect = $TextureRect
#onready var coinText : TextureRect = $TextureRect
onready var ui_Node : Control = $ui
onready var play_button : Button = $ui/grid/PlayButton/play
#onready var dialgue_box = $Dialog_box
onready var language : OptionButton = $ui/grid/language

########Label Spacer Codes Are Used For Aesthetics#########
onready var label_spacer : Label = $ui/grid/label_spacer
onready var label_spacer2 : Label = $ui/grid/label_spacer2
onready var label_spacer3 : Label =$ui/grid/label_spacer3

onready var UI_buttons : Array 
onready var safe_GameHUD : GameHUD = get_node("/root/GameHud")
onready var gameMenu = safe_GameHUD.getMenu()

func _ready():

	UI_buttons = [
		play_button, ui_Node,  
		language, label_spacer, 
		label_spacer2, label_spacer3, Art
	]
	
	safe_Utils.UI.check_for_broken_links(UI_buttons)
	
	# temporarily disabled for refactoring on September 17, 20225
	# check for saved data, if there is, load the code data files and change to cinematics
	#if safe_Utils.Functions.hasSave(safe_Utils.file):
		# load all user data individually
		# 
		
	#	safe_Utils.Functions.load_user_data('languague', get_tree())
		#safe_Utils.Functions.load_user_data('music', get_tree())
		
		# change tree to cinematics
	#	go_to_cinematics()
	# Load Users Prefered Dialogue settings
	
	
	
	# Visibility signals
	# connect game Menu visibility signals to this node's visibility
	if is_instance_valid(gameMenu):
		gameMenu.connect("menu_showing",ui_Node,"hide")
		gameMenu.connect("menu_hidden",ui_Node,"show")
		
	if !is_instance_valid(gameMenu):
		push_error("Debug Game Menu / Form signal connections")
	
	
	# Load Users Prefered DIalogue 
	#Globals.Functions.load_user_data('Music_on_settings')
	
	# If Dialogue Already Preset, Skip to Cinematics.
	#print_debug("User Preloaded Language: ", safe_Diag.language)
	#print_debug("Changing to Cinematics")
	if not safe_Diag.language.empty() :
		#get_tree().change_scene_to(cinematics)
		safe_Utils.Functions.change_scene_to(cinematics, get_tree())
	

	#Adds 3 new languague selection
	language.add_item('English') 
	language.add_item('Brazilian Portuguese') 
	language.add_item('French')
	language.add_item('Russian')
	language.add_item('Hindi')
	language.add_item('Japanese')
	language.add_item('Mandarin')
	language.add_item('Yoruba')
	language.add_item('Arabic')


	
	#translate()


	#print_debug("Globals scenes and level debug:", Globals.curr_scene, "/", Globals.current_level)
	#print_debug("Check if the current scene is a global scene: ", Globals.global_scenes.has(Globals.curr_scene))


func _on_play_pressed():
	

	
	go_to_cinematics()
	
func go_to_cinematics():
	safe_Utils.Functions.change_scene_to(cinematics, get_tree())


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
	print ("Te: ", Dialogs.translate_to("char3", "ru_RU")) # Not working i 3.5 only in 4.0
	print ("hi: ", Dialogs.translate_to("char3", "hi_IN"))
	print ("ja: ", Dialogs.translate_to("char3", "ja"))
	print ("cn: ", Dialogs.translate_to("char3", "zh_CN"))
	print ("yo: ", Dialogs.translate_to("char3", "yo_NG"))
	print_debug ("Error: ", Dialogs.translate_to("char7", "en"))




func _exit_tree():
	print_debug ("Selected Language: ",safe_Diag.language)
	safe_Utils.Functions.save_game(get_tree())
	safe_Utils.MemoryManagement.queue_free_array(UI_buttons)




func _on_language_item_selected(index):
	# connected to language select option buttons
	# should trigger language change by appylying theme to root object
	# Saves User's Language to Global Variable
	# Language Sub system has to be reworked to load/create font packs for every supported Languague
	
	
	if index == 0:
		safe_Diag.language = "en_US"
		#Globals.save_game()
	elif index == 1:
		safe_Diag.language = "pt_BR"
		#Globals.save_game()
	elif index == 2:
		safe_Diag.language = "fr"
	elif index == 3:
		safe_Diag.language = "ru_RU"
	elif index == 4:
		safe_Diag.language = "hi_IN"
	elif index == 5:
		safe_Diag.language = "ja"
	elif index == 6:
		safe_Diag.language = "zh_CN"
	elif index == 7:
		safe_Diag.language = "yo_NG"
	elif index == 8:
		safe_Diag.language = "ar"
		#Globals.save_game()
	else : safe_Diag.language = ""
	
	print_debug("selected language: ", safe_Diag.language) # for debug purposes only
	manually_translate()

func manually_translate():
	# pass the parent node to the dialogs singleton
	# to match the user language with the language theme
	safe_Diag.Ui_translate(ui_Node)

