extends KinematicBody2D

#Puddle_splash_fx



func splash():
	$CollisionShape2D/AnimationPlayer.play("splash_anim")

func change_position(): #Changes the position of the effect to the player's positon
	pass
