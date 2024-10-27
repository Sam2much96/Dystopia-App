extends Node2D

# Simple Drawing App Logic
#
# A Simple Drawing Software in a single Class
# Expandable as a Plugin for Other Software

# To Do :
# (1) Implement As Plugin
# (2) Make Memory Safe
# (3) Expand Functionality For Other Projects

# WOrks

class_name ComicsV8

export (bool) var enabled = false

var _lines_pointer : Array = []
onready var _lines := $Lines
var _pressed := false
var _current_line : Line2D
export (float) var LineWidth = 5.0
export (int) var LineCount : int = 0


func _input(event):
	
	if not enabled: # Guard Clause 2
		return
	
	if not Input.is_mouse_button_pressed(BUTTON_LEFT): # Guard Clause
		return
	
	# Get Mouse Event
	if event is InputEventMouseButton:
		_pressed = event.is_pressed()
	
		# Create A New Line
		if _pressed: # Nested Ifs?
			_current_line = Line2D.new()
			_current_line.set_default_color(Color.black) # Set Line Colour
			_current_line.width = LineWidth # Set Line Width
			_lines.add_child(_current_line) # Add Line to Scene Tree
			_lines_pointer.append(_current_line) # Store Pointer To Line In Array Memory

	# Add Points To Line
	if event is InputEventMouseMotion && _pressed:
		_current_line.add_point(event.position)

# Draw A Cirlce
#func _draw() -> void:
#	for point in _click_pos:
#		draw_circle(point, 10,Color.red)
#_click_pos.append(event.position)
	#update()

# Delete Last Stroke
func _on_undo_pressed():
	#Kinda Works? Not Precise
	get_node("Lines").get_child(1).queue_free()

# Clear All Drawn Lines
func _on_clear_pressed():
	for i in _lines.get_children():
		i.queue_free()



# AI Logic
# (1)  Get Png Of Drawings
# (2) Send It To ToonCrafters A.I. via Replicate API via http request
# (3) Download The resulting video / png sequece
# (4) Load It in For Preview
# (5) Cache Results 
# (6) Show In side viewports
func AI()-> void: 
	pass


"""
UI Signals
"""

# Change Brush Size
func _on_Brush_Size_text_entered(new_text):
	LineWidth = int(new_text)
	return LineWidth


func _on_save_pressed():
	var img =get_tree().get_root().get_texture().get_data() # Get The Viewport Data
	return img.save_png("User://") # SHould save to app's data folder


func _on_Pen_pressed() -> int:
	if enabled == false:
		enabled = true
		return 0
	if enabled == true:
		enabled = false
		return 0
	return 0


func _on_minimap_gui_input(event):
	enabled = true
