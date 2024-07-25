# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Bullet Class
# Code Shared By All Projectile Objects
# Is a member of the weapons group
# 
#
# Features:
#(1) Straight Line motion
# (2) 
# *************************************************

extends Area2D


class_name Bullet


@export var speed : int
@export var facing = ""  # (String, "up", "down", "left", "right")

@onready var anims : AnimationPlayer = $"AnimationPlayer"

func _ready():
	print_debug("Arrow facing:", facing)




func _physics_process(delta):
	#rotate bullet item to player's direction
	# using animation player
	anims.play(facing)

	if facing == "right":
		
		position += -transform.x * speed * delta
		
	if facing == "left":
		
		position += transform.x * speed * delta
		#pass
	if facing == "up":
		
		position += transform.y * speed * delta
		#pass
	if facing == "down":
		position += -transform.y * speed * delta
		#pass



func _on_Bullet_body_entered(body):
	if body is Enemy: # Can attack other enemies
		body.despawn()
	if body is Player:
		body.hitpoints = body.hitpoints - 1
	self.queue_free()




func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()


func _on_Area2D_body_entered(body):
	
	if body is Enemy:
		body.despawn()
	if body is grass:
		print_debug("hitting grass")
		body.destroy()
	#if body is Player:
		#body.hurt(self.position)
	#	pass
