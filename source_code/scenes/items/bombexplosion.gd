# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# BOMB SPRITE
#
# Spawns a Bomb aoe attack
# Featues:
# (1) Shows Bob AOE Animation
#
# TO DO:
# (1) Bomb timeout shout be adjustible
#
#
#
# *************************************************

extends Area2D
# Pointer to all objects to hurt in explosion
onready var objects_to_delete : Array = []

onready var anims : AnimationPlayer = $AnimationPlayer
func _ready():
	# pay bomb sizzlining sfx and item flash
	# trigger cam shake
	# destroy all objects in a collision area
	# play impact fx
	# despawn
	anims.play("FLASHING")

func _on_Timer_timeout():
	anims.play("EXPLODE")


func _on_Area2D_body_entered(body):
	objects_to_delete.append(body)


func _on_Area2D_body_exited(body):
	#print_debug("Bomb Kills:",objects_to_delete)
	if objects_to_delete.has(body):
		
		objects_to_delete.erase(body)


func _on_AnimationPlayer_animation_finished(anim_name):
	# Play exploding animation after flashing
	if anim_name == "FLASHING":
		print_debug("Exploding Bomb")
		anims.play("EXPLODE")
	#
	# otherwise delete
	else:
		self.queue_free()

func hurt()-> void:
	# Deletes all Objects in the Area od Effect
	for i in objects_to_delete:
		if i is Player:
			i.hurt(self.position)
		if i is Enemy:
			i.despawn()
		if i is StaticBody2D :
			# Buggy Method: 
			i.queue_free()
		#if i.name == "hurtbox": # area collision for flowers objects
		#	i.queue_free()
		else:
			print_debug("Unimplemented AOE for:", typeof(i), i.name)
			
			
	#self.queue_free()

func shake():
	# play SFx
	Music.play_track(Music.grass_sfx[0])
	
	# shake fx
	return Globals.player_cam.shake()



func _on_Area2D_area_entered(area):
	objects_to_delete.append(area)
