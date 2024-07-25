# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019

# -----------------------------------------------
# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# GitHUB Grapql API Ported to GDScript + Github UI made in Godot
#
# *************************************************
#
# 
# To Do:
# Should Load Dystopia-App Repository (Done)
# 

#tool
extends Control

class_name Github

@onready var VersionCheck : HTTPRequest = $VersionCheck

@onready var SignIn : Control = $SingIn
@onready var UserPanel : Control = $UserPanel
@onready var CommitRepo : Control = $Commit
@onready var Repo : Control = $Repo
@onready var Gist : Control = $Gist
@onready var Commit : Control = $Commit
@onready var LoadNode : Control = $loading
@onready var Version : Control = $Header/datas/version
@onready var ConnectionIcon : TextureRect = $Header/datas/connection
@onready var Header : Control = $Header
@onready var RestartConnection = Header.get_node("datas/restart_connection")
@onready var Menu : PopupMenu = $Header/datas/Menu.get_popup()
@onready var Notifications : Control = $Notifications

var user_avatar : ImageTexture = ImageTexture.new()
var user_img = Image.new()

# Github ICONS

# Load Required Scripts as Reference Classes
# Instance the Rest Handler Class
@onready var RestHandler : RestHandler = $RestHandler #RestHandler.new()

# Instance the User Data Class
@onready var UserData_ : User_Data = $UserData #UserData.new()

# instance to Plugin Settings
@onready var PluginSettings_ = $PluginSettings #PluginSettings.new()


@onready var avatar : TextureRect= $Header/datas/avatar
@onready var user : Label = $Header/datas/user
class IconLoaderGithub extends RefCounted:
# Loads Connection Icons 


	static func load_icon_from_name(icon_name : String) -> ImageTexture:
			var file : FileAccess= Utils.file #File.new()
			var image = Image.new()
			var texture = ImageTexture.new()
			
			#file.open("res://addons/github-integration/icons.pngs/"+icon_name+".png.iconpng", File.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			image.load_png_from_buffer(buffer)
			texture.create_from_image(image)
			return texture


var connection_status : Array = [
	IconLoaderGithub.load_icon_from_name("searchconnection"),
	IconLoaderGithub.load_icon_from_name("noconnection"),
	IconLoaderGithub.load_icon_from_name("connection")
]

@export var plugin_version : String 
@export var plugin_name : String

# Load the configuration file for this plugin to fetch some info
func load_config() -> void:
	var config =  ConfigFile.new()
	var err = config.load("res://addons/github-integration/plugin.cfg")
	if err == OK:
		plugin_version = config.get_value("plugin","version")
		plugin_name = "[%s] >> " % config.get_value("plugin","name")

func connect_signals() -> void:
	Menu.connect("index_pressed", Callable(self, "menu_item_pressed"))
	RestartConnection.connect("pressed", Callable(self, "check_connection"))
	VersionCheck.connect("request_completed", Callable(self, "_on_version_check"))
	SignIn.connect("signed", Callable(self, "signed"))
	UserPanel.connect("completed_loading", Callable(SignIn, "_on_completed_loading"))
	UserPanel.connect("loaded_gists", Callable(Gist, "_on_loaded_repositories"))
	Header.connect("load_invitations", Callable(Notifications, "_on_load_invitations_list"))
	Header.notifications_btn.connect("pressed", Callable(Notifications, "_open_notifications"))
	Notifications.connect("add_notifications", Callable(Header, "_on_add_notifications"))

func hide_nodes() -> void:
	Repo.hide()
	SignIn.show()
	UserPanel.hide()
	Commit.hide()
	LoadNode.hide()

func _ready():
	
	#self.add_child(RestHandler_)

	# Instance the User Data Class
	#self.add_child(UserData_)

# instance to Plugin Settings
	#self.add_child(PluginSettings_)
	
	connect_signals()
	hide_nodes()
	# Load Config file
	load_config()
	Version.text = "v "+plugin_version
	
	# Sets Run Time Icon for Github
	ConnectionIcon.set_texture(connection_status[0])
	ConnectionIcon.use_parent_material = false
	ConnectionIcon.material.set("shader_param/speed", 3)
	
	# Check the connection with the API
	RestHandler.check_connection()
	# Yield until the "_check_connection" function returns a value
	#var connection = yield(RestHandler, "_check_connection")
	var connection = RestHandler.connection
	match connection:
		true:
			ConnectionIcon.set_texture(connection_status[2])
			ConnectionIcon.set_tooltip("Connected to GitHub API")
			RestartConnection.hide()
		false:
			ConnectionIcon.set_texture(connection_status[1])
			ConnectionIcon.set_tooltip("Can't connect to GitHub API, check your internet connection or API status")
			RestartConnection.show()
	ConnectionIcon.use_parent_material = true
	ConnectionIcon.material.set("shader_param/speed", 0)
	
	Menu.set_item_checked(0, PluginSettings_.debug)
	Menu.set_item_checked(1, PluginSettings_.auto_log)
	
	# Check the plugin verison
	print_debug("Running Version Check")
	#VersionCheck.request("https://api.github.com/repos/Sam2much96/Dystopia-App/tags",[],false,HTTPClient.METHOD_GET,"")
	
	if PluginSettings_.auto_log:
		SignIn.sign_in()
	
	set_darkmode(PluginSettings_.darkmode)

# Show or hide the loading screen
func loading(value : bool) -> void:
	LoadNode.visible = value

# Show the loading process, giving the current value and a maximum value
func show_loading_progress(value : float,  max_value : float) -> void:
	LoadNode.show_progress(value,max_value)

func hide_loading_progress():
	LoadNode.hide_progress()

func show_number(value : float, type : String) -> void:
	LoadNode.show_number(value,type)

func hide_number() -> void:
	LoadNode.hide_number()

# If User Signed
func signed() -> void:
	UserPanel.load_panel()
	set_avatar(UserData_.AVATAR)
	set_username(UserData_.USER.login)
	await UserPanel.completed_loading
	Notifications.request_notifications()

# Print a debug message if the debug setting is set to "true", with a debug type from 0 to 2
func print_debug_message(message : String = "", type : int = 0) -> void:
	if PluginSettings_.debug == true:
			match type:
				0:
						print(plugin_name,message)
				1:
						printerr(plugin_name,message)
				2:
						push_warning(plugin_name+message)
	if type != 1: set_loading_message(message)

func set_loading_message(message : String):
	LoadNode.message.set_text(message)

# Control logic for each item in the plugin menu
func menu_item_pressed(id : int) -> void:
	match id:
#		0:
#			_on_debug_toggled(!Menu.is_item_checked(id))
#		1:
#			_on_autologin_toggled(!Menu.is_item_checked(id))
		0:
			OS.shell_open("https://github.com/Sam2much96/Dystopia-App/wiki")
		1:
			logout()
		2:
			set_darkmode(!Menu.is_item_checked(id))

# Logout function
func logout():
	set_avatar(IconLoaderGithub.load_icon_from_name("circle"))
	set_username("user")
	SignIn.show()
	UserPanel._clear()
	UserPanel.hide()
	Repo.hide()
	Commit.hide()
	Gist.hide()
	Notifications._clear()
	Notifications.hide()
	SignIn.Mail.text = ""
	SignIn.Token.text = ""
	UserData_.logout_user()

# Set to darkmode each single Control
func set_darkmode(darkmode : bool) -> void:
	PluginSettings_.set_darkmode(darkmode)
	SignIn.set_darkmode(darkmode)
	UserPanel.set_darkmode(darkmode)
	Repo.set_darkmode(darkmode)
	Commit.set_darkmode(darkmode)
	Gist.set_darkmode(darkmode)
	Header.set_darkmode(darkmode)
	Notifications.set_darkmode(darkmode)

func set_avatar(github_avatar : ImageTexture) -> void:
	
	avatar.texture = github_avatar

func set_username(username : String) -> void:
	user.text = username

# If the plugin version has been checked
func _on_version_check(result, response_code, headers, body ) -> void:
	if result == 0:
		if response_code == 200:
			var test_json_conv = JSON.new()
			#test_json_conv.parse(body.get_string_from_utf8()).result
			var tags : Array = test_json_conv.get_data()
			var first_tag : Dictionary = tags[0] as Dictionary
			if first_tag.name != ("v"+plugin_version):
				print_debug_message("a new Dystopia App version has been found, current version is %s and new version is %s" % [("v"+plugin_version), first_tag.name],1)
				#Dialogs.show_dialog(str("a new Dystopia App version has been found, current version is %s and new version is %s" % [("v"+plugin_version), first_tag.name],1), "Admin")



