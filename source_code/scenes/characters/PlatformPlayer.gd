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
var gravity = Simulation.gravity # default gravity


export (float) var GRAVITY_TIMEOUT : float = 0.5 # pauses gravity during jumps for 0.5 secs
const MAX_SPEED = 1000
# For Jumping Mechanics
const max_air_jumps : int = 5
var air_jump_counter : int = 0

export (Vector2) var velocity = Vector2.ZERO

# Wall jump power multipliers
const WALL_JUMP_PUSH = 2.5  # Increase horizontal launch distance
const WALL_JUMP_VERTICAL_BOOST = 0.1  # Increase vertical jump height

# State Machine for Platform Player
# Extends States from a Core Player Class

export (bool) var apply_GRAVITY = false



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
	if apply_GRAVITY: # Apply gravity
		velocity.y += gravity * delta
		
		velocity = move_and_slide(velocity, Vector2.UP)
	
	# Slow motion gravity
	if !apply_GRAVITY:
		velocity.y += 20
		velocity = move_and_slide(velocity, Vector2.UP)
	
	# Jump & Wall Jump Logic
	if Input.is_action_just_pressed("roll"): 
		if is_on_floor():
			velocity.y = jump_speed
			air_jump_counter = 0  # Reset air jump counter
		elif air_jump_counter < max_air_jumps:
			velocity.y = jump_speed
			air_jump_counter += 1
			animation.play("roll")
		elif is_on_wall():  # Wall Jump Logic
			var wall_normal = get_wall_normal()
			velocity.y = jump_speed * WALL_JUMP_VERTICAL_BOOST  # Stronger vertical jump
			velocity.x = MAX_SPEED * WALL_JUMP_PUSH * wall_normal.x  # Push farther away
			animation.play("roll")
	# Ledge Grab
#	if Input.is_action_just_pressed("move_up"):
#		if not is_on_floor():
#			
#			# Stop Gravity
#			gravity = 0
#			
#			yield(get_tree().create_timer(GRAVITY_TIMEOUT),"timeout")
#			gravity = 4000 # Reset Gravity
	
func get_wall_normal() -> Vector2:
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x != 0:  # Check if hitting a wall
			return collision.normal
	return Vector2.ZERO  # Default value if no wall is detected
