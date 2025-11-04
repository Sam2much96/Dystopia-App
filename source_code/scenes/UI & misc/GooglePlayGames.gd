extends Node

# documentation : https://github.com/Iakobs/godot-google-play-game-services-android-plugin
#
# methods documentations:
# (1) https://github.com/Iakobs/godot-google-play-game-services-plugin?tab=readme-ov-file#methods
# to do:
# (1) implement google play game services into the game for testing
# (2) test on local hardware
# (3) Implementing Achievements as part of google play games services update

export (bool) var enabled : bool 
var GooglePlayGames : JNISingleton
#
# signals
#

signal achievements_loaded(achievements) #: Array[Dictionary]
signal achievements_revealed(revealed, achievement_id)
signal events_loaded(events)
signal events_loaded_by_ids(events)
signal leaderboards_score_submitted(submitted,leaderboard_id)
signal leaderboards_score_loaded(leaderboard_id, score)
signal leaderboards_all_loaded(leaderboards)
signal leaderboards_player_centered_scores_loaded(leaderboard_id,leaderboard_scores)
signal leaderboards_top_scores_loaded(leaderboard_id, leaderboard_scores)
signal players_current_loaded(player)
signal players_friends_loaded(friends)
signal players_searched(player)
signal sign_in_user_authenticated(is_authenticated)
signal sign_in_requested_server_side_access(token)
signal snapshots_game_saved(saved,file_name,description)
signal snapshots_game_loaded(snapshot)
signal snapshots_conflict_emitted(conflict)


# safe pointer to android singleton
onready var safe_Android = get_node("/root/Android")

func _ready() -> void:
	
	if safe_Android.is_android() && enabled:
		GooglePlayGames=Engine.get_singleton("GodotGooglePlayGameServices")
	else:
		pass 



# Achievements
func achievements_increment(achievement_id: String, amount: int):
	GooglePlayGames.achievements_increment(achievement_id,amount)


func achievements_load(force_reload: bool):
	pass

func achievements_reveal(achievement_id: String):
	pass

func achievements_show():
	pass

func achievements_unlock(achievement_id: String):
	pass

func events_increment(event_id: String, amount: int):
	pass

# Events


func events_load(force_reload: bool):
	pass

func events_load_by_ids(force_reload: bool, event_ids: PoolStringArray):
	pass

# Leader boards
func leaderboards_show_all():
	pass

func leaderboards_show(leaderboard_id: String):
	pass

func leaderboards_show_for_time_span(leaderboard_id: String, time_span: int):
	pass

func leaderboards_show_for_time_span_and_collection(leaderboard_id: String, time_span: int, collection: int):
	pass

func leaderboards_submit_score(leaderboard_id: String, score: float):
	pass

func leaderboards_load_player_score(leaderboard_id: String, time_span: int, collection: int):
	pass

func leaderboards_load_all(force_reload: bool):
	pass

func leaderboards_load(leaderboard_id: String, force_reload: bool):
	pass

func leaderboards_load_player_centered_scores(leaderboard_id: String, time_span: int, collection: int, max_results: int, force_reload: bool):
	pass

func leaderboards_load_top_scores(leaderboard_id: String, time_span: int, collection: int, max_results: int, force_reload: bool):
	pass

# Players

func players_compare_profile(other_player_id: String):
	pass

func players_compare_profile_with_alternative_name_hints(other_player_id: String, other_player_in_game_name: String, current_player_in_game_name: String):
	pass

func players_load_current_player(force_reload: bool):
	pass

func players_load_friends(page_size: int, force_reload: bool, ask_for_permission: bool):
	pass

func players_search():
	pass

# Sign in
#
func sign_in_is_authenticated():
	pass

func sign_in_show_popup():
	pass

func sign_in_request_server_side_access(server_client_id: String, force_refresh_token: bool):
	pass

# Snapshots

func snapshots_load_game(file_name: String):
	pass

func snapshots_save_game(file_name: String, description: String, save_data: PoolByteArray, played_time_millis: int, progress_value: int):
	pass

func snapshots_show_saved_games(title: String, allow_add_button: bool, allow_delete: bool, max_snapshots: int):
	pass
