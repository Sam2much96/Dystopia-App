# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Generic notification bar
# Features:
# To Do:
#(1) Debug and Fix bugs (DONE)
# (2) Implement Banner add as child
# *************************************************


extends Popup

####
"""
NOTIFICATION GENERIC BAR
"""

class_name hint

#add signals

@export var condition : bool
@export var Display_text: String = ""

var label  

enum { STATE_POPUP, STATE_HIDE,}
@export var state = STATE_POPUP

@onready var _help : Help = $Control

func _ready():
	# Node not found Error catcher
	if get_node_or_null("CenterContainer/Label") != null:
		label = $CenterContainer/Label
	else:
		label == null


# Hides the Notification on these levels. 
# Updating notification scene
	# Behavioural tree. 
	if  Globals.curr_scene != 'Outside':
		if  Globals.curr_scene !=  'HouseInside': #Dont show hints when im playing the game
			
			state = STATE_POPUP
	if Globals.curr_scene == 'Outside':# or 'HouseInside':
		
		#
		state = STATE_HIDE 
	if  Globals.curr_scene ==  'HouseInside' :
		#
		state = STATE_HIDE



func _input(event):
	
	
	"Triggers A Disappearing sequence"
	#Hides popup after 4 seconds of any input
	# Refactoring
	# Disabled for refactoring
	
	if event.is_pressed() == true:
		Networking.start_check(4)
	if Networking.stop_check() == true:
		#yield(get_tree().create_timer(0.5), "timeout") # Creates an Engine error, use a timer node instead
		# 
		state = STATE_HIDE
		
		#free from memory
	#	call_deferred('queue_free')


func _exit_tree():
	self.queue_free()


func _process(_delta): #add other functionalities to the notificatioN bar
	#if GlobalInput._state == GlobalInput.RESET:
	#	state =STATE_POPUP
	
	
	match state:
		STATE_POPUP:
			self.call_deferred('move_child', self.get_child(0), 0)
			self.call_deferred('popup_centered')
			if label != null &&  label.is_inside_tree() == true :
				label.set_text (Display_text)

		STATE_HIDE:
			
			self.hide()
			#pass
