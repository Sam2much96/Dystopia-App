extends Control

"""
The purpose of this code is to beautify the UI programmatically
"""
" " # Doesnt work
#()I matched a bunch of UI Animation to an Animational variable node to the
# The purpose is to show a loadinbg animation once the outside environment scene loads
#doesn't work on low process pc



var progress : int
onready var a = Globals.a 
onready var b = Globals.b
onready var Diag = $Dialog_box

"Plays UI Loading animations from Globals Variable"

var show_loading_anim: bool = Globals.loading_resource # this is a loading resource variable from the globals script

func process():
	if show_loading_anim == true:
		progress = ((a/b) *100) # progress calculator
		Diag.show_dialog(str(" Loading Gaame :" + str(progress) + "%"),'')
	if show_loading_anim == false:
		Diag.hide_dialogue()
		set_process(false)


