# *************************************************
# godot3-spacegame by Yanick Bourbeau
# Released under MIT License
# *************************************************
# CLIENT AND SERVER CODE
#
# Spaceship projectile
# kinda useless, alter code for Ogun Gun 
# *************************************************
extends RigidBody2D

class_name projectile

# likely duplicate of Bullet class


#reuse code for something usefull
var total_delta = 0
@onready var node_root = get_node("/root/world")

# Destroy the projectile after 4 seconds
func _process(delta):
	total_delta += delta
	if total_delta >= 4:
		queue_free()
		return
	

# Handle collision
func _on_root_body_entered(body):
	
	if get_tree().is_server():
		# If you are the server, compute the damage and destroy the spaceship
		# if it is damaged enough.
		node_root.player_got_shot(body)
	else:
		# If you are the client, just display some visual effects
		node_root.display_damage(body)
		
	# Remove the projectile
	queue_free()
