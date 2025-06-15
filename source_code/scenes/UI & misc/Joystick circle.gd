# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a script that controls the joystick circle node
# information used by the UI codes and Touchscreen Interface codes.
# Features
# (1) Multiple colors
# (2) Changabe size
# (3) It is touchscreen
 
# Bugs
# (1) Non alignment of circle
# 
# ************************************************* 
# 
# ************************************************* 
# Features to Add
#(1) Add a color changer get function


extends TouchScreenButton

class_name JoystickCircle


##########################################
## Draws a Circle                         ##
## Use cirlcle size to set circle size     ##
###############################################
#export (Texture) var texture setget _set_texture

var colorRed
var colorGrey
var colorYt
var colorBlue
var colorBlck
export (String) var Default_clr

export (int) var circle_size
export (Vector2) onready var pos = $Position2D.position

func _ready():
	
	# Stores color details to Variables
	colorRed= Color( 0.7, 0.13, 0.13, 1)
	colorGrey = Color( 0.41, 0.41, 0.41, 1 )
	colorYt= Color( 0.97, 0.97, 1, 1 )
	colorBlue = Color( 0.12, 0.56, 1, 1 )
	colorBlck= Color( 0, 0, 0, 1 )



func _process(delta):
	if self.visible:
		update()
	else : pass

func _draw():
	if circle_size != null:
		#draw_circle(pos, circle_size, Color( 0.7, 0.13, 0.13, 1 )) #use a color variable instead
		draw_circle(pos, circle_size, colorBlck) # Works, create logic for drawing different circle types amd strokes
