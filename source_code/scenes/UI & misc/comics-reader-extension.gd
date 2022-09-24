extends HBoxContainer

#A Menu for Holding and Displaying Comic book chapters

onready var loaded_comics 

func _ready():
	get_node("chap_1").grab_focus()
	pass


func _input(event):
	'JoyStick Controls'
	#Cancel event 
	if event is InputEventJoypadButton :
		if event.is_action_pressed("ui_cancel"):
			Globals._go_to_title()



#Shows Comics Chapters Buttons
func _on_Comics_loaded_comics():
	loaded_comics = true
	for child in get_children(): # works
		child.hide()


#Hides Comics Chapter Buttons 
func _on_Comics_freed_comics():
	loaded_comics = false
	for child in get_children(): 
		child.show()

#Button controls back
func _on_Back_button_pressed():
	if loaded_comics == false or Globals.comics != null: #&& Globals.comics.enabled == false :
		Globals._go_to_title()
	if loaded_comics == true:
		#$"/root/Dialogs".show_dialog('Finish Comics First ', 'Admin')
		
		#$"/root/Dialogs".dialog_box.hide()
		pass


func _exit_tree()-> void: #resets everything to default
	if Globals.screenSize != Vector2(0,0):
		OS.set_window_size(Globals.screenSize) #uses a default screensize
	#OS.set_screen_orientation (0)
	pass





#Button controls chap_6

func display_locked_text(): #Dis the dialogue noxplays a generic text through
	Dialogs.show_dialog('Extra Chapters locked ', 'Admin')
	yield(get_tree().create_timer(1), "timeout")
	Dialogs.hide_dialogue()



#func _on_chap_4_pressed():
#	display_locked_text()


#func _on_chap_5_pressed():
#	display_locked_text()

#func _on_chap_6_pressed():
#	display_locked_text()

#func _on_chap_7_pressed():
#	display_locked_text()
