# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Controls Illustation COntroller
# 
# 
#
# *************************************************


extends TextureRect

var mobile_texture = load('res://resources/misc/Controls_illustration_touch_controls_webp.webp')
var pc_texture = load('res://resources/misc/Controls_illustration_pad_&_keyboard_webp.webp')

# Sets different texture depending on the operating system
func _ready():
	for i in Globals.mobiles:
		for p in Globals.pc:
			if Globals.os == p:
				set_texture(pc_texture)
			elif Globals.os == i:
				set_texture(mobile_texture)
#	if OS.get_name()=="Android" or "iOS" :
#		set_texture(mobile_texture)
#	elif OS.get_name() ==  "OSX"or  "Server" or "Windows"or "UWP"or "X11":
#		set_texture(pc_texture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
