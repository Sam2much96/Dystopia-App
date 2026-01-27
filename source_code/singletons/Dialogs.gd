# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Dialogue singleton
# 
# To Do:
#(1) Write a documentation
#(2) 
#(3) Implement Portrait tiles
# (4) Implement Dialogue AutoHide Using Dialogue Frame Tmer
# *************************************************
# Features:

# (2) shows a dialogue function, hide_a dialogue function (1/2)
# (3) Has two signals for when dialogue starts and when it ends.
# (4) Translates between languages using a translation .csv file
# (5) Connects signals from Dialog Box and Connects Signals to Player Script

extends Node

class_name DialogsVar

"""
This is the Dialogs system. Any object can send text to it by doing Dialogs.show_dialog(text, speaker)

Before using it 'dialog_box' should be set to some node that implements the following
signal dialog_started
signal dialog_ended
func show_dialog(text, speaker)

This script will connect to those signals and use them to set 'active' to true or false and forward them to other nodes, 
so they can react to the dialog system being active(showing dialog) or inactive

Calls to show_dialog will be forwarded to the dialog_box which is free to implement them in any way (showing the text on screen,
using text to speech, etc)
"""


# what do these signals connect to?
signal singleton_dialog_started
signal singleton_dialog_ended

var active = false

var dialog_box : DialogBox = null setget _set_dialog_box

var language : String = ""# stores the current language the user selects

#var _script_testing : String = 'res://resources/dialogues/script_testing.gd'

const WAIT_TIME = 6 # Wait time before hiding dialogue box
# depreciated code logic
# Contains path to supported languague paired with supported language packs
#var font_pack : Dictionary = {
#"en":"res://fonts/Comic_Andy.ttf",
#"en_US": "res://fonts/Comic_Andy.ttf",
#"pt_BR": "res://fonts/Comic_Andy.ttf",
#"fr": "res://fonts/Comic_Andy.ttf",
#"ru_RU":"res://fonts/RussoOne-Regular.ttf",
#"hi_IN":"res://fonts/TiroDevanagariHindi-Regular.ttf",
#"yo_NG":"res://fonts/WarowniaBlkNrw.ttf",
#"ja":"res://fonts/NotoSerifJP-Regular.otf",
#"zh_CN":"res://fonts/NotoSerifJP-Regular.otf",
#"ar":"res://fonts/NotoSansArabic_Condensed-Bold.ttf",
#"W1":"res://Wallet fonts/Roboto-Medium.ttf"
#}

# to do:
# (1) finish theme packs for all supported locales
# (2) Test theme pack implementation
var theme_pack : Dictionary = {
"":"res://fonts/Dystopia-App-Light-en-theme.tres", # guard clause of empty dialog language variable
"en":"res://fonts/Dystopia-App-Light-en-theme.tres",
"en_US": "res://fonts/Dystopia-App-Light-en-theme.tres",
"pt_BR": "res://fonts/Dystopia-App-Light-en-theme.tres",
"fr": "res://fonts/Dystopia-App-Light-en-theme.tres",
"ru_RU":"res://fonts/Dystopia-App-Light-ru-theme.tres",
"hi_IN":"res://fonts/Dystopia-App-Light-hi_IN-theme.tres",
"yo_NG":"res://fonts/Dystopia-App-Light-yo_NG-theme.tres",
"ja":"res://fonts/Dystopia-App-Light-ja-theme.tres",
"zh_CN":"res://fonts/Dystopia-App-Light-zh_CN-theme.tres",
"ar":"res://fonts/Dystopia-App-Light-ar-theme.tres",
"W1":""
}

onready var custom_font = DynamicFont.new()

# Hints
# To Do: Implement Multiple Translations for Hint System using Spreadsheets
var hints : Dictionary = {0: "hint1",
1: "hint2",
2: "hint3",
3: "hint4",
4: "hint5",
5: "hint6",
6: "hint7"
}


func show_dialog(text:String, speaker:String):
	if is_instance_valid(dialog_box): # If an instance of dialogue box hasn't been deleted from memory?
		dialog_box.show_dialog(text, speaker, false)


func hide_dialogue(): #can be used to hide the dialogue box. Not best Practice
	if is_instance_valid(dialog_box): # If an instance of dialogue box hasn't been deleted from memory?
		dialog_box.hide_dialogue() # Trigger a hide function in it.


func _set_dialog_box(node : DialogBox):
	#if not node is DialogBox: # if not node is not of type node?
	#	push_error("provided node doesn't extend Dialogue Box") # push error
	#	return 
	
	dialog_box = node
	
	if dialog_box.get_script().has_script_signal("dialog_started"):
		dialog_box.connect("dialog_started", self, "_on_dialog_started")
	else:
		push_error("provided node doesn't implement dialog_started signal")
	
	if dialog_box.get_script().has_script_signal("dialog_ended"):
		dialog_box.connect("dialog_ended", self, "_on_dialog_ended")
	
	else:
		push_error("provided node doesn't implement dialog_started signal")



func _on_dialog_started():
	active = true
	emit_signal("singleton_dialog_started")

func _on_dialog_ended():
	if active:
		active = false
		emit_signal("singleton_dialog_ended")
		
		yield(get_tree().create_timer(WAIT_TIME), "timeout")
		# DIalogue Box Node Might Be Removed From Scene Tree After 6 Seconds Wait
		# This bloc Error Checks for any such occurences
		if is_instance_valid(dialog_box):
			dialog_box.hide_dialogue()


#depreciated in favour of ui translate funtion
# Uses the translate feature from the Form at res://scenes/UI & misc/form/form.tscn
# It parses from translations .csv and returns a string
# Edit the translation sources .ods file to expand translations
# should implement Language Based Font
#Documentation: https://www.gotut.net/localisation-godot/
#func translate_to(_language : String, locale: String)-> String:
#	
#	TranslationServer.set_locale(locale)
#	return (tr(_language))
#	#else: return ("sdgdsdhdh") # returns an empty string

func Ui_translate(node : Control): # works
	# Logic:
	# (1) Maps the language local to a theme that supports the font pack for that local
	# (2) Sets the theme on the parent node, automatically translating all children nodes
	
	# debug the ui theme
	TranslationServer.set_locale(language)
	print_debug("theme: ", node.get_theme(), "/", theme_pack[language] , "/", language, "/", TranslationServer.get_locale())
	node.set_theme(load(theme_pack[language]))
	#print_debug("theme 2: ", node.get_theme())

func reset() -> void:
	# Resets Dialogue Key Variables
	language = ""




