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
# (1) Stuck Collision Bug with Enemy Collision     (Fixed with faster draw calls)
# (2) Stuck Collision Bug with Item Objects
# (3) Doesn't preserve tilemap data. Respawning results in massive time lag 
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

# Generated Bool
var generated : bool = false

func _enter_tree()-> void:
	
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
	Utils.procedural.clear(tile_map)

func generate() :
	
	if !generated : # conditional prevents auto dungeon regeneration bug
		
		# generate a seed using a string and the hash of that string
		#simplex_noise.seed = world_seed.hash()
		
		Utils.procedural.genereate(simplex_noise,
		world_seed,
		noise_octaves,
		noise_period,
		noise_persistence,
		noise_lacunarity,
		noise_threshold,
		map_height,
		map_width,
		tile_map
		)
		
		
		print_debug("Finished Procedural Generation")
		generated = true
		
	if generated: pass
	
