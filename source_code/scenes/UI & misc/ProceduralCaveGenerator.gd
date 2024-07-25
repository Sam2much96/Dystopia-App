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

extends Line2D
# Procedurally generated tilemap creator

class_name ProceduralGeneration

#How to Use
# Attach this NOde As a child top the Tilemap with AutoTIle

@export (bool) var enabled
@export (bool) var STATIC # Determine if To use Dynamic or static memory / For RAM Load Balancing


# Specifies the Draw Map Area so the Tilemap drawn isnt infinite
@export var map_width: int = 80
@export var map_height: int = 50

@export var world_seed: String = "Hello World!"
@export var noise_octaves: int = 3
@export var noise_period: int = 3
@export var noise_persistence: float = 0.7
@export var noise_lacunarity: float = 0.4
@export var noise_threshold: float = 0.5

# set get method to update Map generated on the fly
@export var redraw: bool: set = redraw

# Acces the Parent TileMap with the AutoTile
@onready var tile_map : TileMap
@onready var simplex_noise : FastNoiseLite = FastNoiseLite.new()

# Generated Bool
@export var generated: bool 

# Cave Gen Dimensions
var map__width : int 
var map__height : int 
var map_dimensions : Vector2
var point_data : PackedVector2Array

# Random World Seed Generator
# To Do :
# (1) Increase Seed Variation
var word_seeds : Dictionary = {0:"Pleasse Give me a good result nitori olorun",
1: "trying this muther fuccing shuffle randomiser, lool"}




func _enter_tree()-> void:
	
	# Get Cave generator dimensions as points
	point_data = self.get_points()
	
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

func _ready():
	
	if enabled:
		
		if tile_map == null :#&& Globals.tile_map == null:
			# Gets the Parent Tilemap Node
			tile_map = get_parent() as TileMap
			
			
			# Make GLobal
			#Globals.tile_map = tile_map
		
		
		clear()
		generate()


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
		
		
		
		if STATIC:
			# Static Method Impementation
			
			Utils.procedural.genereate(simplex_noise,
			Music.shuffle(word_seeds), # Random World Seed Generator #world_seed,
			noise_octaves,
			noise_period,
			noise_persistence,
			noise_lacunarity,
			noise_threshold,
			map__height,
			map__width,
			tile_map
			)
			
		if !STATIC : #unimplemented version of logic that uses < 1400 calculations and moredynamic memory
			simplex_noise.seed = world_seed.hash()
			
			# set simplex noise using Editor values
			simplex_noise.fractal_octaves = noise_octaves
			simplex_noise.period = noise_period
			simplex_noise.persistence = noise_persistence
			simplex_noise.lacunarity = noise_lacunarity
			
			# Loop to every tile within Map Area Co-ordinates
			# Bug: 
			# (1) This Double for Loop is an optimization hog, its apprx doing >1400 calculations
			#
			
			
			for x in range( -map_width / 2, map_width / 2):
				for y in range(-map_height / 2, map_height / 2):
					
					# conditional
					if simplex_noise.get_noise_2d(x, y) < noise_threshold:
						
						# generataes a tilemap
						
						tile_map.set_cell(x,y, tile_map.get_tileset().get_tiles_ids()[0], false, false, false,tile_map.get_cell_autotile_coord(x, y )) # co-ordinate of the TileSet
						
						tile_map.update_bitmask_area(Vector2(x, y)) # so the engine knows where to configure the autotiling
			tile_map.update_dirty_quadrants()
		
		
		
		print_debug("Finished Procedural Generation")
		generated = true
		
	if generated: pass






func _exit_tree():
	clear()
