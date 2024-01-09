# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Grass
# SHared COnde Between Grass/Flower Objects Within the Scene Tree
# Features:
#
#
# *************************************************

extends KinematicBody2D

class_name Player_v3_Platformer

export (int) var speed = 1200
export (int) var jump_speed = -1800
export (int) var gravity = 4000

var velocity = Vector2.ZERO

func _input(event):
	velocity.x = 0
	if Input.is_action_pressed("walk_right"):
		velocity.x += speed
	if Input.is_action_pressed("walk_left"):
		velocity.x -= speed

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed
