#tool
# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# Github's Repository Item UI ported to Godot Engine
#
#
# *************************************************

class_name RepositoryItem
extends PanelContainer


signal repo_selected(repo)
signal repo_clicked(repo)

# Pointers to Icons Parents
@onready var Name : HBoxContainer = $Repository/Name
@onready var Stars : HBoxContainer = $Repository/Stars
@onready var Forks : HBoxContainer = $Repository/Forks
@onready var Collaborator : TextureRect = $Repository/Name/Collaborator
@onready var BG : ColorRect = $BG

@export var _name : String
@export var _stars : int
@export var _forks : int
@export var _metadata : Dictionary
@export var _repository : Dictionary
@export var is_collaborator : bool

@onready var _Github = get_tree().get_nodes_in_group("github")[0]
@onready var _UserData = get_tree().get_nodes_in_group("github_user_data")[0]
func _ready():
	# Sets UI textures for forks and stars
	Stars.get_node("Icon").set_texture(Github.IconLoaderGithub.load_icon_from_name("stars"))
	Forks.get_node("Icon").set_texture(Github.IconLoaderGithub.load_icon_from_name("forks"))

func set_repository(repository : Dictionary, current_project : bool = false):
	_repository = repository
	_name = str(repository.name)
	name = _name
	_stars = repository.stargazerCount
	_forks = repository.forkCount
	
	# Check collaboration
	is_collaborator = repository.owner.login != _UserData.USER.login
	
	Name.get_node("Text").set_text(_name)
	Stars.get_node("Amount").set_text("Stars: "+str(_stars))
	Forks.get_node("Amount").set_text("Forks: "+str(_forks))
	
	var repo_icon : ImageTexture
	if repository.isPrivate:
		repo_icon = Github.IconLoaderGithub.load_icon_from_name("lock")
		Name.get_node("Icon").set_tooltip("Private")
	else:
		repo_icon = Github.IconLoaderGithub.load_icon_from_name("repos")
		Name.get_node("Icon").set_tooltip("Public")
		if repository.isFork:
			repo_icon = Github.IconLoaderGithub.load_icon_from_name("forks")
			Name.get_node("Icon").set_tooltip("Forked")
	if is_collaborator:
		Collaborator.texture = Github.IconLoaderGithub.load_icon_from_name("collaboration")
		Collaborator.set_tooltip("Collaboration")
	if repository.isInOrganization:
		Collaborator.texture = Github.IconLoaderGithub.load_icon_from_name("organization")
		Collaborator.set_tooltip("Organization")
	Name.get_node("Icon").set_texture(repo_icon)
	
	if current_project:
		pass

func deselect():
	BG.hide()

func _on_RepositoryItem_gui_input(event):
	# A UI Input Event?
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 1:
			BG.show()
			emit_signal("repo_clicked", self)
		if event.doubleclick:
			emit_signal("repo_selected", self)
