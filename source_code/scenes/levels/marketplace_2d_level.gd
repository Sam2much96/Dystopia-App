# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Marketplace 2D Level
#
# It controls gameplay global settings and stores those values to
# 
# ************************************************* 
# To-Do:
# (1) Graphics Art 
# (2) Connect Signals
# (3) Should Connect To wallet From Networking.Wallet Class
# (4) Connect Accept SIgnal TO Admob Open Video Ads Signal
# (5) Connect signal to Wallet Send Txn once rewarded videocloses 
# (6) Decision dialog is a global and needs a simpler way to create decision dialogs
# (7) Dialogbox should extend pop up dialog for better quality of life features
# *************************************************

extends Node2D

class_name MarketPlace2D


signal open_video_ads
signal send_txn


func _ready():
	
	
	Dialogs.dialog_box.connect("dialog_accept", self, "show_video_ads")
	print_debug("Marketplace signal debug:",Dialogs.dialog_box.is_connected("dialog_accept", self, "show_video_ads"))
	# Debug Signal

func show_video_ads():
	Android.show_rewarded_video_ads()
	


func _exit_tree():
	# disconnect signals
	Dialogs.dialog_box.disconnect("dialog_accept", self, "show_video_ads")
	
