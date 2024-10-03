extends Node

# Ads Manager

onready var _ads_node = get_node_or_null("root/GlobalInput/Node/Admob")

onready var timer = get_node_or_null("root/GlobalInput/Node/Timer")




func _on_Timer_timeout():
	if Globals.os == "Android":
		Android.ads(_ads_node, get_tree(), false) # hide the banner
