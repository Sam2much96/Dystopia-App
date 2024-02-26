# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019

# -----------------------------------------------
# 
# To Do:
# Should Load Dystopia-App Repository 
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
@onready var RestHandler = $RestHandler #RestHandler.new()

# Instance the User Data Class
@onready var UserData_ = $RestHandler #UserData.new()

# instance to Plugin Settings
@onready var PluginSettings_ = $PluginSettings #PluginSettings.new()

class IconLoaderGithub extends RefCounted:
# Loads Connection Icons 


	static func load_icon_from_name(icon_name : String) -> ImageTexture:
			var file = File.new()
			var image = Image.new()
			var texture = ImageTexture.new()
			
			file.open("res://addons/github-integration/icons.pngs/"+icon_name+".png.iconpng", File.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			image.load_png_from_buffer(buffer)
			texture.create_from_image(image)
			return texture


# Disabling Temporarily for debug
var connection_status : Array = [
	IconLoaderGithub.load_icon_from_name("searchconnection"),
	IconLoaderGithub.load_icon_from_name("noconnection"),
	IconLoaderGithub.load_icon_from_name("connection")
]

var plugin_version : String 
var plugin_name : String

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
	VersionCheck.request("https://api.github.com/repos/fenix-hub/godot-engine.github-integration/tags",[],false,HTTPClient.METHOD_GET,"")
	
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
	set_avatar(UserData.AVATAR)
	set_username(UserData.USER.login)
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
			OS.shell_open("https://github.com/fenix-hub/godot-engine.github-integration/wiki")
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
	UserData.logout_user()

# Set to darkmode each single Control
func set_darkmode(darkmode : bool) -> void:
	PluginSettings.set_darkmode(darkmode)
	SignIn.set_darkmode(darkmode)
	UserPanel.set_darkmode(darkmode)
	Repo.set_darkmode(darkmode)
	Commit.set_darkmode(darkmode)
	Gist.set_darkmode(darkmode)
	Header.set_darkmode(darkmode)
	Notifications.set_darkmode(darkmode)

func set_avatar(avatar : ImageTexture) -> void:
	$Header/datas/avatar.texture = avatar

func set_username(username : String) -> void:
	$Header/datas/user.text = username

# If the plugin version has been checked
func _on_version_check(result, response_code, headers, body ) -> void:
	if result == 0:
		if response_code == 200:
			var test_json_conv = JSON.new()
			test_json_conv.parse(body.get_string_from_utf8()).result
			var tags : Array = test_json_conv.get_data()
			var first_tag : Dictionary = tags[0] as Dictionary
			if first_tag.name != ("v"+plugin_version):
				print_debug_message("a new plugin version has been found, current version is %s and new version is %s" % [("v"+plugin_version), first_tag.name],1)



class RestHandler_ extends Node:
	# The HTP Rest Handler As A Class
	# Rewrite to use static fuctions 
	signal _check_connection(connection)
	signal request_failed(request_code, error_body)
	signal notification_request_failed(request_code, error_body)
	signal user_requested(user)
	signal user_avatar_requested(avatar)
	signal contributor_avatar_requested(avatar)
	signal user_repositories_requested(repositories)
	signal user_repository_requested(repository)
	signal user_gists_requested(gists)
	signal gist_created(gist)
	signal gist_updated(gist)
	signal branch_contents_requested(branch_contents)
	signal gitignore_requested(gitignore)
	signal file_content_requested(file_content)
	signal pull_branch_requested()
	signal collaborator_requested()
	signal resource_delete_requested()
	signal repository_delete_requested()
	signal new_branch_requested()
	signal invitations_list_requested(list)
	signal invitation_accepted()
	signal invitation_declined()

	var requesting : int = -1
	var notifications_requesting : int = -1

	var repositories_limit : int = 100
	var gists_limit : int = 100
	var owner_affiliations : String

	var checking_connection : bool = false
	var downloading_file : bool = false

	onready var client : HTTPRequest = $Client
	onready var notifications_client : HTTPRequest = $NotificationsClient
	var loading : Control
	var session : HTTPClient = HTTPClient.new()
	var graphql_endpoint : String = "https://api.github.com/graphql"
	var graphql_queries : Dictionary = {
		'repositories':'{user(login: "%s"){repositories(ownerAffiliations:%s, first:%d, orderBy: {field: NAME, direction: ASC}){ nodes { diskUsage name owner { login } description url isFork isPrivate forkCount stargazerCount isInOrganization collaborators(affiliation: DIRECT, first: 100) { nodes {login name avatarUrl} } mentionableUsers(first: 100){ nodes{ login name avatarUrl } } defaultBranchRef { name } refs(refPrefix: "refs/heads/", first: 100){ nodes{ name target { ... on Commit { oid tree { oid } zipballUrl tarballUrl } } } } } } %s } }',
		'repository':'{%s(login: "%s"){repository(name:"%s"){diskUsage name owner { login } description url isFork isPrivate forkCount stargazerCount isInOrganization collaborators(affiliation: DIRECT, first: 100) { nodes {login name avatarUrl} } mentionableUsers(first: 100){ nodes{ login name avatarUrl } } defaultBranchRef { name } refs(refPrefix: "refs/heads/", first: 100){ nodes{ name target { ... on Commit { oid tree { oid } zipballUrl tarballUrl }}}}}}}',
		'gists':'{ user(login: "%s") { gists(first: %s, orderBy: {field: PUSHED_AT, direction: DESC}, privacy: ALL) { nodes { owner { login } id description resourcePath name stargazerCount isPublic isFork files { encodedName encoding extension name size text } } } } }',
		'organizations_repositories':'organizations(first:10){nodes{repositories(first:100){nodes{diskUsage name owner { login } description url isFork isPrivate forkCount stargazerCount isInOrganization collaborators(affiliation: DIRECT, first: 100) { nodes {login name avatarUrl} } mentionableUsers(first: 100){ nodes{ login name avatarUrl } } defaultBranchRef { name } refs(refPrefix: "refs/heads/", first: 100){ nodes{ name target { ... on Commit { oid tree { oid } zipballUrl tarballUrl } } } } }}}}'
	}
	var header : PackedStringArray = ["Authorization: token "]
	var api_endpoints : Dictionary = {
		"github":"https://github.com/",
		"user":"https://api.github.com/user",
		"gist":"https://api.github.com/gists",
		"repos":"https://api.github.com/repos",
		"invitations":"https://api.github.com/user/repository_invitations"
	}
	enum REQUESTS {
		USER,
		USER_AVATAR,
		CONTRIBUTOR_AVATAR,
		USER_REPOSITORIES,
		USER_REPOSITORY,
		USER_GISTS,
		CREATE_GIST,
		UPDATE_GIST,
		BRANCH_CONTENTS,
		FILE_CONTENT,
		GITIGNORE,
		PULL_BRANCH,
		INVITE_COLLABORATOR,
		DELETE_RESOURCE,
		DELETE_REPOSITORY,
		NEW_BRANCH,
		INVITATIONS_LIST,
		ACCEPT_INVITATION,
		DECLINE_INVITATION
	}

	# Called when the node enters the scene tree for the first time.
	func _ready():
		client.connect("request_completed", Callable(self, "_on_request_completed"))
		notifications_client.connect("request_completed", Callable(self, "_on_notification_request_completed"))
		
		



	func load_default_variables():
		pass

	func check_connection() -> void:
		checking_connection = true
		var connection : int = session.connect_to_host("www.githubstatus.com")
		assert(connection == OK) # Make sure connection was OK.
		set_process(true)
		if PluginSettings.debug:
			print("[GitHub Integration] Connecting to API, please wait...")

	func _process(delta):
		process_check_connection()
		process_download_file()

	func process_check_connection():
		if not checking_connection:
			return
		if session.get_status() == HTTPClient.STATUS_CONNECTING or session.get_status() == HTTPClient.STATUS_RESOLVING:
			session.poll()
		else:
			if session.get_status() == HTTPClient.STATUS_CONNECTED:
				if PluginSettings.debug:
					print("[GitHub Integration] Connection to API successful")
				emit_signal("_check_connection",true)
			else:
				if PluginSettings.debug:
					printerr("[GitHub Integration] Connection to API unsuccessful, exited with error %s, staus: %s" % 
				[session.get_response_code(), session.get_status()])
				emit_signal("_check_connection",false)
			checking_connection = false
			set_process(false)

	func process_download_file():
		if downloading_file:
			loading.show_number(client.get_downloaded_bytes()*0.001, disk_usage, "KB")

	# Print the GraphQL query from a String to a JSON/String for GraphQL endpoint
	func print_query(query : String) -> String:
		return JSON.stringify( { "query":query } )

	# Parse the result body to a Dictionary with the requested parameter as the root
	func parse_body_data(body : PackedByteArray) -> Dictionary:
		var test_json_conv = JSON.new()
		test_json_conv.parse(body.get_string_from_utf8()).result.data
		return test_json_conv.get_data()

	func parse_body(body : PackedByteArray) -> Dictionary:
		var test_json_conv = JSON.new()
		test_json_conv.parse(body.get_string_from_utf8()).result
		return test_json_conv.get_data()

	func _on_notification_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
		if result == 0:
			match response_code:
				200:
					match notifications_requesting:
						REQUESTS.INVITATIONS_LIST: emit_signal("invitations_list_requested", parse_body(body))
				204:
					match notifications_requesting:
						REQUESTS.ACCEPT_INVITATION: emit_signal("invitation_accepted")
						REQUESTS.DECLINE_INVITATION: emit_signal("invitation_declined")
				304:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))
				400:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))
				401:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))
				403:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))
				404:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))
				422:
					emit_signal("notification_request_failed", notifications_requesting, parse_body(body))

	func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	#	print(JSON.parse(body.get_string_from_utf8()).result)
		if result == 0:
			match response_code:
				200:
					match requesting:
						REQUESTS.USER: emit_signal("user_requested", parse_body(body))
						REQUESTS.USER_AVATAR:
							emit_signal("user_avatar_requested", body)
	#						set_process(false)
	#						client.set_download_file("")
						REQUESTS.CONTRIBUTOR_AVATAR: 
							emit_signal("contributor_avatar_requested", body)
							temp_contributor.contributor_avatar_requested(body)
						REQUESTS.USER_REPOSITORIES: emit_signal("user_repositories_requested", parse_body_data(body))
						REQUESTS.USER_REPOSITORY: emit_signal("user_repository_requested", parse_body_data(body))
						REQUESTS.USER_GISTS: emit_signal("user_gists_requested", parse_body_data(body))
						REQUESTS.UPDATE_GIST: emit_signal("gist_updated", parse_body(body))
						REQUESTS.BRANCH_CONTENTS: emit_signal("branch_contents_requested", parse_body(body))
						REQUESTS.GITIGNORE: emit_signal("gitignore_requested", parse_body(body))
						REQUESTS.FILE_CONTENT: emit_signal("file_content_requested", parse_body(body))
						REQUESTS.PULL_BRANCH:
							set_process(false)
							client.set_download_file("")
							emit_signal("pull_branch_requested")
						REQUESTS.DELETE_RESOURCE: emit_signal("resource_delete_requested")
				201:
					match requesting:
						REQUESTS.CREATE_GIST: emit_signal("gist_created", parse_body(body))
						REQUESTS.INVITE_COLLABORATOR: emit_signal("collaborator_requested")
						REQUESTS.NEW_BRANCH: emit_signal("new_branch_requested")
				204:
					match requesting:
						REQUESTS.DELETE_REPOSITORY: emit_signal("repository_delete_requested")
						_: emit_signal("request_failed", requesting, parse_body(body))
				400:
					emit_signal("request_failed", requesting, parse_body(body))
				401:
					emit_signal("request_failed", requesting, parse_body(body))
				403:
					emit_signal("request_failed", requesting, parse_body(body))
				422:
					emit_signal("request_failed", requesting, parse_body(body))
		downloading_file = false
		loading.hide_number()

	# ------------------------- REQUESTS -----------------------
	func request_user(token : String) -> void:
		requesting = REQUESTS.USER
		var temp_header = [header[0] + token]
		client.request(api_endpoints.user, temp_header, false, HTTPClient.METHOD_GET)

	func request_user_avatar(avatar_url : String) -> void:
	#	client.set_download_file(UserData.directory+UserData.avatar_name)
		requesting = REQUESTS.USER_AVATAR
	#	downloading_file = true
		client.request(avatar_url)
	#	set_process(true)

	var temp_contributor : ContributorClass

	func request_contributor_avatar(avatar_url : String, contributor_class : ContributorClass) -> void:
		requesting = REQUESTS.CONTRIBUTOR_AVATAR
		temp_contributor = contributor_class
		client.request(avatar_url)

	func request_user_repositories() -> void:
		requesting = REQUESTS.USER_REPOSITORIES
		var owner_affiliations : Array = PluginSettings.owner_affiliations.duplicate(true)
		var is_org_member : bool = false
		if owner_affiliations.has("ORGANIZATION_MEMBER"): 
			owner_affiliations.erase("ORGANIZATION_MEMBER")
			is_org_member = true
		var query : String = graphql_queries.repositories % [UserData.USER.login, owner_affiliations, repositories_limit, graphql_queries.organizations_repositories if is_org_member else ""]
		client.request(graphql_endpoint, UserData.header, true, HTTPClient.METHOD_POST, print_query(query))

	func request_user_repository(repository_affiliation : String, repository_owner : String, repository_name : String) -> void:
		requesting = REQUESTS.USER_REPOSITORY
		var query : String = graphql_queries.repository % [repository_affiliation, repository_owner, repository_name]
		client.request(graphql_endpoint, UserData.header, true, HTTPClient.METHOD_POST, print_query(query))

	func request_user_gists() -> void:
		requesting = REQUESTS.USER_GISTS
		var query : String = graphql_queries.gists % [UserData.USER.login, gists_limit]
		client.request(graphql_endpoint, UserData.header, true, HTTPClient.METHOD_POST, print_query(query))

	func request_commit_gist(body : String) -> void:
		requesting = REQUESTS.CREATE_GIST
		client.request(api_endpoints.gist, UserData.header, true, HTTPClient.METHOD_POST, body)

	func request_update_gist(gistid : String, body : String) -> void:
		requesting = REQUESTS.UPDATE_GIST
		client.request(api_endpoints.gist+"/"+gistid,UserData.header,true,HTTPClient.METHOD_PATCH,body)

	func request_branch_contents(repository_name : String, repository_owner : String, branch : Dictionary) ->  void:
		requesting = REQUESTS.BRANCH_CONTENTS
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/git/trees/"+branch.target.tree.oid+"?recursive=1",UserData.header,true,HTTPClient.METHOD_GET)

	func request_file_content(repository_owner : String, repository_name : String, file_path : String, branch_name : String) -> void:
		requesting = REQUESTS.FILE_CONTENT
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/contents/"+file_path+"?ref="+branch_name,UserData.header,false,HTTPClient.METHOD_GET)

	func request_gitignore(repository_owner : String, repository_name : String, branch_name : String) -> void:
		requesting = REQUESTS.GITIGNORE
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/contents/.gitignore?ref="+branch_name,UserData.header,false,HTTPClient.METHOD_GET)

	var disk_usage : float
	func request_pull_branch(ball_path : String, typeball_url: String, repo_disk_usage : float) -> void:
		client.set_download_file(ball_path)
		requesting = REQUESTS.PULL_BRANCH
		downloading_file = true
		disk_usage = repo_disk_usage
		client.request(typeball_url, UserData.header, true, HTTPClient.METHOD_GET)
		set_process(true)
		print (typeball_url, "------", repo_disk_usage) # for debug purposes only

	func request_collaborator(repository_owner : String, repository_name : String, collaborator_name : String, body : Dictionary) -> void:
		requesting = REQUESTS.INVITE_COLLABORATOR
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/collaborators/"+collaborator_name, UserData.header, true, HTTPClient.METHOD_PUT, JSON.stringify(body))

	func request_delete_resource(repository_owner : String, repository_name : String, path : String, body : Dictionary) -> void:
		requesting = REQUESTS.DELETE_RESOURCE
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/contents/"+path, UserData.header, true, HTTPClient.METHOD_DELETE,JSON.stringify(body))

	func request_delete_repository(repository_owner : String, repository_name : String) -> void:
		requesting = REQUESTS.DELETE_REPOSITORY
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name, UserData.header, true, HTTPClient.METHOD_DELETE)

	func request_create_new_branch(repository_owner : String, repository_name : String, body : Dictionary) -> void:
		requesting = REQUESTS.NEW_BRANCH
		client.request(api_endpoints.repos+"/"+repository_owner+"/"+repository_name+"/git/refs",UserData.header, true, HTTPClient.METHOD_POST, JSON.stringify(body))

	func request_invitations_list():
		notifications_requesting = REQUESTS.INVITATIONS_LIST
		notifications_client.request(api_endpoints.invitations, UserData.header)

	func request_accept_invitation(invitation_id : int):
		notifications_requesting = REQUESTS.ACCEPT_INVITATION
		notifications_client.request(api_endpoints.invitations+"/"+str(invitation_id), UserData.header, true, HTTPClient.METHOD_PATCH)

	func request_decline_invitation(invitation_id : int):
		notifications_requesting = REQUESTS.DECLINE_INVITATION
		notifications_client.request(api_endpoints.invitations+"/"+str(invitation_id), UserData.header, true, HTTPClient.METHOD_DELETE)


class PluginSettings extends Node:

	const directory_name = "github_integration"
	var plugin_path = ProjectSettings.globalize_path("user://").replace("app_userdata/"+ProjectSettings.get_setting('application/config/name')+"/",directory_name)+"/"

	var setting_file : String = "settings.cfg"

	var debug : bool = true
	var auto_log : bool = false
	var darkmode : bool = false
	var auto_update_notifications : bool = true
	var auto_update_timer : float = 300
	var owner_affiliations : Array = ["OWNER","COLLABORATOR","ORGANIZATION_MEMBER"]

	var _loaded : bool = false

	func _check_plugin_path():
		var dir = DirAccess.new()
		if not dir.dir_exists(plugin_path):
			dir.make_dir(plugin_path)
			if debug:
				printerr("[GitHub Integration] >> ","made custom directory in user folder, it is placed at ", plugin_path)

	func _ready():
		_check_plugin_path()
		var config_file : ConfigFile = ConfigFile.new()
		var err = config_file.load(plugin_path+setting_file)
		if err == 0:
			debug = config_file.get_value("settings","debug", debug)
			auto_log = config_file.get_value("settings","auto_log", auto_log)
			darkmode = config_file.get_value("settings","darkmode", darkmode)
			auto_update_notifications = config_file.get_value("settings","auto_update_notifications", auto_update_notifications)
			auto_update_timer = config_file.get_value("settings","auto_update_timer",auto_update_timer)
			owner_affiliations = config_file.get_value("settings", "owner_affiliations", owner_affiliations)
		else:
			config_file.save(plugin_path+setting_file)
			config_file.set_value("settings","debug",debug)
			config_file.set_value("settings","auto_log",auto_log)
			config_file.set_value("settings","darkmode",darkmode)
			config_file.set_value("settings","auto_update_notifications", auto_update_notifications)
			config_file.set_value("settings","auto_update_timer",auto_update_timer)
			config_file.set_value("settings","owner_affiliations",owner_affiliations)
			config_file.save(plugin_path+setting_file)
		_loaded = true

	func set_debug(d : bool):
		debug = d
		save_setting("debug", debug)

	func set_auto_log(a : bool):
		auto_log = a
		save_setting("auto_log", auto_log)

	func set_darkmode(d : bool):
		darkmode = d
		save_setting("darkmode", darkmode)

	func set_auto_update_notifications(enabled : bool):
		auto_update_notifications = enabled
		save_setting("auto_update_notifications", enabled)

	func set_auto_update_timer(timer : float):
		auto_update_timer = timer
		save_setting("auto_update_timer", timer)

	func set_owner_affiliations(affiliations : Array):
		owner_affiliations = affiliations
		save_setting("owner_affiliations", owner_affiliations)

	func save_setting(key : String, value):
		_check_plugin_path()
		var file : ConfigFile = ConfigFile.new()
		var err = file.load(plugin_path+setting_file)
		if err == OK:
			file.set_value("settings",key,value)
		file.save(plugin_path+setting_file)

	func get_setting(key : String, default_value = ""):
		_check_plugin_path()
		var file : ConfigFile = ConfigFile.new()
		var err = file.load(plugin_path+setting_file)
		if err == OK:
			if file.has_section_key("settings","key"):
				return file.get_value("settings","key")
			else:
				print("setting '%s' not found, now created" % key)
				file.set_value("settings", key, default_value)

	func reset_plugin():
		delete_all_files(plugin_path)
		print("[Github Integration] github_integration folder completely removed.")

	func delete_all_files(path : String):
		var directories = []
		var dir : DirAccess = DirAccess.new()
		dir.open(path)
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file = dir.get_next()
		while (file != ""):
			if dir.current_is_dir():
				var directorypath = dir.get_current_dir()+"/"+file
				directories.append(directorypath)
			else:
				var filepath = dir.get_current_dir()+"/"+file
				dir.remove(filepath)
			
			file = dir.get_next()
		
		dir.list_dir_end()
		
		for directory in directories:
			delete_all_files(directory)
		dir.remove(path)

class UserData extends Node:
	# ----------------------------------------------
	#            ~{ GitHub Integration }~
	# [Author] Nicolò "fenix" Santilio 
	# [github] fenix-hub/godot-engine.github-integration
	# [version] 0.2.9
	# [date] 09.13.2019





	# -----------------------------------------------

	# saves and loads user datas from custom folder in user://github_integration/user_data.ud

	var directory : String = ""
	var file_name : String = "user_data.ud"
	var avatar_name : String = "avatar"

	var USER : Dictionary = {}

	# --- on the USER usage
	# login = username
	# avatar
	# id

	var AVATAR : ImageTexture
	var AUTH : String
	var TOKEN : String
	var MAIL : String

	var header : Array = [""]
	var gitlfs_header : Array = [""]
	var gitlfs_request : String = ".git/info/lfs/objects/batch"

	var plugin_version : String = "0.9.4"
	
	onready var PluginSettings_ = get_parent().get_node("PluginSettings")
	func _ready():
		var plugin_path = ProjectSettings.globalize_path("user://").replace("app_userdata/"+ProjectSettings.get_setting('application/config/name')+"/",PluginSettings.directory_name)+"/"

		directory = plugin_path#PluginSettings.plugin_path

	func user_exists():
		var file : File = File.new()
		return (true if file.file_exists(directory+file_name) else false)

	func save(user : Dictionary, avatar : PackedByteArray, auth : String, token : String, mail : String) -> void:
		var file = File.new()
		
		if user!=null:
				var err = file.open_encrypted_with_pass(directory+file_name,File.WRITE,OS.get_unique_id())
				USER = user
				AUTH = auth
				TOKEN = token
				MAIL = mail
				var formatting : PackedStringArray
				formatting.append(auth)                     #0
				formatting.append(mail)                     #1
				formatting.append(token)                    #2
				formatting.append(JSON.stringify(user))         #3
				formatting.append(plugin_version)           #4
				file.store_csv_line(formatting)
				file.close()
				if PluginSettings_.debug:
						print("[GitHub Integration] >> ","saved user datas in user folder")
		
		
		save_avatar(avatar)
		
		header = ["Authorization: Token "+token]

	func save_avatar(avatar : PackedByteArray):
		var file : File = File.new()
		if avatar == null:
			return
		var image : Image = Image.new()
		var extension : String = avatar.subarray(0,1).hex_encode()
		match extension:
			"ffd8":
				image.load_jpg_from_buffer(avatar)
				file.open(directory+avatar_name+".jpg", File.WRITE)
				file.store_buffer(avatar)
			"8950":
				image.load_png_from_buffer(avatar)
				image.save_png(directory+avatar_name+".png")
	#			file.open(directory+avatar_name+".png", File.WRITE)
		file.close()
		load_avatar()

	func load_avatar():
		var file : File = File.new()
		var av : Image = Image.new()
		var img_text : ImageTexture = ImageTexture.new()
		if file.file_exists(directory+avatar_name+".png"):
			av.load(directory+avatar_name+".png")
			img_text.create_from_image(av)
			AVATAR = img_text
		elif file.file_exists(directory+avatar_name+".jpg"):    
			av.load(directory+avatar_name+".jpg")
			img_text.create_from_image(av)
			AVATAR = img_text
		else:
			AVATAR = null

	func load_user() -> PackedStringArray :
		var file = File.new()
		var content : PackedStringArray
		
		if PluginSettings.debug:
			print("[GitHub Integration] >> loading user profile, checking for existing logfile...")
		
		if file.file_exists(directory+file_name) :
			if PluginSettings.debug:
				print("[GitHub Integration] >> ","logfile found, fetching datas..")
			file.open_encrypted_with_pass(directory+file_name,File.READ,OS.get_unique_id())
			content = file.get_csv_line()
			if content.size() < 5:
				if PluginSettings.debug:
					printerr("[GitHub Integration] >> ","this log file belongs to an older version of this plugin and will not support the mail/password login deprecation, so it will be deleted. Please, insert your credentials again.")
				file.close()
				var dir = DirAccess.new()
				dir.remove(directory+file_name)
				content = []
				return content
				
			AUTH = content[0]
			MAIL = content[1]
			TOKEN = content[2]
			var test_json_conv = JSON.new()
			test_json_conv.parse(content[3]).result
			USER = test_json_conv.get_data()
			load_avatar()
			
			header = ["Authorization: Token "+TOKEN]
			gitlfs_header = [
				"Accept: application/vnd.github.v3+json",
				"Accept: application/vnd.git-lfs+json",
				"Content-Type: application/vnd.git-lfs+json"]
			gitlfs_header.append(header[0])
		else:
			if PluginSettings.debug:
				printerr("[GitHub Integration] >> ","no logfile found, log in for the first time to create a logfile.")
		
		return content

	func logout_user():
		AUTH = "null"
		MAIL = "null"
		TOKEN = "null"
		USER = {}
		AVATAR = null
		header = []

	func delete_user():
		var dir : DirAccess = DirAccess.new()
		dir.open(directory)
		dir.remove(directory+file_name)
		dir.remove(directory+avatar_name)
