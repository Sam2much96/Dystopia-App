# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# NPC
# 
# information used by the Quest giving NPC.
# current dialogue variable allows for multiline dialogue using array sizes
# AI prompts
# Features:
# (1) AI prompt for dialogues
# (2) Movement AI Behaviour to Move away from player

# TO do:
# (1) Copy Mob code from enemy and implement it for NPC to follow Player (Done)
# (2) Add walking Animation
# (3) Connect to Navigation AI Server using tween
# (4) Fetch NPC DIalogue from CSV file
# *************************************************


extends KinematicBody2D

class_name NPC

"""
It just wraps around a sequence of dialogs. If it contains a child node named 'Quest'
which should be an instance of Quest.gd it'll become a quest giver and show whatever
text Quest.process() returns
"""

export (bool) var active # Turns NPC Node ON / OFF

export(String) var character_name = "Nameless NPC"
export(Array, String, MULTILINE) var dialogs = ["..."]
var current_dialog = 0
var root : Node2D = get_parent()


onready var Kinematic_Body : KinematicBody2D = self

onready var __body : Player

onready var npc : Area2D = $NPC

onready var simulation_ = get_node_or_null("/root/Simulation")



func _ready():
	if active:
		
		randomize() # trigger the random seed generator
		
		
		# Adds a Kinematic Body for Move and SLide
		#self.add_child(Kinematic_Body)
		
		if not npc.is_connected("body_entered", self, "_on_NPC_body_entered"):
			# warning-ignore:return_value_discarded
			npc.connect("body_entered", self, "_on_NPC_body_entered")

		if not npc.is_connected("body_exited", self, "_on_NPC_body_exited"):
			# warning-ignore:return_value_discarded
			npc.connect("body_exited", self, "_on_NPC_body_exited")

	


func _process(delta : float):
	
	if active:
		
		
		# calculated every 5th frame
		if simulation_.frame_counter % 5 == 0:
			
			if __body != null:
			 
			
			# Triggers Body Movement away from Player Object
			#if  :
				
				# Move away from Player
				# Works
				# TO DO: Implement Behaviour in animal sprites
				#move_and_slide( -Behaviour.FollowPlayer(self, __body))
				#print (get_tree().get_nodes_in_group('player').pop_front())
				
				# Run Away From The Player
				# TO Do : Rewrite to use tween and navigation layer
				move_and_slide( Behaviour.EscapePlayer(self, __body))
				

		
		#"""
		#Sets Custom NPC Dialogue
		#"""
		# Fetched Durrent Dialouge from AI Prompy
		#if frame_counter % 10 == 0 && _AI != null &&_AI.output != "":
		#	if not dialogs.has(_AI.output):
		#		current_dialog = 0
		#		dialogs[current_dialog] =_AI.output
		#		#print_debug(dialogs[current_dialog])
		#	else : pass


# To DO: 
# (1) Rewrite to Show Decision Dialogue
#func _input(event):
#	if (
#			active and not
#			dialogs.empty() and
#			event.is_action_pressed("interact") and not
#			Dialogs.active
#		):
#		
#		print_debug(111111)
#		if self.has_node("QuestGiver"): # Checks if the node is holding the Quest Giver Object
#			print_debug("Has Quest")
#			var quest_dialog = get_node("QuestGiver").process() # call
#			if quest_dialog != "":
#				Dialogs.show_dialog(quest_dialog, character_name)
#				return
#		Dialogs.show_dialog(dialogs[current_dialog], character_name)
#		
#		# Updates the Current Dialogue
#		current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())
#		


#func _on_body_exited(body):



class Behaviour extends Reference:
	
	# Uses the Mob Enemy Function for FOllow the Player Arround
	# Not Working
	
	
	static func EscapePlayer( body_1 : Node2D , player) -> Vector2:
		# Runs from the Player
		# Duplicate of Enemy Mob Method
		#Mob(_enemy : KinematicBody2D, player, _position : Vector2)
		#print ("-----------Following Player-----------")
		#return Enemy.Behaviour.Mob(_body, player, Vector2(0,0))
		#Behaviour.Mob(_body, player, Vector2(0,0))
		
		return Utils.restaVectores(body_1.position, player.position) # The reverse of this method params should be to follow player
	
	


func _on_NPC_body_entered(body):
	if body is Player:
		active = true

		__body = body
		


# Works
func _on_NPC_body_exited(body):
	if body is Player:
		active = false

