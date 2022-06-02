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
#(1) it is a perfomance hog------im working on a fix
#(2) It should be added to a class so other parent scenes can read and control it's state
# (3) It should emit at least 2 signals
# (4) Unable to turn emitting off programmatically
# (5) Use State Machine to emit signals
# (6) It's throtling between on and off states
# *************************************************


extends CPUParticles2D

class_name smoke_fx


enum {EMITTING, NOT_EMITTING} 
var _state_controller = NOT_EMITTING#EMITTING  # works

export (String) onready var current_state = "Is Emitting: " # A current state Debug

onready var timer = $Timer

func _ready():
	pass # Replace with function body.


func _emit() -> bool: # The reason for this function is to fix the state changer throatling bug
	_state_controller = EMITTING
	return _state_controller

func _stop_emit()-> bool: # The reason for this function is to fix the state changer throatling bug
	_state_controller = NOT_EMITTING
	return _state_controller

func _process(_delta):
	#_debug_smoke_fx() # For Debug Purposes. Disabling Temporarily

	## EMITTING STATE MACHINE
	# Bug: It's throttling between two states
	# Help : Emitting is 0, Not Emitting is 1
	match _state_controller:
		EMITTING:
			#if not _state_controller == EMITTING: # If not currently emitting
			self.set_emitting(true)
				#yield(get_tree().create_timer(0.8), "timeout") # use timer nodes
				# Turns on a timer depending on alot of things that stops once
				#timer.start(0.8)
				#print ('dfnafjnadfnadfakndfakfnafknafkafnakfnadfkadnfakdfnadkfnadfk')
				#new_anim = "idle_" + facing
			current_state = str(self.is_emitting())
			return current_state  
		NOT_EMITTING:
			#if not _state_controller == NOT_EMITTING: # If emitting
			self.set_emitting(false)
			current_state = str(self.is_emitting())
			return current_state 
			#timer.stop() # Currently Does Nothing


func _on_Timer_timeout(): # Useless signal. Might be usefull later. Connects to smoke FX from $timer
	print ('____Smoke_Fx State Controler 2 :', _state_controller) # for debug purposes only
	

func _debug_smoke_fx():
	print ('Smoke_Fx State Controler Process: ', _state_controller, " Current Emitting State", current_state)
