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
# *************************************************

extends Position2D


export (bool) var enabled 
export (PackedScene) var enemy_spawn_1
onready var position_in_area = self.position #origin point
onready var anim = $AnimationPlayer

#var enemy = load('res://scenes/characters/Bandits.tscn') 


export(int) var spawn_count 


func _ready():
	randomize()
	anim.play("normal") #hides spriite animation by default
	print ('spawning enemy...')
	if enemy_spawn_1 != null:
		spawn_enemy()



func spawn_enemy(): 
	if spawn_count >= 1 && enabled == true:
		spawn_count -= 1

		#spawn an object in the position
		var spawn = enemy_spawn_1.instance()
		anim.play("spawning")
		spawn.position = position_in_area
		get_parent().call_deferred('add_child', spawn)
	elif spawn_count <= 0:
		return

func _on_enemy_spawner_timeout():
	spawn_enemy()
	pass # Replace with function body.
