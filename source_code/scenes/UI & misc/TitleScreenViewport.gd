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

onready var model : Spatial = $Spatial
const SPEED = 10


func _ready():
	
	# Stream 3d scene renders to the Parent Texture React
	get_parent().set_texture(viewport_image)




func _process(delta):
	# optimize for fps
	
	# auto rotate
	model.rotation_degrees.y += delta * SPEED


func _exit_tree():
	model.queue_free()
	self.queue_free()
	self.queue_free()
