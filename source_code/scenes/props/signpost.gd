# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Features:
# An interractible environment object
# Disabled for performance optimization

# To Do:
# SHould connect to a signal from UI to trigger the UI once player is nearby
# *************************************************
# Bugs:
# (1) 
# (2) Displays A buggy Dialog Box is Outside Level (fixed)
# (3) Doesnt't Trigger UI changes in Touch HUD
# (4) Dialogue ended signal is being fored non-stop ( Dialogue ended is buggy)
# *************************************************


extends Area2D

class_name SignPost

"""
Displays A Dialogue Text When the Player comes near
"""

var interract : bool = false

export(bool) var enabled
export(String) var dialogue = ""



enum {SHOWING, HIDING}

export (int) var state_ = HIDING

var frame_counter : int = 0

export (bool) var triggered #= false # Boolean conditional for controlling signpost activation
func _ready():
	
	if enabled:
		
		#Connect All Signals
		connect("area_entered", self, "_on_player_area_entered")
		connect("area_exited", self, "_on_player_area_exited")
		
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

func _process(delta):
	
	if enabled:
		
		frame_counter += 1
		
		# Frame counter
		if frame_counter  > 1000:
			frame_counter = 0
		
		
		if frame_counter % 1 ==0 : # Every frame
		
			# SIgnpost State Machine
			match state_:
				SHOWING:
					show_signpost()

					state_ = HIDING
				HIDING:
					#triggered = true
					#Dialogs.dialog_box.hide_dialogue()
					#shown = false
					if (GlobalInput._state == GlobalInput.INTERRACT or
					Input.is_action_pressed("interact")
					):
						#triggered = false
						state_ = SHOWING


func show_signpost():
	if interract && Globals.near_interractible_objects:
		print("showing signpost")
		Dialogs.dialog_box.show_dialog(str(dialogue), 'Player')
		activate(false)


func hide_signpost():
	print("hiding signpost")
	Dialogs.dialog_box.hide_dialogue()


# Detect Player
func _on_signpost_body_entered(body : Player):
	
	activate(true)
	print(" Player Body Entered ")
	print_debug ('player near signpost: ', Globals.near_interractible_objects)

func _on_player_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		print (" Player Entered Area ")
		activate(true)

func _on_player_area_exited(area):
	if area.is_in_group("player_hurtbox"):
		print(" Player Exited Area ")
		activate(false)


func _on_dialog_started():
	print("signpost dialogue started")


func _on_dialog_ended():
	print("signpost dialogue ended")
	#activate(false)

func _on_signpost_body_exited(body : Player):
	activate(false)
	print_debug ('player near signpost: ', Globals.near_interractible_objects)
	


# One FUnction to Trigger and Un trigger Signpost state
func activate (state_ : bool) :
	Globals.near_interractible_objects = state_
	triggered = state_
	interract = state_
