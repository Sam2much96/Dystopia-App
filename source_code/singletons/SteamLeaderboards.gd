# *************************************************
# Steam Leaderboards
# Tracks the Kill_Count leaderboard, keyed to Globals.kill_count
# *************************************************

extends Node

const LEADERBOARD_NAME := "Kill_Count"

signal top_entries_downloaded(entries: Array)

var leaderboard_handle: int = 0
var _pending_score: int = -1


func _ready() -> void:
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

	SteamController.steam_ready.connect(_on_steam_ready)


func _on_steam_ready() -> void:
	Steam.findOrCreateLeaderboard(
		LEADERBOARD_NAME,
		Steam.LEADERBOARD_SORT_METHOD_DESCENDING,
		Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC
	)


func submit_kill_count(kill_count: int) -> void:
	if leaderboard_handle == 0:
		_pending_score = kill_count
		return
	Steam.uploadLeaderboardScore(kill_count, true, PackedInt32Array(), leaderboard_handle)


func download_top_entries(count: int = 10) -> void:
	if leaderboard_handle == 0:
		return
	Steam.downloadLeaderboardEntries(1, count, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, leaderboard_handle)


func _on_leaderboard_find_result(handle: int, found: int) -> void:
	if found == 0:
		push_error("SteamLeaderboards: leaderboard '%s' not found" % LEADERBOARD_NAME)
		return

	leaderboard_handle = handle
	if _pending_score >= 0:
		submit_kill_count(_pending_score)
		_pending_score = -1


func _on_leaderboard_score_uploaded(success: bool, _handle: int, this_score: Dictionary) -> void:
	print_debug("SteamLeaderboards: score upload success: ", success, " ", this_score)


func _on_leaderboard_scores_downloaded(_message: String, _handle: int, entries: Array) -> void:
	top_entries_downloaded.emit(entries)
