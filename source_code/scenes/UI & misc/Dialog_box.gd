# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Dialogue box
# Used by UI and player scenes to trigger text
# Features:
# (1) Is a class
#(2) Plays an animation that shows text via the dialogue singletom
# Bugs:
#(1) Broken Alignment with long texts
#(2) Broken Alignment on Mobiles with Horizontal UI
# (3) Doesn't work sometimes
# *************************************************

extends TextureRect
class_name DialogBox

"""
Exposes the show_dialog function to the Dialogs singleton.
Will show a dialog box with the name of the character and
dialog text, two lines at a time. 
"""

var dialog_text : Label 

# warning-ignore:unused_signal
signal dialog_started
# warning-ignore:unused_signal
signal dialog_ended

var lines_to_skip = 0

func _enter_tree():
	Dialogs.dialog_box = self

func _ready():
	dialog_text = $dialog_text
	hide()
	pass # Replace with function body.



func show_dialog(new_text, speaker):
	dialog_text.text = new_text
	$nametag/label.text = speaker
	lines_to_skip = 0
	dialog_text.lines_skipped = lines_to_skip
	$anims.play("appear")
	pass

func hide_dialogue(): #Hides the Dialogue box
	$anims.play("disappear")

func _input(event):
	if event.is_action_pressed("interact"):
		match $anims.assigned_animation:
			"show_text": 
				$anims.play("wait")
			"wait":
				lines_to_skip += 2
				if lines_to_skip < dialog_text.get_line_count(): 
					dialog_text.lines_skipped = lines_to_skip
					$anims.play("show_text")
				else:
					$anims.play("disappear")
