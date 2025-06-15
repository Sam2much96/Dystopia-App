extends Node

# Ads Manager

#onready var _ads_node = get_node_or_null("root/GlobalInput/Node/GameHUD/Admob")

#onready var timer: Timer = get_node_or_null("root/GlobalInput/Node/Timer")


#func _ready():
#	pass
	#Android.ads(_ads_node, get_tree(), true) # hide the banner

#func _on_Timer_timeout():
	# Turn Off Ads
#	if Globals.os == "X11":
#		return
#	if Globals.os == "Android":
#		#Android.ads(_ads_node, get_tree(), false) # hide the banner
#		return
#		#_ads_node.queue_free() # Delete
	


#func _on_AdMob_banner_loaded():
	# Start 220 secs timeout after banner loads
	#timer.start(300)
