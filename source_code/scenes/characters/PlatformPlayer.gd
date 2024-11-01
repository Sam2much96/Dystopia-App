# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Player v3
# Platforming Player Script
#
# Features:
# (1) Implements Platforming Code for Player Object
# (2) x9 Air Jumps
#
# To DO:
# (1) Wall Jumps
# (2) Implement Player Animations
# (3) Implement Facing
# (4) falling Animation When jumping off cliff edge
# *************************************************

extends Player

class_name Player_v3_Platformer

export (int) var speed = 10
export (int) var jump_speed = -1800
export (int) var gravity = 4000 # default gravity


export (float) var GRAVITY_TIMEOUT : float = 0.5 # pauses gravity during jumps for 0.5 secs
const MAX_SPEED = 1000
# For Jumping Mechanics
const max_air_jumps : int = 9
var air_jump_counter : int = 0

export (Vector2) var velocity = Vector2.ZERO



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
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
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
			
			yield(get_tree().create_timer(GRAVITY_TIMEOUT),"timeout")
			gravity = 4000 # Reset Gravity
	

	
