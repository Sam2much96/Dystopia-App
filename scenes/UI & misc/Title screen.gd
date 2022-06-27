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

func _ready():
	_connect_signals() #connect Loadingsignals from the Ingame Menu

func _on_Menu__menu_showing(): #not using this signal for now
	return


func _on_Menu__menu_hidden(): #unused function
	#anim.play("hide_eye_bursts")
	#anim.play("RESET")
	return

func _on_Menu__loading_game(): 
	anim.play("eyes_loop")
	return

func _connect_signals():
	menu.connect("loading_game", self,"_on_Menu__loading_game")
