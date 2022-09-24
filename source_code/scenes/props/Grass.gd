# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Grass
# Grass Objects Within the Scene Tree
# To Do:
#(1) Make translucient
#(2) Should only run shader once interracting with either player or enemy (optimization)
# *************************************************

extends Area2D

onready var timer : Node = $Timer
onready var anim : Node = $AnimationPlayer
func _ready():
	anim.play("normal",-1,1.0,0.0)
	connect("body_entered", self, "_on_grass_area_entered")
	
	timer.connect("timeout", self, "_queue_free")
	#var sfx = load (Music.grass_sfx[0])


"""Destroys the Grass when it's Attacked by Either Player or Enemy Sword collision"""

func _on_grass_area_entered(area):
	if area.name == "player_sword" :
		#play animation here
		destroy()
		print (str(area.name)+' cuts bush')
	if area.name == "enemy_sword" :
		
		destroy()
		print (str(area.name)+' cuts bush')
	else:
		pass
	
func idle():
	anim.play("idle")

func move():
	anim.play("move")

func destroy():
	anim.play("destroy")
	#yield(get_tree().create_timer(0.3), "timeout") # use timer instead
	set_timer(0.3)
	return Music.play_track(Music.grass_sfx[0])

func set_timer(time: int)->void:
	timer.one_shot = true
	timer.autostart = true
	timer.start(time)

"SHader Optimization for Grass and Flower objects"
# Deletes shader if player or enemy isn't nearby
func _on_grass_area_exited(area):
	if area is Player or Enemy:
		idle()


func _queue_free()->void:
	queue_free()


func _on_grass_body_entered(body):
	if body is Player or Enemy:
		#play shader animation if player or enemy is nearby
		move()


func _on_grass_body_exited(body):
	if body is Player or Enemy:
		#play shader animation if player or enemy is nearby
		
		idle()


func _on_flowers_body_exited(body):
	if body is Player or Enemy:
		#play shader animation if player or enemy is nearby
		
		idle()


func _on_flowers_body_entered(body):
	if body is Player or Enemy:
		#play shader animation if player or enemy is nearby
		move()




func _on_flowers_area_entered(area):
	if area.name == "player_sword" :
		#play animation here
		destroy()
		print (str(area.name)+' cuts bush')
	if area.name == "enemy_sword" :
		
		destroy()
		print (str(area.name)+' cuts bush')
	else:
		pass



