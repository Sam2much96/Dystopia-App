# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Stats
# Updates Game Stats to the UI.
# Displays Quest and Inventory INformation to the Player
# currenty updates quests, Killcount and Algos
# Features
# (1) Parses Quest Data from Singleton
#
# TO-DO:
# 
# (1) Scrolling Inbentory Menu (Done)
# (2) Should AutoScale to Screen Display size using Global screen calculation functions
# (3) Inventory Items Should be Accessible

# *************************************************

extends PanelContainer

class_name Stats

export (bool) var enabled #= false
signal not_enabled
signal enabled

onready var scroller : ScrollContainer = $ScrollContainer

func _ready():
	self.get_child(0)
	
	#Globals.save_game() # Depreciated
	get_tree().set_auto_accept_quit(false)
	hide()

func _input(event):
	"""
	UPDATES STATUS HUD ON PAUSE 
	"""
	if event.is_action_pressed("pause")  && enabled == false: #this code breaks
		emit_signal("not_enabled")
		enabled = true
		visible = enabled
		Music.play_track(Music.ui_sfx[0])
		get_tree().paused = enabled
		
		Globals._TouchScreenHUD.status()
		#TouchScreenHUD.status(Globals._TouchScreenHUD) #GameHUD already calls this method
		
		"Grab Focus ?"
		#grab_focus()
		_update_quest_listing()
		_update_item_listing()
		_update_wallet_stats()
		return enabled
		pass
	if event.is_action_pressed("pause") && enabled == true:
		enabled = false
		emit_signal('enabled')
		visible = enabled
		Music.play_track(Music.ui_sfx[1])
		hide()
		get_tree().paused = false
		#print (enabled)
		return enabled



	
	"Auto Scroller"
	# DIsabled
	# Connects to Global Comics Swipe Feature
	#'AutoScroller'
	# Implemented but Requires Proper Swipe Gesture Callibration
	# 

	#if Comics_v6._state == Comics_v6.SWIPE_RIGHT:
		
		# Scroll Down
	#	Globals.Functions.scroll(false, enabled,scroller)
	#elif Comics_v6._state == Comics_v6.SWIPE_DOWN:
		
		# Scroll Up
	#	Globals.Functions.scroll(true, enabled,scroller)
		
	#else: pass



func _update_wallet_stats(): #Updates killcount and Algos
	$ScrollContainer/Quests/Algos.text = 'mAlgos: ' + str (Globals.algos)


func _update_quest_listing():
	var text = ""
	text += "Started:\n"
	for quest in Quest.list(Quest.STATUS.STARTED):
		text += "  %s\n" % quest
	text += "Failed:\n"
	for quest in Quest.list(Quest.STATUS.FAILED):
		text += "  %s\n" % quest
	
	$ScrollContainer/Quests/Details.text = text
	pass

func _update_item_listing():
	var text = ""
	var inventory = Inventory.list()
	if inventory.empty():
		text += "[Empty]"
	for item in inventory:
		# Sorts Items Into Individual Lines using REGEX
		text += "%s x %s\n" % [item, inventory[item]]
	$ScrollContainer/Quests/Details2.text = text
	pass



func _notification(what):  #i removed this notification functioncode from the game cuz i don't know what it does yet
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print_debug("STATUS NOTIFICATION")



func _on_status_showing():
	#TouchInterface.status()
	Globals._TouchScreenHUD.reset()
	#TouchInterface.Anim.play("STATUS") # doesnt work
	
	#print_debug("TC hidden:",TouchInterface._Hide_touch_interface, " SC: ", TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status hidden') #for debug purposes

func _on_status_hidden():
	#$Stats.enabled = false
	 #Duplicate of 
	#TouchInterface.reset()
	Globals._TouchScreenHUD.status()
	#print_debug("TC hidden:",TouchInterface._Hide_touch_interface, " SC: ", TouchInterface._state_controller) # Touch Interface Debug
	print_debug('status showing')

