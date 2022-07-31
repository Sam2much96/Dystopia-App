# *************************************************
# Word Bubble Dialogue System
# Implements a Wordbubble system using line2D, Animation Player, Player's Language and Comic book's current frame
# To Do:
#(1) Finish Building System
#(2) Make a child of Comic book node scene
#(3) Implement multilanguage functionality
#(4) Use Line2d for wordbubble and dialogue boxes
# *************************************************

extends Node

"""
THE PURPOSE OF THIS CODE IS TO PARSE TEXT DATA FROM A JSON FILE AND DISPLAY IT IN A DIALOGUE BOX
"""
#Godot has greater finese in parsing json files
export (String, FILE,  '*.gd') var _script = ('res://resources/dialogues/script_testing.gd')# 'res://resources/dialogues/Dystopia chapter 1 Neo sud.gd'
 
export (int) var index = null

func _ready():
	parse_script() #for debug purposes only.
	pass

func _process(_delta):
	pass


func parse_script(): #Places Dialogue in wordbubbles with Dialogue singleton-aid
	#Parse gd script
	var _f = File.new()
	if _f.file_exists(_script): #('res://resources/dialogues/script_testing.gd'):
		print ('File Exists')
		_f.open (_script, File.READ)
		index = 1 
		while _f.get_position() < _f.get_len() && not _f.eof_reached():
		#iterate through all lines until the end of file is reached
		#var index controls which line is shown
			var line = str (index )  + ' ' + _f.get_line()
			line += " "
			
			#........... # for debug purposes only #...................#
			print (line) 
			if index == 2: #index controls the line to parse
				Dialogs.dialog_box.show_dialog(line, 'script parser')
				#Update Dialogue box to pass script to the wordbubble system
			#Write a controller to control the index
			#
			#
			index += 1 
		_f.close() #don't close yet
		pass


