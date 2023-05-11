# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# NPC
# 
# information used by the Quest giving NPC.
# AI code written here, should be written with Polymorphism in mind as it is shared by all Quest givers
# TO do:
# (1) Copy Mob code from enemy and implement it for NPC to follow Player (Done)
# (2) Add walking Animation
# *************************************************


extends KinematicBody2D

class_name NPC

"""
It just wraps around a sequence of dialogs. If it contains a child node named 'Quest'
which should be an instance of Quest.gd it'll become a quest giver and show whatever
text Quest.process() returns
"""

var active = false

export(String) var character_name = "Nameless NPC"
export(Array, String, MULTILINE) var dialogs = ["..."]
var current_dialog = 0


var Kinematic_Body : KinematicBody2D = get_parent()
var root : Node2D = get_parent()

var __body : Player

onready var npc : Area2D = $NPC

func _ready():
	randomize()
	
	# Adds a Kinematic Body for Move and SLide
	#self.add_child(Kinematic_Body)
	
	if not npc.is_connected("body_entered", self, "_on_NPC_body_entered"):
		# warning-ignore:return_value_discarded
		npc.connect("body_entered", self, "_on_NPC_body_entered")

	if not npc.is_connected("body_exited", self, "_on_NPC_body_exited"):
		# warning-ignore:return_value_discarded
		npc.connect("body_exited", self, "_on_NPC_body_exited")


func _process(_delta):
	
	
	if active && __body != null :
		move_and_slide( -Behaviour.FollowPlayer(self, __body))
	#print (get_tree().get_nodes_in_group('player').pop_front())
	# Follow Player
	#print(  Behaviour.FollowPlayer(self, get_tree().get_nodes_in_group('player').pop_front())  )
	pass

func _input(event):
	if (
			active and not
			dialogs.empty() and
			event.is_action_pressed("interact") and not
			Dialogs.active
		):
		if has_node("Quest"):
			var quest_dialog = get_node("Quest").process()
			if quest_dialog != "":
				Dialogs.show_dialog(quest_dialog, character_name)
				return
		Dialogs.show_dialog(dialogs[current_dialog], character_name)
		current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())
		
#func _on_body_entered(body):


#func _on_body_exited(body):



class Behaviour extends Reference:
	
	# Uses the Mob Enemy Function for FOllow the Player Arround
	# Not Working
	
	
	static func FollowPlayer( body_1 : Node2D , player) -> Vector2:
		# Follows the Player
		# Duplicate of Enemy Mob Method
		#Mob(_enemy : KinematicBody2D, player, _position : Vector2)
		#print ("-----------Following Player-----------")
		#return Enemy.Behaviour.Mob(_body, player, Vector2(0,0))
		#Behaviour.Mob(_body, player, Vector2(0,0))
		
		return Enemy.Functions.calculate_center(body_1, player.position)
	


func _on_NPC_body_entered(body):
	if body is Player:
		active = true

		__body = body
		


# Works
func _on_NPC_body_exited(body):
	if body is Player:
		active = false
		# Prints Center of Player and NPC
		#print(  Behaviour.FollowPlayer(self, body)  ) # for debug purposes only
		 
		#self.position = -Behaviour.FollowPlayer(self, body)
		#move_and_slide( -Behaviour.FollowPlayer(self, body))
		
