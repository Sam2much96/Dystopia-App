# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Joystick UI selector
# Cycles through a list of UI items once the joystick is being used
# To Do:
#(1) Update DOcumentation
# (2) Improve Code
# Bugs:
# (1) Doesn't select well
# (2) Doesn't show button hints
# *************************************************


extends Control

class_name JoyStickUI

var selector = 0

func _input(event):
	if event is InputEventJoypadMotion and visible == true:
		#cycle through the list with analogue and Grab focus
		var axis = event.get_axis_value()
		
		var buttons = []
		buttons = self.get_children() 
		
		if selector == 0:
			#print ('Game menu UI Selector: ', buttons) #for debug purposes only
			return

		
		
		if axis == round (1):
			selector += 1 
		if axis == round (-1):
			selector -= 1
			

#Handles some basic error catching with the selector
		if selector >= int(buttons.size()):#stops the selector from overreaching
			selector = 6
			
		if selector <= -(int(buttons.size())):
			selector = -7
		buttons[selector ].grab_focus()

#handles button clicking
		if event.is_action_pressed("ui_select", true):
#			buttons[selector ].ACTION_MODE_BUTTON_PRESS
			return
		buttons.clear()
		pass
