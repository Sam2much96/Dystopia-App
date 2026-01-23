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
# (3) implement game achievements
# *************************************************

extends Node

var app_id = 3888070

func _ready() -> void:
	#testing the steam api integration
	
	# initialise steam here in code
	var initialize_response: Dictionary = await Steam.steamInitEx( true, app_id )
	print_debug("Did Steam initialize?: %s " % initialize_response)
	
	var app_installed_depots: Array = Steam.getInstalledDepots( app_id )
	var app_languages: String = Steam.getAvailableGameLanguages()
	var app_owner: int = Steam.getAppOwner()
	var build_id: int = Steam.getAppBuildId()
	var game_language: String = Steam.getCurrentGameLanguage()
	var install_dir = Steam.getAppInstallDir( app_id )
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
	
	


func load_steam_achievements():
	pass

func load_steam_stats():
	pass
