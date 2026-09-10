# *************************************************
# godot4-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Steam Integration
# Features:
# (1) Uses godot 4 steam works library for initialisation
#
# *************************************************
# To do :
# (1) organise quest sub system
# (2) connect to quest subsystem
# (3) implement game achievements (1/3)
# *************************************************

extends Node

signal steam_ready

var app_id = 3888070

func _ready() -> void:
	var initialize_response: Dictionary = await Steam.steamInitEx(true, app_id)
	print_debug("Did Steam initialize?: %s " % initialize_response)

	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)

	var app_installed_depots: Array = Steam.getInstalledDepots(app_id)
	var app_languages: String = Steam.getAvailableGameLanguages()
	var app_owner: int = Steam.getAppOwner()
	var build_id: int = Steam.getAppBuildId()
	var game_language: String = Steam.getCurrentGameLanguage()
	var install_dir = Steam.getAppInstallDir(app_id)
	var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	var is_on_vr: bool = Steam.isSteamRunningInVR()
	var is_online: bool = Steam.loggedOn()
	var is_owned: bool = Steam.isSubscribed()
	var launch_command_line: String = Steam.getLaunchCommandLine()
	var steam_id: int = Steam.getSteamID()
	var steam_username: String = Steam.getPersonaName()
	var ui_language: String = Steam.getSteamUILanguage()

	var SteamData = [
		app_installed_depots, app_languages, app_owner,
		build_id, game_language, install_dir, is_on_steam_deck,
		is_on_vr, is_online, is_owned, launch_command_line, steam_id,
		steam_username, ui_language
	]
	print_debug("app data: ", SteamData)

	steam_ready.emit()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _on_p2p_session_request(remote_steam_id: int) -> void:
	Steam.acceptP2PSessionWithUser(remote_steam_id)
	print_debug("Accepted P2P session from Steam ID: ", remote_steam_id)


func _on_p2p_session_connect_fail(remote_steam_id: int, error: int) -> void:
	push_error("P2P session failed — Steam ID: %d, error: %d" % [remote_steam_id, error])


func load_steam_achievements():
	pass

func load_steam_stats():
	pass
