# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Top Dowe Player Code
# SHared COnde Between Player Objects Within the Scene Tree
# Features:
#
# (1) Top Down Player Controls
#
# To Do:
# (1) Refactor Player animation Logic into core Player class
# *************************************************

extends Player


class_name Player_v1_TopDown

func _input(event):
	# Node Individual Input Processes were depreciated in favor of GlobalInput Singleton
	# Facing State Machine
	# 
	if Input.is_action_pressed("move_left") or GlobalInput._state == GlobalInput.LEFT:
		
		facing = LEFT
	if Input.is_action_pressed("move_right") or GlobalInput._state == GlobalInput.RIGHT:
		
		facing = RIGHT
	if Input.is_action_pressed("move_up") or GlobalInput._state == GlobalInput.UP:
		
		facing = UP
	if Input.is_action_pressed("move_down") or GlobalInput._state == GlobalInput.DOWN:
		
		facing = DOWN

func _process(delta):
		# Raises up a Frame Counter
	#frame_counter += 1
	
	# Checks the Spawning Boolean Every 30th Frame
	# Called #very 60th Frame
	if Simulation.frame_counter % 60 == 0:
	#####this updates the player's node to a globals variable
		Globals._player_state = state
#	if frame_counter >= 1000:
#		frame_counter = 0




func _physics_process(delta):
	
		# Facing State machine for Top Down player
	match facing:
		UP:
			_facing = "up"
		DOWN:
			_facing = "down"
		LEFT: 
			_facing = "left"
		RIGHT:
			_facing = "right"
	
	
	
	##LOCALLY PROCESS STATES
	# State Machine physics shouldn't be processed by the server
	
	if not server_player: 
		
		match state:
			STATE_BLOCKED:
				new_anim = "idle_" + _facing
				
			STATE_IDLE:
				if (
						Input.is_action_pressed("move_down") or
						Input.is_action_pressed("move_left") or
						Input.is_action_pressed("move_right") or
						Input.is_action_pressed("move_up") or
						
						GlobalInput._state == GlobalInput.UP or
						GlobalInput._state == GlobalInput.DOWN or
						GlobalInput._state == GlobalInput.LEFT or
						GlobalInput._state == GlobalInput.RIGHT
					):
						state = STATE_WALKING
				if Input.is_action_just_pressed("attack"):
					state = STATE_ATTACK
				if Input.is_action_just_pressed("roll"):
					state = STATE_ROLL
					
					# Roll DIrection Calcualatin
					roll_direction = GlobalInput.roll_direction_calculation()
					
					#_update_facing()
				
				new_anim = "idle_" + _facing
			
			STATE_WALKING:
				if Input.is_action_just_pressed("attack"):
					state = STATE_ATTACK
				if Input.is_action_just_pressed("roll"):
					state = STATE_ROLL
				
				set_velocity(linear_vel)
				set_up_direction(Vector2(0,0))
				move_and_slide()
				linear_vel = velocity
				
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
				
				#_update_facing()
				
				if linear_vel.length() > 5:
					new_anim = "walk_" + _facing
				else:
					goto_idle()
				
			STATE_ATTACK:
				# Playe attack animation
				
				new_anim = "slash_" + _facing
				
				# Shoot Bullet Objects

					#if item_equip == "bomb":
						
						#call_deferred("add_child",bomb_instance)
					#	pass
						
			STATE_ROLL:
				if roll_direction == Vector2.ZERO:
					state = STATE_IDLE
				else:
					set_velocity(linear_vel)
					move_and_slide()
					linear_vel = velocity
					var target_speed = Vector2()
					target_speed = roll_direction
					target_speed *= ROLL_SPEED
					#linear_vel = linear_vel.linear_interpolate(target_speed, 0.9)
					linear_vel = target_speed
					new_anim = "roll"
					if Input.is_action_just_pressed("attack"): #punch and slide funtionality
						state = STATE_ATTACK
			STATE_DIE:
				new_anim = "die"
			STATE_HURT:
				new_anim = "hurt"
				
				# FX works better in script
				Globals.player_cam.shake()
				
		
		## UPDATE ANIMATION
		if new_anim != anim:
			anim = new_anim
			
			animation.play(anim)
		pass

func _on_hurtbox_area_entered(area):
	if state != STATE_DIE and area.is_in_group("enemy_weapons"):
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction = (global_position - area.global_position).normalized()
		set_velocity(pushback_direction * pushback)
		move_and_slide()
		state = STATE_HURT
		var blood = Globals.blood_fx.instantiate()
		blood.global_position = global_position
		get_parent().add_child(blood)
		
		Music.play_track(Music.nokia_soundpack[20])
		
		if hitpoints <= 0:
			state = STATE_DIE
			Music.play_track(Music.nokia_soundpack[27])
	pass

