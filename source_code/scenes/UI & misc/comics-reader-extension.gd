# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Comics Extension script
#
#A Menu for Holding and Displaying Comic book chapters 
#
# Features:
#(1) shows and hides comic page buttons
#(2) Connects to signal from Comics node

# To Do:
#(1) Implement grid panels for mobile screens (done)
# (2) Implement better connects to Comics node, not Signals
# (3) Convert to ads spot emulating webtoons landing page
# *************************************************


extends GridContainer

onready var Grid_Container = self
onready var Scroll_Container = Grid_Container.get_parent()


onready var loaded_comics 

func _ready():
	get_node("chap_1").grab_focus()
	
	#**********Buggy*****************#
	
	# Changes UI Orientation Based on Globals screen Orientation
	if Globals.screenOrientation == 0: #mobile UI 
		Grid_Container.set_columns(2)
		Scroll_Container.set_enable_h_scroll(false)
		Scroll_Container.set_enable_v_scroll(true)
		
		
		
		
		
	elif Globals.screenOrientation == 1: #PC UI
		Grid_Container.set_columns(7)
		Scroll_Container.set_enable_h_scroll(true)
		Scroll_Container.set_enable_v_scroll(false)





"Hides Comics Chapters Buttons"
func _on_Comics_loaded_comics():
	loaded_comics = true
	for child in get_children(): # works
		child.hide()


'Shows Comics Chapter Buttons'
#connected from COomics signal 
func _on_Comics_freed_comics():
	loaded_comics = false
	for child in get_children(): 
		child.show()

"Button controls back"
func _on_Back_button_pressed():
	if loaded_comics == false or Globals.comics != null: #&& Globals.comics.enabled == false :
		Globals._go_to_title()
	if loaded_comics == true:
		#$"/root/Dialogs".show_dialog('Finish Comics First ', 'Admin')
		
		#$"/root/Dialogs".dialog_box.hide()
		pass

# Depreciated
#func _exit_tree()-> void: #resets everything to default
#	if Globals.screenSize != Vector2(0,0):
#		OS.set_window_size(Globals.screenSize) #uses a default screensize
#	#OS.set_screen_orientation (0)
#	pass





#Button controls chap_6
# Depreciated
#func display_locked_text(): #Dis the dialogue noxplays a generic text through
#	Dialogs.show_dialog('Extra Chapters locked ', 'Admin')
#	yield(get_tree().create_timer(1), "timeout")
#	Dialogs.hide_dialogue()



