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
# (1) Stuck Collision Bug with Enemy Collision     (Fixed with faster draw calls & Sidescrollinh Player)
# (2) Stuck Collision Bug with Item Objects
# (3) Doesn't preserve tilemap data. Respawning results in massive time lag 
# (4) Uses Too Much Static Memory, refactor to use more dynamic memory
# (5) Optimize auto tile tilesheet
# (6) Maxes out Static Memory, requires refactor for dynamic memory optimization
# *************************************************
# To DO : 
# (1) Decouple Codebase
#
#
extends Line2D
# Procedurally generated tilemap creator

class_name ProceduralGeneration

#How to Use
# Attach this NOde As a child top the Tilemap with AutoTIle

export (bool) var enabled
export (bool) var STATIC # Determine if To use Dynamic or static memory / For RAM Load Balancing


# Specifies the Draw Map Area so the Tilemap drawn isnt infinite
export(int) var map_width = 10#80
export(int) var map_height = 10#50

export(String) var world_seed = "Hello World!"
export(int) var noise_octaves = 3
export(int) var noise_period = 3
export(float) var noise_persistence = 0.7
export(float) var noise_lacunarity = 0.4
export(float) var noise_threshold = 0.5

# set get method to update Map generated on the fly
export(bool) var redraw setget redraw

# Acces the Parent TileMap with the AutoTile
var tile_map = null # should pass in a tilemap parameter
var simplex_noise = OpenSimplexNoise.new()

# Generated Bool
export(bool) var generated 

# Cave Gen Dimensions
var map__width : int 
var map__height : int 
var map_dimensions : Vector2
var point_data : PoolVector2Array


var counter = 0 # for counting how many calcs are needed for this loop
# Random World Seed Generator
# To Do :
# (1) Increase Seed Variation
var word_seeds = Music.local_playlist_one.duplicate() # THe word seed is a random playlist song


# Chunk size (tiles processed per frame)
var CHUNK_SIZE = 14_297 # Loads in 20 chunks # 276_015  is the size of comultaion for a 70x70 map
var tile_positions = []
var tile_ids
onready var player = get_tree().get_nodes_in_group("player")[0]

func _enter_tree()-> void:
	
	# Get Cave generator dimensions as points
	#point_data = self.get_points()
	point_data= self.get_points() #
	
	# More Acurate Algorithm
	map_dimensions = Utils.Functions.calculate_length_breadth(point_data)
	
	
	#map_dimensions = Utils.Functions.edge_length(point_data)
	
	map__width = map_dimensions.x/10
	map__height = map_dimensions.y/10
	
	# Debug Point data
	# poolVector Array
	#print_debug(point_data)
	
	# point 1
	#print(point_data[0])
	#print(point_data[1])
	#print(point_data[2])
	#print(point_data[3])
	
	#Calculations
	#print_debug(map_dimensions)
	
	tile_map = get_parent() as TileMap
	tile_ids = tile_map.get_tileset().get_tiles_ids()[0]
	# turn off gravity temporarily to stop player dropping 
	print_debug("Turn on Gravity")
	
	#Simulation.gravity = 0
	
	clear()
	generate()
	render()
	

func _ready():
	
	#render()
	#if enabled:
		
	#	if tile_map == null :#&& Globals.tile_map == null:
			# Gets the Parent Tilemap Node
	#		tile_map = get_parent() as TileMap
			
			
			# Make GLobal
			#Globals.tile_map = tile_map
		
		
	#	clear()
	#	generate()
	pass


func redraw(value = null) -> void:
	if tile_map == null :#&& Globals.tile_map == null:
		return
	
	clear()
	generate()

func clear() -> void:
	Utils.procedural.clear(tile_map)

func generate() :
	# Calculated Generator Dimensions
	# For debug purposes only
	print_debug(" Cave Gen Dimensions:", map__width, "/", map__height, "//", map_dimensions)
	

	
	if !generated : # conditional prevents auto dungeon regeneration bug
		
		
		# generate a seed using a string and the hash of that string
		#simplex_noise.seed = world_seed.hash()
		
		# Rewrite using Dynamic Functions instead
		
		
		
		 #unimplemented version of logic that uses < 1400 calculations and moredynamic memory
		simplex_noise.seed = Music.shuffle(word_seeds).hash()
		
		# set simplex noise using Editor values
		simplex_noise.octaves = noise_octaves
		simplex_noise.period = noise_period
		simplex_noise.persistence = noise_persistence
		simplex_noise.lacunarity = noise_lacunarity
		
		# Loop to every tile within Map Area Co-ordinates
		# Bug: 
		# (1) This Double for Loop is an optimization hog, its apprx doing >260782 calculations
		#
		
		
		#for x in range( -map__width / 2, map__width / 2):
		#	for y in range(-map__height / 2, map__height / 2):
				
				# conditional
		#		if simplex_noise.get_noise_2d(x, y) < noise_threshold:
					
					# generataes a tilemap
		#			counter +=1
		#			tile_map.set_cell(x,y, tile_map.get_tileset().get_tiles_ids()[0], false, false, false,tile_map.get_cell_autotile_coord(x, y )) # co-ordinate of the TileSet
					
		#			tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling
		#tile_map.update_dirty_quadrants()
		var tile_ids = tile_map.get_tileset().get_tiles_ids()[0]
		
		for x in range(-map__width / 2, map__width / 2):
			for y in range(-map__height / 2, map__height / 2):
				if simplex_noise.get_noise_2d(x, y) < noise_threshold:
					tile_positions.append(Vector2(x, y)) # store the tile positions on heap
					counter +=1
					#tile_map.set_cellv(Vector2(x,y), tile_ids, false, false, false,tile_map.get_cell_autotile_coord(x, y )) # co-ordinate of the TileSet
					#
					#tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling
		
		print_debug("Finished Procedural Generation", "//", counter)
		print_debug("tilemap data debug: ", tile_positions.size())
		
		#tile_map.update_dirty_quadrants()

		#place_tiles_in_chunks(tile_positions, tile_ids)
		generated = true
		
		print_debug("Turn on gravity")
		#Simulation.gravity = 3500
		
		
	#if generated: 
	#	player.apply_GRAVITY = true

#func _process(_delta):
#	if generated: 
#		player.apply_GRAVITY = true
#		self.set_process(false) # turn off processing
#	if !generated: 
#		player.apply_GRAVITY = false



func render():
	counter = 0
	var chunk = []
	
	
	# Process up to CHUNK_SIZE tile
	
	for pos in tile_positions:
		#print(pos)
		counter +=1
		tile_map.set_cellv(Vector2(pos), tile_ids, false, false, false,tile_map.get_cell_autotile_coord(pos.x, pos.y)) # co-ordinate of the TileSet
		
		tile_map.update_bitmask_area(Vector2(pos)) # so the engine knows where to configure the autotiling
		
		if player:
			player.apply_GRAVITY = false
		
		if counter == CHUNK_SIZE:
			
			tile_map.update_dirty_quadrants()
			counter = 0
			yield(get_tree(), "idle_frame")  # Allow engine to process frames
		
	
	
	if player: player.apply_GRAVITY = true
	print_debug("Tile Position Finished setting")




func place_tiles_in_chunks(tile_positions, tile_id):
	while tile_positions.size() > 0:
		var chunk = []
		
		# Process up to CHUNK_SIZE tiles
		for i in range(min(CHUNK_SIZE, tile_positions.size())):
			chunk.append(tile_positions.pop_front())  # Efficient way to remove elements
			
			print_debug("Chunk debug: ", chunk.size(), "//", tile_positions.size())
			
		for pos in chunk:
			tile_map.set_cellv(pos, tile_id,false, false, false,tile_map.get_cell_autotile_coord(pos.x, pos.y))
			tile_map.update_bitmask_area(pos)

		yield(get_tree(), "idle_frame")  # Allow engine to process frames

		tile_map.update_dirty_quadrants()



func _exit_tree():
	clear()
	
