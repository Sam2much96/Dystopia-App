# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Visibility Optimizer
# Reusable script Optimizes Framerate Performance by hiding it's Parent Node
# Features:
#(1) Can be Reused
#(2) 
#(3) 
#(4) 
# *************************************************
# 
#


extends VisibilityNotifier2D


onready var Parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Connect Signals
	connect("screen_entered",self,"show")
	connect("screen_exited",self,"hide")

	# Hide when first entering scene 
	Parent.hide()
	Parent.visible = false


func hide():
	#print(Parent, "left screen hiding", Parent) # For Debug Purposes only
	
	# Hide Parend
	Parent.hide()
	
	# HIde Parent Visibility
	Parent.visible = false

func show():
	#print(Parent, "entered screen, showing", Parent) # For Debug Purposes only
	Parent.show()
	Parent.visible = true
