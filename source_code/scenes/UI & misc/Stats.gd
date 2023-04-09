# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Stats
# Updates Game Stats to the UI
# currenty updates quests, Killcount and Algos
# Features
# (1) Parses Quest Data from Singleton
# *************************************************

extends PanelContainer

export (bool) var enabled #= false
signal not_enabled
signal enabled

onready var Algos : Label = $VBoxContainer/HBoxContainer/Quests/Algos

func _ready():
	
	
	Globals.save_game()
	get_tree().set_auto_accept_quit(false)
	hide()

func _input(event):
	if event.is_action_pressed("pause")  && enabled == false: #this code breaks
			emit_signal("not_enabled")
			enabled = true
			visible = enabled
			get_tree().paused = enabled
			grab_focus()
			_update_quest_listing()
			_update_item_listing()
			_update_wallet_stats()
			return enabled
			pass
	if event.is_action_pressed("pause") && enabled == true:
			enabled = false
			emit_signal('enabled')
			visible = enabled
			hide()
			get_tree().paused = false
			
			_update_wallet_stats()
			#print (enabled)
			return enabled



#
func _update_wallet_stats(): #Updates killcount and Algos
	Algos.text = 'mAlgos: ' + str (Globals.algos)


func _update_quest_listing():
	var text = ""
	text += "Started:\n"
	for quest in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % quest
	text += "Failed:\n"
	for quest in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % quest
	
	$VBoxContainer/HBoxContainer/Quests/Details.text = text
	pass

func _update_item_listing():
	var text = ""
	var inventory = Inventory.list()
	if inventory.empty():
		text += "[Empty]"
	for item in inventory:
		text += "%s x %s\n" % [item, inventory[item]]
	$VBoxContainer/HBoxContainer/Inventory/Details.text = text
	pass



func _notification(what):  #i removed this notification functioncode from the game cuz i don't know what it does yet
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		quit_game()
		pass
func quit_game():
	Globals.save_game()
	get_tree().quit()
