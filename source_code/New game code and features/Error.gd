extends Control


var text_2 : String ="""
		I'm Sorry the App Crashed :( ,
		 No Internet Access.Please Connect to the
		Internet and Try Again thank you 
		"""

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
#func _ready():
#	label.set_text( text_2)
	



func _on_Timer_timeout():
	get_tree().quit(0)
