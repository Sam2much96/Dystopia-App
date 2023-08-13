# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Enemy Spawner
# Spawns enemy instances Within the Scene Tree
# Features
# (1) Spawns 12 enemies and turns off once the ememy count is at 3
# (2) Plays a flames animation once Enemy node is bieng instanced
# To Do:
#(1) Spawn different enemy types
# (2) Expand code's functionaliy
	# -(a) Only Spawns if Player is nearby, so as to optimize for performance (Done)
# *************************************************
# Bugs
# (1) Becomes a performance hog is constantly active in scene. Shold Auto Delete
#
#
# *************************************************

extends Position2D

class_name enemy_spawner


export (bool) var enabled 
export (PackedScene) var enemy_spawn_1
onready var position_in_area = self.position #origin point
onready var anim = $AnimationPlayer
onready var cool_down: Timer = $COOL_DOWN
#var enemy = load('res://scenes/characters/Bandits.tscn') 

# Boolean For Triggering Spawning
var SPAWNNING : bool = false
export(int) var spawn_count 


func _ready():
	# IT shouldn't call Randomize
	
	#randomize()
	if enemy_spawn_1 != null:
		push_error(" Enemy Spawn is Null, It Cannot Be Null")
	anim.play("normal") #hides spriite animation by default


func _process(_delta):
	
	
	# Should Use a Delta So It's Not Calld Every Frame
	
	# ENemy spawn 1 checks for the Enemy Packed Scene to instance
	if SPAWNNING:
		spawn_enemy()
	else : pass


func spawn_enemy(): 
	if spawn_count >= 1 && enabled == true:
		spawn_count -= 1

		#spawn an object in the position
		var spawn = enemy_spawn_1.instance()
		anim.play("spawning")
		spawn.position = position_in_area
		get_parent().call_deferred('add_child', spawn)
		print ('spawning enemy...')
	elif spawn_count <= 0:
		return

#func _on_enemy_spawner_timeout():
#	#Depreciated
#	spawn_enemy()
#	pass # Replace with function body.


" SPAWN STARTER/ PLAYER DETECTOR"
func _on_Area2D_body_exited(body):
	# :Bug Causes a Perfoormance hog because of a process Loop
	#if body is Player:
	#	print_debug("Player Leaves Enemy Spawn Range")
	#	SPAWNNING = true
	pass

# tEMPLATE FOR iMPLEMENTING A SPAWNING cOOLDOWN WITH tIMER
func _on_COOL_DOWN_timeout():
	self.queue_free()




func _on_Area2D_body_entered(body):
	if body is Player:
		print_debug("Player Leaves Enemy Spawn Range")
		SPAWNNING = true

