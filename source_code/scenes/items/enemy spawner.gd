# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Enemy Spawner
# Spawns enemy instances Within the Scene Tree
# Features
# (1) Spawns 12 enemies and turns off once the ememy count is at 3
# (2) Plays a flames animation once Enemy node is bieng instanced
# (3) Should Extend Idol Code base And Store Player's Body
# (4) Auto-Delete as a performance optimizer
# (5) Only Spawns if Player is nearby, so as to optimize for performance

# To Do:
#(1) Spawn different enemy types
# (2) Expand code's functionaliy
# *************************************************
# Bugs :
#
#
# *************************************************
# Notes :
# (1) Adding (body : Player) autommatically makes that process a priority call, else body remains as a deferred call
#
# *************************************************

extends Position2D

class_name enemy_spawner


export (bool) var enabled 
export (int) var _hitpoints 
export (String, 'Easy', "Intermediate", "Hard") var enemy_type
export (PackedScene) var enemy_spawn_1


onready var position_in_area : Vector2 = self.position #origin point
onready var anim : AnimationPlayer = $AnimationPlayer
onready var cool_down: Timer = $COOL_DOWN
#var enemy = load('res://scenes/characters/Bandits.tscn') 

# Frame Counter
var frame_counter : int = 0


# Boolean For Triggering Spawning
var SPAWNNING : bool = false
export(int) var spawn_count 

onready var area : Area2D = $Area2D

var idol = Idol
var savepoint = idol.new()

func _ready():
	# connect signals
	area.connect("area_entered", self, "_on_Area2D_body_entered")
	area.connect("area_exited", self, "_on_Area2D_body_exited")
	
	# Debug Signal Connections
	
	if not (
	area.is_connected("area_entered", self, "_on_Area2D_body_entered") and
	area.is_connected("area_exited", self, "_on_Area2D_body_exited") 
	):
		push_error("Debug Enemy Spawner Signals")
	
	# IT shouldn't call Randomize
	
	#randomize()
	if enemy_spawn_1 != null:
		push_warning(" Enemy Spawn is Null, It Cannot Be Null")
	anim.play("normal") #hides spriite animation by default
	


func spawn_enemy() -> void:
	if not finished_spawning():
		
		if  enabled == true:
			spawn_count -= 1

			#spawn an object in the position
			var spawn = enemy_spawn_1.instance()
			
			# set Enemy Spawn Parameters
			spawn.hitpoints = _hitpoints
			spawn.enemy_type = enemy_type
			
			anim.play("spawning")
			spawn.position = position_in_area
			get_parent().call_deferred('add_child', spawn)
			print ('spawning enemy...')


func finished_spawning() -> bool:
	if spawn_count > 1 :
		return false
	else : 
		return true
	
	
	
" SPAWN STARTER/ PLAYER DETECTOR"
func _on_Area2D_body_exited(body):
	pass

# tEMPLATE FOR iMPLEMENTING A SPAWNING cOOLDOWN WITH tIMER
func _on_COOL_DOWN_timeout(): # Disabled for performance optimization
		# Reset 
		frame_counter = 0
		savepoint._reset_autosave_debugger()
		
		spawn_enemy()
		
		if finished_spawning():
			#delete
			queue_free()

# Triggers a Spawn When Player Body Enters the Collision
func _on_Area2D_body_entered(body):
	if body is Player:
		
		#print_debug("Player Enters Enemy Spawn Range")
		spawn_enemy()
	
	# Saves Using A Savepoint Class
	#
	#
	savepoint._save(body)




