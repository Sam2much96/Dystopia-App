# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Temple Interior scene
#
#Bug:
#(1) Is broken on mobile ui horizontal screens
# *************************************************

extends Node

class_name TempleInterior

#Play fx once the scene is ready

func _ready():
	$house_inside/AnimationPlayer.play("flames")
