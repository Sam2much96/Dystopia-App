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

# Bugs:
#(1) Broken Alignment with long texts (fixed)
#(2) Broken Alignment on Mobiles with Horizontal UI (fixed)
# (3) Doesn't work sometimes
# (4) Press "E" interract to Hide is not intuitive

#
# To DO:
# (1) Implement Decision Tree
# (2) Should Collect Screen Orientation as a parameter (Done)
# (3) Implement 2 Dialog box icons for different screen orientations (Done)
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

onready var character_text : Label = $nametag/label
onready var anims : AnimationPlayer = $anims

# warning-ignore:unused_signal
signal dialog_started
# warning-ignore:unused_signal
signal dialog_ended

var lines_to_skip : int = 0



func _ready():
	Dialogs.dialog_box = self
	hide()
	# Self position Dialogue Box using Screen Orientation Calculation
	#
	self_set_position()
	# Dialogue box scaling on mobile devices
	# Load Different textures depending on the Screen Orientation
	# Bug: Dialogues UI is misaligned on mobile screens
	if Globals.screenOrientation == 1:
		self.set_texture(load("res://resources/misc/dialog_box_webp_mobile.webp"))
	else : pass


func show_dialog(new_text : String, speaker : String):
	# SHows Dialog Box Programmatically
	# To Do: Add Screen orientation as a parameter
	emit_signal("dialog_started")
	dialog_text.text = new_text
	character_text.text = speaker
	lines_to_skip = 0
	dialog_text.lines_skipped = lines_to_skip
	
	anims.play("appear")
	emit_signal("dialog_ended")
	

func self_set_position():
	# Debug Screen Orientation for Dialogue box positioning
	#Quick Fix for Upscaing/ Positioning On Mobile
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		anims.play("MOBILE")
	if Globals.screenOrientation == 0: #SCREEN_VERTICAL is 0
		anims.play("PC")
	


func hide_dialogue(): #Hides the Dialogue box
	anims.play("disappear")




func _input(event):
	if (event.is_action_pressed("interact") ): #or GlobalInput._state == GlobalInput.INTERRACT 
		
		"Animation State Machine"
		
		match anims.assigned_animation:
			"show_text": 
				anims.play("wait")
			"wait":
				lines_to_skip += 2
				if lines_to_skip < dialog_text.get_line_count(): 
					dialog_text.lines_skipped = lines_to_skip
					anims.play("show_text")
				else:
					anims.play("disappear")
