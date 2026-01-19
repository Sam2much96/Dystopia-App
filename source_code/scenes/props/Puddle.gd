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


extends CharacterBody2D

class_name Puddle

@onready var animation_player_ : AnimationPlayer = $CollisionShape2D/AnimationPlayer

func ripple()-> void:
	animation_player_.play("ripple_anim ")


func splash()-> void:
	
	animation_player_.play("splash_anim")

func change_position(position): #Changes the position of the effect to the player's positon
	var a=position.x
	var b=position.y
	
	set_velocity(Vector2(a,b))
	move_and_slide()
	return velocity


func _exit_tree():
	queue_free()
