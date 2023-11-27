# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Grass
# SHared COnde Between Grass/Flower Objects Within the Scene Tree
# Features:
# Uses List comparison to detect and Destroy self when colliding 
# with pre-saved area name

# To Do:
#(1) Make translucient
#(2) Should only run shader once interracting with either player or enemy (optimization)
# (3) Optimize Ram 
		# Lots of Detection going on in this node from every collision object (1/2)
		# Fix: Implement Layers and Layer masks
# (4) Fix all duplicate Code
# (5) Add and Remove shade object programmatically
# *************************************************

extends Area2D
#export var debug : bool

class_name grass

onready var nodeName : String = self.get_name() 

onready var timer : Node = $Timer
onready var anim : Node = $AnimationPlayer

#List of Aread 2D groups that can destroy this node

var list: Array = ["player_sword", "enemy_sword"] 

var similar_names : Array = [] #list comparer

func _ready():
	anim.play("idle",-1,1.0,0.0) 
	connect("body_entered", self, "_on_grass_area_entered")
	
	timer.connect("timeout", self, "_queue_free")
	#var sfx = load (Music.grass_sfx[0])
#jhcjhccilyc

"""Destroys the Grass when it's Attacked by Either Player or Enemy Sword collision"""

#************TO MUCH DETECTION**************#

func _on_grass_area_entered(area):
	# Stores an Array of all objects colliding with grass object
	update_collision_list(area.name)
	
	
	_destroy_if(similar_names)


func _destroy_if (area: Array)-> void: # Works
	for p in area:
		if list.has(p):
			destroy()
			debug_grass(p) # for debug purposes only

func idle()-> void:
	anim.play("idle")

func move()-> void:
	anim.play("move")

'Destroy animation and sound'
func destroy()-> void:
	anim.play("destroy")
	#yield(get_tree().create_timer(0.3), "timeout") # use timer instead
	set_timer(0.3)
	queue_free()
	Music.play_track(Music.grass_sfx[0])


func set_timer(time: int)->void:
	timer.one_shot = true
	timer.autostart = true
	timer.start(time)




#func _queue_free()->void: #STACK OVERFLOW BUG
#	queue_free()



func _on_flowers_area_entered(area):
	update_collision_list(area.name)

	_destroy_if(similar_names)


func update_collision_list( area : String)-> void:
	
	
	if not similar_names.has(area):
		similar_names.append(area)
	elif similar_names.has(area):
		pass

func debug_grass( area_name : String)-> void: 
	print_debug (area_name+' cuts ' + nodeName)
	print (similar_names) #list of all objects grass and flower nodes collide with

