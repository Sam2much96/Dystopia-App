# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Quest Singleton
# 
# To Do:
#(1) Write Proper Documentation (Done)
# (2) Connect to Playstore through the Networking singleton (Depreciated)
# (3) Match Quest Logic From CSV File
# (4) Match Quest Rewards From CSV Files
# *************************************************


extends Node

class_name quest

"""
Minimal quest system implementation.

A dictionary where each string key represents a quest and an int value represanting a status
"""

enum STATUS { NONEXISTENT, STARTED, COMPLETE, FAILED }


# Emitted whenever a quests changes. It'll pass the quest name and new status
signal quest_changed(quest_name, status)

var quest_list : Dictionary = {}

# Get the status of a quest. If it's not found it returns STATUS.NONEXISTENT
func get_status(quest_name:String) -> int:
	if quest_list.has(quest_name):
		return quest_list[quest_name]
	else:
		return STATUS.NONEXISTENT


func get_status_as_text(quest_name:String) -> int:
	var status = get_status(quest_name)
	return STATUS.keys()[status]


# Change the state of some quest. status should be Quests.STATUS.<some status>
func change_status(quest_name:String, status:int) -> bool:
	if quest_list.has(quest_name):
		quest_list[quest_name] = status
		emit_signal("quest_changed", quest_name, status)
		return true
	else:
		return false


# Start a new quest
func accept_quest(quest_name:String) -> bool:
	if quest_list.has(quest_name):
		return false
	else:
		quest_list[quest_name] = STATUS.STARTED
		emit_signal("quest_changed", quest_name, STATUS.STARTED)
		return true


# List all the quest in a certain status
func list(status:int) -> Array:
	if status == -1:
		return quest_list.keys()
	var result = []
	for quest in quest_list.keys():
		if quest_list[quest] == status:
			result.append(quest)
	return result

func get_quest_list() -> Dictionary:
	return quest_list.duplicate()


# Remove a quest from the list of quests
func remove_quest(quest_name:String) -> bool:
	if quest_list.has(quest_name):
		quest_list.erase(quest_name)
		emit_signal("quest_changed", quest_name, STATUS.NONEXISTENT)
		return true
	else:
		return false









# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Quest Giver (Depreciated Codebase Refactored to Lass)
# 
#Needs:
# (1) Documentation
# (2) Should Be Triggerable Outside NPC Scene
# (3) NPC Navigation A.I. needs refactoring
# (4) Quest Systems needs major refactoring
# *************************************************

# TO DO:
# (1) Refactoring to Dialog Trigger Script


class QuestGivers extends Reference:
	
	# TO DO: 
	# (1) Match Quest Logic From CSV File
	# (2) Match Quest Rewards From CSV Files
	
	# Quest Giver Logic As A Class
	# Matched Different Responses To the state of the Given Quest
	
	static func process(
		quest_name: String, 
		initial_text: String, 
		required_item : String, 
		required_amount : int, 
		reward_item : String , 
		reward_amount : int,
		delivered_text : String,
		pending_text : String
		) -> String:
		
		var quest_status = Quest.get_status(quest_name)
		print_debug ("Quest Debug 1:", quest_status)
		match quest_status:
			Quest.STATUS.NONEXISTENT:
				Quest.accept_quest(quest_name)
				return initial_text
			Quest.STATUS.STARTED:
				if Inventory.get_item(required_item) >= required_amount:
					Inventory.remove_item(required_item, required_amount)
					Quest.change_status(quest_name, Quest.STATUS.COMPLETE)
					Inventory.add_item(reward_item, reward_amount)
					return delivered_text
					
				else:
					return pending_text
			Quest.STATUS.COMPLETE:
				return "Quest Completed"
			_:
				return ""

