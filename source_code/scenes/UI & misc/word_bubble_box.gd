# *************************************************
# Word Bubble Dialogue System
# Implements a Wordbubble system using line2D, Animation Player, Player's Language ,Comic book's current frame
# It connect to both the Comics singleton and the Dialgos Singleton
# Currently supports only 1 translation file and cannot use Translation .csv for word translations
# To Do:
#(1) Finish Building System (2/2)
#(2) Make a child of Comic book node scene (done)
#(3) Implement multilanguage functionality (done)
#(4) Use Line2d for wordbubble and dialogue boxes
# (5) Implement Chat GPT for realtime translations
# *************************************************
# How to Use
#
# (1) use state machine to change Word Bubble type
# (2) use show_dialog and show_dialog_2 to display text respectively
# (3) Use Enabe and Enable Mulitpline to Display PArsed dialogue
# (4) Set Line Index to the exact line to Display from the dialog script
#
# Bugs:
# (1) Uses too much vram. Crashes on mobile
# (2) Convoluted Codebase
# *************************************************

extends AnimatedSprite

# Word Bubble Object
class_name  WordBubbleBox


"Translations"

#

# Path to Dialogue Script
export(String, FILE, "*.gd") var dialogue = ""


# Path to Dialogue Translations
export (String, FILE, "*.gd") var dialogue_tr 
 
export var enable : bool
export var enable_multiline : bool

# For Regression testing
export var debug : bool 

# For Script Parser
export var line_index : int

# FOr multiline Parser
export var line_to_end : int

# Toggle word bubble visibility depending on Comics Page Data
export var visible_on_page : int 

# Synchronizes Page Data with Comics Pages
var Page : int 



#var text_boundary : Vector2 # map & alter this data with the statemachine
#Write Different States for the word bubbles
enum { 
	STATE_NARRATION, STATE_ANGRY ,STATE_THOUGHTS, STATE_TALK_RIGHT, 
	STATE_TALK_LEFT, STATE_TALK_LEFT_2, STATE_TALK_RIGHT_2, STATE_TALK_RIGHT_3,
	STATE_TALK_LEFT_3 
	}

export (String, "Narration", "Angry", "Thoughts",
 "Talk Right", "Talk Right 2", "Talk Right 3","Talk Left", 
"Talk Left 2","Talk Left 3"
) var state


var _state : int  = STATE_THOUGHTS
var Position : Vector2
var index : int 

#var lg : String = Dialogs.language

# Word Bubble Object Data as a Struct
export  var wordbubbleobjectdata : Dictionary = {
	"position": Position,
	"state" : state,
	"index" : index,
	"Language" : ""#Dialogs.language
} # Dictionary containing all object's properties
#Use a polygon2d to build the word bubbles

onready var word_bubble_label : Label = $Label
onready var word_bubble_label_2 : Label = $Label2
# Animation Player is for Syncing Label Text with Work Bubble Boundaries.
onready var anims : AnimationPlayer = $AnimationPlayer

onready var _word_bubble_nodes : Array = [anims, word_bubble_label, word_bubble_label_2]

var bubble_box = self

func show_dialog(new_text : String) -> void:
	print('---showing dialog 1---') # For debug purposes only
	word_bubble_label.text = new_text#new_text 
	
	lines_to_skip = 0
	word_bubble_label.lines_skipped = lines_to_skip



func show_dialog_2(text1 : String, text2 : String) -> void:
	
	# Shows double word bubble text
	# uses 2 labels synced to anim player
	print('---showing dialog 2---') # For debug purposes only
	
	word_bubble_label.text = text1
	word_bubble_label_2.text = text2
	
	
	



var lines_to_skip = 0


func flip()-> void:
	self.flip_h = true

func unflip()-> void:
	self.flip_h = false


func _enter_tree():
	
	"State machine Part A"
	
	#print (state)
	# Match String State to state machine enum
	if state == "Narration":
		_state = STATE_NARRATION
		
	elif state == "Angry":
		_state = STATE_ANGRY
	elif state == "Thoughts":
		_state = STATE_THOUGHTS
		return _state
	elif state == "Talk Right":
		_state = STATE_TALK_RIGHT
	elif state == "Talk Right 2":
		_state = STATE_TALK_RIGHT_2
	elif state == "Talk Right 3":
		_state = STATE_TALK_RIGHT_3
	elif state == "Talk Left":
		_state = STATE_TALK_LEFT
	elif state == " Talk Left 2":
		_state = STATE_TALK_LEFT_2
	elif state == "Talk Left 3":
		_state = STATE_TALK_LEFT_3


func _ready():
	
	
	

	
	#ignore the warning
	Dialogs.word_bubble_box = self

	


	"""
	Multi Line & Single Line Configurations
	"""
	# Note: Multiline return the text after line index, Singleline returns the text on line index


	# Single Line
	if enable:
		
		# Default translation
		if Dialogs.language == "":
			
			show_dialog(Dialogs.Parser.parse_script(line_index,dialogue))
		
		# English Translation file
		if Dialogs.language == "en_US":
			show_dialog(Dialogs.Parser.parse_script(line_index,dialogue))
		if Dialogs.language == "te_IN":
			show_dialog(Dialogs.Parser.parse_script(line_index,dialogue_tr))



	# Multi-Line
	if enable_multiline:
		# English Translation file 
		
		if Dialogs.language == "": # Default
			
			
			
			# Shows a multiline dialogue
			# 
			
			# TO DO: Implement Polymorphism
			show_dialog_2(
				Dialogs.Parser.parse_script_from(
					line_index, 
						line_to_end,
					dialogue
					), 
				Dialogs.Parser.parse_script((line_to_end + 1),dialogue)
				
				)
		
		if Dialogs.language == "en_US":
			show_dialog_2(
				Dialogs.Parser.parse_script(line_index,dialogue), 
				Dialogs.Parser.parse_script(int(line_index + 1),dialogue)
				)
		
		# Telugi Translation file
		# Depreciated in Production Release
		if Dialogs.language == "te_IN":
			show_dialog_2(
				Dialogs.Parser.parse_script(line_index,dialogue_tr), 
				Dialogs.Parser.parse_script(int(line_index + 1),dialogue_tr)
				)




func hide_dialogue(): #my code
	anims.play("disappear")

func _input(event):
	if event.is_action_pressed("interact"): #change the action 
		
		# Similar to Rust Code?
		match anims.assigned_animation:
			"show_text": 
				anims.play("wait")
			"wait":
				lines_to_skip += 2
				#if lines_to_skip < dialog_text.get_line_count(): 
				#	dialog_text.lines_skipped = lines_to_skip
				#	$anims.play("show_text")
				#else:
				#	$anims.play("disappear")


func _process(_delta):
	
	
	# Error Catchers
	
	if enable && enable_multiline:
		push_error(
			"Cannot use single line and double line functionaliy at the same time, disable one"
			)
	

	
	# Synchronizes  Page Data with Comics 
	Page = Comics_v6.current_frame
	
	# Toggles word bubble visibility on/off using Page Data
	# Disabling for Debugging
	if Page == visible_on_page && !debug:
		bubble_box.show()
	elif Page != visible_on_page && !debug:
		bubble_box.hide()
	
	
	
	
	

	
	" State Machine "
	# Features
	# (1) Shrinks Label's Boundaries for Word Bubble
	# (2) Implements RichLabelTexts with effects
	# (3)Syncs Label Boundary data to Word Bubble current frame
	
	# To DO:
	# (1) Find a more elegant way to change frames.
	match  _state:
		STATE_NARRATION:
			
			# Narration Box should resize to fit Label boundaries
			
			bubble_box.set_frame(0)
			anims.play("Narration")
			pass
		STATE_ANGRY :
			pass
		STATE_THOUGHTS :
			bubble_box.set_frame(1)
			anims.play("Thoughts")
			pass 
		STATE_TALK_RIGHT :
			bubble_box.set_frame(2)
			anims.play("Talk Right")
			pass 
		STATE_TALK_LEFT :
			bubble_box.set_frame(3)
			anims.play("Talk Left")
			pass 
		STATE_TALK_LEFT_2:
			bubble_box.set_frame(4)
			anims.play("Talk Left 2")
			pass 
		STATE_TALK_RIGHT_2:
			bubble_box.set_frame(5)
			anims.play("Talk Right 2")
			pass
		STATE_TALK_RIGHT_3: # rename it's member methods
			bubble_box.set_frame(6)
			anims.play("Talk Left 3 flipped")
			pass
		STATE_TALK_LEFT_3: # Unimplemented
			bubble_box.set_frame(6)
			anims.play("Talk Left 3")
			pass

func _exit_tree():
	Globals.MemoryManagement.queue_free_array(_word_bubble_nodes)
