# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#  Title Screen ViewPort
#   Show a 3d render of the 3d overworld scene in the game menu
#
# TO DO:
# (1) Load Scene During Into Loading to remove Auidio Lag
# *************************************************

extends Viewport


export (ViewportTexture )var viewport_image : ViewportTexture = get_texture()
#onready var image : image

func _ready():
	#get_parent().get_node("Sprite").set_texture(viewport_image)
	get_parent().set_texture(viewport_image)
