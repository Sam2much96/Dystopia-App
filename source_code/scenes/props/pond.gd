# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Puddle
# An area2d that triggers a moving effect once it detects the Player
# To Do:
# (1) State machine (done)
# (2) Update ripple animation
# (3) Move all provess functions to Global script
#Bugs:
# (1) It only works on the player. It should work on Player and Enemy
# (2) The puddle FX whith is a kinematic body 2d is supposed to follow the Body collissions movement, it currently does not
# (3 Puddle FX is supposed to instance multiple times as the player moves
# *************************************************
# Depreciated

extends Area2D

class_name Pond

export (bool) var enabled

onready var puddle_fx = $Puddle_FX

enum {STATE_ACTIVE, STATE_IDLE}

export var state = STATE_IDLE

var x :float
var y: float
var  body_pos
var puddle_pos
var final_pos

onready var maxlength : float = $CollisionShape2D.shape.radius

#Frame Rate COunter
var frame_counter : int = 0

func _on_pond_body_entered(body): #Low level program, would not execute
	#if body is Player: 
	print(body)
	
	if body is Player:
		 
		'Include Code Here for Puddle Fx to follow player and instance multiple times'
		#puddle_fx.duplicate(3)
		body_pos = body.position
		#puddle_pos =  puddle_fx.get_position()
		
		#Globals.set_process(true)
		
		final_pos= Utils.restaVectores(body.position, puddle_fx.get_position())
		
		
		
		#print ('Pond FX Debug: ',"body pos ", body_pos , 'final pos',final_pos, 'Pond Fx Position: ', puddle_pos)
			
		#puddle_fx.show()
		state= STATE_ACTIVE
			

func clamp_fx():
	################################################################# 

	###################Clamps the Joystick cirle withing a radius#############################
	if body_pos.length() > maxlength: # SHould be in a separate functio
		var angle = puddle_fx.position.angle()
		puddle_fx.position.x = cos(angle) * maxlength 
		puddle_fx.position.y = sin(angle) * maxlength


func _process(delta):
	if enabled:
		frame_counter += 1
		
		if frame_counter > 600:
			frame_counter = 0
			
		
		# Procesed every 30th frame
		if frame_counter % 5 == 0:

			## PROCESS STATES
			match state:
				STATE_ACTIVE:
					#puddle_fx.ripple() #needs new ripple animation
					
					
					
					puddle_fx.change_position(final_pos)
					clamp_fx() #works
					
					puddle_fx.splash()
					pass
				STATE_IDLE:
					puddle_fx.change_position(Vector2(0, 0))


func _on_pond_body_exited(body):
	if body is Player: 
		state = STATE_IDLE
