extends Node
# Procedurally generated tilemap creator

#How to Use
# Attach this NOde As a child top the Tilemap with AutoTIle


# Specifies the Draw Map Area so the Tilemap drawn isnt infinite
export(int) var map_width = 80
export(int) var map_height = 50

export(String) var world_seed = "Hello World!"
export(int) var noise_octaves = 3
export(int) var noise_period = 3
export(float) var noise_persistence = 0.7
export(float) var noise_lacunarity = 0.4
export(float) var noise_threshold = 0.5

# set get method to update Map generated on the fly
export(bool) var redraw setget redraw

# Acces the Parent TileMap with the AutoTile
var tile_map : TileMap
var simplex_noise : OpenSimplexNoise = OpenSimplexNoise.new()

func _ready() -> void:
	
	# Gets the Parent Tilemap Node
	self.tile_map = get_parent() as TileMap
	
	clear()
	generate()


func redraw(value = null) -> void:
	if self.tile_map == null:
		return
	
	clear()
	generate()

func clear() -> void:
	# Completely clearts the current tilemap
	self.tile_map.clear()


func generate() -> void:
	
	# generate a seed using a string and the hash of that string
	self.simplex_noise.seed = self.world_seed.hash()
	
	# set simplex noise using Editor values
	self.simplex_noise.octaves = self.noise_octaves
	self.simplex_noise.period = self.noise_period
	self.simplex_noise.persistence = self.noise_persistence
	self.simplex_noise.lacunarity = self.noise_lacunarity
	
	# Loop to every tile within Map Area Co-ordinates
	for x in range( -self.map_width / 2, self.map_width / 2):
		for y in range(-self.map_height / 2, self.map_height / 2):
			
			# conditional
			if self.simplex_noise.get_noise_2d(x, y) < self.noise_threshold:
				
				# generataes a tilemap
				self._set_autotile(x, y)
	
	self.tile_map.update_dirty_quadrants()



# Sets the scenes autotile programmatically
# Uses the Tilemap's set cell method & the x and y auto tile co-ordinates
func _set_autotile(x : int, y : int) -> void :
	self.tile_map.set_cell(
		x,
		y, 
		self.tile_map.get_tileset().get_tiles_ids()[0], # Tile ID, the first one 
		false, # Completeley ignore the next three arguments
		false, 
		false, 
		self.tile_map.get_cell_autotile_coord(x, y ) # co-ordinate of the TileSet
	)
	
	self.tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling
