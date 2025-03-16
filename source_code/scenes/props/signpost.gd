# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Features:
# An interractible environment object
# SHows Random Hints to Player

# To Do:
# SHould connect to a signal from UI to trigger the UI once player is nearby
# *************************************************
# Bugs:
# (1) Dialog box bugs out if there's a single error in the script
# (2) 
# (3) Doesnt't Trigger UI changes in Touch HUD
# (4) 
# (5) Replace Player with Global Name / Wallet Address by modifying forms.gd
# *************************************************


extends Area2D

class_name SignPost

"""
Displays A Dialogue Text When the Player comes near
"""

export(bool) var enabled
export(String, MULTILINE) var dialogue : String = ""
export(String) var speaker : String = ""


export (bool) var HINT #= false # Boolean conditional for hint system
export (bool) var DECISION 
export (bool) var QUEST
export (bool) var DIALOGUE

"""
Instance this as a child of any Npc.tscn node and it turns into a 
quest giver.
The character will also check if the player has a certain amount of a given item and if true
Remove said amount from the players inventory and give some amount of another item as a reward
This is only useful for fetch quests but you can also ask for '5 demon horns' or something to turn it
into a kill quest.
Otherwise you'll have to make a quest system a bit more complex. 
"""

export(String) var quest_name = "Life as a Rappi Guy"
export(String) var required_item = "Generic Item"
export(int) var required_amount = 10
export(String) var reward_item = "Generic Reward"
export(int) var reward_amount = 1
export(String, MULTILINE) var initial_text = "TLDR; bring me 10 thingies"
export(String, MULTILINE) var pending_text = "You forgot? I want 10 thingies"
export(String, MULTILINE) var delivered_text = "Thank you! Here's your reward.."



func _ready():
	
	if enabled:
		
		#Connect All Signals
		
		
		if not (is_connected("body_entered",self, "_on_signpost_body_entered") &&
		is_connected("body_exited",self, "_on_signpost_body_exited")
		):
			connect("body_entered",self, "_on_signpost_body_entered")
			connect("body_exited",self, "_on_signpost_body_exited")
		
		
		# Debug All Signals
		
		if not ( is_connected("area_entered", self, "_on_player_area_entered") and 
		is_connected("area_exited", self, "_on_player_area_exited") and
		is_connected("body_entered",self, "_on_signpost_body_entered") and
		is_connected("body_exited",self, "_on_signpost_body_exited") and
		Dialogs.is_connected("dialog_started", self, "_on_dialog_started") and
		Dialogs.is_connected("dialog_ended", self, "_on_dialog_ended") 
		):
		
			push_warning("Debug Connected Signals")


func show_signpost(): # rename to trigger dialogue
	if not is_instance_valid(Dialogs.dialog_box): # Error Catcher 1
		return
	
	#print_debug("showing signpost")
	
	if HINT:
		# Shows Random Hints using a Dictionary shuffle algorithm
		dialogue = Music.shuffle(Dialogs.hints)
		# Translates them to the User's Language
		return Dialogs.dialog_box.show_dialog(
			Dialogs.translate_to( dialogue, Dialogs.language), 'Player', false
			)
	if DIALOGUE:
		Dialogs.dialog_box.show_dialog(Dialogs.translate_to(dialogue, Dialogs.language), speaker, false)
	
	if DECISION:
		Dialogs.dialog_box.show_dialog(Dialogs.translate_to(dialogue, Dialogs.language), speaker, true)
	
	if QUEST:
		
		# Runs quest through quest state machine to determine if quest has been completed
		# Quest Objects are stored to local btw  
		
		# Ro DO : 
		# (1) Rewrite to show players options to accept quest
		# (2) Debug Quest Stats UI and update to serialize quest data
		
		var quest_dialog = Quest.QuestGivers.process(quest_name, initial_text, required_item, required_amount, reward_item, reward_amount, delivered_text, pending_text) # call 
		
		print_debug("Has Quest: ", quest_dialog, "empty : " , quest_dialog.empty())
		
		
		if quest_dialog != "":
			print_debug("Show Quest Dialogue Decisions")
			Dialogs.dialog_box.show_dialog(quest_dialog, speaker, true)
			return
		if quest_dialog == "":
			pass
		#Dialogs.show_dialog(dialogs[current_dialog], character_name)
		
			# Updates the Current Dialogue
			#current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())
		
	
	

func hide_signpost():
	print("hiding signpost")
	Dialogs.dialog_box.hide_dialogue()


# Detect Player
func _on_signpost_body_entered(body):
	if not body is Player:
		pass
	if body is Player:
		show_signpost()
		
		#print_debug ('player near signpost ')


# Unused Dialog Exit Code
# Dialog Hide is triggered instead from the Dialog box code
func _on_signpost_body_exited(body):
	if not body is Player:
		return
	
	if body is Player:
		#print_debug ('player near signpost')
		return


func _exit_tree():
	Utils.MemoryManagement.free_object(self) # Memory Management for All Dialog Triggers
