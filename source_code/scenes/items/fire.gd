extends Node2D

# This is the fire object
# Features:
# (1) Plays the flames animation
# (2) Detects a collision and triggers different state for interaction
#  -i.e burning for bushes/enemies

# To DO:
# (1) Collision groups
# (2) Collision detection in grass and other items
# (3) Area 2d is currently disabled


onready var anim : AnimationPlayer = $AnimationPlayer


func _ready():
	
	# Plays the Flames animation in a recursive loop
	#
	anim.play("flames")
