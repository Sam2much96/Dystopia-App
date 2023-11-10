# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Controls Illustation COntroller
# 
# triggers different illustations for all supported platforms
# Bugs:
# (1) Controls_illustratins.gd has texture positional bug on titlescreen
#
# *************************************************


extends TextureRect


class_name ControlIllustrations


#export(String, FILE, "*.webp") var mobile_texture 
#export(String, FILE, "*.webp") var pc_texture
export(Texture) var mobile_texture
export(Texture) var pc_texture
export(Texture) var backup_texture

#var mobile_texture 
#var pc_texture = load('res://resources/misc/Controls_illustration_pad_&_keyboard_webp.webp')

#var mobile_texture = load('res://resources/misc/Controls_illustration_touch_controls_webp.webp')
#var pc_texture = load('res://resources/misc/Controls_illustration_pad_&_keyboard_webp.webp')

# Sets different texture depending on the operating system
func _ready():
	
	
	
	#if Globals.os=="Android" or "iOS" :
	#	set_texture(mobile_texture)
	if Globals.screenOrientation == 1:
		set_texture(mobile_texture)
	if Globals.screenOrientation == 0:
		
		set_texture(pc_texture)
	#elif Globals.os ==  "OSX"or  "Server" or "Windows"or "UWP"or "X11":
	#	set_texture(pc_texture)
