# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Features:
# An interractible environment object
# SHows Random Hints to Player

# To Do:
# SHould connect to a signal from UI to trigger the UI once player is nearby
# *************************************************
# Bugs:
# (1) 
# (2) Displays A buggy Dialog Box is Outside Level (fixed)
# (3) Doesnt't Trigger UI changes in Touch HUD
# (4) Dialogue ended signal is being fored non-stop ( Dialogue ended is buggy)
# (5) Replace Player with Global Name by modifying forms.gd
# *************************************************


extends Area2D

class_name SignPost

"""
Displays A Dialogue Text When the Player comes near
"""

var interract : bool = false

export(bool) var enabled
export(String) var dialogue : String = ""
export(String) var speaker : String = ""




var frame_counter : int = 0



export (bool) var HINT #= false # Boolean conditional for hint system
export (bool) var triggered #= false # Boolean conditional for controlling signpost activation
func _ready():
	
	if enabled:
		
		#Connect All Signals
		# Method Not found
		#connect("area_entered", self, "_on_player_area_entered")
		#connect("area_exited", self, "_on_player_area_exited")
		
		if not (is_connected("body_entered",self, "_on_signpost_body_entered") &&
		is_connected("body_exited",self, "_on_signpost_body_exited")
		):
			connect("body_entered",self, "_on_signpost_body_entered")
			connect("body_exited",self, "_on_signpost_body_exited")
		

		
		# Dialogs
		
		Dialogs.connect("dialog_started", self, "_on_dialog_started")
		
		Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
		
		# Debug All Signals
		
		if not ( is_connected("area_entered", self, "_on_player_area_entered") and 
		is_connected("area_exited", self, "_on_player_area_exited") and
		is_connected("body_entered",self, "_on_signpost_body_entered") and
		is_connected("body_exited",self, "_on_signpost_body_exited") and
		Dialogs.is_connected("dialog_started", self, "_on_dialog_started") and
		Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended") 
		):
		
			push_error("Debug Connected Signals")


func show_signpost():
	if not is_instance_valid(Dialogs.dialog_box): # Error Catcher 1
		return
	
	#if interract && Globals.near_interractible_objects:
	print_debug("showing signpost")
	
	if HINT:
		# Shows Random Hints using a Dictionary shuffle algorithm
		dialogue = Music.shuffle(Dialogs.hints)
		# Translates them to the User's Language
		return Dialogs.dialog_box.show_dialog(
			Dialogs.translate_to( dialogue, Dialogs.language), 'Player'
			)
	elif not HINT:
		Dialogs.dialog_box.show_dialog(Dialogs.translate_to(dialogue, Dialogs.language), speaker)


func hide_signpost():
	print("hiding signpost")
	Dialogs.dialog_box.hide_dialogue()


# Detect Player
func _on_signpost_body_entered(body):
	if not body is Player:
		pass
	if body is Player:
		show_signpost()
		#activate(true)
		#print(" Player Body Entered ")
		print_debug ('player near signpost: ', Globals.near_interractible_objects)

# Error Method Not found
#func _on_player_area_exited(area):
#	if area.is_in_group("player_hurtbox"):
#		print(" Player Exited Area ")
#		#activate(false)


func _on_dialog_started():
	print_debug("signpost dialogue started")


func _on_dialog_ended():
	#print_debug("signpost dialogue ended")
	#activate(false)
	pass

func _on_signpost_body_exited(body):
	if not body is Player:
		return
	
	if body is Player:
		print_debug ('player near signpost: ', Globals.near_interractible_objects)
	

