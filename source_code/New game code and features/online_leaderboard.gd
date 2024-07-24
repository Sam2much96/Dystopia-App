extends Node

class_name OnlineLeaderboard


"""
A RUDIMENTARY IMPLEMENTATION OF AN ONLINE HIGHSCORE SYSTEM
"""
#This Should run as a child of the Server scene
# Depreciated, Use Google Play games services instead
var leaderboard = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Get Request
func _get_highscores(): #Gets the top 5 highscore killcount as a dictionary
	pass

# Post Request
func _save_highscores(): #Saves your highscore and your name to the server
	pass

# Show 
func _display_highsocres():
	pass
