# *************************************************
# Word Bubble Dialogue System
# Implements a Wordbubble system using line2D, Animation Player, Player's Language ,Comic book's current frame
# To Do:
#(1) Finish Building System (2/2)
#(2) Make a child of Comic book node scene (done)
#(3) Implement multilanguage functionality (done)
#(4) Use Line2d for wordbubble and dialogue boxes
# *************************************************
# How to Use
#
# (1) use state machine to change Word Bubble type
# (2) use show_dialog and show_dialog_2 to display text respectively
#
# *************************************************

extends AnimatedSprite2D

# Word Bubble Object
class_name  WordBubbleBox

@export var dialogue : String = ''  

# For Regression testing
@export var debug : bool 

@export var text_boundary : Vector2 # map & alter this data with the statemachine
#Write Different States for the word bubbles
enum { 
	STATE_NARRATION, STATE_ANGRY ,STATE_THOUGHTS, STATE_TALK_RIGHT, 
	STATE_TALK_LEFT, STATE_TALK_LEFT_2, STATE_TALK_RIGHT_2, 
	STATE_TALK_LEFT_3 
	}

var state = STATE_NARRATION

var Position : Vector2
var index : int 

@export  var wordbubbleobjectdata : Dictionary = {
	"position": Position,
	"state" : state,
	"index" : index
} # Dictionary containing all object's properties
#Use a polygon2d to build the word bubbles

@onready var word_bubble_label : Label = $Label
@onready var word_bubble_label_2 : Label = $Label2
# Animation Player is for Syncing Label Text with Work Bubble Boundaries.
@onready var anims : AnimationPlayer = $AnimationPlayer

signal dialog_started
signal dialog_ended
func show_dialog(new_text : String) -> void:
	word_bubble_label.text = new_text
	#$nametag/label.text = speaker
	lines_to_skip = 0
	word_bubble_label.lines_skipped = lines_to_skip
	#$anims.play("appear")
	#pass


func show_dialog_2(text1 : String, text2 : String) -> void:
	# Shows double word bubble text
	# uses 2 labels synced to anim player
	
	
	word_bubble_label.text = text1
	word_bubble_label_2.text = text2
	


var lines_to_skip = 0



func _ready():
	Dialogs.word_bubble_box = self
	
	#hide()
	if debug:
		# Debug 0 : Various types of WordBubbles
		state = STATE_TALK_LEFT_2
		
		# Debug 1 : Show dialog + Script Parser
		#show_dialog(Dialogs.Parser.parse_script(6,Dialogs._script_testing))

		# Debug 2 : Show Double Dialog + Script Parser
		show_dialog_2(Dialogs.Parser.parse_script(6,Dialogs._script_testing), Dialogs.Parser.parse_script(7,Dialogs._script_testing))



# Depreciated
#func sort_frames(): #Gets the frames of the spritesheet and sorts it out into the state machine
#	self.get_frame() #Write an automatic state changer

func hide_dialogue(): #my code
	$anims.play("disappear")

func _input(event):
	if event.is_action_pressed("interact"): #change the action 
		
		# Similar to Rust Code?
		match $anims.assigned_animation:
			"show_text": 
				$anims.play("wait")
			"wait":
				lines_to_skip += 2
				#if lines_to_skip < dialog_text.get_line_count(): 
				#	dialog_text.lines_skipped = lines_to_skip
				#	$anims.play("show_text")
				#else:
				#	$anims.play("disappear")


func _process(_delta):
	
	" State Machine "
	# Features
	# (1) Shrinks Label's Boundaries for Word Bubble
	# (2) Implements RichLabelTexts with effects
	# (3)Syncs Label Boundary data to Word Bubble current frame
	match  state:
		STATE_NARRATION:
			set_frame(0)
			anims.play("Narration")
			pass
		STATE_ANGRY :
			pass
		STATE_THOUGHTS :
			set_frame(1)
			anims.play("Thoughts")
			pass 
		STATE_TALK_RIGHT :
			set_frame(2)
			anims.play("Talk Right")
			pass 
		STATE_TALK_LEFT :
			set_frame(3)
			anims.play("Talk Left")
			pass 
		STATE_TALK_LEFT_2:
			set_frame(4)
			anims.play("Talk Left 2")
			pass 
		STATE_TALK_RIGHT_2:
			set_frame(5)
			anims.play("Talk Right 2")
			pass
		STATE_TALK_LEFT_3:
			set_frame(3)
			anims.play("Talk Right 3")
			pass
