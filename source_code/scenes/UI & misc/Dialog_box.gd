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
# (4) Implements 2 Dialog box icons for different screen orientations
# Bugs:


#
# To DO:
# (1) Add Redundancy Code For node Signals
# (2) Refactor to Popup dialog class
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


onready var decisionParent : HBoxContainer = $HBoxContainer
onready var yes_accept : Button = $HBoxContainer/accept
onready var no_decline : Button = $HBoxContainer/decline

# signal emitted to Dialogs singleton and connected via a set get function
# signal is the routed to Player kinematics which triggers player's pause on dialogue
signal dialog_started
signal dialog_ended

# decision dialogue signals
signal dialog_accept
signal dialog_decline 

onready var all_dialogue_nodes = [dialog_text, timer, character_text, anims, yes_accept, no_decline]

func _ready():
	
	# Make Self Global and connect signals
	Dialogs.dialog_box = self
	hide()
	
	self_set_position()
	
	
	# Dialogue box scaling on mobile devices
	# Load Different textures depending on the Screen Orientation
	# Bug: Dialogues UI is misaligned on mobile screens
	# depreciated bug fix
	#if Globals.screenOrientation == 1:
	#	self.set_texture(load("res://resources/misc/dialog_box_webp_mobile.webp"))
	#else : 
	#	pass



func show_dialog(new_text : String, speaker : String, action : bool):
	# Shows Dialog Box Programmatically
	# 
	#print_debug("show dialog")
	anims.play("appear")
	emit_signal("dialog_started")
	dialog_text.text = new_text
	character_text.text = speaker
	timer.start(1)
	if action:
	#	print_debug("Decision Logic Triggered")
	#	anims.play("decision")
		show_decision_buttons()
	if !action:
		hide_decision_buttons()

func show_decision_buttons():
	decisionParent.show()
	yes_accept.show()
	no_decline.show()

func hide_decision_buttons():
	decisionParent.hide()


func self_set_position():
	# Debug Screen Orientation for Dialogue box positioning
	#Quick Fix for Upscaing/ Positioning On Mobile
	# Porting the class to pop us class would make this code redundant
	# you're using the wrong node type
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		anims.play("MOBILE")
	if Globals.screenOrientation == 0: #SCREEN_VERTICAL is 0
		anims.play("PC")
	


func hide_dialogue(): #Hides the Dialogue box
	anims.play("disappear")


func _exit_tree():
	# Memory Management for Node
	Utils.Functions

func _on_Timer_timeout():
	# signal connected to TouchScreen HUD reset animation
	# this animation triggers the touchscreen hud to appear and disappear
	
	emit_signal("dialog_ended")

# Decision Tree Buttons 
# To DO : 
# (1) Connect Yes and No Decisions to functions dynamically
func _on_accept_pressed():
	print_debug("accept")
	emit_signal("dialog_accept")
	emit_signal("dialog_ended")



func _on_decline_pressed():
	print_debug("decline")
	emit_signal("dialog_decline")
	emit_signal("dialog_ended")
	hide_dialogue()
