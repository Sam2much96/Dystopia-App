extends Control

"""
The purpose of this code is to beautify the UI programmatically
"""
" " # Doesnt work
#()I matched a bunch of UI Animation to an Animational variable node to the
# The purpose is to show a loadinbg animation once the outside environment scene loads
#doesn't work on low process pc


#changes Title Screen Art using Global Screen Orientation
onready var art1 = $TextureRect
onready var art2 = $TextureRect2


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.screenOrientation == 0:
		art1.show()
		art2.hide()
	elif Globals.screenOrientation == 1:
		art1.hide()
		art2.show()
	pass
# Called every fra

	# Testing  Unzip
	# Works
#	var t=Globals.uncompress('res://test.zip')
	#Works
#	print(t.get_string_from_utf8())

