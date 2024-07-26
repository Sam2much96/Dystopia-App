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
# (3) Implement Navigation AI
# *************************************************


extends CharacterBody2D

class_name NPC

"""
It just wraps around a sequence of dialogs. If it contains a child node named 'Quest'
which should be an instance of Quest.gd it'll become a quest giver and show whatever
text Quest.process() returns
"""

@export var active : bool

@export var character_name: String = "Nameless NPC"
@export var dialogs = ["..."] # (Array, String, MULTILINE)
var current_dialog = 0


var Kinematic_Body : CharacterBody2D = get_parent()
var root : Node2D = get_parent()

var __body : Player

@onready var npc : Area2D = $NPC

# AI API fetches Prompt from server
@onready var _AI = $AI#: Llama2API = $AI

var frame_counter : int = 0

func _ready():
	if active:
		Utils._randomize(self)
		
		# Adds a Kinematic Body for Move and SLide
		#self.add_child(Kinematic_Body)
		
		if not npc.is_connected("body_entered", Callable(self, "_on_NPC_body_entered")):
			# warning-ignore:return_value_discarded
			npc.connect("body_entered", Callable(self, "_on_NPC_body_entered"))

		if not npc.is_connected("body_exited", Callable(self, "_on_NPC_body_exited")):
			# warning-ignore:return_value_discarded
			npc.connect("body_exited", Callable(self, "_on_NPC_body_exited"))

	#print_debug(_AI.name)


func _process(delta : float):
	
	if active:
		frame_counter += 1
		
		# stops interger overflow from frame counter variable 
		if frame_counter >= 1000: frame_counter = 0 # Reset frame counter
		
		# calculated every 5th frame
		if frame_counter % 5 == 0:
			
			if __body != null:
			 
			
			# Triggers Body Movement away from Player Object
			#if  :
				
				# Move away from Player
				# Works
				# TO DO: Implement Behaviour in animal sprites
				#move_and_slide( -Behaviour.FollowPlayer(self, __body))
				#print (get_tree().get_nodes_in_group('player').pop_front())
				
				# Follow Player
				set_velocity(Behaviour.EscapePlayer(self, __body))
				move_and_slide()
				
				pass
		
		# Fetched Durrent Dialouge from AI Prompy
		if frame_counter % 10 == 0 && _AI != null &&_AI.output != "":
			if not dialogs.has(_AI.output):
				current_dialog = 0
				dialogs[current_dialog] =_AI.output
				#print_debug(dialogs[current_dialog])
			else : pass


func _input(event):
	if (
			active and not
			dialogs.is_empty() and
			event.is_action_pressed("interact") and not
			Dialogs.active
		):
		if has_node("Quest"):
			var quest_dialog = get_node("Quest").process()
			if quest_dialog != "":
				Dialogs.show_dialog(quest_dialog, character_name)
				return
		Dialogs.show_dialog(dialogs[current_dialog], character_name)
		
		# Updates the Current Dialogue
		current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())
		
#func _on_body_entered(body):


#func _on_body_exited(body):



class Behaviour extends RefCounted:
	
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
		# Prints Center of Player and NPC
		#print(  Behaviour.FollowPlayer(self, body)  ) # for debug purposes only
		 
		#self.position = -Behaviour.FollowPlayer(self, body)
		#move_and_slide( -Behaviour.FollowPlayer(self, body))
		
