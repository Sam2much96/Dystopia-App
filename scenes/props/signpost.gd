# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Features:
# An interractible environment object
# To Do:
# SHould connect to a signal from UI to trigger the UI once player is nearby

extends Area2D


"""
Displays A Dialogue Text When the Player comes near
"""

export (bool) var shown = false # it runs as a oneshot bool
export (bool) var interract = false

export(String) var dialogue #signpost dialogue

export (bool) var _player_near 
func _ready():
	#shown = false
	return connect("area_entered", self, "_on_player_area_entered")
	return connect("area_exited", self, "_on_player_area_exited")
	#Dialogs.connect("dialog_started", self, "_on_dialog_started")
	#Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	pass



func _input(_event):
	if Input.is_action_pressed("interact") && _player_near == true:
		interract = true
		print ('Interract is :', interract)
		if interract == true  && shown == false:#  && _player_near == true: 
			print('signpost clicked') #for debug purposes only
			shown = true
			Dialogs.dialog_box.show_dialog(str(dialogue), 'Player')
			#get_tree().paused = true
			yield(get_tree().create_timer(2), "timeout") #Displays the dialogue for 2 seconds
			Dialogs.dialog_box.hide_dialogue()
			shown = false

func _on_player_area_entered(body):
	#print('_on_player_area_entered_ functin running', body.get_parent().name)
	if  body.get_parent().name == 'Player' :
		_player_near = true
		print ('player near signpost: ', _player_near) #send this information to the UI viab a global variable
		Globals.near_interractible_objects = _player_near



func _on_player_area_exited(body):
	if  body.get_parent().name == 'Player' :
		_player_near = false
		interract = false
		print ('player near signpost: ', _player_near)
		Globals.near_interractible_objects = _player_near
		shown = false

func _process(delta): # Triggers the UI if _player_near is true.
	return 
