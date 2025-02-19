extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	
	# WEB WAY TEMPLATE
	# this is testing opening the Dystopia store site
	print_debug("opening store webway")
	# Open URL to My Website
	# TO DO:
	# (1) Add more parameters to turn off HowlerJS via header setting
	# (2) Add config for the site in headers
	#
	# Turn off Music Temp Hacky fix
	# should ideally pass a parameter to the website via headers to disable music
	Music._notification(NOTIFICATION_APP_PAUSED)
	
	Networking.open_browser("https://www.dystopia-app.store")
