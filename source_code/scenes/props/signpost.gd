# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Features:
# An interractible environment object
# To Do:
# SHould connect to a signal from UI to trigger the UI once player is nearby
# *************************************************
# Bugs:
# (1) Cn be triggered frm anywhere within the Game's main loop, showing previous signpost ext, which is bad UX
# (2) Displays A buggy Dialog Box is Outside Level
# (3) Doesnt't Trigger UI changes in Touch HUD
# *************************************************


extends Area2D

class_name SignPost

"""
Displays A Dialogue Text When the Player comes near
"""

var shown : bool = false # it runs as a oneshot bool
var interract : bool = false

export(String) var dialogue = ""

# 
#export (bool) var _player_near 
func _ready():
	
	#COnnect Signals
	connect("area_entered", self, "_on_player_area_entered")
	connect("area_exited", self, "_on_player_area_exited")
	#Dialogs.connect("dialog_started", self, "_on_dialog_started")
	#Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	


func _input(event) :
	
	if Globals.near_interractible_objects:
		# Processes the interact input every frame
		if event.is_action_pressed("interact"):
			interract = true
			print_debug ('Interract is :', interract)
	else: pass



func _on_signpost_body_entered(body):
	#print('_on_player_area_entered_ functin running', body.get_parent().name)
	#if  body.get_parent().name == 'Player' :
	if body is Player:
		
		# Shoud Trigger UI changes in Touch HUD
		#_player_near = true
		#print ('player near signpost: ', _player_near) #send this information to the UI viab a global variable
		
		# Update a global boolean
		Globals.near_interractible_objects = true


	#if Input.is_action_pressed("interact") :
	#	interract = true
	#	print_debug ('Interract is :', interract)
	
	if interract == true  && shown == false:#  && _player_near == true: 
		print('signpost clicked') #for debug purposes only
		shown = true
		
		# Use Networking Timer?
		Dialogs.dialog_box.show_dialog(str(dialogue), 'Player')
			
		yield(get_tree().create_timer(2), "timeout") #Displays the dialogue for 2 seconds
		Dialogs.dialog_box.hide_dialogue()
		shown = false



func _on_signpost_body_exited(body):
	if body is Player:
	#if  body.get_parent().name == 'Player' :
		
		# Shoud Trigger UI changes in Touch HUD
		Globals.near_interractible_objects = false
		interract = false
		print ('player near signpost: ', Globals.near_interractible_objects)
		
		shown = false
