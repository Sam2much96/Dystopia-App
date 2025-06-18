# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#  Touch Debug
#  Features:
# (1) Debugs the Touch Input to the screen
# (2) Requires a node 2d object to draw debug circles
# *************************************************
# To do:
# (1) Map state and controls to debug singleton
# *************************************************


extends Node2D

class_name Touch_Debug

export (bool) var Debug_ = false

# Declare member variables here. Examples:

onready var Touch = get_parent()

func _process(_delta):
	Debug_ = Debug.enabled # sync state with global debug
	if Debug_:
		# Keep redrawing on every frame.
		update()
	else:
		
		self.hide() # should ideally clear but haven't figured out that functio yet
		# to do: (1) clear debug
		#set_process(false) # turn off

func _draw():
	
	if Debug_:
		# Draw every pointer as a circle.
		#print(Touch.touches)
		for ptr_index in Touch.touch_pos.keys():
			var pos = Touch.touch_pos[ptr_index]
			#print_debug("pos debug: ", pos)
			
			var color = get_parent().Screen._get_color_for_ptr_index(int(ptr_index))
			color.a = 0.75
			draw_circle(pos, 40.0, color)
