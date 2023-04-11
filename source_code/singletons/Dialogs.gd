# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Dialogue singleton
# I sure as fvck don't know what it does. Ama fuck around and find out!
# To Do:
#(1) Write a documentation
#(2) Connect it to dialogic addon
# *************************************************
# fEATURES:
#(1) Converts Text to speech
# (2) shows a dialogue function, hide_a dialogue function (1/2)
# (3) Has two signals for when dialogue starts and when it ends.
# (4) Translates between languages using a translation .csv file

#Questions. WHy not just make it a class instead?
# why all the complicated codes

extends Node

#####INSTRUCTIONALS___________________#######
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

signal dialog_started
signal dialog_ended

var active = false

# Set Get Implementation in Godot 4 Docs: https://godotengine.org/qa/137477/how-to-use-godot-4-setget

#var dialog_box = null setget _set_dialog_box
@onready var dialog_box : DialogBox = null : set = _set_dialog_box , get =_get_dialog_box

var language : String = ""# stores the current language the user selects

func show_dialog(text:String, speaker:String):
	if is_instance_valid(dialog_box): # If an instance of dialogue box hasn't been deleted from memory?
		dialog_box.show_dialog(text, speaker)

func hide_dialogue(): #can be used to hide the dialogue box. Not best Practice
	if is_instance_valid(dialog_box): # If an instance of dialogue box hasn't been deleted from memory?
		dialog_box.hide_dialogue() # Trigger a hide function in it.


func _set_dialog_box(dialog_box : DialogBox):
	if not dialog_box is DialogBox: # if not node is not of type node?
		push_error("provided node doesn't extend Node") # push error
		return 
	
	
	#dialog_box = node
	
	print (dialog_box) # for debug purposes only
	
	if dialog_box.get_script().has_script_signal("dialog_started"):
		
		dialog_box.connect("dialog_started", _on_dialog_started)
		#dialog_box.connect_signal_A()
	else:
		push_error("provided node doesn't implement dialog_started signal")
		
	if dialog_box.get_script().has_script_signal("dialog_ended"):
		dialog_box.connect("dialog_ended", _on_dialog_ended)
		#dialog_box.connect_signal_B()
	else:
		push_error("provided node doesn't implement dialog_started signal")
		
	#pass

# currently unused get function
func _get_dialog_box():
	pass

var _on_dialog_started = func _on_dialog_started():
	active = true
	emit_signal("dialog_started")
	print ("dialog started")

var _on_dialog_ended = func _on_dialog_ended():
	active = false
	emit_signal("dialog_ended")
	print("dialog ended")




#Documentation: https://www.gotut.net/localisation-godot/
func translate_to(_language : String, locale: String)-> String:
	
	TranslationServer.set_locale(locale)
	#print (TranslationServer.get_loaded_locales() ) # for debug purposes only
	print (TranslationServer.get_locale())
	return (tr(_language))


