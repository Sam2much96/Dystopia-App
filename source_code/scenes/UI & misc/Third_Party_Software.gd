# SImplifies the Ingame Menu UI

extends Control


class_name ThirdPartySoftware

var github = Globals.github
var wallet = Globals.wallet

func _ready():
	pass


func _on_github_pressed():
	get_tree().change_scene_to(Globals.github)


func _on_wallet_pressed():
	get_tree().change_scene_to(Globals.wallet)
