# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Generic Item Spawner
# Spawns Item Objects of various amounts Within the Scene Tree
# Its in the items group and saves iteslf to the Inventory Singleton
# Item Use Logic is in the Logic Singleton
#
# To Do:
#(1) 
# *************************************************

extends Area2D

class_name item

@export var item_type: String #= "Generic Item"
@export var amount: int = 1

@onready var anims : AnimationPlayer = $anims

@onready var sub_nodes : Array = [self, anims]

func _ready():
	connect("body_entered", Callable(self, "_on_Item_body_entered"))
	pass

func _on_Item_body_entered(body):
	if body is Player:

		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		# Adds Items to the Inventory Singleton
		Inventory.add_item(item_type, amount)
		anims.play("collected")
		Music.play_track("res://sounds/item_collected.ogg") # Plays sound via singleton
		
		queue_free()
	else : pass


func _exit_tree():
	Utils.MemoryManagement.queue_free_array(sub_nodes)
