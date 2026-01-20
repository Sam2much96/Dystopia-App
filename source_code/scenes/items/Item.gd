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
#(1) Modify code to play music from Audio singleton
# (2) Separate implementation into resource types and code
# *************************************************

extends Area2D

class_name item

export(String) var item_type #= "Generic Item"
export(int) var amount = 1

onready var anims : AnimationPlayer = $anims


onready var safe_Music = get_node("/root/Music")
onready var safe_Inventory = get_node("/root/Inventory")

func _ready():
	if not is_connected("body_entered", self, "_on_Item_body_entered"):
		connect("body_entered", self, "_on_Item_body_entered")

func _on_Item_body_entered(body):
	if body is Player:

		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		# Adds Items to the Inventory Singleton
		safe_Inventory.add_item(item_type, amount)
		anims.play("collected") # depreciated & unused animation
		safe_Music.play_track("res://sounds/item_collected.ogg") # Plays sound via singleton
		
		get_parent().queue_free()
	else : pass


