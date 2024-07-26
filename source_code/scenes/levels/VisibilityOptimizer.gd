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


extends VisibleOnScreenNotifier2D


@onready var Parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Connect Signals
	connect("screen_entered", Callable(self, "show"))
	connect("screen_exited", Callable(self, "hide"))

	# Hide when first entering scene 
	Parent.hide()
	Parent.visible = false


func _hide():
	#print(Parent, "left screen hiding", Parent) # For Debug Purposes only
	
	# Hide Parend
	Parent.hide()
	
	# HIde Parent Visibility
	Parent.visible = false

func _show():
	#print(Parent, "entered screen, showing", Parent) # For Debug Purposes only
	Parent.show()
	Parent.visible = true
