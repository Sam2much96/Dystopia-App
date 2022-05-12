# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Puddle
# An area2d that triggers a moving effect once it detects the Player
# Bugs:
# (1) It only works on the player. It should work on Player and Enemy
# (2) The puddle FX whith is a kinematic body 2d is supposed to follow the Body collissions movement, it currently does not
# (3 Puddle FX is supposed to instance multiple times as the player moves
# *************************************************


extends Area2D

onready var puddle_fx = $Puddle_FX



func _on_pond_body_entered(body): #Low level program, would not execute
	if body is Player: 
		#var player_pos = body.get_position()
		#var fx_pos = puddle_fx.get_position()
		#print ('Pond FX Debug: ', 'Player Position', player_pos, 'Pond Fx Position: ', puddle_fx.get_position())
		#$pond.move_and_slide(  Vector2(player_pos))
		'Include Code Here for Puddle Fx to follow player and instance multiple times'
		#puddle_fx.duplicate(3)
		
		puddle_fx.show()
		
		puddle_fx.splash()
