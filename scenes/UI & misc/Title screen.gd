extends Control

"""
The purpose of this code is to beautify the UI programmatically
"""
" It is currently empty"
#()I matched a bunch of UI Animation to an Animational variable node to the
# The purpose is to show a loadinbg animation once the outside environment scene loads

"It uses the ingame menu to change the user's UI screen"

onready var anim = $YSort/AnimationPlayer
onready	var menu = $"Menu "

#onready var 
"Plays UI animations from ingame menu signals"

#func _process(_delta):
#	'Triggers Logic from INgame Menu State machine'
#	#print ("menu state debug: ",str(menu.menu_state )) # for debug purposes only
#	if menu.menu_state == 2: #(loading new game state)
#		anim.play("eyes_loop") #plays an animation loop as new game loads


func _on_Menu__menu_showing(): #not using this signal for now
	return


func _on_Menu__menu_hidden(): #unused function
	#anim.play("hide_eye_bursts")
	#anim.play("RESET")
	return

func _on_Menu__loading_game(): #unused function
	#anim.play("eyes_loop")
	return
