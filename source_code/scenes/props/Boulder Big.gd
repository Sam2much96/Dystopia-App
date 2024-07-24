# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Boulder Big
# Boulder Objects Within the Scene Tree
#
# Features:
# (1) Manages Node Object Deletion to prevent memory leks

extends StaticBody2D


class_name Boulder_Big

onready var _sprite : Sprite = $Sprite
onready var _collision : CollisionPolygon2D = $CollisionPolygon2D

onready var pointer : Array = [_sprite, _collision]

func _exit_tree():
	Utils.MemoryManagement.queue_free_array(pointer)


