# SImplifies the Ingame Menu UI

extends Control


class_name ThirdPartySoftware

# Disabled for refactoring
var github #= Globals.github 
var _wallet #= Globals._wallet

func _ready():
	pass


func _on_github_pressed():
	#Utils.Functions.change_scene_to_packed(Globals.github, get_tree())
	pass

func _on_wallet_pressed():
	#Utils.Functions.change_scene_to_packed(Globals._wallet, get_tree())
	pass
