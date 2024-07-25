# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# Extra Life
#
# Features:
# (1) Replicates a Zelda Like Potion Item
# (2) Adds a 1 to the Plaker Body's hitpoint
# (3) Registers the health potion Item to the Player Inventory
# *************************************************
# To Do:
# (1) Implement As Inventory Item


extends Area2D

class_name Potion

"""
EXTRA LIFE
"""

@export var item_type: String = "health potion"
@export var amount: int = 1

@onready var anims : AnimationPlayer = $anims



func _ready():
	connect("body_entered", Callable(self, "_on_Item_body_entered"))
	pass

func _on_Item_body_entered(body): # use body : Player to make priority process
	if body is Player:
		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		
		# SHould save to inventory
		Inventory.add_item(item_type, 1)
		
		#body.hitpoints += 1
		anims.play("collected")
		#body.emit_signal("health_changed", body.hitpoints)
		#anims.play("collected")
		#yield(get_tree().create_timer(0.8), "timeout")
		#$pickup.stop()
		
		self.queue_free()


func _use_item():
	# To Do:
	# (1) Rewrite as a inventory State
	# (2) CHange Icon to Bottle Image
	# Get the player in the scene tree and make global
	#var body = Utils.Player_utils._get_player(get_tree())
	
	# Update player object body
	#body.hitpoints += 1
	
	# emit signal
	#body.emit_signal("health_changed", body.hitpoints)
	pass
