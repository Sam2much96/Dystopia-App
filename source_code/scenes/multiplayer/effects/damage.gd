# *************************************************
# godot3-spacegame by Yanick Bourbeau
# Released under MIT License
# *************************************************
# CLIENT-SIDE CODE
#
# Display damage on the spaceship
#
# *************************************************
extends Node2D

class_name damage

var total_delta = 0

func _ready():
	# Offset the explosion a bit
	position.x = randf_range(-10,10)
	position.y = randf_range(-10,10)


func _process(delta):
	# Destroy after 2 seconds
	total_delta += delta
	if total_delta > 2:
		queue_free()
