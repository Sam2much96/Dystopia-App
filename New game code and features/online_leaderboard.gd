extends Node
"""
A RUDIMENTARY IMPLEMENTATION OF AN ONLINE HIGHSCORE SYSTEM
"""
#This Should run as a child of the Server scene
var leaderboard = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _get_highscores(): #Gets the top 5 highscore killcount as a dictionary
	pass

func _save_highscores(): #Saves your highscore and your name to the server
	pass
	
func _display_highsocres():
	pass
