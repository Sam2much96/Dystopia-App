# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Puddle Splash FX
# A KinematicBody2d that triggers a Splash FX (Plays an Animation) 
# It's triggered by functions 
# Bugs:
# (1) The pond FX whith is a kinematic body 2d is supposed to follow the Body collissions movement, it currently does not (fixed)
# *************************************************


extends KinematicBody2D

func _enter_tree():
	#hide()
	pass

func _ready():
	pass

func ripple()-> void:
	$CollisionShape2D/AnimationPlayer.play("ripple_anim ")


func splash()-> void:
	
	$CollisionShape2D/AnimationPlayer.play("splash_anim")

func change_position(position): #Changes the position of the effect to the player's positon
	var a=position.x
	var b=position.y
	move_and_slide(Vector2(a,b))
	return
