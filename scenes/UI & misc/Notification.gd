extends Popup


"""
NOTIFICATION GENERIC BAR
"""
#add signals

export (bool)var condition 
export(String) var Display_text = ""

var label  

func _ready():
	# Node not found Error catcher
	if $CenterContainer/Label != null:
		label = $CenterContainer/Label
	else:
		label == null


# Hides the Notification on these levels. Improve code later
	if  str(Globals.curr_scene) != 'Outside':
		if  str(Globals.curr_scene) !=  'HouseInside': #Dont show hints when im playing the game
			#set_exclusive(true)
			#self.call_deferred('popup')
			self.call_deferred('move_child', self.get_child(0), 0)
			self.call_deferred('popup_centered')
			#popup_centered()
			#print (Globals.curr_scene)
	if str (Globals.curr_scene) == 'Outside':# or 'HouseInside':
		hide() 
	if  str(Globals.curr_scene) ==  'HouseInside' :
		hide()

	if label != null &&  label.is_inside_tree() == true :
		label.set_text (Display_text)

func _input(event):
	if event.is_pressed() == true:
		yield(get_tree().create_timer(0.5), "timeout") # Creates an Engine error, use a timer node instead
		hide() 



func _exit_tree():
	self.queue_free()


#func _process(_delta): #add other functionalities to the notificatio bar
#	self.popup() if condition == true else pass
