extends TextureRect


class_name heart, 'res://resources/misc/Pixel Heart 32x32.png'
onready var local_globals = get_tree().get_root().get_node("/root/Globals")

func _ready():
	
	# Heart box scaling on mobile devices
	# Load Different textures depending on the Screen Orientation
	if local_globals.screenOrientation == 1:
		self.set_texture(load("res://resources/misc/Pixel Heart 64x64.webp"))
	else : pass
