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


# Sets different texture depending on the operating system
func _ready():
	
	# Disabled for refactoring
	if Globals.screenOrientation == 1:
		#set_texture(mobile_texture)
		pass
	if Globals.screenOrientation == 0:
		
		#set_texture(pc_texture)
		pass
	#elif Globals.os ==  "OSX"or  "Server" or "Windows"or "UWP"or "X11":
	#	set_texture(pc_texture)
