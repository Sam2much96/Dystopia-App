# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Top Dowe Player Code
# SHared COnde Between Player Objects Within the Scene Tree
# Features:
#
# (1) Top Down Player Controls
# (2) Implements State Buffer For Multiplayer 
#
# To Do:
# (1) Refactor Player animation Logic into core Player class (DOne)
# (2) Player Animation Script Needs refactoring to Play animation as an extended method 
# (3) Refactor Animation State Machine To Use Animation Tree Blend States Locally and In Simulation Logic
# *************************************************

extends Player


class_name Player_v1_TopDown

signal state_changed(state_)

# Client & Server Logic for Top Down Player Movement

# Error Catcher for physics logic
# Checks if Peer Id can be called and Network Is Set up
onready var err = Networking.GamePlay

func _unhandled_input(event):
#func _input(event):
	# Node Individual Input Processes were depreciated in favor of GlobalInput Singleton
	"""
	Facing State Machine
	"""
	# Bugs:
	# (1) Captures All Input During Multiplayer Game Play
	#
	# To Do:
	# (1) Optimize for Online Player and Offline Player
	
	# Single Player Input
	if err == 0: # Local Playay 
		facing_logic(self, -99) # the default peer id

	# Online Player Input is captured in PlayerOnline.gd script

func _physics_process(delta):
	
	"""
	Local Client State Machine
	"""
	# Features : 
	# (1) Extended by Multiplayer Networking Class
	
	# To DO:
	# (1) Fix Multiple Player COntroller Bug
	# Implement Peer ID into Child Script Parameters
	
	# Facing State machine for Top Down player
	
	# Offline Physics Calculations
	# Online Physics Calculation would be shared by both CLient and Player Classes
	# Only One Player object in scene tree
	if  err == 0: # Error Catcher
		state_machine_logic(self, peer_id) # uses dummy -99 peer id for offline play
	
	# Online Physics calculation is written in PlayerOnline.gd formerly Player v2.gd


func _on_hurtbox_area_entered(area):
	"""Player Hit Collision Detection"""
	Simulation.Player_.hit_collision_detected(
		area , 
		state, 
		hitpoints, 
		self,
		global_position
		)


func facing_logic(node : Player, peed_id : int):
	# Called in the Input Process
	# TO DO: Implement Polymorphism for Multiplayer Gameplay
	
	#print_debug(node)
	if Input.is_action_pressed("move_left") or GlobalInput._state == GlobalInput.LEFT:
		
		node.facing = LEFT
	if Input.is_action_pressed("move_right") or GlobalInput._state == GlobalInput.RIGHT:
		
		facing = RIGHT
	if Input.is_action_pressed("move_up") or GlobalInput._state == GlobalInput.UP:
		
		node.facing = UP
	if Input.is_action_pressed("move_down") or GlobalInput._state == GlobalInput.DOWN:
		
		node.facing = DOWN

func state_machine_logic(node, peer_id : int):
	"""
	STATE MACHINE LOGIC
	"""
	# For Singleplayers
	# called as a physics process method
	# TO DO:
	# (1) Simplify Code Bloc
	# (2) Implement Polymorphism for both Online and Offline Play modes
	# (3) Im making the animation, facing and state, node specific
	
	match node.facing:
		UP:
			node._facing = "up"
		DOWN:
			node._facing = "down"
		LEFT: 
			node._facing = "left"
		RIGHT:
			node._facing = "right"
	
	
	
	##LOCALLY PROCESS STATES
	# State Machine physics shouldn't be processed by the server
	
	#if offline: 
	# refactor codebase into Node based implementation
	match state:
		STATE_BLOCKED: # Un Implemented State?
			node.new_anim = "idle_" + node._facing
			
		STATE_IDLE:
			if (
				# should be moved to input class imho
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up") or
					
					GlobalInput._state == GlobalInput.UP or
					GlobalInput._state == GlobalInput.DOWN or
					GlobalInput._state == GlobalInput.LEFT or
					GlobalInput._state == GlobalInput.RIGHT
				):
					node.state = STATE_WALKING
					
					if err > 0 :emit_signal("state_changed", node.state)
			# Attack State
			if Input.is_action_just_pressed("attack"):
				node.state = STATE_ATTACK
				#state = node.state
				if err > 0 : emit_signal("state_changed", node.state)
			# State Dash
			if Input.is_action_just_pressed("roll"):
				node.state = STATE_ROLL
				if err > 0 : emit_signal("state_changed", node.state)
				# Roll DIrection Calcualatin
				node.roll_direction = GlobalInput.roll_direction_calculation()
			
			node.new_anim = "idle_" + node._facing
			if Input.is_action_just_pressed("interact"):
				node.state = STATE_DANCE
		STATE_WALKING:
			if Input.is_action_just_pressed("attack"):
				node.state = STATE_ATTACK
				
			
			if Input.is_action_just_pressed("roll"):
				node.state = STATE_ROLL
				#emit_signal("state_changed")
			
			linear_vel = move_and_slide(linear_vel, Vector2(0,0))
			
			#print('Player linear velocity: ', linear_vel) #for debug purposes only
			
			var target_speed = Vector2()
			
			if Input.is_action_pressed("move_down"):
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				target_speed += Vector2.UP
			
			target_speed *= WALK_SPEED
			#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			linear_vel = target_speed
			roll_direction = linear_vel.normalized()
			
			if err > 0: emit_signal("state_changed", node.state)
			if linear_vel.length() > 5:
				node.new_anim = "walk_" + _facing
			else:
				goto_idle()
			
		STATE_ATTACK:
			# Playe attack animation
				
				node.new_anim = "slash_" + _facing
				
		STATE_ROLL:
			if roll_direction == Vector2.ZERO:
				
				
				#
				# get roll direction from facing
				#
				# 
				#print_debug("11111111", _facing)
				if facing == RIGHT:
					roll_direction = Vector2.RIGHT
				if facing == LEFT:
					roll_direction = Vector2.LEFT
				if facing == UP:
					roll_direction = Vector2.UP
				if facing == DOWN:
					roll_direction = Vector2.DOWN
			if roll_direction != Vector2.ZERO:
				linear_vel = move_and_slide(linear_vel)
				var target_speed = Vector2()
				target_speed = roll_direction
				target_speed *= ROLL_SPEED
				
				linear_vel = target_speed
				node.new_anim = "roll"
				if Input.is_action_just_pressed("attack"): #punch and slide funtionality
					state = STATE_ATTACK
					#emit_signal("state_changed")
		STATE_DIE:
			node.new_anim = "die"
			#emit_signal("state_changed")
		STATE_HURT:
			node.new_anim = "hurt"
			
			# FX works better in script
			Globals.player_cam.shake()
			
		STATE_DANCE:
			node.new_anim = "dance"
			if (
				# should be moved to input class imho
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up") or
					
					GlobalInput._state == GlobalInput.UP or
					GlobalInput._state == GlobalInput.DOWN or
					GlobalInput._state == GlobalInput.LEFT or
					GlobalInput._state == GlobalInput.RIGHT
				):
					node.state = STATE_WALKING
			
			#goto_idle()
	if new_anim != anim:
		node.anim = new_anim
		node.animation.play(anim)
	
