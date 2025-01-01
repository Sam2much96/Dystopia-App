# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# 2D Space Ship Game Object
#
# A spaceship object that's a part of the Game's story
# It is a static body 2d
# Features:
# (1) Displays an ingame comic scene once during the game's runtime from res://scenes/Comics/Outside/outside.tscn
# (2) Turns on / off smoke emitting Via A class + statemachine combo
# (3) Emits smoke Programmatically only when Player is nearby. Check scene's area2D
#
#
#
# *************************************************



extends StaticBody2D

class_name BrokenShip


"SMOKE FX TURNS OFF AND ON DEPENDEING ON THE PLAYER'S POSITION"
export (int) var counter #= 0 #used to off and on the comics placeholder

export (bool) var emitting_smoke

onready var _smoke_fx : CPUParticles2D = $smoke_fx
onready var _smoke_fx_2 : CPUParticles2D = $smoke_fx2


#toggles comics placeholder visible on player contact
func _on_Area2D_body_entered(body):
	
	if body is Player:
		
		emitting_smoke = true
		
		
		
		"""
		Turns Smoke emitting on/ off 
		"""
		# it saves cpu performance

			# Via A class + statemachine combo
			# 2 turns it off 1 turns it on
		_smoke_fx._emit(true) # Emits smoke Programmatically
		_smoke_fx_2._emit(true) # Emits smoke Programmatically
		
		#print_debug ("Player Near Spaceship. Is Smoke Emitting? :",_smoke_fx._state_controller) #not working



func _on_Area2D_body_exited(body): 
	if body is Player:
		emitting_smoke = false

			# it saves cpu performance
		_smoke_fx._emit(false) # Stops smoke Emits Programmatically
		_smoke_fx_2._emit(false) # Stops smoke Emits Programmatically


