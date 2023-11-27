# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Space Ship
# A spaceship object that's a part of the Game's story
# It is a static body 2d
# Features:
# (1) Displays an ingame comic scene once during the game's runtime from res://scenes/Comics/Outside/outside.tscn
# (2) Turns on / off smoke emitting Via A class + statemachine combo
# (3) Emits smoke Programmatically only when Player is nearby. Check scene's area2D
# To Do:
#(1) Make Optimized by writing states
# (2) Reduce CPU usage by only emitting cpu particles once the player interracts with the object
# (3) Make rideable by the player, convert to kinematic body 2d
# *************************************************
# Bugs:
# (1) Smoke emitter is buggy, Debug.
# *************************************************



extends StaticBody2D

class_name BrokenShip


"SMOKE FX TURNS OFF AND ON DEPENDEING ON THE PLAYER'S POSITION"
export (int) var counter #= 0 #used to off and on the comics placeholder

export (bool) var emitting_smoke

onready var _smoke_fx = $smoke_fx
onready var _smoke_fx_2 = $smoke_fx2
#toggles comics placeholder visible on player contact
func _on_Area2D_body_entered(body : Player):
	
	
	emitting_smoke == true
	
	
	
	"""
	Turns Smoke emitting on/ off 
	"""
	# it saves cpu performance

		# Via A class + statemachine combo
		# 2 turns it off 1 turns it on
	_smoke_fx._emit(true) # Emits smoke Programmatically
	_smoke_fx_2._emit(true) # Emits smoke Programmatically
		
	print_debug ("Player Near Spaceship. Is Smoke Emitting? :",_smoke_fx._state_controller) #not working
		
		

func show_scene_comic() -> void:
	# Turns on the comic placeholder once the player is near
	# Disabled for bad UX
	var comic_placeholder=get_tree().get_nodes_in_group('Cmx_Root') # Calls the comic placeholder node
	if comic_placeholder.empty() != true && counter == 0: 
		comic_placeholder = comic_placeholder.pop_front()
		
		comic_placeholder.enabled= true
		counter+=1
		




func _on_Area2D_body_exited(body : Player): 
	#if body is Player:
		#print ('Called From Broken Ship>>>>sdbasjgbasgbasigbasgubs') # Works # For debug purposes only
	emitting_smoke == false

		# it saves cpu performance
	_smoke_fx._emit(false) # Stops smoke Emits Programmatically
	_smoke_fx_2._emit(false) # Stops smoke Emits Programmatically


