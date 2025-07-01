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




"Triggers a Pause state on the player if dialogue is triggered"
func _ready():
	# Connect To Dialogue Singleton
	
	if not (
			safe_Dialogs.connect("singleton_dialog_started", self, "_on_dialog_started") == OK and
			safe_Dialogs.connect("singleton_dialog_ended", self, "_on_dialog_ended") == OK):
		push_error("Error Connecting To The Dialog System")
		print_debug("Error connecting to dialog system")
	


func _on_dialog_started():
	state = TOP_DOWN.STATE_BLOCKED

func _on_dialog_ended():
	state = TOP_DOWN.STATE_IDLE


# to do: debug the stack that calls this function
func hurt(from_position: Vector2):
	print_debug("Hurt function called, debug stack")
	# Duplicate of _on_hurtbox_area_entered
	if state != TOP_DOWN.STATE_DIE:
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction: Vector2 = (global_position - from_position).normalized()
		move_and_slide(pushback_direction * pushback)
		state = TOP_DOWN.STATE_HURT
		
		blood.global_position = global_position
		get_parent().add_child(blood)
		
		music_singleton_.play_track(hurt_sfx)
		if hitpoints <= 2:
			# Play Music With SFX
			music_singleton_.set_sound_effect(music_singleton_.FX.PITCH_SHIFT, true)
		
		if hitpoints <= 0:
			state = TOP_DOWN.STATE_DIE
			# turn off music sfx
			music_singleton_.set_sound_effect(music_singleton_.FX.PITCH_SHIFT, false)
			music_singleton_.play_track(die_sfx)

func _unhandled_input(event):


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
		facing_input_logic(self, -99) # the default peer id
	
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
	# err is a parent variable that stores the Networking state
	if  err == 0: # Error Catcher
		state_machine_logic(self, peer_id) # uses dummy -99 peer id for offline play
	
	# Online Physics calculation is written in PlayerOnline.gd formerly Player v2.gd


func _on_hurtbox_area_entered(area):
	"""Player Hit Collision Detection"""
	# gets singleton pointer from player class
	safe_Simulation.Player_.hit_collision_detected(
		area , 
		state, 
		hitpoints, 
		self,
		global_position
		)


func facing_input_logic(node : Player, peed_id : int):
	# Called in the unhandled Input Process
	# manages the single player's input and maps it to the player top down state
	# it takes peer id as a parameter but it is unused
	# implements facing logic and input for the top down player object
	# code is repeted in side scrolling player logic
	# code is also used in playeronline.gd for mesh network mulitplayer
	# warning: code would break if there's any bugs in the player.gd player class
	# TO DO: Implement Polymorphism for Multiplayer Gameplay
	
	#Keyboard Input
	if Input.is_action_pressed("move_left") : #or GlobalInput._state == GlobalInput.LEFT:
		
		node.facing = FACING.LEFT
	if Input.is_action_pressed("move_right") : #or GlobalInput._state == GlobalInput.RIGHT:
		
		facing = FACING.RIGHT
	if Input.is_action_pressed("move_up") : #or GlobalInput._state == GlobalInput.UP:
		
		node.facing = FACING.UP
	if Input.is_action_pressed("move_down") : #or GlobalInput._state == GlobalInput.DOWN:
		
		node.facing = FACING.DOWN
	
	# Touch Screen Input
	if safe_TouchScreen.direction == Vector2.ZERO: return # guard clause
	if safe_TouchScreen.direction.x > 0.5:
		node.facing = FACING.RIGHT
	if safe_TouchScreen.direction.x < -0.5:
		node.facing = FACING.LEFT
	if safe_TouchScreen.direction.y > 0.5:
		node.facing = FACING.DOWN
	if safe_TouchScreen.direction.y < -0.5:
		node.facing = FACING.UP


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
		FACING.UP:
			node._facing = "up"
		FACING.DOWN:
			node._facing = "down"
		FACING.LEFT: 
			node._facing = "left"
		FACING.RIGHT:
			node._facing = "right"
	
	
	
	##LOCALLY PROCESS STATES
	# State Machine physics shouldn't be processed by the server
	
	#if offline: 
	# refactor codebase into Node based implementation
	match state:
		TOP_DOWN.STATE_BLOCKED: 
			# Called From THe Dialog Singleton emmiting dialog started
			#  Triggers a slight pause in player's movements
			node.new_anim = "idle_" + node._facing
			
		TOP_DOWN.STATE_IDLE:
			if (
					# Keyboard Input
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up") or
					
					# Touch Interface state
					# redundancy code for input
					safe_TouchScreen.state == safe_TouchScreen.INPUT.UP or
					safe_TouchScreen.state == safe_TouchScreen.INPUT.DOWN or
					safe_TouchScreen.state == safe_TouchScreen.INPUT.LEFT or
					safe_TouchScreen.state == safe_TouchScreen.INPUT.RIGHT or 
					
					# Touch screen inputs
					InputEventSingleScreenDrag
					
					
					
				):
					node.state = TOP_DOWN.STATE_WALKING
					
					if err > 0 :emit_signal("state_changed", node.state)
			# Attack State
			if Input.is_action_just_pressed("attack"):
				node.state = TOP_DOWN.STATE_ATTACK
				#state = node.state
				if err > 0 : emit_signal("state_changed", node.state)
			# State Dash
			if Input.is_action_just_pressed("roll"):
				node.state = TOP_DOWN.STATE_ROLL
				if err > 0 : emit_signal("state_changed", node.state)
				# Roll DIrection Calcualatin
				node.roll_direction = GameHud.TouchInterface.roll_direction_calculation()
			
			node.new_anim = "idle_" + node._facing
			if Input.is_action_just_pressed("interact"):
				node.state = TOP_DOWN.STATE_DANCE
		TOP_DOWN.STATE_WALKING:
			
			# state transition
			if Input.is_action_just_pressed("attack"):
				node.state = TOP_DOWN.STATE_ATTACK
				
			#state transition
			if Input.is_action_just_pressed("roll"):
				node.state = TOP_DOWN.STATE_ROLL
				#emit_signal("state_changed")
			
			linear_vel = move_and_slide(linear_vel, Vector2(0,0))
			
			#print('Player linear velocity: ', linear_vel) #for debug purposes only
			
			var target_speed = Vector2()
			
			# movement controls 
			if Input.is_action_pressed("move_down"):
				safe_TouchScreen.direction = Vector2.ZERO # reset Touchscreen directions when using keyboard input
				target_speed += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				safe_TouchScreen.direction = Vector2.ZERO # reset Touchscreen directions when using keyboard input
				target_speed += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				safe_TouchScreen.direction = Vector2.ZERO # reset Touchscreen directions when using keyboard input
				target_speed += Vector2.RIGHT
			if Input.is_action_pressed("move_up"):
				safe_TouchScreen.direction = Vector2.ZERO # reset Touchscreen directions when using keyboard input
				target_speed += Vector2.UP
			
			# auto matically set direction to touch screen input serialisation
			if safe_TouchScreen.direction != Vector2.ZERO : # bug no button release for idle state
				target_speed += safe_TouchScreen.direction
				
				# it needs a reset timeout for dirction
				
			
			target_speed *= WALK_SPEED
			#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
			linear_vel = target_speed
			roll_direction = linear_vel.normalized()
			
			if err > 0: emit_signal("state_changed", node.state)
			if linear_vel.length() > 5:
				node.new_anim = "walk_" + _facing
			else:
				goto_idle()
			
		TOP_DOWN.STATE_ATTACK:
			# Playe attack animation
				
				node.new_anim = "slash_" + _facing
				
		TOP_DOWN.STATE_ROLL:
			if roll_direction == Vector2.ZERO:
				
				
				#
				# get roll direction from facing
				#
				# 
				#print_debug("11111111", _facing)
				if facing == FACING.RIGHT:
					roll_direction = Vector2.RIGHT
				if facing == FACING.LEFT:
					roll_direction = Vector2.LEFT
				if facing == FACING.UP:
					roll_direction = Vector2.UP
				if facing == FACING.DOWN:
					roll_direction = Vector2.DOWN
			if roll_direction != Vector2.ZERO:
				linear_vel = move_and_slide(linear_vel)
				var target_speed = Vector2()
				target_speed = roll_direction
				target_speed *= ROLL_SPEED
				
				linear_vel = target_speed
				node.new_anim = "roll"
				if Input.is_action_just_pressed("attack"): #punch and slide funtionality
					state = TOP_DOWN.STATE_ATTACK
					#emit_signal("state_changed")
		TOP_DOWN.STATE_DIE:
			node.new_anim = "die"
			#emit_signal("state_changed")
		TOP_DOWN.STATE_HURT:
			node.new_anim = "hurt"
			
			# FX works better in script
			Globals.player_cam.shake()
			
		TOP_DOWN.STATE_DANCE:
			node.new_anim = "dance"
			if (
				# should be moved to input class imho
					Input.is_action_pressed("move_down") or
					Input.is_action_pressed("move_left") or
					Input.is_action_pressed("move_right") or
					Input.is_action_pressed("move_up") #or
					
					#GlobalInput._state == GlobalInput.UP or
					#GlobalInput._state == GlobalInput.DOWN or
					#GlobalInput._state == GlobalInput.LEFT or
					#GlobalInput._state == GlobalInput.RIGHT
				):
					node.state = TOP_DOWN.STATE_WALKING
			
			#goto_idle()
	if new_anim != anim:
		node.anim = new_anim
		node.animation.play(anim)
	
