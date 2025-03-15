# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Dialogue box
# Used by UI and player scenes to trigger text
# Features:
# (1) Is a class
# (2) Plays an animation that shows text via the dialogue singletom
# (3) Fetches Global Screen Orientation calculated from cinematics class and uses it for Self Positioning
# (4) Implement 2 Dialog box icons for different screen orientations
# Bugs:


#
# To DO:
# (1) Implement Decision Tree
# 
# (4) Implement Decision tree diaglue box with buttons
# (5) Add dialogue box Icon (Done)
# *************************************************

extends NinePatchRect
class_name DialogBox, "res://resources/misc/dialoguebox 32x32.png"

"""
Exposes the show_dialog function to the Dialogs singleton.
Will show a dialog box with the name of the character and
dialog text, two lines at a time. 
"""

onready var dialog_text : Label = $dialog_text
onready var timer : Timer = $Timer
onready var character_text : Label = $nametag/label
onready var anims : AnimationPlayer = $"%anims"

signal dialog_started
signal dialog_ended



func _ready():
	
	# uses set get functions to connect signals from Dialogs singleton
	Dialogs.dialog_box = self
	hide()
	
	self_set_position()
	# Dialogue box scaling on mobile devices
	# Load Different textures depending on the Screen Orientation
	# Bug: Dialogues UI is misaligned on mobile screens
	if Globals.screenOrientation == 1:
		self.set_texture(load("res://resources/misc/dialog_box_webp_mobile.webp"))
	else : pass


func show_dialog(new_text : String, speaker : String):
	# Shows Dialog Box Programmatically
	# 
	anims.play("appear")
	emit_signal("dialog_started")
	dialog_text.text = new_text
	character_text.text = speaker
	timer.start(1)
	
	

func self_set_position():
	# Debug Screen Orientation for Dialogue box positioning
	#Quick Fix for Upscaing/ Positioning On Mobile
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		anims.play("MOBILE")
	if Globals.screenOrientation == 0: #SCREEN_VERTICAL is 0
		anims.play("PC")
	


func hide_dialogue(): #Hides the Dialogue box
	anims.play("disappear")



func _on_Timer_timeout():
	emit_signal("dialog_ended")
