#tool
# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Github's Gist Item UI panel ported to godot 
#
#  
#
#
# *************************************************

class_name GistItem
extends PanelContainer

signal gist_selected(gist)
signal gist_clicked(this_gist)

var gist_icon : ImageTexture 
onready var Name : HBoxContainer = $Gist/Name
onready var Files : HBoxContainer = $Gist/Files
onready var BG : ColorRect = $BG

var _name : String
var _files_amount : int
var _files : Array
var _metadata : Dictionary
var _gist : Dictionary
var _id : String

func _ready():
	Files.get_node("Icon").set_texture(Github.IconLoaderGithub.load_icon_from_name("gists"))

func set_gist(gist : Dictionary):
	_gist = gist
	_id = gist.resourcePath
	_name = gist.files[0].name
	_files = gist.files
	_files_amount = _files.size()
	Name.get_node("Text").set_text(_name)
	Files.get_node("Amount").set_text("Files: "+str(_files_amount))
	
	
	if gist.isPublic:
		gist_icon = (Github.IconLoaderGithub.load_icon_from_name("gists"))
	else:
		gist_icon = (Github.IconLoaderGithub.load_icon_from_name("lock"))
	if gist.isFork:
		pass
	Name.get_node("Icon").set_texture(gist_icon)

func deselect():
	BG.hide()

func _on_GistItem_gui_input(event):
	# GUI Input Event
	if event is InputEventMouseButton:
		
		if event.is_pressed() and event.button_index == 1:
			BG.show()
			emit_signal("gist_clicked", self)
		if event.doubleclick:
			emit_signal("gist_selected", self)
