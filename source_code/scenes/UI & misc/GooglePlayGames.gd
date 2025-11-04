extends Node

# documentation : https://github.com/Iakobs/godot-google-play-game-services-android-plugin
#
# methods documentations:
# (1) https://github.com/Iakobs/godot-google-play-game-services-plugin?tab=readme-ov-file#methods
# to do:
# (1) implement google play game services into the game for testing
# (2) test on local hardware

var GooglePlayGames : JNISingleton
#
# signals
#
signal leaderboards_all_loaded
signal achievements_loaded(achievements) #: Array[Dictionary]
signal achievements_revealed(revealed, achievement_id)
signal events_loaded(events)




func _ready() -> void:

	GooglePlayGames=Engine.get_singleton("GodotGooglePlayGameServices")
#	pass # Replace with function body.



# Achievements
func achievements_increment(achievement_id: String, amount: int):
	pass

# Events

# Leader boards
func _on_leaderboards_all_loaded():
	pass

# Players

# Sign in

# Snapshots
