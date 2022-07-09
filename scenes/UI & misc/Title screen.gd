extends Control

"""
The purpose of this code is to beautify the UI programmatically
"""
" It is currently empty"
#()I matched a bunch of UI Animation to an Animational variable node to the
# The purpose is to show a loadinbg animation once the outside environment scene loads
#doesn't work on low process pc

"It uses the ingame menu to change the user's UI screen"

onready var anim = $YSort/AnimationPlayer
onready	var menu = $"Menu "

#onready var 
"Plays UI animations from ingame menu signals"

var play_anim: bool = false


