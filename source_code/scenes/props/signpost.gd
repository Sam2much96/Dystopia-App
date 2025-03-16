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
# (1) Dialog box bugs out if there's a single error in the script
# (2) 
# (3) Doesnt't Trigger UI changes in Touch HUD
# (4) 
# (5) Replace Player with Global Name / Wallet Address by modifying forms.gd
# *************************************************


extends Area2D

class_name SignPost

"""
Displays A Dialogue Text When the Player comes near
"""

export(bool) var enabled
export(String, MULTILINE) var dialogue : String = ""
export(String) var speaker : String = ""


export (bool) var HINT #= false # Boolean conditional for hint system
export (bool) var DECISION 
func _ready():
	
	if enabled:
		
		#Connect All Signals
		
		
		if not (is_connected("body_entered",self, "_on_signpost_body_entered") &&
		is_connected("body_exited",self, "_on_signpost_body_exited")
		):
			connect("body_entered",self, "_on_signpost_body_entered")
			connect("body_exited",self, "_on_signpost_body_exited")
		
		
		# Debug All Signals
		
		if not ( is_connected("area_entered", self, "_on_player_area_entered") and 
		is_connected("area_exited", self, "_on_player_area_exited") and
		is_connected("body_entered",self, "_on_signpost_body_entered") and
		is_connected("body_exited",self, "_on_signpost_body_exited") and
		Dialogs.is_connected("dialog_started", self, "_on_dialog_started") and
		Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended") 
		):
		
			push_warning("Debug Connected Signals")


func show_signpost():
	if not is_instance_valid(Dialogs.dialog_box): # Error Catcher 1
		return
	
	#print_debug("showing signpost")
	
	if HINT:
		# Shows Random Hints using a Dictionary shuffle algorithm
		dialogue = Music.shuffle(Dialogs.hints)
		# Translates them to the User's Language
		return Dialogs.dialog_box.show_dialog(
			Dialogs.translate_to( dialogue, Dialogs.language), 'Player', false
			)
	if !HINT:
		Dialogs.dialog_box.show_dialog(Dialogs.translate_to(dialogue, Dialogs.language), speaker, false)
	
	if DECISION:
		Dialogs.dialog_box.show_dialog(Dialogs.translate_to(dialogue, Dialogs.language), speaker, true)
	
	
	

func hide_signpost():
	print("hiding signpost")
	Dialogs.dialog_box.hide_dialogue()


# Detect Player
func _on_signpost_body_entered(body):
	if not body is Player:
		pass
	if body is Player:
		show_signpost()
		
		#print_debug ('player near signpost ')


# Unused Dialog Exit Code
# Dialog Hide is triggered instead from the Dialog box code
func _on_signpost_body_exited(body):
	if not body is Player:
		return
	
	if body is Player:
		#print_debug ('player near signpost')
		return


func _exit_tree():
	Utils.MemoryManagement.free_object(self) # Memory Management for All Dialog Triggers
