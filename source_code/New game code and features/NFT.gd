extends TextureRect




class_name NFT
# Called when the node enters the scene tree for the first time.
func _ready():
	#makes itself a global variable to avvoid proken node paths
	Globals.NFT = self
	pass # Replace with function body.

" Sets Img Texture"
func load_local_image_texture(_local_image_path):
	"Doesn't load Image with proper aspect ratio"
	#improve this code base
	#print ("NFT debug: ", NFT)
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(_local_image_path)
	texture.create_from_image(image)
	self.show()
	self.set_texture(texture) #cannot load directly from local storage without permissions
		#print (NFT.texture) for debug purposes only
	self.set_expand(true)
