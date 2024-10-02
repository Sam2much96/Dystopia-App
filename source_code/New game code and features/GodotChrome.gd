extends Node


# Tests The Plugin Integration

var singleton

func _enter_tree():
	if Engine.has_singleton("GodotChrome"):
		var singleton = Engine.get_singleton("GodotChrome")

func _ready():
	var p =singleton.myCustomFunction("Test Integration")
	print_debug(p) #works



func open_chrome_embedded():
	var err = singleton.helloWorld("https://www.google.com")
	if err == OK:
		print_debug("Opening URL: ", err)
	else:
		print(err)
