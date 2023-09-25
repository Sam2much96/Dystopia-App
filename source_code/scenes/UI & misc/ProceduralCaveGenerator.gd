# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Procedural Generated Cave
# Creates Procedural Cave Collision Objects Within the Scene Tree using a seed phrase
# Features:
# Uses Auto TIle and Perlin Noise to generate a proceudrally generated cave 
# 
# *************************************************
# Bugs:
# (1) Stuck Collision Bug with Enemy Collision 
# (2) Stuck Collision Bug with Item Objects
# *************************************************

extends Node
# Procedurally generated tilemap creator

class_name ProceduralGeneration

#How to Use
# Attach this NOde As a child top the Tilemap with AutoTIle

export (bool) var enabled

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
	
	if enabled:
		# Gets the Parent Tilemap Node
		tile_map = get_parent() as TileMap
		
		clear()
		generate()


func redraw(value = null) -> void:
	if tile_map == null:
		return
	
	clear()
	generate()

func clear() -> void:
	# Completely clearts the current tilemap
	tile_map.clear()


func generate() -> void:
	
	# generate a seed using a string and the hash of that string
	simplex_noise.seed = world_seed.hash()
	
	# set simplex noise using Editor values
	simplex_noise.octaves = noise_octaves
	simplex_noise.period = noise_period
	simplex_noise.persistence = noise_persistence
	simplex_noise.lacunarity = noise_lacunarity
	
	# Loop to every tile within Map Area Co-ordinates
	for x in range( -map_width / 2, map_width / 2):
		for y in range(-map_height / 2, map_height / 2):
			
			# conditional
			if simplex_noise.get_noise_2d(x, y) < noise_threshold:
				
				# generataes a tilemap
				_set_autotile(x, y)
	
	tile_map.update_dirty_quadrants()

	print_debug("Finished Procedural Generation")


# Sets the scenes autotile programmatically
# Uses the Tilemap's set cell method & the x and y auto tile co-ordinates
func _set_autotile(x : int, y : int) -> void :
	tile_map.set_cell(
		x,
		y, 
		tile_map.get_tileset().get_tiles_ids()[0], # Tile ID, the first one 
		false, # Completeley ignore the next three arguments
		false, 
		false, 
		tile_map.get_cell_autotile_coord(x, y ) # co-ordinate of the TileSet
	)
	
	tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling
