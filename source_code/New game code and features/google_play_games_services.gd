# *************************************************
# Google Play Games Services
# Implements Google Play Game Services 
# To Do:
#(1) Implements
#(2) Use
#(3) Debug
# *************************************************


extends Node

class_name GooglePlay


var play_games_services
var show_popups := true 

func _enter_tree():
# Check if plugin was added to the project
	if Engine.has_singleton("GodotPlayGamesServices"):
	  play_games_services = Engine.get_singleton("GodotPlayGamesServices")
	
  # Initialize plugin by calling init method and passing to it a boolean to enable/disable displaying game pop-ups
  
func _ready():
  # For enabling saved games functionality use below initialization instead
  # play_games_services.initWithSavedGames(show_popups, "SavedGamesName")
	connect_signals()

func _init():
	play_games_services.init(show_popups)

func sign_in()-> bool:
	play_games_services.signIn()
	
	var is_signed_in: bool = play_games_services.isSignedIn() #checks if user is signed in
	return is_signed_in


func unlock_achievement (ACHIEVEMENT_ID :String): # Unlocks an achievement with Achievement ID
	play_games_services.unlockAchievement(ACHIEVEMENT_ID)

# Callbacks:
func _on_achievement_unlocked(achievement: String):
	pass

func _on_achievement_unlocking_failed(achievement: String):
	pass

# Callbacks:
func _on_sign_in_success(account_id: String) -> void:
	pass
  
func _on_sign_in_failed(error_code: int) -> void:
	pass



# Callbacks:
func _on_sign_out_success():
	pass
  
func _on_sign_out_failed():
	pass
  
func increment_achievement() -> void:
	var step = 1
	play_games_services.incrementAchievement("ACHIEVEMENT_ID", step)

# Callbacks:
func _on_achievement_incremented(achievement: String):
	pass

func _on_achievement_incrementing_failed(achievement: String):
	pass


func reveal_achievement(ACHIEVEMENT_ID : String ) -> void:
	play_games_services.revealAchievement(ACHIEVEMENT_ID)

# Callbacks:
func _on_achievement_revealed(achievement: String):
	pass

func _on_achievement_revealing_failed(achievement: String):
	pass

func show_achievements()-> void:
	play_games_services.showAchievements()

func load_achievement_info()-> void:
	play_games_services.loadAchievementInfo(false) # forceReload

# Callbacks:
func _on_achievement_info_load_failed(event_id: String):
	pass

func _on_achievement_info_loaded(achievements_json: String):
	var achievements = parse_json(achievements_json)

	# The returned JSON contains an array of achievement info items.
	# Use the following keys to access the fields
	for a in achievements:
		a["id"] # Achievement ID
		a["name"]
		a["description"]
		a["state"] # unlocked=0, revealed=1, hidden=2 (for the current player)
		a["type"] # standard=0, incremental=1
		a["xp"] # Experience gain when unlocked

		# Steps only available for incremental achievements
		if a["type"] == 1:
			a["current_steps"] # Users current progress
			a["total_steps"] # Total steps to unlock achievement

func submit_leaderboard_score(score : int) -> void:
#var score = 1234
	play_games_services.submitLeaderBoardScore("LEADERBOARD_ID", score)

# Callbacks:
func _on_leaderboard_score_submitted(leaderboard_id: String):
	pass

func _on_leaderboard_score_submitting_failed(leaderboard_id: String):
	pass


func show_leader_board()-> void:
	play_games_services.showLeaderBoard("LEADERBOARD_ID")
	play_games_services.showAllLeaderBoards()

func submit_event()-> void:
	var increment_by := 2
	play_games_services.submitEvent("EVENT_ID", increment_by)

# Callbacks:
func _on_event_submitted(event_id: String):
	pass
	
func _on_event_submitted_failed(event_id: String):
	pass


func load_all_events() -> void:
	# Load all events
	play_games_services.loadEvents()

func load_by_event_id(EVENT_ID: String):
	# Or load events by given ids
	play_games_services.loadEventsById(["EVENT_ID_1", "EVENT_ID_2", "..."])

# Callbacks:
# If there is at least one event, following callback will be triggered:
func _on_events_loaded(events_array):
	# Parse received string json of events using parse_json
	var available_events = parse_json(events_array)
	# Iterate through the events_list to retrieve data for specific events
	for event in available_events:
		var event_id = event["id"] # you can get event id using 'id' key
		var event_name = event["name"] # you can get event name using 'name' key
		var event_desc = event["description"] # you can get event name using 'description' key 
		var event_img = event["imgUrl"] # you can get event name using 'imgUrl' key
		var event_value = event["value"] # you can get event name using 'value' key  
	
# Triggered if there are no events:
func _on_events_empty():
	pass

# Triggered if something went wrong:
func _on_events_loading_failed():
	pass

func load_player_stats():
	var force_refresh := true # If true, this call will clear any locally cached data and attempt to fetch the latest data from the server.
	play_games_services.loadPlayerStats(force_refresh)

# Callbacks:
func _on_player_stats_loaded(stats):
	var stats_dictionary: Dictionary = parse_json(stats)
	# Using below keys you can retrieve data about a player’s in-game activity
	stats_dictionary["avg_session_length"] # Average session length
	stats_dictionary["days_last_played"] # Days since last played
	stats_dictionary["purchases"] # Number of purchases
	stats_dictionary["sessions"] # Number of sessions
	stats_dictionary["session_percentile"] # Session percentile
	stats_dictionary["spend_percentile"] # Spend percentile

func _on_player_stats_loading_failed():
	pass


func load_player_info() -> void:
	play_games_services.loadPlayerInfo()

# Callbacks:	
func _on_player_info_loaded(info):
	var info_dictionary: Dictionary = parse_json(info)
	# Using below keys you can retrieve player’s info
	info_dictionary["display_name"]
	info_dictionary["name"]
	info_dictionary["title"]
	info_dictionary["player_id"]
	info_dictionary["hi_res_image_url"]
	info_dictionary["icon_image_url"]
	info_dictionary["banner_image_landscape_url"] 
	info_dictionary["banner_image_portrait_url"]
	# Also you can get level info for the player
	var level_info_dictionary = info_dictionary["level_info"]
	level_info_dictionary["current_xp_total"]
	level_info_dictionary["last_level_up_timestamp"]
	
	var current_level_dictionary = level_info_dictionary["current_level"]
	current_level_dictionary["level_number"]
	current_level_dictionary["max_xp"]
	current_level_dictionary["min_xp"]

	var next_level_dictionary = level_info_dictionary["next_level"]
	next_level_dictionary["level_number"]
	next_level_dictionary["max_xp"]
	next_level_dictionary["min_xp"]
	

func _on_player_info_loading_failed():
	pass 



func save_game_snapshot()-> void: # Use actual player details from form
	var data_to_save: Dictionary = {
		"name": "John", 
		"age": 22,
		"height": 1.82,
		"is_gamer": true
	}
	play_games_services.saveSnapshot("SNAPSHOT_NAME", to_json(data_to_save), "DESCRIPTION")

# Callbacks:
func _on_game_saved_success():
	pass
	
func _on_game_saved_fail():
	pass

func load_game_snapshot( SNAPSHOT_NAME: String )-> void:
	play_games_services.loadSnapshot(SNAPSHOT_NAME)

# Callbacks:
func _on_game_load_success(data):
	var game_data: Dictionary = parse_json(data)
	var name = game_data["name"]
	var age = game_data["age"]
	#...
	
	
func _on_game_load_fail():
	pass


func show_saved_snapshot_screen() -> void:
	var allow_add_button := true
	var allow_delete_button := true
	var max_saved_games_snapshots := 5
	var saved_games_screen_title := "TITLE"
	play_games_services.showSavedGames(saved_games_screen_title, allow_add_button, allow_delete_button, max_saved_games_snapshots)

#Godot callback	
# If user clicked on add new snapshot button on the screen with all saved snapshots, below callback will be triggered:
func _on_create_new_snapshot(name):
	var game_data_to_save: Dictionary = {
		"name": "John", 
		"age": 22,
		"height": 1.82,
		"is_gamer": true
	}
	play_games_services.save_snapshot(name, to_json(game_data_to_save), "DESCRIPTION")



func _sign_out():
	play_games_services.signOut() # Disable during runtime


func troubleshoot()-> void :
	#Check adb logcat for debuging. To filter only Godot messages use next command: adb logcat -s godot
	pass

func connect_signals()-> void:
	  # Connect callbacks (Use only those that you need)
	  play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success") # account_id: String
	  play_games_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed") # error_code: int
	  play_games_services.connect("_on_sign_out_success", self, "_on_sign_out_success") # no params
	  play_games_services.connect("_on_sign_out_failed", self, "_on_sign_out_failed") # no params
	  play_games_services.connect("_on_achievement_unlocked", self, "_on_achievement_unlocked") # achievement: String
	  play_games_services.connect("_on_achievement_unlocking_failed", self, "_on_achievement_unlocking_failed") # achievement: String
	  play_games_services.connect("_on_achievement_revealed", self, "_on_achievement_revealed") # achievement: String
	  play_games_services.connect("_on_achievement_revealing_failed", self, "_on_achievement_revealing_failed") # achievement: String
	  play_games_services.connect("_on_achievement_incremented", self, "_on_achievement_incremented") # achievement: String
	  play_games_services.connect("_on_achievement_incrementing_failed", self, "_on_achievement_incrementing_failed") # achievement: String
	  play_games_services.connect("_on_achievement_info_loaded", self, "_on_achievement_info_loaded") # achievements_json : String
	  play_games_services.connect("_on_achievement_info_load_failed", self, "_on_achievement_info_load_failed")
	  play_games_services.connect("_on_leaderboard_score_submitted", self, "_on_leaderboard_score_submitted") # leaderboard_id: String
	  play_games_services.connect("_on_leaderboard_score_submitting_failed", self, "_on_leaderboard_score_submitting_failed") # leaderboard_id: String
	  play_games_services.connect("_on_game_saved_success", self, "_on_game_saved_success") # no params
	  play_games_services.connect("_on_game_saved_fail", self, "_on_game_saved_fail") # no params
	  play_games_services.connect("_on_game_load_success", self, "_on_game_load_success") # data: String
	  play_games_services.connect("_on_game_load_fail", self, "_on_game_load_fail") # no params
	  play_games_services.connect("_on_create_new_snapshot", self, "_on_create_new_snapshot") # name: String
	  play_games_services.connect("_on_player_info_loaded", self, "_on_player_info_loaded")  # json_response: String
	  play_games_services.connect("_on_player_info_loading_failed", self, "_on_player_info_loading_failed")
	  play_games_services.connect("_on_player_stats_loaded", self, "_on_player_stats_loaded")  # json_response: String
	  play_games_services.connect("_on_player_stats_loading_failed", self, "_on_player_stats_loading_failed")
