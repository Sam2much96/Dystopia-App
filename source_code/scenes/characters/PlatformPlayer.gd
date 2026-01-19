# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Player v3
# Platforming Player Script
#
# Features:
# (1) Implements Platforming Code for Player Object
# (2) x4 Air Jumps
#
# To DO:
# (1) Wall Jumps
# (2) Implement Player Animations
# (3) Implement Facing
# *************************************************

extends Player

class_name Player_v3_Platformer

@export (int) var speed = 10
@export (int) var jump_speed = -1800
@export (int) var gravity = 4000

const MAX_SPEED = 1000
# For Jumping Mechanics
const max_air_jumps : int = 6
var air_jump_counter : int = 0

@export (Vector2) var velocity = Vector2.ZERO



# State Machine for Platform Player
# Extends States from a Core Player Class




func _physics_process(delta):
	# left & right
	
	
	# Left & Right
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
		#print (velocity.x) # for debug purposes only 
		if velocity.x >= MAX_SPEED:
			velocity.x = MAX_SPEED
		animation.play("walk_right")
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed 
		if velocity.x <= (-MAX_SPEED):
			velocity.x = -MAX_SPEED
		animation.play("walk_left")




	
	# Gravity
	velocity.y += gravity * delta
	
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity
	
	# Jump
	if Input.is_action_just_pressed("roll"): # jump 1
		if is_on_floor():
			velocity.y = jump_speed
			
			# Reset Jump counter
			air_jump_counter = 0
		if not is_on_floor() && Input.is_action_just_pressed("roll"): # 4x Jumps
			# Nested Ifs ? # Bad Code
			# Limits air jumps with a counter
			if air_jump_counter < max_air_jumps:
				velocity.y = jump_speed
			
				# increase airjump counter
				air_jump_counter += 1
				
				animation.play("roll")
	# Ledge Grab
	if Input.is_action_just_pressed("move_up"):
		if not is_on_floor():
			
			# Stop Gravity
			gravity = 0
			
			await get_tree().create_timer(0.5).timeout
			gravity = 4000 # Reset Gravity
	
