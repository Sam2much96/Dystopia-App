# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Dialogue box
# Used by UI and player scenes to trigger text
# Features:
# (1) Is a class
# (2) Plays an animation that shows text via the dialogue singletom
#
# Bugs:
#(1) Broken Alignment with long texts
#(2) Broken Alignment on Mobiles with Horizontal UI
# (3) Doesn't work sometimes
# (4) Press "E" interract to Hide is not intuitive

#
# To DO:
# (1) Implement Decision Tree
# *************************************************

extends TextureRect
class_name DialogBox

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
	


func show_dialog(new_text, speaker):
	emit_signal("dialog_started")
	dialog_text.text = new_text
	character_text.text = speaker
	lines_to_skip = 0
	dialog_text.lines_skipped = lines_to_skip
	anims.play("appear")
	emit_signal("dialog_ended")

func hide_dialogue(): #Hides the Dialogue box
	anims.play("disappear")




func _input(event):
	if event.is_action_pressed("interact"):
	#if GlobalInput._state == GlobalInput.INTERRACT:
		
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
