# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Marketplace 2D Level
#
# It controls gameplay global settings and stores those values to
# 
# ************************************************* 
# Features:
# (1) Uses google play games services
# (2) Uses google admob
#
# ************************************************* 
# To-Do:
# (1) Graphics Art (1/3)
# (2) Connect Signals
# (3) Should Connect To wallet From Networking.Wallet Class
# (4) Connect Accept SIgnal TO Admob Open Video Ads Signal
# (5) Connect signal to Wallet Send Txn once rewarded videocloses 
# (6) Decision dialog is a global and needs a simpler way to create decision dialogs
# (7) Dialogbox should extend pop up dialog for better quality of life features
# (8) Update Decision Dialogue
# (9) Implement all time sales
# (10) Implement dungeon item collection on death animation
# (11) Implement Items sell UI
# (12) Implement Firebase analytics api
# (13) Implement Admob UI
# (14) Implement Google play games services api
# (15) Update Decision dialog box functionality
# (16) Update dialog box class to pop up class and call visibility animation via functions
# *************************************************

extends Node2D

class_name MarketPlace2D


signal open_video_ads
signal send_txn

# safe pointers to global singeltons
onready var safe_Dialogs = get_node("/root/Dialogs")
onready var safe_Android = get_node("/root/Android")

func _ready():
	
	
	safe_Dialogs.dialog_box.connect("dialog_accept", self, "show_video_ads")
	print_debug("Marketplace signal debug:",safe_Dialogs.dialog_box.is_connected("dialog_accept", self, "show_video_ads"))
	# Debug Signal

func show_video_ads():
	safe_Android.ads("banner")
	


func _exit_tree():
	# disconnect signals
	Dialogs.dialog_box.disconnect("dialog_accept", self, "show_video_ads")
	
	# hide banner add if showing
