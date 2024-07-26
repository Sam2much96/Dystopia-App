# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Smoke fx done using CPU particles. See Particle2d as alternative
# Features:
#(1) It processes and emits smoke effects using the cpu
# (2) Read the Documentation for proper coding
# (3) Features a state changer function to change the state from lower down the scene tree
# Bugs 
#(1) it is a perfomance hog (fixed) 
#(2) It should be added to a class so other parent scenes can read and control it's state (Done)
# (3) It should emit at least 2 signals
# (4) Unable to turn emitting off programmatically
# (5) Use State Machine to emit signals
# (6) It's throtling between on and off states
# *************************************************


extends CPUParticles2D

class_name smoke_fx


enum {EMITTING, NOT_EMITTING} 
var _state_controller = NOT_EMITTING#EMITTING  # works

var current_state : bool  # A current state pointer to reduce performance hog

var frame_counter : int = 0

func _ready():
	# Make Global
	Simulation.smokeFX = self


func _emit(value : bool) -> void: # The reason for this function is to fix the state changer throatling bug

	current_state = value
	
	if value == true:
		_state_controller = EMITTING
	elif value == false:
		_state_controller = NOT_EMITTING


func _physics_process(delta : float):
	frame_counter += 1
	#print(frame_counter)
#	
	if frame_counter > 1000:
		frame_counter = 0
#	
	# Called Every 60th Frame
#	
#
#	#_debug_smoke_fx() # For Debug Purposes. Disabling Temporarily
#	
	if frame_counter % 60 == 0:
#		## EMITTING STATE MACHINE
#		# Bug: It's throttling between two states
#		# Help : Emitting is 0, Not Emitting is 1
#		# Fix 
#		# (1) Use Physics Process instead of Process
#		current_state = is_emitting()
#		
		match _state_controller:
			EMITTING:

				set_emitting(current_state) 

			NOT_EMITTING:

				set_emitting(current_state)
