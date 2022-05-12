# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Puddle Splash FX
# A KinematicBody2d that triggers a Splash FX (Plays an Animation) 
# It's triggered by a splash() function and can be called from other nodes by Node.Puddle_FX.splash()
# Bugs:
# (1) The pond FX whith is a kinematic body 2d is supposed to follow the Body collissions movement, it currently does not
# *************************************************


extends KinematicBody2D


func _ready():
	hide()

func splash():
	$CollisionShape2D/AnimationPlayer.play("splash_anim")

func change_position(): #Changes the position of the effect to the player's positon
	pass
